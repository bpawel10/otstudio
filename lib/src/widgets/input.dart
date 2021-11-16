import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String label;
  final String value;
  final dynamic onChanged;

  Input({this.label, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 5, 2),
            child: Text(label ?? '', style: TextStyle(fontSize: 11))),
        Expanded(
            child: TextFormField(
          decoration: InputDecoration(
            // floatingLabelBehavior: FloatingLabelBehavior.never,
            // floatingLabelStyle: TextStyle(pos
            // label: Text(label),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5)),
            isDense: true,
            contentPadding:
                EdgeInsets.fromLTRB(6, 6, 6, 6), // EdgeInsets.all(6),
          ),
          style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
          initialValue: value,
          onChanged: onChanged,
        ))
      ]);
}
