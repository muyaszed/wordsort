import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text("WORDSORT",
            style: TextStyle(
              color: Color(0xffffffff),
              fontSize: 24,
            )),
      ],
    );
  }
}
