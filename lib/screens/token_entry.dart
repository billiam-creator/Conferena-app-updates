import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ticketkona/config.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/theme/colors.dart';

class TokenEntry extends StatefulWidget {
  const TokenEntry({super.key});

  @override
  State<TokenEntry> createState() => _TokenEntryState();
}

class _TokenEntryState extends State<TokenEntry> {
  final TextEditingController tokenController = TextEditingController();

  bool loading = false;
  String? errorMessage;

  Future<Map?> fetchEventByToken(String scanningToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}/events/get_by_token'),
            body: {
              'event_token': scanningToken,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == 200 && decoded['data'] != null) {
          return Map<String, dynamic>.from(decoded['data']);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> onScanPressed() async {
    final token = tokenController.text.trim().toUpperCase();

    if (token.isEmpty) {
      setState(() {
        errorMessage = "Please enter an event token";
      });
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanCode(
            event: event,
            token: token,
            eventToken: event['ticket_scanning_token'] ?? token,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
        errorMessage =
            "Invalid event token. Please check and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final h = media.size.height;
    final w = media.size.width;

    final isSmall = h < 650;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: w * .08,
                right: w * .08,
                top: isSmall ? 20 : 32,
                bottom: media.viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      media.padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Image.asset(
                        'assets/images/logo.png',
                        height: isSmall ? 70 : 90,
                      ),

                      SizedBox(height: isSmall ? 22 : 32),

                      Text(
                        "Enter Event Token",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 24 : 28,
                          color: CustomColors.textBlack,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Enter the event scanning token to start validating tickets.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CustomColors.textGrey,
                          fontSize: isSmall ? 14 : 16,
                        ),
                      ),

                      SizedBox(height: isSmall ? 28 : 40),

                      TextField(
                        controller: tokenController,
                        autofocus: true,
                        cursorColor: CustomColors.primaryColor,
                        textCapitalization:
                            TextCapitalization.characters,
                        onChanged: (_) {
                          if (errorMessage != null) {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        onSubmitted: (_) => onScanPressed(),
                        decoration: InputDecoration(
                          hintText: "e.g. 443XIE5",
                          prefixIcon:
                              const Icon(Icons.vpn_key_outlined),
                          filled: true,
                          fillColor: errorMessage == null
                              ? Colors.grey.shade100
                              : Colors.red.shade50,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: errorMessage == null
                                  ? Colors.grey.shade300
                                  : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: errorMessage == null
                                  ? CustomColors.primaryColor
                                  : Colors.red,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
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

                      SizedBox(height: isSmall ? 28 : 36),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                CustomColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmall ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              loading ? null : onScanPressed,
                          icon: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.qr_code_scanner,
                                ),
                          label: Text(
                            loading
                                ? "Verifying..."
                                : "START SCANNING",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Go Back"),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              CustomColors.textGrey,
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
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