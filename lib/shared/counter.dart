import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  const Counter({
    Key? key,
    required this.title,
    required this.showCounter,
    required this.counterItem,
  }) : super(key: key);
  final String title;
  final bool showCounter;
  final String counterItem;

  @override
  Widget build(BuildContext context) {
    return showCounter
        ? Column(
            children: [
              Text(title.toUpperCase(),
                  style:
                      const TextStyle(color: Color(0xffffffff), fontSize: 22)),
              Container(
                width: 80,
                height: 80,
                // margin: const EdgeInsets.only(left: 35, right: 35),
                alignment: Alignment.center,
                child: Text(
                  counterItem.toUpperCase(),
                  style: const TextStyle(fontSize: 26),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xffffffff),
                ),
              )
            ],
          )
        : const SizedBox();
  }
}
