import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/choice.dart';
import '../providers/game_providers.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showChoices = false;
  bool _textComplete = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
    
    // Show choices after text animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _textComplete = true;
          _showChoices = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = ref.watch(currentSceneProvider);
    final gameState = ref.watch(gameStateProvider);
    final audioService = ref.watch(audioServiceProvider);

    if (scene == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Play music if specified
    if (scene.music != null) {
      audioService.playMusic('music/${scene.music}');
    }

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header with location and stats
              _buildHeader(scene, gameState),
              
              // Main story content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location
                      if (scene.location != null) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            scene.location!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade300,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Date
                      if (scene.date != null) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            scene.date!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Narration with typing effect
                      if (scene.narration != null) ...[
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              scene.narration!,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                height: 1.6,
                              ),
                              speed: const Duration(milliseconds: 50),
                            ),
                          ],
                          totalRepeatCount: 1,
                          onFinished: () {
                            setState(() => _textComplete = true);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Description
                      if (scene.description != null && _textComplete) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            scene.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade300,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      
                      // Scarlett appears
                      if (scene.scarlettAppears != null && _textComplete) ...[
                        _buildScarlettAppearance(scene.scarlettAppears!),
                        const SizedBox(height: 24),
                      ],
                      
                      // Scarlett dialogue
                      if (scene.scarlettDialogue != null && _textComplete) ...[
                        _buildDialogue('Scarlett', scene.scarlettDialogue!),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Choices
              if (_showChoices && scene.choices != null)
                _buildChoices(scene.choices!, gameState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(scene, gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loop ${gameState.currentLoop}',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (gameState.playerStats.name.isNotEmpty)
                Text(
                  gameState.playerStats.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              _buildStatBadge('💰', '\$${gameState.playerStats.money}'),
              const SizedBox(width: 12),
              _buildStatBadge('⭐', '${gameState.playerStats.respect}'),
              const SizedBox(width: 12),
              _buildStatBadge('🧠', '${gameState.playerStats.sanity}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade900, width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScarlettAppearance(Map<String, dynamic> scarlettData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade700, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade900,
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'SCARLETT APPEARS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scarlettData['description'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogue(String speaker, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade900, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            speaker.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade300,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoices(List<Choice> choices, gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: choices.map((choice) {
          final canSelect = choice.canSelect(gameState.playerStats);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceButton(choice, canSelect),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChoiceButton(Choice choice, bool canSelect) {
    return Opacity(
      opacity: canSelect ? 1.0 : 0.5,
      child: InkWell(
        onTap: canSelect ? () => _handleChoice(choice) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canSelect ? Colors.red.shade700 : Colors.grey.shade800,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  choice.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: canSelect ? Colors.white : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
              if (choice.respect != null || choice.truth != null) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (choice.respect != null)
                      Text(
                        '⭐ ${choice.respect! > 0 ? '+' : ''}${choice.respect}',
                        style: TextStyle(
                          fontSize: 12,
                          color: choice.respect! > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    if (choice.truth != null)
                      Text(
                        '👁 +${choice.truth}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleChoice(Choice choice) {
    final audioService = ref.read(audioServiceProvider);
    audioService.playSfx('choice');

    // Apply choice effects
    final effects = choice.toJson();
    ref.read(gameStateProvider.notifier).applyChoice(effects);

    // Show response if available
    if (choice.response != null) {
      _showChoiceResponse(choice.response!);
    }

    // Handle special events
    if (choice.specialEvent != null) {
      _handleSpecialEvent(choice.specialEvent!);
    }

    // Auto-continue to next scene or show result
    Future.delayed(const Duration(seconds: 2), () {
      _proceedToNextScene(choice);
    });
  }

  void _showChoiceResponse(String response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogue('Scarlett', response),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSpecialEvent(Map<String, dynamic> event) {
    // Handle special events like sanity loss, revelations, etc.
    if (event['sanity'] != null) {
      final gameNotifier = ref.read(gameStateProvider.notifier);
      final currentStats = ref.read(gameStateProvider).playerStats;
      gameNotifier.updatePlayerStats(
        currentStats.copyWith(sanity: currentStats.sanity + (event['sanity'] as int)),
      );
    }
  }

  void _proceedToNextScene(Choice choice) {
    // Determine next scene based on choice
    String? nextScene;
    
    if (choice.effect == 'break_time') {
      nextScene = 'intro_2'; // Example
    } else {
      // Default progression logic
      final currentScene = ref.read(currentSceneProvider);
      if (currentScene?.autoContinue != null) {
        nextScene = currentScene!.autoContinue;
      }
    }

    if (nextScene != null) {
      ref.read(gameStateProvider.notifier).updateScene(nextScene);
    }
  }
}
