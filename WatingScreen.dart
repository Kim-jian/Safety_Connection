import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: WaitingScreen(),
  ));
}

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('동행자 응답 대기 중',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
  }
}


