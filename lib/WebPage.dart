import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:kitin/Widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'Bindings/NetworkManager.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> with SingleTickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();

  String? sharedUrl, loadingwidget;
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings =
      PullToRefreshSettings(color: const Color(0xFF5f56c6));
  double progress = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _debugLabelString = "";
  final bool _requireConsent = true;
  bool pullToRefreshEnabled = true;


  @override
  void initState() {
    setupInteractedMessage();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
    pullToRefreshController?.setEnabled(pullToRefreshEnabled);
    super.initState();
  }

  Future<void> setupInteractedMessage() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      if (kDebugMode) {
        print('NOTIFICATION OPENED HANDLER CALLED WITH: $result');
      }
      if (result.notification.additionalData != null) {
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri.uri(
                    Uri.parse(result.notification.additionalData!['uri']))));
      }
      setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) async {
      if (kDebugMode) {
        print('FOREGROUND HANDLER CALLED WITH: $event');
      }

      /// Display Notification, send null to not display

      event.complete(event.notification);
      if (event.notification.additionalData != null) {
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: WebUri.uri(
                    Uri.parse(event.notification.additionalData!['uri']))));
      }
      setState(() {
        _debugLabelString =
            "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) async {
      // if(action.clickUrl!=null){
      //   await webViewController?.loadUrl(urlRequest:URLRequest(url:WebUri.uri(Uri.parse(action.))));
      // }
      setState(() {
        _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      if (kDebugMode) {
        print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
      }
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      if (kDebugMode) {
        print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
      }
    });

    OneSignal.shared.setOnWillDisplayInAppMessageHandler((message) {
      if (kDebugMode) {
        print("ON WILL DISPLAY IN APP MESSAGE ${message.messageId}");
      }
    });

    OneSignal.shared.setOnDidDisplayInAppMessageHandler((message) {
      if (kDebugMode) {
        print("ON DID DISPLAY IN APP MESSAGE ${message.messageId}");
      }
    });

    OneSignal.shared.setOnWillDismissInAppMessageHandler((message) {
      if (kDebugMode) {
        print("ON WILL DISMISS IN APP MESSAGE ${message.messageId}");
      }
    });

    OneSignal.shared.setOnDidDismissInAppMessageHandler((message) {
      if (kDebugMode) {
        print("ON DID DISMISS IN APP MESSAGE ${message.messageId}");
      }
    });

    // NOTE: Replace with your own app ID from https://www.onesignal.com

    await OneSignal.shared.setAppId("32edc226-c7aa-45a5-ae52-80bfad5cad95");
    await OneSignal.shared.consentGranted(true);
    // iOS-only method to open launch URLs in Safari when set to false
    OneSignal.shared.setLaunchURLsInApp(false);

    // bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    // setState(() {
    //   _enableConsentButton = requiresConsent;
    // });

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    oneSignalInAppMessagingTriggerExamples();

    OneSignal.shared.disablePush(false);

    bool userProvidedPrivacyConsent =
        await OneSignal.shared.userProvidedPrivacyConsent();
    if (kDebugMode) {
      print("USER PROVIDED PRIVACY CONSENT: $userProvidedPrivacyConsent");
    }
  }

  oneSignalInAppMessagingTriggerExamples() async {
    /// Example addTrigger call for IAM
    /// This will add 1 trigger so if there are any IAM satisfying it, it
    /// will be shown to the user
    OneSignal.shared.addTrigger("trigger_1", "one");

    /// Example addTriggers call for IAM
    /// This will add 2 triggers so if there are any IAM satisfying these, they
    /// will be shown to the user
    Map<String, Object> triggers = <String, Object>{};
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    // Removes a trigger by its key so if any future IAM are pulled with
    // these triggers they will not be shown until the trigger is added back
    OneSignal.shared.removeTriggerForKey("trigger_2");

    // Get the value for a trigger by its key
    Object? triggerValue =
        await OneSignal.shared.getTriggerValueForKey("trigger_3");
    if (kDebugMode) {
      print("'trigger_3' key trigger value: ${triggerValue?.toString()}");
    }

    // Create a list and bulk remove triggers based on keys supplied
    List<String> keys = ["trigger_1", "trigger_3"];
    OneSignal.shared.removeTriggersForKeys(keys);

    // Toggle pausing (displaying or not) of IAMs
    OneSignal.shared.pauseInAppMessages(false);
  }

  Future<WebUri> get _url async {
    final SharedPreferences prefs = await _prefs;
    sharedUrl = prefs.getString('url');
    if (kDebugMode) {
      print('sharedurl:$sharedUrl');
    }

    return WebUri.uri(Uri.parse(sharedUrl!));
  }


  Future<void> loadTime() async{
    try {
      await http.get(Uri.parse("https://www.app.kitin.in/new-home")).timeout(const Duration(seconds: 10));

    } on TimeoutException catch (e, s) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your Internet Connection Is Slow. Please Wait !')));
    }
  }

  final NetworkManager controller = Get.put(NetworkManager());
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("webpage :${controller.connectionType}");
    }

    return GetBuilder<NetworkManager>(builder: (value) {

      return Scaffold(body:WillPopScope(
        onWillPop: () async {
          // detect Android back button click
          final controller = webViewController;
          if (controller != null) {
            if (await controller.canGoBack()) {
              controller.goBack();
              return false;
            }
          }
          return true;
        },
        child: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
              child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(children: [
                    controller.connectionType != 0
                        ? FutureBuilder(
                            future: _url,
                            builder: (BuildContext context,
                                    AsyncSnapshot snapshot) =>
                                snapshot.hasData
                                    ? Visibility(
                                        visible: true,
                                        maintainState: true,
                                        child: InAppWebView(
                                          key: webViewKey,
                                          gestureRecognizers: Set()
                                            ..add(Factory<
                                                    VerticalDragGestureRecognizer>(
                                                () =>
                                                    VerticalDragGestureRecognizer())),
                                          pullToRefreshController:
                                              pullToRefreshController,
                                          initialUrlRequest:
                                              URLRequest(url: snapshot.data),
                                          initialSettings: InAppWebViewSettings(
                                              allowsBackForwardNavigationGestures:
                                                  true,
                                              useShouldOverrideUrlLoading: true,
                                              cacheEnabled:true,
                                              allowFileAccess: true,
                                              mediaPlaybackRequiresUserGesture:
                                                  false,
                                              allowsInlineMediaPlayback: true,
                                              iframeAllow: "camera; microphone",
                                              iframeAllowFullscreen: true,
                                              useHybridComposition: true),
                                          contextMenu: ContextMenu(
                                              settings: ContextMenuSettings(
                                                  hideDefaultSystemContextMenuItems:
                                                      true)),
                                          onEnterFullscreen:(controller){
                                            SystemChrome.setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.landscapeLeft,
                                              DeviceOrientation.landscapeRight,
                                            ]);
                                          },
                                          onExitFullscreen: (controller){
                                            SystemChrome.setPreferredOrientations([
                                              DeviceOrientation.portraitUp
                                            ]);
                                          },
                                          shouldOverrideUrlLoading: (controller,
                                              navigationAction) async {
                                            loadTime();
                                            final SharedPreferences prefs =
                                                await _prefs;
                                            var uri =
                                                navigationAction.request.url!;

                                            if (uri.toString().startsWith(
                                                    "https://app.kitin.in") ||
                                                uri.toString().startsWith(
                                                    "https://kitin.in")) {
                                              final tempUrl = prefs
                                                  .getString('permanentLink');
                                              controller.loadUrl(
                                                  urlRequest: URLRequest(
                                                      url: WebUri.uri(Uri.parse(
                                                          tempUrl!))));
                                            }
                                            if (uri.toString() ==
                                                "https://www.app.kitin.in") {
                                              const tempUrl = 'https://www.app.kitin.in/new-home';
                                              controller.loadUrl(
                                                  urlRequest: URLRequest(
                                                      url: WebUri.uri(Uri.parse(
                                                          tempUrl))));
                                            }
                                            if (uri.toString().startsWith("https://kitinapp.page.link/") ||
                                                uri.toString().startsWith("http://kitinapp.page.link/") ||
                                                uri.toString().startsWith(
                                                    "https://app.kitin.in/") ||
                                                uri.toString().startsWith(
                                                    "http://app.kitin.in/") ||
                                                uri.toString().startsWith(
                                                    "https://www.app.kitin.in/") ||
                                                uri.toString().startsWith(
                                                    "http://www.app.kitin.in/") ||
                                                uri.toString().startsWith(
                                            "https://kitin.in/") ||
                                                uri.toString().startsWith(
                                                    "https://kitin.in/") ||
                                                uri.toString().startsWith(
                                                    "https://secure.ccavenue.com/") ||  uri.toString().startsWith(sharedUrl.toString()) ) {
                                              // do whatever you want and cancel the request.

                                              print(
                                                  'loading Widget:$loadingwidget');
                                              return NavigationActionPolicy
                                                  .ALLOW;
                                            }
                                            if (kDebugMode) {
                                              print("loading unknown url");
                                            }
                                            await launchUrl(uri,mode: LaunchMode.externalNonBrowserApplication);
                                            return NavigationActionPolicy
                                                .CANCEL;
                                          },
                                          onWebViewCreated: (controller) {
                                            webViewController = controller;
                                          },

                                          onProgressChanged:
                                              (controller, progress) {

                                            setState(() {
                                              this.progress = progress / 75;
                                            });
                                            if (progress == 100) {
                                              pullToRefreshController
                                                  ?.endRefreshing();
                                            }


                                          },

                                          onLoadStart: (controller, url) {

                                            loader();
                                            },
                                          onLoadStop: (controller, url) {
                                            pullToRefreshController
                                                ?.endRefreshing();
                                            // progress < 1.0 ? loader(context) : Container(color: Colors.transparent,);
                                          },
                                          onReceivedHttpError: (controller,
                                              request, errorResponse) async {
                                            // Handle HTTP errors here
                                            var isForMainFrame =
                                                request.isForMainFrame ?? false;
                                            if (!isForMainFrame) {
                                              return;
                                            }
                                            await FirebaseAnalytics.instance.logEvent(
                                              name: 'Http_Error',
                                              parameters: <String, dynamic>{
                                                'string': errorResponse.reasonPhrase.toString(),
                                                'status code':errorResponse.statusCode
                                              },
                                            );
                                            controller.loadFile(
                                                assetFilePath:
                                                'assets/404.html');
                                          },
                                          onReceivedError: (controller, request,
                                              error) async {
                                            pullToRefreshController
                                                ?.endRefreshing();
                                            // Handle web page loading errors here
                                            var isForMainFrame =
                                                request.isForMainFrame ?? false;
                                            if (!isForMainFrame ||
                                                (!kIsWeb &&
                                                    defaultTargetPlatform ==
                                                        TargetPlatform.iOS &&
                                                    error.type ==
                                                        WebResourceErrorType
                                                            .CANCELLED)) {
                                              return;
                                            }
                                            await FirebaseAnalytics.instance.logEvent(
                                              name: 'custom_error',
                                              parameters: <String, dynamic>{
                                                'string': error.toString(),
                                                'type':error.type.toString()
                                              },
                                            );
                                            // controller.loadFile(
                                            //     assetFilePath:
                                            //     'assets/404.html');
                                          },
                                        ))
                                    : loader())
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: Svg('assets/network_error.svg'),
                                  alignment: Alignment.topCenter),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 50),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'WHOOPS!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(5.0)),
                                const Text(
                                  'Looks like network has been disabled.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(5.0)),
                                MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width *
                                      (3 / 4),
                                  height: 60,
                                  onPressed: () {
                                    webViewController?.reload();
                                  },
                                  color: const Color(0xFF5f56c6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Refresh",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                ),
                                MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 2,
                                  height: 60,
                                  onPressed: () {
                                    AppSettings.openDataRoamingSettings();
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Turn on data.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                )
                              ],
                            )),
                    progress < 1.0 ? loader() : Container(),
                  ]))),
        ])),
      ));
    });
  }
}
