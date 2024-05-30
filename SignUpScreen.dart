import 'package:flutter/material.dart';
import 'package:proto/Crypto.dart';
import 'ConnectionProvider.dart';
import 'dart:math';

String generateRandomString(int length) {
  const chars = '0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
    length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
  ));
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 각 필드의 값을 저장할 변수
  String _name = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _userId = '';
  ConnectionProvider connectionProvider = ConnectionProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  hintText: 'example@example.com',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '유효한 이메일 주소를 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '01012345678(\'-\' 기호 생략)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return '유효한 전화번호를 입력해주세요';
                  }
                  if (value.length < 10 || value.length > 15) {
                    return '전화번호는 10자에서 15자 사이여야 합니다';
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
                  if (value.length < 6) {
                    return '비밀번호는 최소 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      // 입력된 값을 변수에 저장
                      _name = _nameController.text;
                      _email = _emailController.text;
                      _phone = _phoneController.text;
                      _password = _passwordController.text;
                    });
                    _password = sha256Hash(_password);
                    _userId = generateRandomString(9);
                    bool success = await connectionProvider.sendSignupRequest(_userId, _name, _phone, _email, _password);
                    if (success) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("회원 가입 성공"),
                            content: Text("회원 가입에 성공했습니다."),
                            actions: [
                              TextButton(
                                child: Text("확인"),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 다이얼로그 닫기
                                  Navigator.of(context).pop(); // 홈 화면으로 돌아가기
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("회원 가입 실패"),
                            content: Text("오류가 발생했습니다. 다시 시도해주세요."),
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
                    }
                  }
                },
                child: Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
