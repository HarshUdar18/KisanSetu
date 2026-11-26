import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating 3-item capsule bottom navigation bar matching the Kisan Setu
/// Minimal Green Navigation Bar design: Home | (+) | Categories.
class KisanFloatingNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const KisanFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  State<KisanFloatingNavBar> createState() => _KisanFloatingNavBarState();
}

class _KisanFloatingNavBarState extends State<KisanFloatingNavBar> {
  static const Color _deepGreen = Color(0xFF006B2E);
  static const Color _primaryGreen = Color(0xFF087A32);
  static const Color _freshGreen = Color(0xFF35B817);
  static const Color _orangeAccent = Color(0xFFF59E0B);

  bool _isAddPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Floating white capsule container
              Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: _deepGreen.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _deepGreen.withValues(alpha: 0.16),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavTabItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: widget.selectedIndex == 0,
                        onTap: () => widget.onTabSelected(0),
                      ),
                    ),
                    const SizedBox(width: 72),
                    Expanded(
                      child: _NavTabItem(
                        icon: Icons.grid_view_outlined,
                        label: 'Categories',
                        isSelected: widget.selectedIndex == 1,
                        onTap: () => widget.onTabSelected(1),
                      ),
                    ),
                  ],
                ),
              ),

              // Raised center circular (+) button with orange accent dashes
              Positioned(
                top: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -5,
                      left: -7,
                      child: CustomPaint(
                        size: const Size(20, 20),
                        painter: _OrangeAccentSparkPainter(color: _orangeAccent),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isAddPressed = true),
                      onTapUp: (_) {
                        setState(() => _isAddPressed = false);
                        widget.onAddPressed();
                      },
                      onTapCancel: () => setState(() => _isAddPressed = false),
                      child: AnimatedScale(
                        scale: _isAddPressed ? 0.93 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: Container(
                          width: 62,
                          height: 62,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _deepGreen.withValues(alpha: 0.24),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_freshGreen, _primaryGreen, _deepGreen],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _deepGreen = Color(0xFF006B2E);
  static const Color _freshGreen = Color(0xFF35B817);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [_freshGreen, _deepGreen],
                  )
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                  ? Row(
                      key: ValueKey('selected_$label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: ValueKey('unselected_$label'),
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: _deepGreen, size: 21),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _deepGreen,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrangeAccentSparkPainter extends CustomPainter {
  final Color color;

  const _OrangeAccentSparkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    // Two small tilted accent dashes matching the reference image
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.72),
      Offset(size.width * 0.02, size.height * 0.45),
      paint,
    );
    final angle = -math.pi / 12;
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.48),
      Offset(
        size.width * 0.58 + math.sin(angle) * 8,
        size.height * 0.48 - math.cos(angle) * 8,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrangeAccentSparkPainter oldDelegate) =>
      oldDelegate.color != color;
}
