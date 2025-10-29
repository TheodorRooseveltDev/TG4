import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/text_styles.dart';
import '../providers/game_providers.dart';
import '../services/game_save_service.dart';
import 'settings_screen.dart';
import 'casino_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _selectedCasino;
  Offset? _modalPosition;
  bool _showLockedMessage = false;
  
  // Locked message animations
  late AnimationController _messageController;
  late Animation<double> _messageSlideAnimation;
  late Animation<double> _messageOpacityAnimation;
  late Animation<double> _messageScaleAnimation;
  late Animation<double> _messageDismissAnimation;
  
  // Casino modal animations
  AnimationController? _modalController;
  Animation<double>? _modalScaleAnimation;
  Animation<double>? _modalOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Load saved game on startup to restore progress after hot restart
    _loadSavedGame();
    
    // Initialize locked message animations
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _messageSlideAnimation = Tween<double>(
      begin: 1.0,  // Start from bottom (below center)
      end: 0.0,    // End at center
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut), // Faster appear
    ));
    
    _messageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn), // Faster fade in
    ));
    
    _messageScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
    ));
    
    // Separate animation for dismissing (center to top)
    // Starts at 0.7 (after holding at center from 0.25 to 0.7)
    _messageDismissAnimation = Tween<double>(
      begin: 0.0,  // At center
      end: -1.0,   // Go up to top
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn), // Dismiss phase
    ));
    
    _messageController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation finished, hide the message
        if (mounted) {
          setState(() {
            _showLockedMessage = false;
          });
          _messageController.reset();
        }
      }
    });
    
    // Initialize casino modal animations
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _modalScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController!,
      curve: Curves.elasticOut,
    ));
    
    _modalOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController!,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _modalController?.dispose();
    super.dispose();
  }

  Future<void> _loadSavedGame() async {
    final savedGame = await GameSaveService.instance.loadGame(fromAutoSave: true);
    if (savedGame != null && mounted) {
      // Restore the saved game state
      ref.read(gameStateProvider.notifier).loadGame(savedGame);
      print('Loaded saved game: Money: ${savedGame.playerStats.money}, Respect: ${savedGame.playerStats.respect}, Completed: ${savedGame.completedCasinos}');
    }
  }

  void _showLockedCasinoMessage() {
    setState(() {
      _showLockedMessage = true;
    });
    _messageController.forward();
  }

  void _closeModal() {
    // Animate modal closing
    _modalController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedCasino = null;
          _modalPosition = null;
        });
      }
    });
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main map content
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/utilities/map.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              // Dark overlay for readability
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(gameState),
                    
                    // Map content - Serpentine path
                    Expanded(
                      child: SingleChildScrollView(
                        reverse: true, // Start from bottom
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: _buildSerpentinePath(gameState),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Modal overlay
          if (_selectedCasino != null && _modalPosition != null)
            _buildCasinoModal(),
          
          // Locked casino message
          if (_showLockedMessage)
            _buildLockedMessage(),
          
          // Settings button (bottom-right corner)
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: _showSettings,
              child: Container(
                width: 50,
                height: 50,
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
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFFF5E6D3),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(gameState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gameState.playerStats.name.isNotEmpty)
                Text(
                  gameState.playerStats.name,
                  style: WesternTextStyles.dialogue(
                    fontSize: 18,
                    color: const Color(0xFFF5E6D3),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              _buildStatBadge('💰', '\$${gameState.playerStats.money}'),
              const SizedBox(width: 12),
              _buildStatBadge('⭐', '${gameState.playerStats.respect}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            value,
            style: WesternTextStyles.button(
              fontSize: 14,
              color: const Color(0xFFF5E6D3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerpentinePath(gameState) {
    final unlockedCasinos = ref.watch(gameStateProvider).unlockedCasinos;
    
    // Completely new approach - define absolute positions for each casino like Candy Crush
    // Reverse order: 10 at top, 1 at bottom
    // DRAMATIC X movement (0.1-0.7), tight Y spacing
    final casinoData = [
      // Casino 10 - TOP - Far RIGHT
      {'number': 10, 'name': 'The Pharaoh\'s Palace', 'boss': 'Aldrich & Marcus', 'locked': !unlockedCasinos.contains('casino_10'), 'x': 0.65, 'y': 50.0},
      // Casino 9 - SWING to FAR LEFT (dramatic!)
      {'number': 9, 'name': 'The Midnight Oil', 'boss': 'The Professor', 'locked': !unlockedCasinos.contains('casino_9'), 'x': 0.15, 'y': 160.0},
      // Casino 8 - SWING to FAR RIGHT (huge curve!)
      {'number': 8, 'name': 'The Crystal Crown', 'boss': 'The Baron', 'locked': !unlockedCasinos.contains('casino_8'), 'x': 0.70, 'y': 300.0},
      // Casino 7 - Back to LEFT side
      {'number': 7, 'name': 'The Velvet Room', 'boss': 'Delilah Rose', 'locked': !unlockedCasinos.contains('casino_7'), 'x': 0.20, 'y': 410.0},
      // Casino 6 - Swing RIGHT
      {'number': 6, 'name': 'The Iron Horse', 'boss': 'Cornelius', 'locked': !unlockedCasinos.contains('casino_6'), 'x': 0.60, 'y': 520.0},
      // Casino 5 - SWING to FAR LEFT
      {'number': 5, 'name': 'The Jade Dragon', 'boss': 'Scarlett', 'locked': !unlockedCasinos.contains('casino_5'), 'x': 0.10, 'y': 660.0},
      // Casino 4 - SWING to FAR RIGHT (massive curve!)
      {'number': 4, 'name': 'The Golden Nugget', 'boss': 'Ling', 'locked': !unlockedCasinos.contains('casino_4'), 'x': 0.68, 'y': 820.0},
      // Casino 3 - Swing back to LEFT
      {'number': 3, 'name': 'The Silver Saddle', 'boss': 'McCalister', 'locked': !unlockedCasinos.contains('casino_3'), 'x': 0.25, 'y': 930.0},
      // Casino 2 - Swing to RIGHT
      {'number': 2, 'name': 'The Broken Spoke', 'boss': 'Mary Crow Feather', 'locked': !unlockedCasinos.contains('casino_2'), 'x': 0.55, 'y': 1040.0},
      // Casino 1 - BOTTOM - Center-left
      {'number': 1, 'name': 'The Dusty Dollar', 'boss': 'Old Moses', 'locked': !unlockedCasinos.contains('casino_1'), 'x': 0.30, 'y': 1150.0},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SizedBox(
          height: 1300, // Compact beautiful map
          child: Stack(
            children: [
              // Draw all connecting paths FIRST (underneath icons)
              CustomPaint(
                size: const Size(double.infinity, 1300),
                painter: CandyCrushPathPainter(casinos: casinoData),
              ),
              // Then place all casino icons on top
              ...casinoData.map((casino) => _buildCasinoIcon(
                casino['number'] as int,
                casino['name'] as String,
                casino['boss'] as String,
                casino['locked'] as bool,
                casino['x'] as double,
                casino['y'] as double,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasinoIcon(int number, String name, String boss, bool locked, double xPercent, double yPos) {
    const iconSize = 100.0;
    final completedCasinos = ref.watch(gameStateProvider).completedCasinos;
    final isCompleted = completedCasinos.contains('casino_$number');
    
    return Builder(
      builder: (context) {
        // Get screen width
        final screenWidth = MediaQuery.of(context).size.width - 32; // Minus padding
        final xPos = (screenWidth * xPercent) - (iconSize / 2);
        
        return Positioned(
          left: xPos + 16, // Add back left padding
          top: yPos,
          child: SizedBox(
            width: iconSize,
            child: GestureDetector(
              onTap: () {
                if (locked) {
                  // Show locked message
                  _showLockedCasinoMessage();
                } else {
                  print('Casino $number clicked! Name: $name');
                  
                  // Get the global position of this widget
                  final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final globalPosition = renderBox.localToGlobal(Offset.zero);
                    
                    setState(() {
                      _selectedCasino = {
                        'number': number,
                        'name': name,
                        'boss': boss,
                        'locked': locked,
                      };
                      // Use global coordinates for modal positioning
                      _modalPosition = Offset(
                        globalPosition.dx + (iconSize / 2),  // Center of icon
                        globalPosition.dy,  // Top of icon
                      );
                      print('Modal position set to: $_modalPosition');
                      print('Selected casino: $_selectedCasino');
                    });
                    
                    // Trigger modal entrance animation
                    _modalController?.reset();
                    _modalController?.forward();
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Casino icon
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      boxShadow: locked ? null : [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withOpacity(0.7),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/utilities/casino_icon.png',
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.contain,
                        ),
                        Center(
                          child: locked
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.lock,
                                    size: 36,
                                    color: Colors.grey.shade300,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Completed checkmark
                        if (isCompleted)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Image.asset(
                              'assets/images/utilities/completed.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Casino name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/utilities/buttons.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      name,
                      style: WesternTextStyles.button(
                        fontSize: 8,
                        color: locked ? Colors.grey.shade600 : const Color(0xFFF5E6D3),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCasinoModal() {
    print('_buildCasinoModal called. Selected: $_selectedCasino, Position: $_modalPosition');
    
    if (_selectedCasino == null || _modalPosition == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final casinoName = _selectedCasino!['name'] as String;
    final casinoNumber = _selectedCasino!['number'] as int;
    
    // Bigger modal - speech bubble style
    final modalWidth = 260.0;
    final modalHeight = 140.0;
    final arrowHeight = 20.0;
    
    // Position modal above the casino icon
    double left = _modalPosition!.dx - (modalWidth / 2);
    double top = _modalPosition!.dy - modalHeight - arrowHeight - 10;
    
    // Keep modal on screen
    if (left < 20) left = 20;
    if (left + modalWidth > screenSize.width - 20) {
      left = screenSize.width - modalWidth - 20;
    }
    if (top < 100) top = 100; // Below header
    
    // Calculate arrow position relative to modal
    double arrowLeft = _modalPosition!.dx - left - 10;
    arrowLeft = arrowLeft.clamp(20.0, modalWidth - 40.0);
    
    return GestureDetector(
      onTap: () {
        // Close modal when tapping outside
        _closeModal();
      },
      child: Container(
        color: Colors.transparent, // Transparent overlay to capture taps
        child: AnimatedBuilder(
          animation: _modalController ?? const AlwaysStoppedAnimation(0),
          builder: (context, child) {
            return Opacity(
              opacity: _modalOpacityAnimation?.value ?? 1.0,
              child: Transform.scale(
                scale: _modalScaleAnimation?.value ?? 1.0,
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // Modal bubble
              Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping modal
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main modal content
                  Container(
                    width: modalWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Casino name only (centered)
                        Text(
                          casinoName,
                          style: WesternTextStyles.title(
                            fontSize: 20,
                            color: const Color(0xFF1A0F08),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        
                        // Start button
                        GestureDetector(
                          onTap: () {
                            print('Starting casino $casinoNumber: $casinoName');
                            _closeModal();
                            // Navigate to casino screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CasinoScreen(
                                  casinoNumber: casinoNumber,
                                  casinoName: casinoName,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 10,
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
                              'START',
                              style: WesternTextStyles.button(
                                fontSize: 16,
                                color: const Color(0xFFF5E6D3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow pointing down to casino
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: casinoNumber == 4 ? 85.0 : 0.0, // Move arrow 85px right for Casino 4
                      right: casinoNumber == 5 ? 105.0 : 0.0, // Move arrow 105px left for Casino 5
                    ),
                    child: CustomPaint(
                      size: Size(30, arrowHeight),
                      painter: TrianglePainter(
                        color: const Color(0xFFF5E6D3),
                        borderColor: const Color(0xFF8B6F47),
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

  Widget _buildLockedMessage() {
    return AnimatedBuilder(
      animation: _messageController,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Two-phase animation:
        // Phase 1 (0.0-0.25): Slide from bottom to center
        // Phase 2 (0.25-0.7): Hold at center (delay for reading)
        // Phase 3 (0.7-1.0): Slide from center to top
        final slideValue = _messageSlideAnimation.value + _messageDismissAnimation.value;
        final yPosition = screenHeight * 0.5 - 60 + (screenHeight * 0.35 * slideValue);
        
        // Fade out during dismiss phase (starts at 0.7)
        final dismissProgress = _messageController.value >= 0.7 
            ? 1.0 - ((_messageController.value - 0.7) / 0.3)
            : 1.0;
        final opacity = (_messageOpacityAnimation.value * dismissProgress).clamp(0.0, 1.0);
        
        return Positioned(
          left: 0,
          right: 0,
          top: yPosition,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: _messageScaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32), // Reduced margin for wider modal
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/utilities/dialogs_bg.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decorative element - western style divider
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6F47),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Message text with more padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18), // Increased from 8 to 18
                        child: Text(
                          'Complete the previous level\nto unlock this casino',
                          style: WesternTextStyles.dialogue(
                            fontSize: 17,
                            color: const Color(0xFF1A0F08),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Bottom decorative element
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6F47),
                          borderRadius: BorderRadius.circular(2),
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
    );
  }
}

// COMPLETELY NEW Candy Crush style path painter
class CandyCrushPathPainter extends CustomPainter {
  final List<Map<String, dynamic>> casinos;

  CandyCrushPathPainter({required this.casinos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.9)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw path from casino 10 (top) to casino 1 (bottom)
    // Reverse iterate since casinos list is 10->1
    for (int i = 0; i < casinos.length - 1; i++) {
      final current = casinos[i];
      final next = casinos[i + 1];
      
      final startX = size.width * (current['x'] as double);
      final startY = (current['y'] as double) + 50; // Center of icon (100px icon)
      
      final endX = size.width * (next['x'] as double);
      final endY = (next['y'] as double) + 50;
      
      _drawBeautifulCurve(canvas, paint, startX, startY, endX, endY, size.width);
    }
  }

  void _drawBeautifulCurve(Canvas canvas, Paint paint, double startX, double startY, double endX, double endY, double canvasWidth) {
    final path = Path();
    path.moveTo(startX, startY);
    
    final deltaX = endX - startX;
    final deltaY = endY - startY;
    final distance = deltaX.abs();
    
    // Create organic, flowing curves with multiple control points like Candy Crush
    // Add MORE dramatic loops when distance is big
    
    if (deltaY > 200) {
      // VERY FAR APART vertically - add EXTRA DRAMATIC LOOP
      final midY = startY + deltaY * 0.5;
      
      // First arc - swoop out WAY to the side
      final arc1ControlX = startX + deltaX * 0.2;
      final arc1ControlY = startY + deltaY * 0.2;
      final arc1EndX = startX + deltaX * 0.35;
      final arc1EndY = startY + deltaY * 0.35;
      
      path.quadraticBezierTo(arc1ControlX, arc1ControlY, arc1EndX, arc1EndY);
      
      // MEGA LOOP - swoop WAY out creating a big beautiful loop
      final loopDirection = deltaX > 0 ? 1 : -1;
      final loopControlX = arc1EndX + loopDirection * canvasWidth * 0.25; // BIG loop
      final loopControlY = midY - 50;
      final loopEndX = startX + deltaX * 0.65;
      final loopEndY = startY + deltaY * 0.6;
      
      path.quadraticBezierTo(loopControlX, loopControlY, loopEndX, loopEndY);
      
      // Final S-curve to destination
      final finalControlX = endX - deltaX * 0.25;
      final finalControlY = endY - deltaY * 0.25;
      
      path.quadraticBezierTo(finalControlX, finalControlY, endX, endY);
      
    } else if (distance > canvasWidth * 0.3) {
      // LARGE horizontal movement - create a LOOP with multiple curves
      final midY = startY + deltaY * 0.5;
      
      // First arc - swoop out dramatically
      final arc1ControlX = startX + deltaX * 0.25;
      final arc1ControlY = startY + deltaY * 0.15;
      final arc1EndX = startX + deltaX * 0.4;
      final arc1EndY = midY - 30;
      
      path.quadraticBezierTo(arc1ControlX, arc1ControlY, arc1EndX, arc1EndY);
      
      // Create a LOOP - swoop out to the side
      final loopDirection = deltaX > 0 ? 1 : -1;
      final loopControlX = arc1EndX + loopDirection * distance * 0.35;
      final loopControlY = midY;
      final loopEndX = startX + deltaX * 0.6;
      final loopEndY = midY + 30;
      
      path.quadraticBezierTo(loopControlX, loopControlY, loopEndX, loopEndY);
      
      // Final curve to destination
      final finalControlX = endX - deltaX * 0.2;
      final finalControlY = endY - deltaY * 0.2;
      
      path.quadraticBezierTo(finalControlX, finalControlY, endX, endY);
      
    } else if (distance > canvasWidth * 0.15 || deltaY > 140) {
      // MEDIUM distance - smooth S-curve
      final controlX1 = startX + deltaX * 0.4;
      final controlY1 = startY + deltaY * 0.3;
      
      final controlX2 = endX - deltaX * 0.3;
      final controlY2 = endY - deltaY * 0.3;
      
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
      
    } else {
      // SMALL distance - gentle flowing wave (casinos close together)
      final controlX1 = startX + deltaX * 0.35;
      final controlY1 = startY + deltaY * 0.35;
      
      final controlX2 = endX - deltaX * 0.35;
      final controlY2 = endY - deltaY * 0.35;
      
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
    }
    
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 20.0;
    const dashSpace = 15.0;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CandyCrushPathPainter oldDelegate) => false;
}
// Triangle painter for speech bubble arrow
class TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  TrianglePainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw border triangle first (slightly larger)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final borderPath = Path();
    borderPath.moveTo(size.width / 2, size.height); // Bottom point
    borderPath.lineTo(0, 0); // Top left
    borderPath.lineTo(size.width, 0); // Top right
    borderPath.close();

    canvas.drawPath(borderPath, borderPaint);

    // Draw inner triangle (slightly smaller to show border)
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height - 3); // Bottom point (slightly up)
    path.lineTo(2, 0); // Top left (slightly in)
    path.lineTo(size.width - 2, 0); // Top right (slightly in)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}
