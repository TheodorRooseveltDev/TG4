import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../services/game_save_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Check for saved game and navigate after 2.5 seconds
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    // Check if there's a saved game
    final gameSaveService = GameSaveService.instance;
    final savedGame = await gameSaveService.loadGame();
    
    if (savedGame != null) {
      final prologueCompleted = savedGame.playerStats.specialFlags['prologueCompleted'] ?? false;
      
      if (prologueCompleted && savedGame.playerStats.name.isNotEmpty) {
        // Navigate to map if prologue is completed
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/map');
        }
        return;
      }
    }
    
    // Navigate to prologue for new game or incomplete prologue
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/prologue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/utilities/splash_screen.png',
            fit: BoxFit.cover,
          ),
          // Waving bullets loader at bottom center
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: WavingBulletsLoader(),
            ),
          ),
        ],
      ),
    );
  }
}

// Waving bullets loader widget
class WavingBulletsLoader extends StatefulWidget {
  const WavingBulletsLoader({super.key});

  @override
  State<WavingBulletsLoader> createState() => _WavingBulletsLoaderState();
}

class _WavingBulletsLoaderState extends State<WavingBulletsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Stagger the wave animation for each bullet
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay) % 1.0;
            
            // Create a smooth wave using sine
            final offset = sin(animationValue * 2 * pi) * 15;
            
            return Transform.translate(
              offset: Offset(0, offset),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Image.asset(
                  'assets/images/utilities/bullet.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
