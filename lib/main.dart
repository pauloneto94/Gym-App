import 'package:flutter/material.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/screens/signup_screen.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: MaterialApp(
        title: "Gym App",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.red,
        ),
        debugShowCheckedModeBanner: false,
        home: ScopedModelDescendant<UserModel>(
            builder: (context, child, model){
              if(!model.isLoggedIn()) {
                return LoginScreen();
              }
              else return HomeScreen();
            }
        ),
      )
    );
  }
}