import 'package:fish_caster/core/image_cons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FastGifWidget extends StatefulWidget {
  final double size;
  FastGifWidget({super.key, this.size = 50});

  @override
  State<FastGifWidget> createState() => _FastGifWidgetState();
}

class _FastGifWidgetState extends State<FastGifWidget>
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
    return RotationTransition(
      // turns: _controller,
      turns: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.linear, // smooth constant speed
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImgCons.loader),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
