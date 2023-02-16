
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:kitin/WebPage.dart';
import 'package:kitin/spalsh.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:upgrader/upgrader.dart';


import 'OnBoardingScreens.dart';

import 'Bindings/NetworkBinding.dart';
import 'OptionScreen.dart';
import 'Widgets.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


bool shouldUseFirestoreEmulator = false;
bool _initialUriIsHandled = false;
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;
int counter =0;
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  await Upgrader.clearSavedSettings();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FlutterError.onError = (errorDetails) {
    // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
    analytics.logEvent(name: 'fatalError',parameters: {'message':errorDetails.toString()});
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
    analytics.logEvent(name: 'fatalError',parameters: {'message':error.toString()});
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FlutterNativeSplash.remove();
  final SharedPreferences prefs = await _prefs;
  if(prefs.getInt('counter')!=null){
    if(prefs.getString('url')!=null){
      counter=(prefs.getInt('counter'))!;
    }
  }
  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }


  if(counter<=1){
    counter++;
    prefs.setInt('counter', counter);
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {

  String? _emailAddress;
  String? _smsNumber;
  String? _externalUserId;
  String? _language;
  bool _enableConsentButton = false;
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;
  StreamSubscription? _sub;
  String? sharedUrl;
  String? storeVersion;
  bool permissionGranted=false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }


  @override
  void initState() {
    _initializeFlutterFireFuture = _initializeFlutterFire();
     secureScreen();
    _initPackageInfo();
     getStoreVersion('kitin.kyro.edu.kitin');
    _getStoragePermission();
    _handleIncomingLinks();
    _handleInitialUri();

    super.initState();
  }
  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  Future<String?> getStoreVersion(String myAppBundleId) async {

    if (Platform.isAndroid) {
      PlayStoreSearchAPI playStoreSearchAPI = PlayStoreSearchAPI();
      final result = await playStoreSearchAPI.lookupById(myAppBundleId, country: 'US');
      if (result != null) storeVersion = PlayStoreResults.version(result);
      log('PlayStore version: $storeVersion}');
    } else if (Platform.isIOS) {
      ITunesSearchAPI iTunesSearchAPI = ITunesSearchAPI();
      Map<dynamic, dynamic>? result =
      await iTunesSearchAPI.lookupByBundleId(myAppBundleId, country: 'US');
      if (result != null) storeVersion = ITunesResults.version(result);
      log('AppStore version: $storeVersion}');
    } else {
      storeVersion = null;
    }
    return storeVersion;
  }



  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  Future _getStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isRestricted || status.isDenied || status.isPermanentlyDenied) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage
      ].request();
      if (kDebugMode) {
        print(statuses[Permission.storage]);
      } // it should print PermissionStatus.granted
    }

  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got uri: $uri');
        }
        setState(() async {
          if (uri != null) {
            _latestUri = uri;
          }
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got err: $err');
        }
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        var uri = await getInitialUri();
        if (uri == null) {
          if (kDebugMode) {
            print('no initial uri');
          }
        } else {
          if (kDebugMode) {
            print('got initial uri: $uri');
          }
        }
        if (!mounted) return;
        final docRef = FirebaseFirestore.instance
            .collection("temp")
            .doc("8IrsyMVUtmfFOwzufhpX");
        docRef.get().then((DocumentSnapshot doc) async {
          final SharedPreferences prefs = await _prefs;
          if (doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;
            if(uri!=null){
              if(uri.toString()=="https://www.app.kitin.in"){
                uri=Uri.parse('https://www.app.kitin.in/new-home');
              }
            }
            setState((){sharedUrl =uri==null ? data['url']!='' ?data['url']:'https://www.app.kitin.in/new-home':uri as String?;
            prefs.setString('url',sharedUrl!);
            if (kDebugMode) {
              print('sharedurl:$sharedUrl');
            }
            });
          }

          }, onError: (e) => print("Error getting document: $e"));
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        if (kDebugMode) {
          print('falied to get initial uri');
        }
      } on FormatException catch (err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('malformed initial uri');
        }
        setState(() => _err = err);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        initialBinding: NetworkBinding(),
        title: 'Kitin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: buildMaterialColor(const Color(0xFF5f56c6)),
        ),
        routes: {
          '/': (context) => const Splash(),
          '/home': (context) =>_packageInfo.version==storeVersion? (counter==1?const OnBoardingPage():const WebPage()):(counter==1?UpgradeAlert(child:const OnBoardingPage()):UpgradeAlert(child:const WebPage())),
          '/option-screen':(context) => const OptionScreen(),
          '/webpage':(context) => _packageInfo.version==storeVersion?const WebPage():UpgradeAlert(child:const WebPage()),

        });
  }
}
