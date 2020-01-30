import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/tabs/current_tab.dart';
import 'package:gym_app/tabs/home_tab.dart';
import 'package:gym_app/widgets/custom_drawer.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  final _scafoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model){
        return PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Scaffold(
              key: _scafoldKey,
              appBar: AppBar(
                title: Text("Trainings"),
                centerTitle: true,
              ),
              body: HomeTab(),
              drawer: CustomDrawer(_pageController),
              floatingActionButton: FloatingActionButton(onPressed: (){
                if(model.isTraining)
                    _scafoldKey.currentState.showSnackBar(
                    SnackBar(content: Text("Already Training!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                else {
                   model.startTraining();
                  _pageController.jumpToPage(1);
                }
              },
                child: Icon(Icons.playlist_add),
                backgroundColor: Theme.of(context).primaryColor,
              ),

            ),
            Scaffold(
              appBar: AppBar(
                title: Text("Current Training"),
                centerTitle: true,
              ),
              drawer: CustomDrawer(_pageController),
              body: CurrentTab(),
            ),
          ],
        );

      },
    );
  }
}
