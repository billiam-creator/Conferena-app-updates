import 'package:flutter/material.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/theme/colors.dart';
import 'package:ticketkona/config.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenEntry extends StatefulWidget {
  const TokenEntry({super.key});

  @override
  State<TokenEntry> createState() => _TokenEntryState();
}

class _TokenEntryState extends State<TokenEntry> {

  final TextEditingController tokenController = TextEditingController();
  bool loading = false;
  String? errorMessage;

  // Look up event by its scanning token
  Future<Map?> fetchEventByToken(String scanningToken) async {
    try {
      print("LOOKING UP EVENT WITH TOKEN: $scanningToken");

      // First verify the token is valid
      final verifyResponse = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/bookings/verify'),
        body: {
          'event_token': scanningToken,
          'booking_code': 'TOKEN_CHECK',
        },
      ).timeout(const Duration(seconds: 10));

      print("TOKEN CHECK STATUS: ${verifyResponse.statusCode}");

      // 200 or 400 means token exists, anything else means invalid
      if (verifyResponse.statusCode != 200 &&
          verifyResponse.statusCode != 400) {
        return null;
      }

      // Token is valid — try to get full event details
      // Load saved session to use Bearer + cookie
      final session = await SessionManager.loadSession();
      final token = session?['token'] ?? '';
      final cookie = session?['sessionCookie'] ?? '';

      if (token.isNotEmpty) {
        final headers = {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          if (cookie.isNotEmpty) 'Cookie': 'ci_session=$cookie',
        };

        final eventsResponse = await http.get(
          Uri.parse(AppConfig.eventsGet),
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        print("EVENTS LOOKUP STATUS: ${eventsResponse.statusCode}");

        if (eventsResponse.statusCode == 200 &&
            eventsResponse.body.isNotEmpty) {
          final decoded = jsonDecode(eventsResponse.body);
          final data = decoded['data'];
          if (data is List) {
            for (final event in data) {
              final eventToken =
                  event['ticket_scanning_token'] ?? event['token'] ?? '';
              if (eventToken.toString().toUpperCase() ==
                  scanningToken.toUpperCase()) {
                print("MATCHED EVENT: ${event['event_name']}");
                return Map<String, dynamic>.from(event);
              }
            }
          }
        }
      }

      // Token valid but no matching event in user's list
      // Return minimal map so scanning still works
      return {
        'event_name': 'Event',
        'event_location': '',
        'ticket_scanning_token': scanningToken,
        'token': scanningToken,
        'bookings_count': 0,
      };

    } catch (e) {
      print("TOKEN LOOKUP ERROR: $e");
      return null;
    }
  }

  void onScanPressed() async {
    final token = tokenController.text.trim().toUpperCase();

    if (token.isEmpty) {
      setState(() => errorMessage = "Please enter an event token");
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final event = await fetchEventByToken(token);

    if (!mounted) return;

    if (event != null) {
      setState(() => loading = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScanCode(
            event: event,
            token: token,
            eventToken: token,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
        errorMessage = "Invalid event token. Please check and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 30),

              Text(
                'Enter Event Token',
                style: TextStyle(
                  color: CustomColors.textBlack,
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the event scanning token to start validating tickets',
                style: TextStyle(
                  color: CustomColors.textGrey,
                  fontSize: MediaQuery.of(context).size.width / 28,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: tokenController,
                cursorColor: CustomColors.primaryColor,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() => errorMessage = null),
                onSubmitted: (_) => onScanPressed(),
                decoration: InputDecoration(
                  hintText: 'e.g. 693DAE5',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: errorMessage != null
                          ? Colors.red.shade400
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: errorMessage != null
                          ? Colors.red.shade500
                          : CustomColors.primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: errorMessage != null
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  filled: true,
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.red.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: MediaQuery.of(context).size.height / 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: loading ? null : onScanPressed,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                  label: Text(
                    loading ? 'Verifying...' : 'START SCANNING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width / 26,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text("Go Back"),
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.textGrey,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }
}