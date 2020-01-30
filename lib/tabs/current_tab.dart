import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/model/exercise_data.dart';
import 'package:gym_app/model/training_data.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/screens/count_screen.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/tiles/exercise_tile.dart';
import 'package:gym_app/tiles/training_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class CurrentTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model){
        if(!model.isTraining)
          return Container(
            alignment: Alignment(0.0, 0.0),
            padding: EdgeInsets.all(16.0),
            height: 75.0,
            child: RaisedButton(
                child: Text(
                  "New Training",
                  style: TextStyle(
                      fontSize: 18.0
                  ),
                ),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: (){
                  model.startTraining();
                }
            ),
          );
        else return FutureBuilder<QuerySnapshot>(
          future: Firestore.instance.collection("users").document(model.firebaseUser.uid).collection("trainings").document(model.trainingID).collection("exercises").getDocuments(),
          builder: (context, snapshot){
            if(!snapshot.hasData)
              return Center(child: CircularProgressIndicator(),);
            else
              return Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment(0.0, 0.0),
                    padding: EdgeInsets.all(16.0),
                    height: 75.0,
                    child: RaisedButton(
                        child: Text(
                          "Add Exercise",
                          style: TextStyle(
                              fontSize: 18.0
                          ),
                        ),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: (){
                          model.startExercise();
                          Navigator.of(context).push(
                             MaterialPageRoute(builder: (context)=>CountScreen())
                          );
                        }
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.all(4.0),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index){
                          return ExerciseTile(ExerciseData.fromDocument(snapshot.data.documents[index]));
                        }
                    ),
                  ),
                  Container(
                    alignment: Alignment(0.0, 0.0),
                    padding: EdgeInsets.all(16.0),
                    height: 75.0,
                    child: RaisedButton(
                        child: Text(
                          "End Training",
                          style: TextStyle(
                              fontSize: 18.0
                          ),
                        ),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: (){
                          model.endTraining(7);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context)=> HomeScreen())
                          );
                        }
                    ),
                  ),
                ],
              );
          },
        );
      },
    );
  }
}
