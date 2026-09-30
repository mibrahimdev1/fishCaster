import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class globalSnack {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: CustomText(text: message, color: ClrCons.whiteColor),
      duration: Duration(seconds: 3),
      backgroundColor: const Color.fromARGB(255, 35, 53, 106),
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: CustomText(text: message, color: ClrCons.whiteColor),
      duration: Duration(seconds: 3),
      backgroundColor: const Color.fromARGB(255, 212, 22, 22),
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class TopSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = ClrCons.primaryColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder:
          (context) => _TopSnackBarWidget(
            message: message,
            backgroundColor: backgroundColor,
            onDismissed: () => entry?.remove(),
            duration: duration,
          ),
    );

    Overlay.of(context).insert(entry);
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    required this.onDismissed,
    required this.duration,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      _controller.reverse().then((value) => widget.onDismissed());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: CustomButtonTextField(
        isHeight: true,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: SlideTransition(
            position: _animation,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              color: widget.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  widget.message,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
