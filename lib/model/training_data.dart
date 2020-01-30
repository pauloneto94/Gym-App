import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingData {

  String id;
  DateTime data;
  int nExercises;

  TrainingData.fromDocument(DocumentSnapshot snapshot){

    id = snapshot.documentID;
    data = snapshot.data["start"].toDate();
    nExercises = snapshot.data["nEx"];

  }

}