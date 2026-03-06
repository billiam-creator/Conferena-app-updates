import 'package:flutter/material.dart';
import 'package:ticketkona/screens/home.dart';
import 'package:ticketkona/theme/colors.dart';

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  bool isVerifying = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        isVerifying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isVerifying
        ? SafeArea(
            child: Scaffold(
              backgroundColor: CustomColors.initializerScaffold,
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: MediaQuery.of(context).size.width / 1.3,
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height / 6,
                    // ),
                    // Text(
                    //   'Ticket Kona',
                    //   style: TextStyle(
                    //       color: CustomColors.textBlack,
                    //       fontSize: MediaQuery.of(context).size.width / 18,
                    //       fontWeight: FontWeight.bold),
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),
              ),
            ),
          )
        : const Home();
  }
}
