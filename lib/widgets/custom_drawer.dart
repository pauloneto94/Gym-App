import 'package:flutter/material.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/tiles/drawer_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class CustomDrawer extends StatelessWidget {

  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Container(color: Colors.black12,),
          ListView(
            padding: EdgeInsets.only(left: 32.0, top: 16.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 170.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 50.0,
                      left: 0.0,
                      child: Text("Gym App", style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: ScopedModelDescendant<UserModel>(
                        builder: (context, child, model){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Olá, ${!model.isLoggedIn() ? "" : model.userData["name"]}", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0
                              ),
                              ),
                              GestureDetector(
                                child: Text("Sing Out", style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold
                                ),
                                ),
                                onTap: (){
                                  model.signOut();
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context)=>LoginScreen())
                                  );

                                },
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              DrawerTile(Icons.home, "Trainings", pageController, 0),
              DrawerTile(Icons.fitness_center, "Current", pageController, 1),
              DrawerTile(Icons.directions_run, "Exercises", pageController, 2),
              DrawerTile(Icons.help, "Help", pageController, 3),
            ],
          ),
        ],
      ),
    );
  }
}
