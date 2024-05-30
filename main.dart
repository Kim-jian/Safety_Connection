import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'SettingEnvironmentController.dart';
import 'HomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ConnectionProvider.dart';



//test 용 아이디
// ID : onlytest, PW : test12
// ID : hi, PW : 123456

final ConnectionProvider connectionProvider = ConnectionProvider();

//background에서 푸시메시지 처리
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  if (message != null) {
    if (message.notification != null) {
      print(message.notification!.title);
      print(message.notification!.body);
      String userName = message.data["click_action"];
      bool startsWithReq = userName.startsWith('req');
      if(startsWithReq){
        SettingEnvironmentController.instance.updateRequestUser(await connectionProvider.requestIDbyName(userName));
        //차량 이동 요청을 전송받았을 시 requestUser에 set
      }
      else {
        SettingEnvironmentController.instance.updateConnectedCompanion(
            await connectionProvider.requestIDbyName(userName));
      }
    }
  }
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}



//background에서 푸시메시지 처리
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermission();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  // 토큰 초기화 및 서버 업데이트
  if(SettingEnvironmentController.instance.userID != ""){
    String? _fcmToken = await FirebaseMessaging.instance.getToken();
    if (_fcmToken != null) {
      await SettingEnvironmentController.instance.updatePK(_fcmToken);
    }
  }


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => SettingEnvironmentController.instance,
      child: MaterialApp(
        title: 'Safety Connection Provider App',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}