import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/game_providers.dart';
import '../styles/text_styles.dart';
import 'map_screen.dart';

class PrologueScreen extends ConsumerStatefulWidget {
  const PrologueScreen({super.key});

  @override
  ConsumerState<PrologueScreen> createState() => _PrologueScreenState();
}

class _PrologueScreenState extends ConsumerState<PrologueScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _modalController;
  late Animation<double> _modalScaleAnimation;
  late Animation<double> _modalOpacityAnimation;
  bool _showText = false;
  bool _showContinue = false;
  bool _showChoices = false;
  bool _skipAnimation = false; // Flag to skip typewriter and show full text
  bool _showModal = false; // Control modal animation
  int _currentScene = 0; // 0=intro_1, 1=intro_2, 2=intro_3, 3=scarlett_dialogue
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textKey = GlobalKey(); // Key for AnimatedTextKit to force rebuild
  Timer? _autoScrollTimer; // Timer for auto-scrolling during animation

  // Prologue scenes data
  final List<Map<String, dynamic>> _scenes = [];
  final Map<int, double> _sceneHeights = {}; // Store calculated height for each scene

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Modal animation controller
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _modalScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack),
    );
    _modalOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOut),
    );

    // Load prologue data
    _loadPrologueScenes();

    // Start first scene immediately
    _fadeController.forward();
    setState(() => _showText = true);
    
    // Start auto-scroll after text starts showing
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _loadPrologueScenes() async {
    try {
      final gameData = ref.read(gameDataServiceProvider);
      final allData = await gameData.loadGameData();
      
      if (mounted) {
        setState(() {
          // Extract prologue scenes from screens_part1 (just 4 main scenes)
          final screens = allData['screens_part1'] as Map<String, dynamic>?;
          if (screens != null) {
            _scenes.addAll([
              screens['intro_1'] ?? {},       // Wake up at station
              screens['intro_2'] ?? {},       // Scarlett speaks
              screens['name_question'] ?? {}, // Ask for name
              screens['intro_3'] ?? {},       // Presentation & welcome
            ]);
          }
          _calculateMaxDialogHeight();
        });
      }
    } catch (e) {
      print('Error loading prologue scenes: $e');
      // Add fallback scenes
      if (mounted) {
        setState(() {
          _scenes.addAll([
            {
              'type': 'narration',
              'bg': 'assets/images/prologue/dialogue.png',
              'text': 'September 13th, 1800. Friday the 13th. Your stagecoach crashes. You wake at Perdition Station.',
            },
            {
              'type': 'dialogue',
              'bg': 'assets/images/prologue/dialogue.png',
              'character': 'scarlett',
              'character_image': 'assets/images/characters/scarlett/friendly.png',
              'dialogue': 'Welcome to Perdition Station. You\'re late, but you\'re here now.',
            },
            {
              'type': 'name_input',
              'bg': 'assets/images/prologue/dialogue.png',
              'character': 'scarlett',
              'character_image': 'assets/images/characters/scarlett/friendly.png',
              'dialogue': 'What should I call you, stranger?',
            },
            {
              'type': 'narration',
              'bg': 'assets/images/prologue/dialogue.png',
              'character': 'scarlett',
              'character_image': 'assets/images/characters/scarlett/beer.png',
              'text': 'Behind the station, the town of Perdition stretches out. Ten casinos await.',
            },
          ]);
          _calculateMaxDialogHeight();
        });
      }
    }
  }

  void _calculateMaxDialogHeight() {
    // Calculate approximate height for each scene individually
    for (int i = 0; i < _scenes.length; i++) {
      final scene = _scenes[i];
      double sceneHeight = 0;
      
      // Base padding (vertical)
      sceneHeight += 80; // 40 top + 40 bottom padding
      
      // Character name height if present
      final character = scene['character'] as String?;
      if (character != null) {
        sceneHeight += 20; // name height
        sceneHeight += 16; // spacing after name
      }
      
      // Text content height (rough estimate: 18px per line, ~50 chars per line)
      final text = scene['text'] as String? ?? scene['dialogue'] as String? ?? '';
      final estimatedLines = (text.length / 50).ceil();
      sceneHeight += estimatedLines * 27; // 18px font + 1.5 line height = ~27px per line
      
      // ALWAYS add space for buttons (they appear after typewriter finishes)
      // Choices height if present
      final choices = scene['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        sceneHeight += 24; // spacing before choices
        sceneHeight += choices.length * 72; // ~60px per choice button + 12px spacing
      }
      
      // Name input field if present
      final sceneType = scene['type'] as String?;
      if (sceneType == 'name_input') {
        sceneHeight += 24; // spacing before input
        sceneHeight += 60; // text field height
        sceneHeight += 16; // spacing after input
        sceneHeight += 60; // submit button height
      }
      // Note: Continue button is now floating outside, no need to add its height
      
      // Add some buffer
      _sceneHeights[i] = sceneHeight + 20;
      print('Scene $i calculated height: ${_sceneHeights[i]}');
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    _modalController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    // Cancel any existing timer
    _autoScrollTimer?.cancel();
    
    // Only start if not skipping animation
    if (_skipAnimation) return;
    
    // Start a periodic timer to scroll to bottom during animation
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Stop if animation was skipped or completed
      if (_skipAnimation || _showContinue || _showChoices) {
        timer.cancel();
        return;
      }
      
      // Scroll to bottom if there's content overflow
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _nextScene() {
    // Cancel auto-scroll before changing scenes
    _autoScrollTimer?.cancel();
    
    if (_currentScene < _scenes.length - 1) {
      setState(() {
        _currentScene++;
        _showText = false;
        _showContinue = false;
        _showChoices = false;
        _skipAnimation = false;
      });
      
      // Reset scroll position to top
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        // Start auto-scroll for new scene
        _startAutoScroll();
      });
      
      // Start fade animation for text
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _showText = true;
          });
        }
      });
    }
  }

  void _submitName(String name) {
    // Update game state with player name
    final gameNotifier = ref.read(gameStateProvider.notifier);
    final currentStats = ref.read(gameStateProvider).playerStats;
    gameNotifier.updatePlayerStats(currentStats.copyWith(name: name));

    // Continue to next scene (intro_3 - back of station)
    _nextScene();
  }
  
  void _finishPrologue() {
    // Save player name if entered
    final playerName = _nameController.text.trim();
    if (playerName.isNotEmpty) {
      final gameStateNotifier = ref.read(gameStateProvider.notifier);
      final currentStats = ref.read(gameStateProvider).playerStats;
      
      // Update player stats with name and mark prologue as completed
      final updatedFlags = Map<String, bool>.from(currentStats.specialFlags);
      updatedFlags['prologueCompleted'] = true;
      
      final updatedStats = currentStats.copyWith(
        name: playerName,
        specialFlags: updatedFlags,
      );
      
      gameStateNotifier.updatePlayerStats(updatedStats);
      
      // Save the game
      gameStateNotifier.saveGame();
    }
    
    // Navigate to map screen after prologue is complete
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if scenes are loaded
    if (_scenes.isEmpty || _currentScene >= _scenes.length) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    final currentSceneData = _scenes[_currentScene];
    final bg = currentSceneData['bg'] as String? ?? '';
    String? characterImage = currentSceneData['character_image'] as String?;
    
    // Get text and replace [PLAYER_NAME] with actual player name
    final gameState = ref.watch(gameStateProvider);
    final playerName = gameState.playerStats.name.isEmpty 
        ? 'Stranger' 
        : gameState.playerStats.name;
    
    String text = currentSceneData['text'] as String? ??
        currentSceneData['dialogue'] as String? ??
        '';
    
    // Replace [PLAYER_NAME] placeholder with actual player name
    text = text.replaceAll('[PLAYER_NAME]', playerName);
    
    final character = currentSceneData['character'] as String?;
    final characterEmotion = currentSceneData['character_emotion'] as String?;
    final sceneType = currentSceneData['type'] as String?;
    final isNameInput = sceneType == 'name_input';
    
    // Build character image path if emotion is specified
    if (character != null && characterEmotion != null && characterImage == null) {
      characterImage = 'assets/images/characters/$character/${character}_$characterEmotion.png';
    }

    // Debug output
    print('Scene $_currentScene - Character Image: $characterImage');
    print('Character: $character');
    print('Type: ${currentSceneData['type']}');

    return Scaffold(
      body: GestureDetector(
        // Click anywhere on screen to skip animation or continue
        onTap: () {
          // Skip if name input modal is showing - modal handles its own input
          if (isNameInput && (_showContinue || _skipAnimation)) {
            return;
          }
          
          // First click: Skip animation and show continue/input
          if (!_showContinue && !_showChoices) {
            _autoScrollTimer?.cancel();
            
            setState(() {
              _skipAnimation = true;
              _showContinue = true;
            });
            
            // If it's name input scene, trigger modal animation after a delay
            if (isNameInput) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _showModal = true;
                  });
                  _modalController.forward();
                }
              });
            }
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (_showContinue) {
            // Second click: Advance scene (but not on name input - modal handles that)
            if (isNameInput) {
              return;
            }
            
            // Check if last scene
            if (_currentScene >= _scenes.length - 1) {
              _finishPrologue();
            } else {
              _nextScene();
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Background image
          if (bg.isNotEmpty)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                bg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.red.shade900.withOpacity(0.3),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Character sprite BEFORE overlay (so it's visible)
          if (characterImage != null && characterImage.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  characterImage,
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.65,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Error loading character image: $characterImage');
                    print('Error: $error');
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

          // Dark overlay for text readability (only at top and bottom)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with leather background - FIXED HEIGHT
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 70, // Fixed height to prevent movement
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROLOGUE',
                        style: WesternTextStyles.characterName(
                          fontSize: 18,
                          color: const Color(0xFFF5E6D3),
                        ),
                      ),
                      // Continue button appears here after text finishes (not on name input)
                      // Using Opacity to keep space when hidden
                      Opacity(
                        opacity: (_showContinue && !isNameInput) ? 1.0 : 0.0,
                        child: GestureDetector(
                          onTap: (_showContinue && !isNameInput) ? () {
                            if (_currentScene < _scenes.length - 1) {
                              _nextScene();
                            } else {
                              // Last scene - go to map
                              _finishPrologue();
                            }
                          } : null,
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
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_forward,
                                    color: Color(0xFFF5E6D3), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'CONTINUE',
                                  style: WesternTextStyles.button(fontSize: 14).copyWith(
                                    color: const Color(0xFFF5E6D3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Text box at bottom
                if (_showText)
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
                      height: 150, // Fixed height for 3 rows of text
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Character name
                            if (character != null) ...[
                              Text(
                                character.toUpperCase(),
                                style: WesternTextStyles.characterName(
                                  fontSize: 16,
                                  color: const Color(0xFF1A0F08),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Text display - instant if skipped, animated if not
                            if (_skipAnimation)
                              // Show full text instantly
                              Text(
                                text,
                                style: (character != null
                                    ? WesternTextStyles.dialogue(fontSize: 19)
                                    : WesternTextStyles.narration(fontSize: 19))
                                    .copyWith(
                                      color: const Color(0xFF1A0F08),
                                      height: 1.5,
                                    ),
                              )
                            else
                              // Typewriter animated text
                              AnimatedTextKit(
                                key: _textKey,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    text,
                                    textStyle: (character != null
                                        ? WesternTextStyles.dialogue(fontSize: 19)
                                        : WesternTextStyles.narration(fontSize: 19))
                                        .copyWith(
                                          color: const Color(0xFF1A0F08),
                                          height: 1.5,
                                        ),
                                    speed: const Duration(milliseconds: 50),
                                  ),
                                ],
                                totalRepeatCount: 1,
                                displayFullTextOnTap: false, // We handle tap manually
                                pause: Duration.zero, // No pause after animation finishes
                                onFinished: () {
                                  if (mounted) {
                                    setState(() {
                                      _showContinue = true;
                                    });
                                    // Stop auto-scroll timer when animation finishes
                                    _autoScrollTimer?.cancel();
                                    
                                    // If it's name input scene, trigger modal animation after a delay
                                    if (isNameInput) {
                                      Future.delayed(const Duration(milliseconds: 300), () {
                                        if (mounted) {
                                          setState(() {
                                            _showModal = true;
                                          });
                                          _modalController.forward();
                                        }
                                      });
                                    }
                                  }
                                },
                              ),

                            // Continue button is now in header
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Centered name input modal (shows only for name_input scene)
          if (isNameInput && _showModal)
            AnimatedBuilder(
              animation: _modalController,
              builder: (context, child) {
                return Opacity(
                  opacity: _modalOpacityAnimation.value,
                  child: Container(
                    color: Colors.black.withOpacity(0.7 * _modalOpacityAnimation.value),
                    child: Center(
                      child: Transform.scale(
                        scale: _modalScaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(40),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'What\'s Your Name?',
                                style: WesternTextStyles.title(
                                  fontSize: 22,
                                  color: const Color(0xFF1A0F08),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _nameController,
                                autofocus: true,
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
                                  fillColor: const Color(0xFFF5E6D3).withOpacity(0.5),
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
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    _submitName(value.trim());
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  if (_nameController.text.trim().isNotEmpty) {
                                    _submitName(_nameController.text.trim());
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/utilities/buttons.png'),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'CONTINUE',
                                      style: WesternTextStyles.button(
                                        fontSize: 18,
                                        color: const Color(0xFFF5E6D3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ), // Stack
      ), // GestureDetector
    );
  }
}
