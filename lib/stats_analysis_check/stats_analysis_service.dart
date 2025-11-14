import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_check.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_web_view.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_parameters.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

class StatsAnalysisService {
  Future<void> statsAnalysisInitializeOneSignal() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Location.setShared(false);
    OneSignal.initialize(statsAnalysisOneSignalString);
    external_id = Uuid().v1();
  }

  Future<void> statsAnalysisRequestPermissionOneSignal() async {
    await OneSignal.Notifications.requestPermission(true);
    external_id = Uuid().v1();
    try {
      OneSignal.login(external_id!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void statsAnalysisSendRequiestToBack() {
    try {
      OneSignal.login(external_id!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  Future statsAnalysisNavigateToSplash(BuildContext context) async {
    aSharedPreferences.setBool("sendedAnalytics", true);
    statsAnalysisOpenStandartAppLogic(context);
  }

  Future<bool> isSystemPermissionGranted() async {
    if (!Platform.isIOS) return false;
    try {
      final status = await OneSignal.Notifications.permissionNative();
      return status == OSNotificationPermission.authorized ||
          status == OSNotificationPermission.provisional ||
          status == OSNotificationPermission.ephemeral;
    } catch (_) {
      return false;
    }
  }

  void statsAnalysisNavigateToWebView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebViewWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  AppsFlyerOptions statsAnalysisCreateAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (statsAnalysisAfDevKey1 + statsAnalysisAfDevKey2),
      appId: statsAnalysisDevKeypndAppId,
      timeToWaitForATTUserAuthorization: 7,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> statsAnalysisRequestTrackingPermission() async {
    if (Platform.isIOS) {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(seconds: 2));
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        statsAnalysisTrackingPermissionStatus = status.toString();

        if (status == TrackingStatus.authorized) {
          statsAnalysisGetAdvertisingId();
        }
        if (status == TrackingStatus.notDetermined) {
          final status =
              await AppTrackingTransparency.requestTrackingAuthorization();
          statsAnalysisTrackingPermissionStatus = status.toString();

          if (status == TrackingStatus.authorized) {
            statsAnalysisGetAdvertisingId();
          }
        }
      }
    }
  }

  Future<void> statsAnalysisGetAdvertisingId() async {
    try {
      statsAnalysisAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendAnalyticsRequest(Map<dynamic, dynamic> parameters) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {statsAnalysisStandartWord: base64Parameters};

      final response = await http.post(
        Uri.parse(statsAnalysisUrl),
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
