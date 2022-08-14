import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:appwrite/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynote/appwrite.dart';

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  static String id = '/RegisterPage';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _showSpinner = false;

  bool _wrongEmail = false;
  bool _wrongPassword = false;

  String _emailText = 'Please use a valid email';
  String _passwordText = 'Please use a strong password';

  Account appwriteAccount = AppWriteCustom().getAppwriteAccount();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        color: Colors.blueAccent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/images/background.png'),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 60.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(fontSize: 50.0),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lets get',
                        style: TextStyle(fontSize: 30.0),
                      ),
                      Text(
                        'you on board',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          labelText: 'Full Name',
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _wrongEmail ? _emailText : null,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _wrongPassword ? _passwordText : null,
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                  RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    color: Color(0xff447def),
                    onPressed: () async {
                      setState(() {
                        _wrongEmail = false;
                        _wrongPassword = false;
                      });
                      try {
                        await appwriteAccount.create(
                            userId: 'unique()',
                            email: _emailController.text,
                            password: _passwordController.text,
                            name: _nameController.text);
                        await SharedPreferences.getInstance().then((value) => {
                              value.setBool('isLoggedIn', true),
                              Navigator.pushReplacementNamed(context, '/')
                            });
                        Navigator.pushReplacementNamed(context, '/');
                      } catch (e) {
                        setState(() {
                          _wrongEmail = true;
                          _emailText =
                              'The email address is already in use by another account';
                        });
                      }
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 25.0, color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 1.0,
                          width: 60.0,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Or',
                        style: TextStyle(fontSize: 25.0),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          height: 1.0,
                          width: 60.0,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: RaisedButton(
                  //         padding: EdgeInsets.symmetric(vertical: 5.0),
                  //         color: Colors.white,
                  //         shape: ContinuousRectangleBorder(
                  //           side:
                  //               BorderSide(width: 0.5, color: Colors.grey),
                  //         ),
                  //         onPressed: () {
                  //           onGoogleSignIn(context);
                  //         },
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Image.asset('assets/images/google.png',
                  //                 fit: BoxFit.contain,
                  //                 width: 40.0,
                  //                 height: 40.0),
                  //             Text(
                  //               'Google',
                  //               style: TextStyle(
                  //                   fontSize: 25.0, color: Colors.black),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 20.0),
                  //     Expanded(
                  //       child: RaisedButton(
                  //         padding: EdgeInsets.symmetric(vertical: 5.0),
                  //         color: Colors.white,
                  //         shape: ContinuousRectangleBorder(
                  //           side:
                  //               BorderSide(width: 0.5, color: Colors.grey[400]),
                  //         ),
                  //         onPressed: () {
                  //           //TODO: Implement facebook functionality
                  //         },
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Image.asset('assets/images/facebook.png',
                  //                 fit: BoxFit.cover, width: 40.0, height: 40.0),
                  //             Text(
                  //               'Facebook',
                  //               style: TextStyle(
                  //                   fontSize: 25.0, color: Colors.black),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 25.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          ' Sign In',
                          style: TextStyle(fontSize: 25.0, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
