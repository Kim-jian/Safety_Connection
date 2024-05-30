import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proto/Crypto.dart';
import 'package:proto/HomeScreen.dart';
import 'ConnectionProvider.dart';
import 'SettingEnvironmentController.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String userName = await ConnectionProvider().getUserIdByUsernameAndPassword(
                      _usernameController.text,
                      sha256Hash(_passwordController.text));
                  if (userName == "error") {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("로그인 실패"),
                          content: Text("이름 혹은 비밀번호가 계정 정보와 일치하지 않습니다."),
                          actions: [
                            TextButton(
                              child: Text("확인"),
                              onPressed: () {
                                Navigator.of(context).pop(); // 다이얼로그 닫기
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }else{
                    SettingEnvironmentController.instance.loginInfo(userName,_usernameController.text);
                    String? _fcmToken = await FirebaseMessaging.instance.getToken();
                    if (_fcmToken != null) {
                      await SettingEnvironmentController.instance.updatePK(_fcmToken);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                },
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
