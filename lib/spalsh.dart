import 'package:flutter/material.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    onSplashEnd();

  }

  Future<void> onSplashEnd() async {
    await Future.delayed(const Duration(seconds: 3))
        .then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
          Expanded(
          child: Align(
            alignment: Alignment.center,
            child:Image.asset(
                  "assets/kitin.gif",
                  gaplessPlayback: true,
                )
          )),
                const Align(
                        alignment: Alignment.bottomCenter,
                        child:
                            Text(
                              "Powered by \n PADMANABH Innovations LLP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                letterSpacing: 2.0,
                                decoration: TextDecoration.none,
                                fontFamily: 'Open Sans',
                                fontStyle: FontStyle.normal
                              ),
                            ),
                         )],
      ),
    ));
  }
}
