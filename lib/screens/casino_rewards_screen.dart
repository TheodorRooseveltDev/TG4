import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/text_styles.dart';

class CasinoRewardsScreen extends ConsumerStatefulWidget {
  final String casinoName;
  final Map<String, int> rewards; // money, respect, sanity changes
  
  const CasinoRewardsScreen({
    super.key,
    required this.casinoName,
    required this.rewards,
  });

  @override
  ConsumerState<CasinoRewardsScreen> createState() => _CasinoRewardsScreenState();
}

class _CasinoRewardsScreenState extends ConsumerState<CasinoRewardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _rewardsController;
  late AnimationController _continueController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleScaleAnimation;
  
  late Animation<double> _rewardsSlideAnimation;
  late Animation<double> _rewardsFadeAnimation;
  
  late Animation<double> _continueSlideAnimation;
  late Animation<double> _continueFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    
    _titleScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    
    // Rewards animation
    _rewardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _rewardsSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _rewardsController, curve: Curves.easeOutBack),
    );
    
    _rewardsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rewardsController, curve: Curves.easeIn),
    );
    
    // Continue button animation
    _continueController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _continueSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _continueController, curve: Curves.easeOut),
    );
    
    _continueFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _continueController, curve: Curves.easeIn),
    );
    
    // Start animations in sequence
    _titleController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _rewardsController.forward();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        _continueController.forward();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rewardsController.dispose();
    _continueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/prologue/dialogue.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                children: [
                  // Title
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleFadeAnimation.value,
                        child: Transform.scale(
                          scale: _titleScaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'CASINO CONQUERED',
                                  style: WesternTextStyles.title(
                                    fontSize: 32,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.casinoName.toUpperCase(),
                                  style: WesternTextStyles.title(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Rewards list
                  AnimatedBuilder(
                    animation: _rewardsController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _rewardsFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _rewardsSlideAnimation.value),
                          child: Column(
                            children: [
                              if (widget.rewards['money'] != null && widget.rewards['money']! != 0)
                                _buildRewardItem(
                                  '💰',
                                  'MONEY',
                                  widget.rewards['money']!,
                                ),
                              if (widget.rewards['respect'] != null && widget.rewards['respect']! != 0)
                                _buildRewardItem(
                                  '⭐',
                                  'RESPECT',
                                  widget.rewards['respect']!,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Continue button
                  AnimatedBuilder(
                    animation: _continueController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _continueFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _continueSlideAnimation.value),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // Return to map
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/utilities/buttons.png'),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                'CONTINUE',
                                style: WesternTextStyles.dialogue(
                                  fontSize: 20,
                                  color: const Color(0xFFF5E6D3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(String icon, String label, int value) {
    final displayValue = value >= 0 ? '+$value' : '$value';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: WesternTextStyles.dialogue(
                    fontSize: 20,
                    color: const Color(0xFFF5E6D3),
                  ),
                ),
              ],
            ),
            Text(
              displayValue,
              style: WesternTextStyles.dialogue(
                fontSize: 22,
                color: const Color(0xFFF5E6D3),  // White/cream for readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
