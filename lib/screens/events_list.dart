import 'package:flutter/material.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/theme/colors.dart';

class EventsList extends StatefulWidget {

  final String token;

  const EventsList({super.key, required this.token});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {

  List events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // Fetch events from API
  fetchEvents() async {
    try {

      final response = await EventService().fetchEvents(widget.token);

      if (response['status'] == 200 && response['data'] != null) {

        setState(() {
          events = [response['data']];
          loading = false;
        });

      } else {

        setState(() {
          events = [];
          loading = false;
        });

      }

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load events. Please try again.")),
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: CustomColors.lightGreyScaffold,

      appBar: AppBar(
        title: const Text("My Events"),
        backgroundColor: CustomColors.primaryColor,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          // EMPTY STATE UI
          : events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [

                      Icon(
                        Icons.event_busy,
                        size: 90,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 20),

                      Text(
                        "No events assigned yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Please contact the organizer if you should have access to an event.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    ],
                  ),
                )

              // EVENTS LIST
              : ListView.builder(

                  padding: const EdgeInsets.all(12),

                  itemCount: events.length,

                  itemBuilder: (context, index) {

                    final event = events[index];

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
                          event['event_name'] ?? "Event",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Row(
                          children: [

                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                event['event_location'] ?? "No location",
                                style: const TextStyle(color: Colors.grey),
                              ),
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

                              builder: (context) => ScanCode(
                                event: event,
                                token: widget.token,
                                eventToken: event['ticket_scanning_token'],
                              ),

                            ),

                          );

                        },

                      ),

                    );

                  },

                ),
    );
  }
}