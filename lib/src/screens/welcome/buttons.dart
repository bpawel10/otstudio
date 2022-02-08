import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Buttons extends StatelessWidget {
  Buttons();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ElevatedButton.icon(
              onPressed: () => {},
              icon: FaIcon(FontAwesomeIcons.plus),
              label: Text('New')),
          SizedBox(height: 10),
          ElevatedButton.icon(
              onPressed: () => {},
              icon: FaIcon(FontAwesomeIcons.solidFolderOpen),
              label: Text('Open'))
        ],
      );
}
