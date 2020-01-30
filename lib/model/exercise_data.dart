import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseData {

  String id;
  String name;

  ExerciseData.fromDocument(DocumentSnapshot snapshot){

    id = snapshot.documentID;
    name = snapshot.data["name"];

  }

}