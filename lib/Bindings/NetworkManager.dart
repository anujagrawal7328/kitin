import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// class NetworkManager extends GetxController {
//   var TAG = "NetWorkManager";
//   int connectionType = 0;
//
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription _streamSubscription;
//
//   @override
//   void onInit() {
//     ///  implement onInit
//     getConnectionType();
//     _streamSubscription =
//         _connectivity.onConnectivityChanged.listen(_updateState);
//     super.onInit();
//   }
//
//   Future<void> getConnectionType() async {
//     var connectivityResult;
//
//     try {
//     connectivityResult = await _connectivity.checkConnectivity();
//     } on PlatformException catch (e) {
//       printMessage(TAG, "$e");
//     }
//
//     return _updateState(connectivityResult);
//   }
//
//   _updateState(ConnectivityResult result) {
//     switch (result) {
//       case ConnectivityResult.wifi:
//         connectionType = 1;
//         refresh();
//         break;
//
//       case ConnectivityResult.mobile:
//         connectionType = 2;
//         refresh();
//         break;
//
//       case ConnectivityResult.none:
//         connectionType = 0;
//         refresh();
//         break;
//
//       default:
//         printMessage(TAG,"Network Error : failed to get network status");
//     }
//   }
//
// }

class NetworkManager extends GetxController {
  //this variable 0 = No Internet, 1 = connected to WIFI ,2 = connected to Mobile Data.
  var connectionType = 1;

  //Instance of Flutter Connectivity
  final Connectivity _connectivity = Connectivity();

  //Stream to keep listening to network change state
  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    GetConnectionType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  // a method to get which connection result, if you we connected to internet or no if yes then which network
  Future<void> GetConnectionType() async {
    var connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      print(e);
    }
    return _updateState(connectivityResult);
  }

  // state update, of network, if you are connected to WIFI connectionType will get set to 1,
  // and update the state to the consumer of that variable.
  _updateState(ConnectivityResult result) {
    if (kDebugMode) {
      print('text$result');
    }
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType = 1;
        refresh();
        break;
      case ConnectivityResult.mobile:
        connectionType = 2;
        refresh();
        if (kDebugMode) {
          print('connectionType $connectionType');
        }
        break;
      case ConnectivityResult.none:
        connectionType = 0;
        refresh();
        if (kDebugMode) {
          print('connectionType $connectionType');
        }
        break;
      default:
        Get.snackbar('Network Error', 'Failed to get Network Status');
        break;
    }
  }

  @override
  void onClose() {
    //stop listening to network state when app is closed
    _streamSubscription!.cancel();
  }
}
