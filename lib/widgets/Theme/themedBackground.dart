import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: SizeCons.getHeight(context),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF00182E), Color(0xFF010B40)],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImgCons.loginBottomLeft),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: SizeCons.getHeight(context),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImgCons.loginCenter),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImgCons.loginBottomRight),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          // Inject your screen content here
          child,
        ],
      ),
    );
  }
}
