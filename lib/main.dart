import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otstudio/src/bloc/app_bloc.dart';
import 'package:otstudio/src/screens/welcome/welcome.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(OTStudio());
  doWhenWindowReady(() {
    final Size initialSize = Size(500, 400);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.maxSize = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'OTStudio';
    appWindow.show();
  });
}

class OTStudio extends StatelessWidget {
  final TextStyle textStyle = GoogleFonts.roboto(); // montserrat();

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
      home: BlocProvider(
          create: (BuildContext context) => AppBloc()..add(AppInitEvent()),
          child: Scaffold(body: Welcome())),
    );
  }
}
