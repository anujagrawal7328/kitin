import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:skeleton_text/skeleton_text.dart';
List<BoxShadow> shadowList = [
  BoxShadow(color: Colors.grey[300]!, blurRadius: 30, offset: const Offset(0, 10))
];
Widget loginSkeleton(){
  return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
          children: [
            Expanded(
              child: SkeletonAnimation(
                shimmerColor: Colors.grey,
                borderRadius: BorderRadius.circular(20),
                shimmerDuration: 1000,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: shadowList,
                  ),
                  margin: const EdgeInsets.only(top: 40),
                ),
              ),
            ),]));
}
Widget homeSkeleton(){
  return Container(
    height: 800,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
    Expanded(
    child: SkeletonAnimation(
    shimmerColor: Colors.grey,
      borderRadius: BorderRadius.circular(20),
      shimmerDuration: 1000,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadowList,
        ),
        margin: const EdgeInsets.only(top: 40),
      ),
    ),
  ),]));
}

Widget loader() {
  return Container(
       color: Colors.white,
      child:Center(
      child: Container(
    width: 100.0,
    height: 100.0,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.grey[300]?.withOpacity(0.3),
    ),
    child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
          SizedBox(
            height: 30.0,
            width: 30.0,
            child: CircularProgressIndicator(),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0)),
          Text('Loading ...',
              style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  decoration: TextDecoration.none))
        ])),
  )));
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
