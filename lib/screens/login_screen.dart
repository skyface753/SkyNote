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
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () async {
                try {
                  await appwriteAccount.createEmailSession(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  await SharedPreferences.getInstance().then((value) => {
                        value.setBool('isLoggedIn', true),
                        Navigator.pushReplacementNamed(context, '/')
                      });
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
