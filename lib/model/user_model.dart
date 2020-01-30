import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class UserModel extends Model{

  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;

  Map<String, dynamic> userData = Map();

  bool isLoadinng = false;

  bool isTraining = false;

  String trainingID = null;

  String exerciseID = null;

  String repID = null;


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();

  }

  void signUp({ @required Map<String, dynamic> userData,
                @required String pass,
                @required VoidCallback onSuccess,
                @required VoidCallback onFail} ){

    isLoadinng = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
        email: userData["email"],
        password: pass).then(
        (user) async{
          firebaseUser = user;

          await _saveUserData(userData);

          onSuccess();
          isLoadinng = false;
          notifyListeners();
        }
    ).catchError((e){
      onFail();
      isLoadinng = false;
      notifyListeners();
    });

  }

  void signIn({@required String email,
               @required String pass,
               @required VoidCallback onSuccess,
               @required VoidCallback onFail}) async{

    isLoadinng = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then(
            (user) async {

      firebaseUser = user;

      await _loadCurrentUser();

      onSuccess();

      isLoadinng = false;
      notifyListeners();

    }).catchError((e){

      onFail();
      isLoadinng = false;
      notifyListeners();

    });

  }

  void signOut() async {

    await _auth.signOut();

    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  void recoverPass(String email){

    _auth.sendPasswordResetEmail(email: email);

  }

  bool isLoggedIn(){
    return firebaseUser != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async{

    this.userData = userData;

    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);

  }

  Future<Null> _loadCurrentUser() async{

    if(firebaseUser == null) firebaseUser = await _auth.currentUser();
    if(firebaseUser != null){

      if(userData["name"] == null){
        DocumentSnapshot docUser = await Firestore.instance
                  .collection("users").document(firebaseUser.uid).get();
        userData = docUser.data;
      }

    }

    notifyListeners();

  }

  Future<Null> startTraining() async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document();

    documentReference.setData({"start": new DateTime.now()});

    isTraining = true;
    notifyListeners();

    trainingID = documentReference.documentID;

  }

  Future<Null> startExercise() async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document(trainingID).collection("exercises").document();

    documentReference.setData({"name": "puley"});

    notifyListeners();

    exerciseID = documentReference.documentID;

  }

  Future<Null> startRep() async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document(trainingID).collection("exercises").document(exerciseID).collection("rep").document();

    documentReference.setData({"name": "rep"});

    notifyListeners();

    repID = documentReference.documentID;

  }

  Future<Null> saveRep(Map<String, dynamic> rep) async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document(trainingID).collection("exercises").document(exerciseID).collection("rep").document(repID);

    documentReference.updateData(rep);

    repID = null;

  }

  Future<Null> saveExercise(Map<String, dynamic> exercise) async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document(trainingID).collection("exercises").document(exerciseID);

    documentReference.updateData(exercise);

  }

  void endTraining(int nEx) async{

    DocumentReference documentReference = await Firestore.instance.collection("users").document(firebaseUser.uid).collection("trainings").document(trainingID);

    documentReference.updateData({"nEx": nEx,"stop": new DateTime.now()});

    trainingID = null;

    isTraining = false;
    notifyListeners();

  }

}