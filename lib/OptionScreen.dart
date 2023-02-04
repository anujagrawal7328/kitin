import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({Key? key}) : super(key: key);

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Image.asset('assets/kitin-app-logo.png'),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        "Select Course",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          decoration: TextDecoration.none,
                            fontFamily: 'Open Sans',
                            fontStyle: FontStyle.normal
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(20.0)),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width*(3/4),
                    height: 60,
                    onPressed: () async {
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString('url', "https://www.app.kitin.in/lsa-livestock-assistant");
                      prefs.setString('permanentLink',"https://www.app.kitin.in/lsa-livestock-assistant");
                      navigator?.pushNamedAndRemoveUntil('/webpage', (Route<dynamic> route) => false);
                    },
                    color: const Color(0xFF5f56c6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      "LSA - Livestock Assistant",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Open Sans',
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(10.0)),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width*(3/4),
                    height: 60,
                    onPressed: () async {
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString('url', "https://www.app.kitin.in/agriculture-supervisor");
                      prefs.setString('permanentLink', "https://www.app.kitin.in/agriculture-supervisor");
                      navigator?.pushNamedAndRemoveUntil('/webpage', (Route<dynamic> route) => false);
                    },
                    color: const Color(0xFF5f56c6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      "Agriculture Supervisor",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Open Sans',
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                ])));
  }
}
