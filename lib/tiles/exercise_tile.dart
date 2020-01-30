import 'package:flutter/material.dart';
import 'package:gym_app/model/exercise_data.dart';

class ExerciseTile extends StatelessWidget {

  final ExerciseData data;

  ExerciseTile(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Text("${data.name}", style: TextStyle(color: Colors.red, fontSize: 20.0),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
