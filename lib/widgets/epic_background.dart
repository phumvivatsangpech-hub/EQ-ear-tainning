import 'package:flutter/material.dart';

class EpicBackground extends StatefulWidget {
  final Widget child;
  const EpicBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<EpicBackground> createState() => _EpicBackgroundState();
}

class _EpicBackgroundState extends State<EpicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF0F0C29), const Color(0xFF1E1366), _controller.value)!,
                Color.lerp(const Color(0xFF302B63), const Color(0xFF2A0845), _controller.value)!,
                const Color(0xFF24243E),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100 + (_controller.value * 50),
                left: -100 + (_controller.value * 30),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 120,
                        spreadRadius: 60,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -150 - (_controller.value * 50),
                right: -50 + (_controller.value * 40),
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan.withOpacity(0.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.12),
                        blurRadius: 120,
                        spreadRadius: 60,
                      )
                    ],
                  ),
                ),
              ),
              SafeArea(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}
