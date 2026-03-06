import 'package:flutter/material.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/theme/colors.dart';

class EventsList extends StatefulWidget {
  const EventsList({super.key, required String token});

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

  // Fetch events when screen loads
  fetchEvents() async {
    try {
      final response = await EventService().fetchEvents("demo");

      setState(() {
        events = [response];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGreyScaffold,
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: CustomColors.primaryColor,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(event['data']['event_name']),
                    subtitle: Text(event['data']['event_description']),
                    trailing: const Icon(Icons.qr_code_scanner),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanCode(
                            event: event,
                            token: event['data']['event_token'], eventToken: null,
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