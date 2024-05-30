import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proto/Crypto.dart';
import 'package:proto/SetCompleteTime.dart';
import 'package:proto/main.dart';
import 'package:provider/provider.dart';
import 'SettingEnvironmentController.dart';
import 'CompanionManagementScreen.dart';
import 'ConnectionProvider.dart';
import 'CompanionSelectScreen.dart';
import 'LoginScreen.dart';
import 'LoginInfoScreen.dart';
import 'SignUpScreen.dart';
import 'AuthScreen.dart';
import 'SettingScreen.dart';
import'AcceptScreen.dart';
import 'JustWaitScreen.dart';
import 'HelpScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    if(!SettingEnvironmentController.instance.updatedListner){
      print("갱신 실행");
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
        if (message != null) {
          String userName = message.data["click_action"];
          bool startsWithReq = userName.startsWith('req');
          bool startsWithctime = userName.startsWith('ctime');
          if(startsWithReq){
            userName = userName.substring(3);
            SettingEnvironmentController.instance.updateRequestUser(userName);
            if(SettingEnvironmentController.instance.shareGPS){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompanionSelectScreen()),
              );
            }
            else{
              print("도착한 user명: $userName");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetCompleteTime()),
              );
            }
          }//차량 이동 요청을 눌렀을 때
          else if(userName == "finished"){
            SettingEnvironmentController.instance.updateRequestUser("");
            SettingEnvironmentController.instance.updateConnectedCompanion("");
          }
          else if(startsWithctime){

          }
          else{
            print("도착한 user명: $userName");
            SettingEnvironmentController.instance.updateConnectedCompanion(userName);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AcceptScreen()),
            );
          }
        }
      });// 동행자 요청 일 때
      FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
        if (message != null) {
          String answer = message.data["click_action"];
          bool startsWithReq = answer.startsWith('req');
          bool startsWithctime = answer.startsWith('ctime');
          print(answer);
          if(answer == "수락"){
            SettingEnvironmentController.instance.updateConnectedCompanion(decryptData(
                await connectionProvider.sendSearchRequest(SettingEnvironmentController.instance.connectedCompanion)
            , aeskey));
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SetCompleteTime()),
              );
          }
          else if(answer == "finished"){
            SettingEnvironmentController.instance.updateRequestUser("");
            SettingEnvironmentController.instance.updateConnectedCompanion("");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('차량 이동 완료'),
                  content: Text('차량 이동이 완료되었습니다.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                      },
                    ),
                  ],
                );
              },
            );
          }
          else if(startsWithReq){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('차량 이동 요청 도착'),
                  content: Text('차량 이동 요청이 도착했습니다.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('확인'),
                      onPressed: () {
                        answer = answer.substring(3);
                        SettingEnvironmentController.instance.updateRequestUser(answer);
                        if(SettingEnvironmentController.instance.shareGPS){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CompanionSelectScreen()),
                          );
                        }
                        else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => JustWaitScreen()),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          }
          else if(startsWithctime){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('예상 차량 이동 소요 시간'),
                  content: Text('${answer.substring(5)}분 뒤면 차량 이동이 완료될 거에요!'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                      },
                    ),
                  ],
                );
              },
            );
          }
          else{
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('동행 요청 거절'),
                  content: Text('요청이 거절되었습니다. 다른 동행자를 선택해주세요.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('확인'),
                      onPressed: () {
                        Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                      },
                    ),
                  ],
                );
              },
            );
          }

        }
      });
      SettingEnvironmentController.instance.updateListener();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(args),
              duration: Duration(seconds: 3), // 스낵바가 3초간 표시됩니다.
            )
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
        ],
      ),
      drawer: Drawer(
        child: Consumer<SettingEnvironmentController>(
          builder: (context, settingController, child) {
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  color: Colors.blueAccent,
                  child: const Text(
                    '메뉴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('계정'),
                  onTap: () {
                    if (settingController.loginStatus == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginInfoScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('설정'),
                  onTap: () {
                    // Navigate to settings screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Setting()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('도움말'),
                  onTap: () {
                    // Navigate to help screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                    );
                  },
                ),
                settingController.loginStatus == true
                    ? ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('로그아웃'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('로그아웃 확인'),
                          content: const Text('정말 로그아웃 하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('로그아웃'),
                              onPressed: () {
                                settingController.logout();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
                    : ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('회원 가입'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            QRInputWidget(),
            TransactionList(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    if(SettingEnvironmentController.instance.loginStatus){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CompanionManagementScreen()),
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("오류"),
                            content: Text("로그인 후 이용해주세요."),
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // 배경색
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 3, // 그림자
                  ),
                  child: Text(
                    '동행자 관리',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // 텍스트 색상
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingController = Provider.of<SettingEnvironmentController>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            '최근 함께한 동행자',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        for (int i = 0; i < settingController.companionList.length && i < 5; i++)
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.deepPurple),
            title: Text(settingController.companionList[i].key),
            // subtitle: Text('06 June, 2:00 pm', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}

class QRInputWidget extends StatefulWidget {
  @override
  _QRInputWidgetState createState() => _QRInputWidgetState();
}

class _QRInputWidgetState extends State<QRInputWidget> {
  final TextEditingController _controller = TextEditingController();
  ConnectionProvider connectionProvider = ConnectionProvider();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      color: Colors.blueAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '사용자 ID 입력',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              labelText: SettingEnvironmentController.instance.loginStatus? '여기에 ID를 입력하세요' : '서비스 이용을 위해 로그인 해주세요.',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // 입력값 처리 로직
              var qrCode = _controller.text;
              print('입력된 ID: $qrCode');
              if(qrCode == SettingEnvironmentController.instance.userID){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("검색 실패"),
                      content: Text("본인의 ID로 차량 요청을 시도하셨습니다. 다시 시도해주세요."),
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
              else if(await connectionProvider.sendBoolSearchRequest(qrCode)){
                SettingEnvironmentController.instance.updateRequestUser(qrCode);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen())
                );
              }
              //일치 시, 개인인증화면 진행,(임시로 항상 일치한다고 가정)
              else{
                print("Qr failed.");
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("검색 실패"),
                      content: Text("입력된 ID로 사용자를 찾을 수 없습니다. 다시 시도해주세요."),
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
            },
            child: Text(
              SettingEnvironmentController.instance.loginStatus? '확인':'로그인을 해주세요',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}