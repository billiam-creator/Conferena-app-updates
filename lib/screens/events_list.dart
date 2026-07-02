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
  List events        = [];
  List filteredEvents = [];
  bool loading       = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredEvents = query.isEmpty
          ? events
          : events.where((e) {
              final name = (e['event_name'] ?? e['name'] ?? '')
                  .toString()
                  .toLowerCase();
              final loc = (e['event_location'] ?? e['location'] ?? '')
                  .toString()
                  .toLowerCase();
              return name.contains(query) || loc.contains(query);
            }).toList();
    });
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
        setState(() {
          events         = extracted;
          filteredEvents = extracted;
          loading        = false;
        });
      } else {
        setState(() {
          events         = [];
          filteredEvents = [];
          loading        = false;
        });
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
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Log Out",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _confirmLogout();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Events"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Log Out",
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: Column(
          children: [

            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events by name or location',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: _searchController.clear,
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ── Events list ─────────────────────────────────────────────────
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchEvents,
                      color: CustomColors.primaryColor,
                      child: filteredEvents.isEmpty
                          ? _buildEmptyState()
                          : _buildEventsList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = _searchController.text.isNotEmpty;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(
          isSearching ? Icons.search_off : Icons.event_busy,
          size: 90,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        Text(
          isSearching ? "No matching events" : "No events assigned yet",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            isSearching
                ? "Try a different search term."
                : "Pull down to refresh, or contact the organizer if you should have access to an event.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final Map event = filteredEvents[index];

        // ── Data extraction ────────────────────────────────────────────────
        final String eventName =
            event['event_name'] ?? event['name'] ?? "Event";

        final String location =
            event['event_location'] ?? event['location'] ?? "No location";

        final int totalBookings = int.tryParse(
                (event['bookings_count'] ??
                        event['total_bookings'] ??
                        0)
                    .toString()) ??
            0;

        // Pull checked-in and pending from API if available
        final int checkedIn = int.tryParse(
                (event['checked_in'] ??
                        event['scanned_count'] ??
                        event['checked_in_count'] ??
                        0)
                    .toString()) ??
            0;

        final int pending = totalBookings - checkedIn;

        final String? rawBanner =
            event['event_banner'] ?? event['banner'];
        final String? bannerUrl =
            rawBanner != null && rawBanner.isNotEmpty
                ? (rawBanner.startsWith('http')
                    ? rawBanner
                    : 'https://go.conferena.com/uploads/$rawBanner')
                : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanCode(
                  event: event,
                  token: widget.token,
                  eventToken: event['ticket_scanning_token'] ??
                      event['token'] ??
                      '',
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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

                // ── Banner with event name overlaid ────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      // Banner image or placeholder
                      bannerUrl != null
                          ? Image.network(
                              bannerUrl,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _bannerPlaceholder(eventName),
                            )
                          : _bannerPlaceholder(eventName),

                      // Dark gradient so text is readable over any banner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 70,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black87,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Event name over gradient
                      Positioned(
                        bottom: 10,
                        left: 12,
                        right: 60,
                        child: Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // "Tap to Scan" badge (top-right)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: CustomColors.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_scanner,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Tap to Scan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Footer: location + booking stats ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location row
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Stats row: Total | Checked-in | Pending
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.people,
                            label: 'Total',
                            value: '$totalBookings',
                            color: CustomColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            icon: Icons.check_circle_outline,
                            label: 'Checked in',
                            value: '$checkedIn',
                            color: const Color(0xFF1A7A4A),
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            icon: Icons.hourglass_empty,
                            label: 'Pending',
                            value: pending > 0 ? '$pending' : '0',
                            color: const Color(0xFF7A5A1A),
                          ),
                        ],
                      ),
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

  Widget _bannerPlaceholder(String eventName) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColors.primaryColor.withOpacity(0.8),
            CustomColors.primaryColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 48,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 11, color: color),
                const SizedBox(width: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}