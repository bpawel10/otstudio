import 'package:flutter/material.dart';
import 'package:path/path.dart';

class RecentProject extends StatelessWidget {
  final String path;

  RecentProject({required this.path});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Text(basenameWithoutExtension(path),
                      overflow: TextOverflow.ellipsis),
                  Text(path, overflow: TextOverflow.ellipsis),
                ],
              )),
        ));
  }
}
