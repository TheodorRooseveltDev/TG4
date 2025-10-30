import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/game_providers.dart';
import '../styles/text_styles.dart';
import 'casino_rewards_screen.dart';

class CasinoScreen extends ConsumerStatefulWidget {
  final int casinoNumber;
  final String casinoName;

  const CasinoScreen({
    super.key,
    required this.casinoNumber,
    required this.casinoName,
  });

  @override
  ConsumerState<CasinoScreen> createState() => _CasinoScreenState();
}

class _CasinoScreenState extends ConsumerState<CasinoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _modalController;
  late Animation<double> _modalScaleAnimation;
  late Animation<double> _modalOpacityAnimation;
  bool _showContinue = false;
  bool _showChoices = false;
  bool _showModal = false; // Control modal animation
  bool _skipAnimation = false;
  int _currentSceneIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textKey = GlobalKey();
  Timer? _autoScrollTimer;

  // Casino scenes data
  final List<Map<String, dynamic>> _scenes = [];
  String _currentSceneId = '';
  
  // Track total rewards earned during casino
  final Map<String, int> _totalRewards = {
    'money': 0,
    'respect': 0,
    'sanity': 0,
    'truthLevel': 0,
  };

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

    // Load casino scenes
    _loadCasinoScenes();

    // Start first scene
    _fadeController.forward();
  }

  void _loadCasinoScenes() async {
    try {
      final gameData = ref.read(gameDataServiceProvider);
      final allData = await gameData.loadGameData();
      
      if (mounted) {
        setState(() {
          // Merge both parts of screens
          final screensPart1 = allData['screens_part1'] as Map<String, dynamic>? ?? {};
          final screensPart2 = allData['screens_part2'] as Map<String, dynamic>? ?? {};
          final screens = {...screensPart1, ...screensPart2};
          
          if (screens.isNotEmpty) {
            // Start from the appropriate scene for each casino
            if (widget.casinoNumber == 1) {
              _currentSceneId = 'scarlett_casino_1_intro';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 2) {
              _currentSceneId = 'sheriff_1';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 3) {
              _currentSceneId = 'casino_3_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 4) {
              _currentSceneId = 'casino_4_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 5) {
              _currentSceneId = 'casino_5_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 6) {
              _currentSceneId = 'casino_6_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 7) {
              _currentSceneId = 'casino_7_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 8) {
              _currentSceneId = 'casino_8_enter';
              _loadSceneById(_currentSceneId, screens);
            } else if (widget.casinoNumber == 9) {
              _currentSceneId = 'casino_9_enter';
              _loadSceneById(_currentSceneId, screens);
            }
          }
        });
        
        // Start animations after scenes are loaded
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _startAutoScroll();
          }
        });
      }
    } catch (e) {
      print('Error loading casino scenes: $e');
    }
  }

  void _loadSceneById(String sceneId, Map<String, dynamic> screens) {
    if (screens.containsKey(sceneId)) {
      final sceneData = screens[sceneId] as Map<String, dynamic>;
      final sceneType = sceneData['type'] as String?;
      
      // Handle system scenes immediately without displaying them
      if (sceneType == 'system') {
        final action = sceneData['action'] as String?;
        if (action == 'return_to_map') {
          final unlockCasino = sceneData['unlock'] as String?;
          if (unlockCasino != null) {
            print('Unlocking casino: $unlockCasino');
            ref.read(gameStateProvider.notifier).unlockCasino(unlockCasino);
          }
          // Mark current casino as completed
          print('Completing casino_${widget.casinoNumber}');
          ref.read(gameStateProvider.notifier).completeCasino('casino_${widget.casinoNumber}');
          _showRewardsAndReturn();
          return;
        } else if (action == 'game_over') {
          setState(() {
            _scenes.add(sceneData);
          });
          Future.delayed(Duration.zero, () => _handleGameOver(sceneData));
          return;
        }
      }
      
      // Handle respect_branch immediately without displaying
      if (sceneType == 'respect_branch') {
        _handleRespectBranch(sceneData);
        return;
      }
      
      // Add normal display scenes
      setState(() {
        _scenes.add(sceneData);
      });
    }
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

  @override
  void dispose() {
    _fadeController.dispose();
    _modalController.dispose();
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _showRewardsAndReturn() async {
    
    // Navigate to rewards screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CasinoRewardsScreen(
          casinoName: widget.casinoName,
          rewards: _totalRewards,
        ),
      ),
    );
    
    // After rewards screen is dismissed, return to map
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleScreenTap() {
    if (_showChoices) {
      // Don't allow skipping when choices are shown
      return;
    }

    final currentScene = _scenes[_currentSceneIndex];
    final choices = currentScene['choices'] as List<dynamic>?;

    if (!_skipAnimation) {
      // First tap: skip typewriter animation
      setState(() {
        _skipAnimation = true;
        _autoScrollTimer?.cancel();
        
        // Show choices if available, otherwise show continue
        if (choices != null && choices.isNotEmpty) {
          _showChoices = true;
        } else {
          _showContinue = true;
        }
      });
      
      // If choices are available, trigger modal animation after a delay
      if (choices != null && choices.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showModal = true;
            });
            _modalController.forward();
          }
        });
      }
    } else {
      // Second tap: advance to next scene (only if no choices)
      if (choices == null || choices.isEmpty) {
        _advanceToNextScene();
      }
    }
  }

  void _advanceToNextScene() {
    final currentScene = _scenes[_currentSceneIndex];
    final nextSceneId = currentScene['next'] as String?;
    final sceneType = currentScene['type'] as String?;
    
    // Handle game over scenes
    if (sceneType == 'game_over') {
      _handleGameOver(currentScene);
      return;
    }
    
    // Handle special system actions
    if (sceneType == 'system') {
      final action = currentScene['action'] as String?;
      if (action == 'return_to_map') {
        final unlockCasino = currentScene['unlock'] as String?;
        if (unlockCasino != null) {
          // Unlock the next casino in game state
          print('Unlocking casino: $unlockCasino');
          ref.read(gameStateProvider.notifier).unlockCasino(unlockCasino);
        }
        // Show rewards screen then return to map
        _showRewardsAndReturn();
        return;
      }
    }
    
    // Handle respect branch scenes
    if (sceneType == 'respect_branch') {
      _handleRespectBranch(currentScene);
      return;
    }
    
    if (nextSceneId != null) {
      // Load the next scene by ID
      _loadNextSceneFromId(nextSceneId);
    } else {
      // No more scenes, return to map
      Navigator.pop(context);
    }
  }

  void _handleRespectBranch(Map<String, dynamic> scene) {
    final branches = scene['branches'] as List<dynamic>?;
    if (branches == null) return;
    
    final gameState = ref.read(gameStateProvider);
    final currentRespect = gameState.playerStats.respect;
    
    // Find matching branch
    for (final branch in branches) {
      final condition = branch['condition'] as String;
      final nextScene = branch['next'] as String;
      
      // Parse condition (e.g., "respect < 10", "respect >= 30")
      if (_evaluateRespectCondition(condition, currentRespect)) {
        _loadNextSceneFromId(nextScene);
        return;
      }
    }
    
    // Fallback if no condition matches
    print('No respect branch matched for respect: $currentRespect');
  }
  
  bool _evaluateRespectCondition(String condition, int respect) {
    // Parse conditions like "respect < 10", "respect >= 30", "respect >= 10 && respect < 30"
    if (condition.contains('&&')) {
      final parts = condition.split('&&').map((s) => s.trim()).toList();
      return parts.every((part) => _evaluateSingleCondition(part, respect));
    }
    return _evaluateSingleCondition(condition, respect);
  }
  
  bool _evaluateSingleCondition(String condition, int respect) {
    if (condition.contains('>=')) {
      final value = int.parse(condition.split('>=')[1].trim());
      return respect >= value;
    } else if (condition.contains('<=')) {
      final value = int.parse(condition.split('<=')[1].trim());
      return respect <= value;
    } else if (condition.contains('<')) {
      final value = int.parse(condition.split('<')[1].trim());
      return respect < value;
    } else if (condition.contains('>')) {
      final value = int.parse(condition.split('>')[1].trim());
      return respect > value;
    }
    return false;
  }
  
  void _handleGameOver(Map<String, dynamic> scene) {
    final deathText = scene['text'] as String? ?? scene['message'] as String? ?? 'GAME OVER';
    final characterImage = scene['character_image'] as String?;
    final canRetry = scene['can_retry'] as bool? ?? true;
    
    // Show full-screen game over with character image
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Character image in background (killing.png)
              if (characterImage != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      characterImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading death image: $characterImage - $error');
                        return Container(color: Colors.black);
                      },
                    ),
                  ),
                ),
              
              // Death message overlay
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "YOU DIED" title
                      Text(
                        'YOU DIED',
                        style: WesternTextStyles.title(
                          fontSize: 32,
                          color: const Color(0xFF8B0000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Death description
                      Text(
                        deathText.replaceAll('[PLAYER_NAME]', ref.read(gameStateProvider).playerStats.name),
                        style: WesternTextStyles.dialogue(
                          fontSize: 16,
                          color: const Color(0xFF2C1810),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Restart button
                      if (canRetry)
                        GestureDetector(
                          onTap: () {
                            // Close dialog and return to map
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Close casino
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/utilities/buttons.png'),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'RETURN TO MAP',
                              style: WesternTextStyles.dialogue(
                                fontSize: 18,
                                color: const Color(0xFFF5E6D3),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadNextSceneFromId(String sceneId) async {
    // Cancel auto-scroll before changing scenes
    _autoScrollTimer?.cancel();
    
    print('Loading next scene by ID: $sceneId');
    
    try {
      final gameData = ref.read(gameDataServiceProvider);
      final allData = await gameData.loadGameData();
      
      // Merge both parts of screens
      final screensPart1 = allData['screens_part1'] as Map<String, dynamic>? ?? {};
      final screensPart2 = allData['screens_part2'] as Map<String, dynamic>? ?? {};
      final screens = {...screensPart1, ...screensPart2};
      
      print('Screens available: ${screens.keys.toList()}');
      print('Looking for scene: $sceneId');
      print('Scene exists: ${screens.containsKey(sceneId)}');
      
      if (screens.isNotEmpty && screens.containsKey(sceneId)) {
        final sceneData = screens[sceneId];
        final sceneType = sceneData['type'] as String?;
        print('Found scene data: $sceneType, next: ${sceneData['next']}');
        
        // Handle system scenes immediately without displaying
        if (sceneType == 'system') {
          final action = sceneData['action'] as String?;
          if (action == 'return_to_map') {
            final unlockCasino = sceneData['unlock'] as String?;
            if (unlockCasino != null) {
              // Unlock the next casino in game state
              print('Unlocking casino: $unlockCasino');
              ref.read(gameStateProvider.notifier).unlockCasino(unlockCasino);
            }
            // Mark current casino as completed
            print('Completing casino_${widget.casinoNumber}');
            ref.read(gameStateProvider.notifier).completeCasino('casino_${widget.casinoNumber}');
            // Show rewards screen then return to map
            _showRewardsAndReturn();
            return;
          }
        }
        
        // Handle game scenes - show placeholder then auto-advance to win
        if (sceneType == 'game') {
          print('Game scene detected - showing placeholder and auto-advancing to win scene');
          final winScene = sceneData['win'] as String?;
          
          // Add game scene placeholder to scenes list
          setState(() {
            _scenes.add(sceneData);
            _currentSceneIndex = _scenes.length - 1;
            _skipAnimation = false;
            _showContinue = false;
            _showChoices = false;
          });
          
          if (winScene != null) {
            // Apply buy-in cost
            final buyIn = sceneData['buy_in'] as int? ?? 0;
            if (buyIn > 0) {
              ref.read(gameStateProvider.notifier).applyChoice({'money': -buyIn});
            }
            // Auto-advance to win scene after showing game placeholder
            Future.delayed(const Duration(milliseconds: 1500), () {
              _loadSceneById(winScene, screens);
            });
          }
          return;
        }
        
        // Handle respect_branch immediately without displaying
        if (sceneType == 'respect_branch') {
          _handleRespectBranch(sceneData);
          return;
        }
        
        setState(() {
          _scenes.add(sceneData);
          _currentSceneIndex = _scenes.length - 1;
          _skipAnimation = false;
          _showContinue = false;
          _showChoices = false;
        });
        
        // Reset scroll position to top
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
          // Start auto-scroll for new scene
          _startAutoScroll();
        });
        
        _fadeController.reset();
        _fadeController.forward();
      } else {
        print('ERROR: Scene $sceneId not found in screens!');
      }
    } catch (e) {
      print('Error loading next scene: $e');
    }
  }

  void _handleChoice(Map<String, dynamic> choice) {
    // Reset modal animation
    _modalController.reset();
    setState(() {
      _showModal = false;
    });
    
    // Handle choice effects
    final effects = choice['effects'] as Map<String, dynamic>?;
    if (effects != null) {
      // Track rewards
      effects.forEach((key, value) {
        if (key == 'money' || key == 'respect' || key == 'sanity' || key == 'truthLevel') {
          _totalRewards[key] = (_totalRewards[key] ?? 0) + (value as int);
        }
      });
      
      ref.read(gameStateProvider.notifier).applyChoice(effects);
    }

    // Load next scene based on choice
    final nextSceneId = choice['next'] as String?;
    if (nextSceneId != null) {
      _loadNextSceneFromChoice(nextSceneId);
    }
  }

  Future<void> _loadNextSceneFromChoice(String sceneId) async {
    // Cancel auto-scroll before changing scenes
    _autoScrollTimer?.cancel();
    
    try {
      final gameData = ref.read(gameDataServiceProvider);
      final allData = await gameData.loadGameData();
      
      // Merge both parts of screens
      final screensPart1 = allData['screens_part1'] as Map<String, dynamic>? ?? {};
      final screensPart2 = allData['screens_part2'] as Map<String, dynamic>? ?? {};
      final screens = {...screensPart1, ...screensPart2};
      
      if (screens.isNotEmpty && screens.containsKey(sceneId)) {
        final sceneData = screens[sceneId];
        final sceneType = sceneData['type'] as String?;
        
        // Handle respect_branch scenes immediately without displaying
        if (sceneType == 'respect_branch') {
          _handleRespectBranch(sceneData);
          return;
        }
        
        // Handle system scenes immediately without displaying
        if (sceneType == 'system') {
          final action = sceneData['action'] as String?;
          if (action == 'return_to_map') {
            final unlockCasino = sceneData['unlock'] as String?;
            if (unlockCasino != null) {
              // Unlock the next casino in game state
              print('Unlocking casino: $unlockCasino');
              ref.read(gameStateProvider.notifier).unlockCasino(unlockCasino);
            }
            // Show rewards screen then return to map
            Navigator.pop(context);
            return;
          }
        }
        
        setState(() {
          _scenes.add(sceneData);
          _currentSceneIndex = _scenes.length - 1;
          _skipAnimation = false;
          _showContinue = false;
          _showChoices = false;
        });
        
        // Reset scroll position to top
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
          // Start auto-scroll for new scene
          _startAutoScroll();
        });
        
        _fadeController.reset();
        _fadeController.forward();
      }
    } catch (e) {
      print('Error loading next scene: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scenes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentScene = _scenes[_currentSceneIndex];
    final sceneType = currentScene['type'] as String? ?? 'narration';
    final background = currentScene['bg'] as String? ?? 'assets/images/prologue/dialogue.png';
    final character = currentScene['character'] as String?;
    final characterImage = currentScene['character_image'] as String?;
    final text = currentScene['text'] as String? ?? currentScene['dialogue'] as String? ?? '';
    final narration = currentScene['narration'] as String?;
    final choices = currentScene['choices'] as List<dynamic>?;
    final gameState = ref.watch(gameStateProvider);
    final playerName = gameState.playerStats.name.isNotEmpty 
        ? gameState.playerStats.name 
        : 'Stranger';

    // Debug: Print current scene info
    print('Current scene: ${_currentSceneIndex}, Type: $sceneType, Character: $character, Image: $characterImage');

    // Handle game scenes - show special game text
    String displayText;
    String? displayNarration;
    String fullText;
    
    if (sceneType == 'game') {
      final special = currentScene['special'] as String? ?? '';
      final buyIn = currentScene['buy_in'] as int? ?? 0;
      displayText = '🎰 POKER GAME 🎰';
      displayNarration = '$special\n\nBuy-in: \$$buyIn\n\nThe game plays automatically...';
      fullText = '$displayText\n\n$displayNarration';
    } else {
      // Replace player name placeholder
      displayText = text.replaceAll('[PLAYER_NAME]', playerName);
      displayNarration = narration?.replaceAll('[PLAYER_NAME]', playerName);
      
      // Combine text and narration for special_scene type
      fullText = sceneType == 'special_scene' && displayNarration != null
          ? '$displayText\n\n$displayNarration'
          : displayText;
    }
    
    // Debug full text
    print('Text: "$text"');
    print('Narration: "$narration"');
    print('Full text to display: "$fullText"');

    return Scaffold(
      body: GestureDetector(
        onTap: _handleScreenTap,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                background,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2C1810),
                  );
                },
              ),
            ),

            // Character image (bottom-right, different positions for each casino)
            if (characterImage != null)
              Positioned(
                bottom: 0,
                right: widget.casinoNumber == 2 ? -5 : 20, // Casino 2: 25px more left (20 - 25 = -5)
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    characterImage,
                    height: MediaQuery.of(context).size.height * 0.7,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $characterImage - $error');
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Dialog box (fixed 150px height, bottom-anchored)
            Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Character name (if dialogue)
                      if (character != null) ...[
                        Text(
                          character.toUpperCase(),
                          style: WesternTextStyles.button(
                            fontSize: 14,
                            color: const Color(0xFF8B6F47),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Text content with typewriter effect
                      if (!_skipAnimation)
                        AnimatedTextKit(
                          key: _textKey,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              fullText,
                              textStyle: WesternTextStyles.dialogue(
                                fontSize: 16,
                                color: const Color(0xFF1A0F08),
                              ),
                              speed: const Duration(milliseconds: 30),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: false,
                          onFinished: () {
                            if (mounted) {
                              setState(() {
                                _skipAnimation = true;
                                _autoScrollTimer?.cancel();
                                
                                // Show choices if available, otherwise show continue
                                if (choices != null && choices.isNotEmpty) {
                                  _showChoices = true;
                                } else {
                                  _showContinue = true;
                                }
                              });
                            }
                          },
                        )
                      else
                        Text(
                          fullText,
                          style: WesternTextStyles.dialogue(
                            fontSize: 16,
                            color: const Color(0xFF1A0F08),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Continue button (top-right, only if no choices)
            if (_showContinue && !_showChoices && choices == null)
              Positioned(
                top: 60,
                right: 32,
                child: Opacity(
                  opacity: _showContinue ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: _showContinue ? () {
                      _advanceToNextScene();
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
              ),

            // Choices modal (centered overlay)
            if (_showChoices && _showModal && choices != null && choices.isNotEmpty)
              _buildChoicesModal(choices),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesModal(List<dynamic> choices) {
    return AnimatedBuilder(
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
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(40),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(12),
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
                      // Title
                      Text(
                        'WHAT DO YOU SAY?',
                        style: WesternTextStyles.title(
                          fontSize: 20,
                          color: const Color(0xFF1A0F08),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Choice buttons
                      ...choices.asMap().entries.map((entry) {
                        final choice = entry.value as Map<String, dynamic>;
                        final choiceText = choice['text'] as String? ?? '';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => _handleChoice(choice),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
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
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                choiceText,
                                style: WesternTextStyles.dialogue(
                                  fontSize: 15,
                                  color: const Color(0xFFF5E6D3),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
