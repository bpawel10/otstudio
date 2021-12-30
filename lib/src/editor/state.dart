import 'package:flutter/material.dart';

class State extends StatelessWidget {
  final Offset offset;
  final Offset mouse;

  State({required this.offset, required this.mouse});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Offset: $offset'),
        Text('Mouse: $mouse'),
        Text('Together: ${offset + mouse}')
      ],
    );
  }
}
