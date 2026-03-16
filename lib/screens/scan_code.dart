import 'package:flutter/material.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/theme/colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert'; 

class ScanCode extends StatefulWidget {
  final Map event;
  final String token;
final String eventToken;

const ScanCode({
  super.key,
  required this.event,
  required this.token,
  required this.eventToken,
});

  @override
  State<ScanCode> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;
  QRViewController? controller;
  bool? valid;
  bool? alreadyUsed; 
  bool validating = false;
  String? scanCount; 
  String? bookingCount;

  @override
  void initState() {
    super.initState();
    final count = widget.event['bookings_count'];
    bookingCount = count != null ? count.toString() : '0';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomColors.lightGreyScaffold,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              child: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width / 40),
                  TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black12,
                          foregroundColor: CustomColors.textGrey),
                      icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                      label: Text(
                        'Back to Events',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 26,
                        ),
                      )),
                  const Expanded(child: SizedBox()),
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          valid = null;
                          alreadyUsed = null; 
                          validating = false;
                          scanCount = null;
                        });
                        controller?.resumeCamera();
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black12,
                          foregroundColor: CustomColors.textGrey),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(
                        'Resume Scan',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 26,
                        ),
                      )),
                  SizedBox(width: MediaQuery.of(context).size.width / 40),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 55),
            Text(
              widget.event['event_name'],
              style: TextStyle(
                color: CustomColors.textBlack,
                fontSize: MediaQuery.of(context).size.width / 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            Text(
              widget.event['event_name'],
              style: TextStyle(
                color: CustomColors.textGrey,
                fontSize: MediaQuery.of(context).size.width / 26,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 120),
            Text(
              'Total Bookings: $bookingCount', 
              style: TextStyle(
                color: CustomColors.textGrey,
                fontSize: MediaQuery.of(context).size.width / 28,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 20),
            Text(
              'Point your camera at the QR Code to scan.',
              style: TextStyle(
                color: CustomColors.textGrey,
                fontSize: MediaQuery.of(context).size.width / 26,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 80),
            SizedBox(
              height: MediaQuery.of(context).size.width,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: valid == true
                    ? Colors.green
                    : alreadyUsed == true
                        ? Colors.amber[700]
                        : valid == false
                            ? Colors.red
                            : CustomColors.lightGreyScaffold,
                child: validating
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Validating Ticket...',
                            style: TextStyle(
                              color: CustomColors.textGrey,
                              fontSize:
                                  MediaQuery.of(context).size.width / 26,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : valid == true
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: CustomColors.lightGreyScaffold,
                                size: MediaQuery.of(context).size.width / 4.5,
                              ),
                              Text(
                                'Valid Ticket,Attendee checked in',
                                style: TextStyle(
                                  color: CustomColors.textWhite,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 26,
                                ),
                              ),
                              if (scanCount != null)
                                Text(
                                  'Scan Count: $scanCount',
                                  style: TextStyle(
                                    color: CustomColors.textWhite,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 28,
                                  ),
                                ),
                            ],
                          )
                        : alreadyUsed == true
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: CustomColors.lightGreyScaffold,
                                    size: MediaQuery.of(context).size.width / 4.5,
                                  ),
                                  Text(
                                    'Ticket already Used',
                                    style: TextStyle(
                                      color: CustomColors.textWhite,
                                      fontSize:
                                          MediaQuery.of(context).size.width / 26,
                                    ),
                                  ),
                                  if (scanCount != null)
                                    Text(
                                      'Scan Count: $scanCount',
                                      style: TextStyle(
                                        color: CustomColors.textWhite,
                                        fontSize:
                                            MediaQuery.of(context).size.width / 28,
                                      ),
                                    ),
                                ],
                              )
                            : valid == false
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel_rounded,
                                        color: CustomColors.lightGreyScaffold,
                                        size: MediaQuery.of(context).size.width / 4.5,
                                      ),
                                      Text(
                                        'Invalid Ticket',
                                        style: TextStyle(
                                          color: CustomColors.textWhite,
                                          fontSize:
                                              MediaQuery.of(context).size.width / 26,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
              ),
            )
          ],
        ),
      ),
    );
  }

  _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        setState(() {
          valid = null;
          validating = true;
          scanCount = null;
        });

        validateTicket(widget.eventToken, scanData.code as String).then((value) {
          if (value['status'] == 200) {
            var data;
            try {
              data = jsonDecode(value['data']);
            } catch (_) {
              data = value['data'];
            }

            final int count = int.tryParse(data['scan_count'].toString()) ?? 0;

            if (count == 1) {
              setState(() {
                valid = true;
                alreadyUsed = false;
                validating = false;
                scanCount = data['scan_count'].toString();
              });

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green,
                width: 200,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
                content: Text(
                  value ["message"],
                  textAlign: TextAlign.center,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ));
            } 
            else if (count > 1) {
              setState(() {
                valid = false;
                alreadyUsed = true;
                validating = false;
                scanCount = data['scan_count'].toString();
              });

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber[700],
                width: 200,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
                content:  Text(
                  value ["message"],
                  textAlign: TextAlign.center,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ));
            }
          } 
          else {
            setState(() {
              valid = false;
              validating = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              width: 200,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1500),
              content:  Text(
                value ["message"],
                textAlign: TextAlign.center,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ));
          } 
          
        }).catchError((error) {
          setState(() {
            validating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            width: 200,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
            content: const Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ));
        });
      }
    });
  }


  validateTicket(String token, String code) async {
    return await EventService().validateTicket(token, code);
  }
}