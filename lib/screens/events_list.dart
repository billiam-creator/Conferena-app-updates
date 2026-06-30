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
  List events = [];
  List filteredEvents = [];
  bool loading = true;

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
      if (query.isEmpty) {
        filteredEvents = events;
      } else {
        filteredEvents = events.where((event) {
          final name = (event['event_name'] ?? event['name'] ?? '')
              .toString()
              .toLowerCase();
          final location = (event['event_location'] ?? event['location'] ?? '')
              .toString()
              .toLowerCase();
          return name.contains(query) || location.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchEvents() async {
    setState(() => loading = true);
    try {
      final response = await EventService().fetchEvents(
        widget.token,
        sessionCookie: widget.sessionCookie,
      );

      final status = response['status'];
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
          events = extracted;
          filteredEvents = extracted;
          loading = false;
        });
      } else {
        setState(() {
          events = [];
          filteredEvents = [];
          loading = false;
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
      onWillPop: () async {
        _confirmLogout();
        return false;
      },
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

        body: Column(
          children: [

            // ── Search bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events by name or location',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ── Events list ─────────────────────────────────────────
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

        final bookingsCount =
            event['bookings_count'] ?? event['total_bookings'] ?? 0;

        final String? rawBanner =
            event['event_banner'] ?? event['banner'];

        final String? bannerUrl = rawBanner != null && rawBanner.isNotEmpty
            ? (rawBanner.startsWith('http')
                ? rawBanner
                : 'https://go.conferena.com/uploads/$rawBanner')
            : null;

        final String eventName =
            event['event_name'] ?? event['name'] ?? "Event";

        final String location =
            event['event_location'] ?? event['location'] ?? "No location";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanCode(
                  event: event,
                  token: widget.token,
                  eventToken:
                      event['ticket_scanning_token'] ?? event['token'] ?? '',
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      bannerUrl != null && bannerUrl.isNotEmpty
                          ? Image.network(
                              bannerUrl,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                            )
                          : _buildBannerPlaceholder(eventName),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              CustomColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people,
                                size: 13,
                                color: CustomColors.primaryColor),
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

  Widget _buildBannerPlaceholder(String eventName) {
    return Container(
      width: double.infinity,
      height: 140,
      color: CustomColors.primaryColor.withOpacity(0.7),
      child: Center(
        child: Text(
          eventName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
