import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_check.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_consent_prompt.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_service.dart';
import 'package:casino_clash/stats_analysis_check/stats_analysis_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({super.key});

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget>
    with WidgetsBindingObserver {
  late InAppWebViewController statsAnalysisWebViewController;

  bool statsAnalysisShowLoading = true;
  bool statsAnalysisShowConsentPrompt = false;

  bool statsAnalysisWasOpenNotification =
      aSharedPreferences.getBool("wasOpenNotification") ?? false;

  final bool savePermission =
      aSharedPreferences.getBool("savePermission") ?? false;

  bool waitingForSettingsReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (waitingForSettingsReturn) {
        waitingForSettingsReturn = false;
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            statsAnalysisAfterSetting();
          }
        });
      }
    }
  }

  Future<void> statsAnalysisAfterSetting() async {
    final deviceState = OneSignal.User.pushSubscription;

    bool havePermission = deviceState.optedIn ?? false;
    final bool systemNotificationsEnabled = await StatsAnalysisService()
        .isSystemPermissionGranted();

    if (havePermission || systemNotificationsEnabled) {
      aSharedPreferences.setBool("wasOpenNotification", true);
      statsAnalysisWasOpenNotification = true;
      StatsAnalysisService().statsAnalysisSendRequiestToBack();
    }

    statsAnalysisShowConsentPrompt = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: statsAnalysisShowLoading ? 0 : 1,

          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(analyticsLink!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: false,
                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                      ),
                      onWebViewCreated: (controller) {
                        statsAnalysisWebViewController = controller;
                      },
                      onLoadStop: (controller, url) async {
                        statsAnalysisShowLoading = false;
                        setState(() {});
                        if (statsAnalysisWasOpenNotification) return;

                        final bool systemNotificationsEnabled =
                            await StatsAnalysisService().isSystemPermissionGranted();

                        await Future.delayed(Duration(milliseconds: 3000));

                        if (systemNotificationsEnabled) {
                          aSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                          statsAnalysisWasOpenNotification = true;
                        }

                        if (!systemNotificationsEnabled) {
                          statsAnalysisShowConsentPrompt = true;
                          statsAnalysisWasOpenNotification = true;
                        }

                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return statsAnalysisBuildWebBottomBar(orientation);
              },
            ),
          ),
        ),
        if (statsAnalysisShowLoading) const StatsAnalysisSplash(),
        if (!statsAnalysisShowLoading)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            reverseDuration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: statsAnalysisShowConsentPrompt
                ? StatsAnalysisConsentPromptPage(
                    key: const ValueKey('consent_prompt'),
                    onYes: () async {
                      if (savePermission == true) {
                        waitingForSettingsReturn = true;
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        );
                      } else {
                        await StatsAnalysisService()
                            .statsAnalysisRequestPermissionOneSignal();

                        final bool systemNotificationsEnabled =
                            await StatsAnalysisService().isSystemPermissionGranted();

                        if (systemNotificationsEnabled) {
                          aSharedPreferences.setBool(
                            "wasOpenNotification",
                            true,
                          );
                        } else {
                          aSharedPreferences.setBool("savePermission", true);
                        }
                        statsAnalysisWasOpenNotification = true;
                        statsAnalysisShowConsentPrompt = false;
                        setState(() {});
                      }
                    },
                    onNo: () {
                      setState(() {
                        statsAnalysisWasOpenNotification = true;
                        statsAnalysisShowConsentPrompt = false;
                      });
                    },
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
      ],
    );
  }

  Widget statsAnalysisBuildWebBottomBar(Orientation orientation) {
    return Container(
      color: Colors.black,
      height: orientation == Orientation.portrait ? 25 : 30,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await statsAnalysisWebViewController.canGoBack()) {
                statsAnalysisWebViewController.goBack();
              }
            },
          ),
          const SizedBox.shrink(),
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await statsAnalysisWebViewController.canGoForward()) {
                statsAnalysisWebViewController.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}
