import 'package:cloud_firestore/cloud_firestore.dart';

class RepData {

  String id;
  String times;
  int weight;

  RepData.fromDocument(DocumentSnapshot snapshot){

    id = snapshot.documentID;
    times = snapshot.data["times"];
    weight = snapshot.data["weight"];

  }

}