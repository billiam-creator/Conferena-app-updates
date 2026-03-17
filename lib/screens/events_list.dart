import 'package:flutter/material.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/services/session_manager.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/screens/home.dart';
import 'package:ticketkona/theme/colors.dart';

class EventsList extends StatefulWidget {

  final String token;
  final String? sessionCookie;

  const EventsList({
    super.key,
    required this.token,
    this.sessionCookie,
  });

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {

  List events  = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() => loading = true);
    try {
      final response = await EventService().fetchEvents(
        widget.token,
        sessionCookie: widget.sessionCookie,
      );

      final status   = response['status'];
      final isSuccess = status == 200 || status == '200';

      if (isSuccess) {
        List extracted = [];
        final raw = response['data'];

        if (raw is List) {
          extracted = raw;
        } else if (raw is Map) {
          extracted = raw['data'] ?? raw['events'] ?? [];
        } else if (response['events'] is List) {
          extracted = response['events'];
        }

        setState(() {
          events  = extracted;
          loading = false;
        });
      } else {
        setState(() { events = []; loading = false; });
      }

    } catch (e) {
      print("EVENT FETCH ERROR: $e");
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to load events.")),
        );
      }
    }
  }

  // Logout — clears session and goes back to Home
  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

  // Confirm logout dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept back button — ask to logout instead of just popping
      onWillPop: () async {
        _confirmLogout();
        return false; // prevent automatic pop
      },
      child: Scaffold(

        backgroundColor: CustomColors.lightGreyScaffold,

        appBar: AppBar(
          title: const Text("My Events"),
          backgroundColor: CustomColors.primaryColor,
          automaticallyImplyLeading: false, // hide default back arrow
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Log Out",
              onPressed: _confirmLogout,
            ),
          ],
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())

            // Pull-to-refresh wraps both empty state and list
            : RefreshIndicator(
                onRefresh: fetchEvents,
                color: CustomColors.primaryColor,
                child: events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // Wrap in ListView so RefreshIndicator works even on empty state
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Icon(Icons.event_busy, size: 90, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          "No events assigned yet",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Pull down to refresh, or contact the organizer if you should have access to an event.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {

        final Map event = events[index];

        // Bookings count — works with both API response formats
        final bookingsCount =
            event['bookings_count'] ?? event['total_bookings'] ?? 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

            title: Text(
              event['name'] ?? event['event_name'] ?? "Event",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'] ?? event['event_location'] ?? "No location",
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Bookings count badge
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$bookingsCount bookings",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: CustomColors.primaryColor,
              ),
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanCode(
                    event: event,
                    token: widget.token,
                    eventToken: event['token'] ??
                        event['ticket_scanning_token'] ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}