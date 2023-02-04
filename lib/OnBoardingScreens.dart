import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/option-screen', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();

  }




  Widget _buildImage(String assetName, [double width = 350]) {
    return SvgPicture.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    PageDecoration pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700,fontFamily: 'Open Sans',
          fontStyle: FontStyle.normal),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      imagePadding: EdgeInsets.all(20.0),
      contentMargin: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
      boxDecoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );

    return SafeArea(
        child: IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000,
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFffcc00)),
          ),
          child: const Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.black,fontFamily: 'Open Sans',
                fontStyle: FontStyle.normal),
          ),
          onPressed: () => _onIntroEnd(context),
        )
      ),
      pages: [
        PageViewModel(
          title: "",
          body: "Learn from the comfort of home.",
          image:_buildImage('Screen_1.svg'),
          decoration: pageDecoration.copyWith(bodyFlex: 4,imageFlex: 9,safeArea: 0),
        ),
        PageViewModel(
          title: "",
          body:
              "Download the Stockpile app and master the market with our mini-lesson.",
          image: _buildImage('Screen_2.svg'),
          decoration: pageDecoration.copyWith(bodyFlex: 4,imageFlex: 8,safeArea: 0),
        ),
        PageViewModel(
          title: "",
          body:
              "Kids and teens can track their stocks 24/7 and place trades that you approve.",
          image: _buildImage('Screen_3.svg'),
          decoration: pageDecoration.copyWith(bodyFlex: 4,imageFlex: 8,safeArea: 0),
        )
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back,color:Colors.white ),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Open Sans',
          fontStyle: FontStyle.normal)),
      next: const Icon(Icons.arrow_forward,color: Colors.white,),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Open Sans',
          fontStyle: FontStyle.normal)),
      skipStyle: TextButton.styleFrom(primary: Colors.white),
      doneStyle: TextButton.styleFrom(primary: Colors.white),
      nextStyle: TextButton.styleFrom(primary: Colors.white),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFFFFFFF),
        activeColor: Color(0xFFFFFFFF),
        activeSize: Size(22.0, 10.0),
        spacing: EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xFF5f56c6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    ));
  }
}
