import 'package:flutter/material.dart';
import 'package:word_sort/shared/button.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({
    Key? key,
    required this.handleCloseButton,
    required this.size,
    required this.color,
    required this.textColor,
    required this.textSize,
  }) : super(key: key);
  final void Function() handleCloseButton;
  final double size;
  final Color color;
  final Color textColor;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Button(
      child: Text(
        'x',
        style: TextStyle(fontSize: textSize, color: textColor),
      ),
      handleButtonPressed: handleCloseButton,
      width: size,
      height: size,
      color: color,
      borderRadius: size / 2,
    );
  }
}
