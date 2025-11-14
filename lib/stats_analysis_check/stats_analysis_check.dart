import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_service.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_splash.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_parameters.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences aSharedPreferences;

dynamic statsAnalysisConversionData;
String? statsAnalysisTrackingPermissionStatus;
String? statsAnalysisAdvertisingId;
String? analyticsLink;

String? appsflyer_id;
String? external_id;

String? statsAnalysisPushconsentmsg;

class StatsAnalysisCheck extends StatefulWidget {
  const StatsAnalysisCheck({super.key});

  @override
  State<StatsAnalysisCheck> createState() => _StatsAnalysisCheckState();
}

class _StatsAnalysisCheckState extends State<StatsAnalysisCheck> {
  @override
  void initState() {
    super.initState();
    statsAnalysisInitAll();
  }

  statsAnalysisInitAll() async {
    await Future.delayed(Duration(milliseconds: 10));
    aSharedPreferences = await SharedPreferences.getInstance();
    bool sendedAnalytics =
        aSharedPreferences.getBool("sendedAnalytics") ?? false;
    analyticsLink = aSharedPreferences.getString("link");

    statsAnalysisPushconsentmsg = aSharedPreferences.getString("pushconsentmsg");

    if (analyticsLink != null && analyticsLink != "" && !sendedAnalytics) {
      StatsAnalysisService().statsAnalysisNavigateToWebView(context);
    } else {
      if (sendedAnalytics) {
        StatsAnalysisService().statsAnalysisNavigateToSplash(context);
      } else {
        statsAnalysisInitializeMainPart();
      }
    }
  }

  void statsAnalysisInitializeMainPart() async {
    await StatsAnalysisService().statsAnalysisRequestTrackingPermission();
    await StatsAnalysisService().statsAnalysisInitializeOneSignal();
    await statsAnalysisTakeParams();
  }

  String? statsAnalysisGetPushConsentMsgValue(String link) {
    try {
      final uri = Uri.parse(link);
      final params = uri.queryParameters;

      return params['pushconsentmsg'];
    } catch (e) {
      return null;
    }
  }

  Future<void> statsAnalysisCreateLink() async {
    Map<dynamic, dynamic> parameters = statsAnalysisConversionData;

    parameters.addAll({
      "tracking_status": statsAnalysisTrackingPermissionStatus,
      "${statsAnalysisStandartWord}_id": statsAnalysisAdvertisingId,
      "external_id": external_id,
      "appsflyer_id": appsflyer_id,
    });

    String? link = await StatsAnalysisService().sendAnalyticsRequest(parameters);

    analyticsLink = link;

    if (analyticsLink == "" || analyticsLink == null) {
      StatsAnalysisService().statsAnalysisNavigateToSplash(context);
    } else {
      statsAnalysisPushconsentmsg = statsAnalysisGetPushConsentMsgValue(analyticsLink!);
      if (statsAnalysisPushconsentmsg != null) {
        aSharedPreferences.setString("pushconsentmsg", statsAnalysisPushconsentmsg!);
      }
      aSharedPreferences.setString("link", analyticsLink.toString());
      aSharedPreferences.setBool("success", true);
      StatsAnalysisService().statsAnalysisNavigateToWebView(context);
    }
  }

  Future<void> statsAnalysisTakeParams() async {
    final appsFlyerOptions = StatsAnalysisService().statsAnalysisCreateAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    appsflyer_id = await appsFlyerSdk.getAppsFlyerUID();

    appsFlyerSdk.onInstallConversionData((res) async {
      statsAnalysisConversionData = res;
      await statsAnalysisCreateLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        StatsAnalysisService().statsAnalysisNavigateToSplash(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const StatsAnalysisSplash();
  }
}
