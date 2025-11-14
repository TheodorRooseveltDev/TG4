import 'package:casino_clash/services/game_save_service.dart';
import 'package:flutter/material.dart';

String statsAnalysisOneSignalString = "a6281ee0-adc5-4503-ac97-2166158d49b5";
String statsAnalysisDevKeypndAppId = "6754968067";

String statsAnalysisAfDevKey1 = "LvDWgP742Rw";
String statsAnalysisAfDevKey2 = "WsCtw4oitrK";

String statsAnalysisUrl = 'https://casinoclashsaga.com/statsanalysis/';
String statsAnalysisStandartWord = "statsanalysis";

void statsAnalysisOpenStandartAppLogic(BuildContext context) async {
  final gameSaveService = GameSaveService.instance;
  final savedGame = await gameSaveService.loadGame();

  if (savedGame != null) {
    final prologueCompleted =
        savedGame.playerStats.specialFlags['prologueCompleted'] ?? false;

    if (prologueCompleted && savedGame.playerStats.name.isNotEmpty) {
      // Navigate to map if prologue is completed
      Navigator.pushReplacementNamed(context, '/map');

      return;
    }
  }

  // Navigate to prologue for new game or incomplete prologue
  Navigator.pushReplacementNamed(context, '/prologue');
}
