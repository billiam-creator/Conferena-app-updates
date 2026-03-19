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

      final status    = response['status'];
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
        setState(() { events = extracted; loading = false; });
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

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

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
            onPressed: () { Navigator.pop(context); _logout(); },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { _confirmLogout(); return false; },
      child: Scaffold(
        backgroundColor: CustomColors.lightGreyScaffold,
        appBar: AppBar(
          title: const Text("My Events"),
          backgroundColor: CustomColors.primaryColor,
          automaticallyImplyLeading: false,
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
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final Map event = events[index];
        final bookingsCount = event['bookings_count'] ?? event['total_bookings'] ?? 0;
        final String? bannerUrl = event['banner'];
        final String eventName = event['name'] ?? event['event_name'] ?? "Event";
        final String location = event['location'] ?? event['event_location'] ?? "No location";
        final String startDate = event['start_date'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanCode(
                  event: event,
                  token: widget.token,
                  eventToken: event['token'] ?? event['ticket_scanning_token'] ?? '',
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Banner image ─────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [

                      // Banner image or placeholder
                      bannerUrl != null && bannerUrl.isNotEmpty
                          ? Image.network(
                              bannerUrl,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildBannerPlaceholder(eventName),
                              loadingBuilder: (_, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return _buildBannerPlaceholder(eventName);
                              },
                            )
                          : _buildBannerPlaceholder(eventName),

                      // Gradient overlay 
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Event name overlaid on banner
                      Positioned(
                        bottom: 10, left: 12, right: 50,
                        child: Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Scan icon button — top right
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: CustomColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                // ── Event details ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [

                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bookings count 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 13, color: CustomColors.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              "$bookingsCount",
                              style: TextStyle(
                                color: CustomColors.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Date 
                      if (startDate.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                startDate,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],

                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // Placeholder shown while image loads or broken
  Widget _buildBannerPlaceholder(String eventName) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.primaryColor.withOpacity(0.7),
            CustomColors.primaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern
          Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.calendar_month,
              size: 120,
              color: Colors.white,
            ),
          ),
          // Event name centered
          Positioned(
            bottom: 10, left: 12, right: 50,
            child: Text(
              eventName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}