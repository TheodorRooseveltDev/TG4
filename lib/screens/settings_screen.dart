import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../styles/text_styles.dart';
import '../services/audio_service.dart';
import '../services/game_save_service.dart';
import '../services/notification_service.dart';
import '../providers/game_providers.dart';
import 'prologue_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Load current player name
    final gameState = ref.read(gameStateProvider);
    _nameController.text = gameState.playerStats.name;
    // Load notifications state
    _notificationsEnabled = NotificationService.instance.notificationsEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openWebView(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WebViewScreen(title: title, url: url),
      ),
    );
  }

  void _saveName() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final gameNotifier = ref.read(gameStateProvider.notifier);
    gameNotifier.updatePlayerName(_nameController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Name saved successfully!'),
        backgroundColor: const Color(0xFF8B6F47),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/utilities/dialogs_bg.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Delete All Data?',
                  style: WesternTextStyles.title(
                    fontSize: 22,
                    color: const Color(0xFF1A0F08),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Warning message
                Text(
                  'This will permanently delete all your progress and return you to the beginning of the game. This action cannot be undone!',
                  textAlign: TextAlign.center,
                  style: WesternTextStyles.dialogue(
                    fontSize: 16,
                    color: const Color(0xFF1A0F08),
                  ),
                ),
                const SizedBox(height: 32),
                // Buttons - stacked vertically
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context); // Close dialog
                    await _deleteAllData();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/utilities/buttons.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Delete All',
                        style: WesternTextStyles.button(
                          fontSize: 16,
                          color: const Color(0xFFF5E6D3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/utilities/buttons.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: WesternTextStyles.button(
                          fontSize: 16,
                          color: const Color(0xFFF5E6D3),
                        ),
                      ),
                    ),
                  ),
                ),
              ], // Column children
            ), // Column
          ), // Padding
        ), // Container
      ), // Dialog
    ); // showDialog
  }

  Future<void> _deleteAllData() async {
    // Reset game state
    final gameNotifier = ref.read(gameStateProvider.notifier);
    gameNotifier.resetGame();

    // Clear saved games (both manual and auto saves)
    await GameSaveService.instance.deleteSave(deleteAutoSave: false);
    await GameSaveService.instance.deleteSave(deleteAutoSave: true);

    // Navigate to prologue
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PrologueScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/utilities/workshop.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Dark overlay
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Settings content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Player Name Section
                        _buildSection(
                          title: 'Player Name',
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                style: WesternTextStyles.dialogue(
                                  fontSize: 19,
                                  color: const Color(0xFF1A0F08),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your name...',
                                  hintStyle: WesternTextStyles.dialogue(
                                    fontSize: 19,
                                    color: const Color(0xFF6B4E3D),
                                  ),
                                  filled: true,
                                  fillColor: const Color(
                                    0xFFF5E6D3,
                                  ).withOpacity(0.5),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8B6F47),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8B6F47),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6B4E3D),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildButton('Save Name', _saveName),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Audio Settings Section
                        _buildSection(
                          title: 'Audio Settings',
                          child: Column(
                            children: [
                              _buildAudioToggle('🎵 Music', _musicEnabled, (
                                value,
                              ) {
                                setState(() {
                                  _musicEnabled = value;
                                });
                                AudioService.instance.setMusicEnabled(value);
                              }),
                              const SizedBox(height: 16),
                              _buildAudioToggle(
                                '🔊 Sound Effects',
                                _sfxEnabled,
                                (value) {
                                  setState(() {
                                    _sfxEnabled = value;
                                  });
                                  AudioService.instance.setSfxEnabled(value);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Notifications Section
                        _buildSection(
                          title: 'Notifications',
                          child: Column(
                            children: [
                              _buildAudioToggle(
                                '🔔 Push Notifications',
                                _notificationsEnabled,
                                (value) async {
                                  if (value) {
                                    // Включение - запрашиваем разрешение и ждем результата
                                    final result = await OneSignal
                                        .Notifications.requestPermission(true);

                                    if (mounted) {
                                      setState(() {
                                        _notificationsEnabled = result;
                                      });
                                    }
                                  } else {
                                    // Выключение - сразу обновляем UI и отключаем
                                    setState(() {
                                      _notificationsEnabled = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Legal Section
                        _buildSection(
                          title: 'Legal',
                          child: Column(
                            children: [
                              _buildButton(
                                'Privacy Policy',
                                () => _openWebView(
                                  'Privacy Policy',
                                  'https://casinoclashsaga.com/privacy/',
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildButton(
                                'Terms & Conditions',
                                () => _openWebView(
                                  'Terms & Conditions',
                                  'https://casinoclashsaga.com/terms/',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Danger Zone Section
                        _buildSection(
                          title: 'Danger Zone',
                          child: Column(
                            children: [
                              _buildButton(
                                'Delete All Data',
                                _showDeleteConfirmation,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Back button
                        _buildButton(
                          'Back to Map',
                          () => Navigator.pop(context),
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/utilities/header_bg.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, color: Color(0xFFF5E6D3), size: 32),
          const SizedBox(width: 12),
          Text(
            'SETTINGS',
            style: WesternTextStyles.title(
              fontSize: 28,
              color: const Color(0xFFF5E6D3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/utilities/dialogs_bg.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: WesternTextStyles.title(
                fontSize: 20,
                color: const Color(0xFF1A0F08),
              ),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAudioToggle(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: WesternTextStyles.dialogue(
              fontSize: 20,
              color: const Color(0xFF1A0F08),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/utilities/buttons.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              value ? 'ON' : 'OFF',
              style: WesternTextStyles.button(
                fontSize: 16,
                color: const Color(0xFFF5E6D3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onTap, {
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/utilities/buttons.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: WesternTextStyles.button(
              fontSize: isPrimary ? 18 : 16,
              color: const Color(0xFFF5E6D3),
            ),
          ),
        ),
      ),
    );
  }
}

// WebView Screen for Privacy Policy and Terms
class _WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const _WebViewScreen({required this.title, required this.url});

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF8B6F47),
        foregroundColor: const Color(0xFFF5E6D3),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8B6F47),
              ),
            ),
        ],
      ),
    );
  }
}
