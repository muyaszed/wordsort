import 'package:flutter/material.dart';

class FullScreenOverlay extends StatelessWidget {
  const FullScreenOverlay({
    Key? key,
    required this.backgroundColor,
    required this.child,
  }) : super(key: key);

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: backgroundColor,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
