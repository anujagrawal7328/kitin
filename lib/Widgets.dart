import 'dart:developer';

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
  return  Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
      ),
      child:Align(alignment:Alignment.center,
      child: Image.asset(
          "assets/Preloader.gif",
          gaplessPlayback: true,
          width: 50.0,
          height:50.0
      ),)
      ,

  );

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
