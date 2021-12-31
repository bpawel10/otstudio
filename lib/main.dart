import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otstudio/src/grid/grid_bloc.dart';
import 'package:otstudio/src/grid/grid_cell_bloc.dart';
import './src/grid/grid.dart';

void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider.value(value: GridBloc()),
    BlocProvider.value(value: GridCellBloc()),
  ], child: OTStudio()));
}

class OTStudio extends StatelessWidget {
  final TextStyle textStyle = GoogleFonts.montserrat();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTStudio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green.shade500,
        textTheme: TextTheme(
          headline1: textStyle,
          headline2: textStyle,
          headline3: textStyle,
          headline4: textStyle,
          headline5: textStyle,
          headline6: textStyle,
          subtitle1: textStyle,
          subtitle2: textStyle,
          bodyText1: textStyle,
          bodyText2: textStyle,
          caption: textStyle,
          button: textStyle,
          overline: textStyle,
        ).apply(
            displayColor: Colors.grey.shade300,
            bodyColor: Colors.grey.shade300),
        primarySwatch: Colors.green,
        inputDecorationTheme: InputDecorationTheme(
          // floatingLabelBehavior: FloatingLabelBehavior.
          filled: true,
          border: InputBorder.none,
          // isDense: true,
          // contentPadding: EdgeInsets.zero,
          // constraints: BoxConstraints.expand(width: 100, height: 20),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Grid(),
    );
  }
}
