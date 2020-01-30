import 'package:flutter/material.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
        appBar: AppBar(
          title: Text("Welcome"),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text(
                  "New Account",
                  style: TextStyle(fontSize: 12.0)
              ),
              textColor: Colors.white,
              onPressed: (){
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context)=> SignUpScreen())
                );
              },
            )
          ],
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
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: "e-mail address"
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
                          hintText: "password"
                      ),
                      obscureText: true,
                      validator: (text){
                        if(text.isEmpty || text.length < 6) return "Invalid password";
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: (){

                          if(_emailController.text.isEmpty)
                            _scafoldKey.currentState.showSnackBar(
                              SnackBar(content: Text("Insert email for recover password"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          else{
                            model.recoverPass(_emailController.text);
                            _scafoldKey.currentState.showSnackBar(
                              SnackBar(content: Text("Check your email"),
                                backgroundColor: Theme.of(context).primaryColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }


                        },
                        child: Text("Forgot Password", textAlign: TextAlign.right,),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 16.0,),
                    SizedBox(
                      height: 44.0,
                      child: RaisedButton(
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18.0
                          ),
                        ),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: (){
                          if(_formKey.currentState.validate()){

                            model.signIn(email: _emailController.text,
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

    Navigator.of(context).push(
        MaterialPageRoute(builder: (context)=>HomeScreen())
    );

  }

  void _onFail() {

    _scafoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Login fail!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

  }

}

