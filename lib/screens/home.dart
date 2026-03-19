import 'package:flutter/material.dart';
import 'package:ticketkona/screens/token_entry.dart';
import 'package:ticketkona/screens/login.dart';
import 'package:ticketkona/theme/colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: CustomColors.lightGreyScaffold,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/qr_illustration.png',
                    width: MediaQuery.of(context).size.width / 1.5,
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
              ),
              Text(
                'Conferena',
                style: TextStyle(
                  color: CustomColors.textBlack,
                  fontSize: MediaQuery.of(context).size.width / 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 40,
              ),
              Text(
                'Scan the QR code on a ticket to confirm its validity.',
                style: TextStyle(
                  color: CustomColors.textGrey,
                  fontSize: MediaQuery.of(context).size.width / 26,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              ),

              // Start scanning using token 
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width / 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TokenEntry(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: CustomColors.textWhite,
                      ),
                      label: Text(
                        'SCAN WITH TOKEN',
                        style: TextStyle(
                          color: CustomColors.textWhite,
                          fontSize: MediaQuery.of(context).size.width / 26,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 6),
                ],
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height / 40,
              ),

              // NEW: view events list
              // LOGIN TO VIEW EVENTS
Row(
  children: [
    SizedBox(width: MediaQuery.of(context).size.width / 6),
    Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.primaryColor,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.login,
          color: CustomColors.textWhite,
        ),
        label: Text(
          'LOGIN TO VIEW EVENTS',
          style: TextStyle(
            color: CustomColors.textWhite,
            fontSize: MediaQuery.of(context).size.width / 26,
          ),
        ),
      ),
    ),
    SizedBox(width: MediaQuery.of(context).size.width / 6),
  ],
)
            ],
          ),
        ),
      ),
    );
  }
}