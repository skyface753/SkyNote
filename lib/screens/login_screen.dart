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
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value) => _btnController.reset(),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value) => _btnController.reset(),
            ),
            RoundedLoadingButton(
                child: Text('Login', style: TextStyle(color: Colors.white)),
                controller: _btnController,
                onPressed: () async {
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
                    _btnController.error();
                    print(e);
                  }
                })
          ],
        ),
      ),
    );
  }
}
