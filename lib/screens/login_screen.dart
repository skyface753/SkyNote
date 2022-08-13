import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynote/appwrite.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Account appwriteAccount = AppWriteCustom().getAppwriteAccount();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  void login() async {
    try {
      await appwriteAccount.createEmailSession(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _btnController.success();
      await SharedPreferences.getInstance().then((value) => {
            value.setBool('isLoggedIn', true),
            Navigator.pushReplacementNamed(context, '/')
          });
    } catch (e) {
      setState(() {
        _btnController.error();
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value) => _btnController.reset(),
            ),
            TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value) => _btnController.reset(),
              onSubmitted: (value) => login(),
            ),
            _btnController.currentState == ButtonState.error
                ? Text('Invalid email or password')
                : Container(),
            RoundedLoadingButton(
              controller: _btnController,
              onPressed: () {
                login();
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            )
            // MaterialButton(
            //   onPressed: () async {
            //     Future result = appwriteAccount.createOAuth2Session(
            //       provider: 'google',
            //       success: 'https://appwrite.skyface.de/oauth/google/success',
            //     );

            //     result.then((response) {
            //       print(response);
            //     }).catchError(
            //       (error) {
            //         print(error.response);
            //       },
            //     );
            //   },
            //   child: Text('Login with Google'),
            // )
          ],
        ),
      ),
    );
  }
}
