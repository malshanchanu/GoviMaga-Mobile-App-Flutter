import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; 
import '../screens/ai_chat_screen.dart';

class FloatingRobo extends StatefulWidget {
  const FloatingRobo({super.key});

  @override
  State<FloatingRobo> createState() => _FloatingRoboState();
}

class _FloatingRoboState extends State<FloatingRobo> with SingleTickerProviderStateMixin {
  bool _showBubble = false;
  late AnimationController _floatController;
  Timer? _bubbleTimer;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() => _showBubble = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBubble = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // "Hello" Bubble
          AnimatedOpacity(
            opacity: _showBubble ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.only(bottom: 110, right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: const Text(
                "Hello! මම උදව් කරන්නද? 🤖",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 13),
              ),
            ),
          ),
          
          
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AIChatScreen(),
              );
            },
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatController.value * -15),
                  child: SizedBox( 
                    width: 110,
                    height: 110,
                    child: Lottie.asset(
                      'assets/animations/robot_wave.json',
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}