import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../services/game_save_service.dart';
import '../services/audio_service.dart';
import '../styles/text_styles.dart';
import 'story_screen.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _hasSavedGame = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _checkForSavedGame();
    _playMenuMusic();
  }

  Future<void> _checkForSavedGame() async {
    final hasSave = await GameSaveService.instance.hasSavedGame();
    setState(() {
      _hasSavedGame = hasSave;
      _isLoading = false;
    });
  }

  void _playMenuMusic() {
    // Menu music disabled
    // AudioService.instance.playMusic('music/thunder_crash.mp3', loop: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.red.shade900.withOpacity(0.5),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.7 + (_pulseController.value * 0.3),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          'CASINO CLASH',
                          style: WesternTextStyles.title(fontSize: 48),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Trail of Chances',
                          style: WesternTextStyles.subtitle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Menu buttons
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    _buildMenuButton(
                      'NEW GAME',
                      Icons.play_arrow,
                      () => _startNewGame(),
                    ),
                    const SizedBox(height: 16),
                    if (_hasSavedGame) ...[
                      _buildMenuButton(
                        'CONTINUE',
                        Icons.restore,
                        () => _continueGame(),
                      ),
                      const SizedBox(height: 8),
                      // Save game stats preview
                      FutureBuilder(
                        future: GameSaveService.instance.loadGame(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final gameState = snapshot.data!;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatPreview(
                                        Icons.account_balance_wallet,
                                        'Money',
                                        '\$${gameState.playerStats.money}',
                                      ),
                                      _buildStatPreview(
                                        Icons.star,
                                        'Respect',
                                        '${gameState.playerStats.respect}',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Casinos: ${gameState.completedCasinos.length}/10 completed',
                                    style: TextStyle(
                                      color: Colors.red.shade300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildMenuButton(
                      'SETTINGS',
                      Icons.settings,
                      () => _showSettings(),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      'ABOUT',
                      Icons.info_outline,
                      () => _showAbout(),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Footer - removed loop counter
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade900, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red.shade300),
            const SizedBox(width: 12),
            Text(
              text,
              style: WesternTextStyles.button(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPreview(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber.shade300, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _startNewGame() {
    if (_hasSavedGame) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          title: Text(
            'Start New Game?',
            style: TextStyle(color: Colors.red.shade300),
          ),
          content: const Text(
            'This will overwrite your current saved game. Are you sure?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(gameStateProvider.notifier).resetGame();
                _navigateToGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
              ),
              child: const Text('Start New Game'),
            ),
          ],
        ),
      );
    } else {
      ref.read(gameStateProvider.notifier).resetGame();
      _navigateToGame();
    }
  }

  Future<void> _continueGame() async {
    final savedGame = await GameSaveService.instance.loadGame();
    if (savedGame != null) {
      ref.read(gameStateProvider.notifier).loadGame(savedGame);
      _navigateToGame();
    }
  }

  void _navigateToGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StoryScreen()),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.red.shade300),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Music', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: (value) {
                AudioService.instance.setMusicEnabled(value);
              },
              activeColor: Colors.red.shade300,
            ),
            SwitchListTile(
              title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: (value) {
                AudioService.instance.setSfxEnabled(value);
              },
              activeColor: Colors.red.shade300,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        title: Text(
          'About',
          style: TextStyle(color: Colors.red.shade300),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CASINO CLASH: Trail of Chances',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'A psychological thriller where every choice echoes through time. '
                'Navigate through ten casinos, each representing a deadly sin, '
                'as you unravel the truth about your mother\'s death.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'The game features multiple endings, branching narratives, '
                'and a story that questions the nature of reality itself.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
