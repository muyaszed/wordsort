import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.child,
    required this.handleButtonPressed,
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius,
    this.textColor,
  }) : super(key: key);
  final Widget child;
  final void Function() handleButtonPressed;
  final double width;
  final double height;
  final Color color;
  final Color? textColor;
  final double? borderRadius;

  renderChild() {
    if (child is Text) {
      var currentChild = child as Text;
      var data = currentChild.data;
      if (data != null) {
        data = data.toUpperCase();

        return Text(
          data,
          style: currentChild.style,
        );
      }

      return const Text('');
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 0))),
            onPressed: handleButtonPressed,
            child: renderChild()),
      ),
    );
  }
}
