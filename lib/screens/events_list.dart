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

      setState(() {
        events = [response];
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load events"))
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
          : ListView.builder(

              itemCount: events.length,

              itemBuilder: (context, index) {

                final event = events[index]['data'];

                return Card(

                  margin: const EdgeInsets.all(12),

                  child: ListTile(

                    title: Text(event['event_name']),

                    subtitle: Text(event['event_location'] ?? "No location"),

                    trailing: const Icon(Icons.qr_code_scanner),

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