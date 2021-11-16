// import 'package:flutter/material.dart';
// import '../models/item.dart';

// class Items extends StatelessWidget {
//   final List<Item> items;
//   selectedItemIndex

//   @override
//   Widget build(BuildContext context) => ListView.builder(
//       cacheExtent: 10000,
//       itemCount: items.length,
//       itemBuilder: (context, index) => GestureDetector(
//           onTap: () => setState(() => selectedItemIndex = index),
//           child: MouseRegion(
//               cursor: SystemMouseCursors.click,
//               child: Container(
//                   decoration: index == selectedItemIndex
//                       ? BoxDecoration(color: Theme.of(context).primaryColor)
//                       : BoxDecoration(),
//                   child: Padding(
//                       padding: EdgeInsets.all(2),
//                       child: Row(children: [
//                         SizedBox(
//                             width: 32,
//                             height: 32,
//                             child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(3),
//                                 child: items[index].image)),
//                         Padding(
//                             padding: EdgeInsets.only(left: 5),
//                             child: Text(items[index].id.toString())),
//                         // Text('spriteId:' + items[index].spriteId.toString())
//                       ]))))));
// }
