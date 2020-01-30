import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String _picked = "User";

  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text("New Account"),
        centerTitle: true,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model){
          if(model.isLoadinng) return Center(child: CircularProgressIndicator(),);
          return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "Name"
                    ),
                    validator: (text){
                      if(text.isEmpty) return "Invalid name";
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "E-mail address"
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (text){
                      if(text.isEmpty || !text.contains("@")) return "Invalid email";
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                        hintText: "Password"
                    ),
                    obscureText: true,
                    validator: (text){
                      if(text.isEmpty || text.length < 6) return "Invalid password";
                    },
                  ),
                  SizedBox(height: 16.0,),
                  Align(
                    alignment: Alignment.center,
                    child: RadioButtonGroup(
                      orientation: GroupedButtonsOrientation.HORIZONTAL,
                      onSelected: (String selected) => setState((){
                        _picked = selected;
                      }),
                      labels: <String>[
                        "User",
                        "Admin"
                      ],
                      picked: _picked,
                      itemBuilder: (Radio rb, Text tx, int i){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            rb,
                            tx
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                    height: 44.0,
                    child: RaisedButton(
                      child: Text(
                        "Create",
                        style: TextStyle(
                            fontSize: 18.0
                        ),
                      ),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        if(_formKey.currentState.validate()){

                          Map<String, dynamic> userData = {
                            "name": _nameController.text,
                            "email": _emailController.text,
                            "admin": (_picked == "User") ? false : true
                          };

                          model.signUp(
                              userData: userData,
                              pass: _passController.text,
                              onSuccess: _onSuccess,
                              onFail: _onFail);
                        }
                      },
                    ),
                  )
                ],
              )
          );
        },
      )
    );
  }

  void _onSuccess(){

    _scafoldKey.currentState.showSnackBar(
      SnackBar(content: Text("User created successfuly!"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 2)).then(
        (_){
          Navigator.of(context).pop();
        }
    );

  }

  void _onFail(){

    _scafoldKey.currentState.showSnackBar(
      SnackBar(content: Text("User created fail!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

  }

}


