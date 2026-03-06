import 'package:flutter/material.dart';
import 'package:ticketkona/screens/scan_code.dart';
import 'package:ticketkona/services/event.dart';
import 'package:ticketkona/theme/colors.dart';

class TokenEntry extends StatefulWidget {
  const TokenEntry({super.key});

  @override
  State<TokenEntry> createState() => _TokenEntryState();
}

class _TokenEntryState extends State<TokenEntry> {
  final TextEditingController tokenController = TextEditingController();

  AutovalidateMode validationMode = AutovalidateMode.disabled;

  bool loading = false;

  late Map event;

  fetchEvent(String token) async {
    return await EventService().fetchEvent(token);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Event Token Below',
                    style: TextStyle(
                      color: CustomColors.textGrey,
                      fontSize: MediaQuery.of(context).size.width / 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    controller: tokenController,
                    cursorColor: CustomColors.primaryColor,
                    autofocus: true,
                    autovalidateMode: validationMode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Token is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.primaryColor),
                            onPressed: () async {
                              if (tokenController.text.isEmpty) {
                                setState(() {
                                  validationMode = AutovalidateMode.always;
                                });
                              } else {
                                setState(() {
                                  loading = true;
                                });

                                // get associated details. persist details and token then navigate.
                                // if token is invalid, show user 'Invalid Token' Snackbar.
                                fetchEvent(tokenController.text).then((value) {
                                  print(
                                      '----------------> the value is $value');
                                  if (value['status'] == 200) {
                                    event = value;
                                    setState(() {
                                      loading = false;
                                    });
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => ScanCode(
                                                event: event,
                                                token: tokenController.text, eventToken: null,)));
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      width: 200,
                                      behavior: SnackBarBehavior.floating,
                                      duration:
                                          const Duration(milliseconds: 1500),
                                      content: Text(
                                        value['message'],
                                        textAlign: TextAlign.center,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                    ));
                                  }
                                }).catchError((error) {
                                  print("------------>error is: $error");
                                  setState(() {
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    width: 200,
                                    behavior: SnackBarBehavior.floating,
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    content: Text(
                                      'Something went wrong. Please try again.',
                                      textAlign: TextAlign.center,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ));
                                });
                              }
                            },
                            icon: loading
                                ? const SizedBox()
                                : const Icon(
                                    Icons.qr_code_scanner,
                                    color: CustomColors.textWhite,
                                  ),
                            label: loading
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 25,
                                    height:
                                        MediaQuery.of(context).size.width / 25,
                                    child: const CircularProgressIndicator(
                                      color: CustomColors.textWhite,
                                    ),
                                  )
                                : Text(
                                    'SCAN QR',
                                    style: TextStyle(
                                      color: CustomColors.textWhite,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              26,
                                    ),
                                  )),
                      )
                    ],
                  )
                ],
              ))),
    );
  }

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }
}
