import 'package:flutter/material.dart';
import 'package:gym_app/model/training_data.dart';
import 'package:intl/intl.dart';

class TrainingTile extends StatelessWidget {

  final TrainingData data;

  TrainingTile(this.data);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 100.0,
                      child: Icon(Icons.fitness_center, size: 75.0,),
                    ),
                    Text("Data: " + (new DateFormat("dd-MM-yyyy").format(data.data)).toString(), style: TextStyle(fontSize: 20.0, color: Colors.black),),
                    //Text("Exercises: " + data.nExercises.toString(), style: TextStyle(fontSize: 20.0, color: Colors.black),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
