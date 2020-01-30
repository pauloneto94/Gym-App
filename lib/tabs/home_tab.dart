import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/model/training_data.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/tiles/training_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
        builder: (context, child, model){
          if(!model.isLoggedIn())
            return Center(
              child: Text("No User Logged In"),
            );
          else return FutureBuilder<QuerySnapshot>(
            future: Firestore.instance.collection("users").document(model.firebaseUser.uid).collection("trainings").getDocuments(),
            builder: (context, snapshot){
              if(!snapshot.hasData)
                return Center(child: CircularProgressIndicator(),);
              else
                return GridView.builder(
                    padding: EdgeInsets.all(4.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index){
                      return TrainingTile(TrainingData.fromDocument(snapshot.data.documents[index]));
                    }
                );
            },
          );
        }
    );
  }
}
