import 'package:flutter/material.dart';
import 'package:proto/SettingEnvironmentController.dart';
import 'package:provider/provider.dart';
import 'ConnectionProvider.dart';
import 'Crypto.dart';


class CompanionManagementScreen extends StatefulWidget {
  const CompanionManagementScreen({super.key});

  @override
  _CompanionManagementScreenState createState() => _CompanionManagementScreenState();
}

class _CompanionManagementScreenState extends State<CompanionManagementScreen> {
  ConnectionProvider connectionProvider = ConnectionProvider();
  @override
  Widget build(BuildContext context) {
    final settingController = Provider.of<SettingEnvironmentController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('동행자 관리'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context); // 홈 화면으로 이동
          },
        ),
      ),
      body: ListView.builder(
        itemCount: settingController.companionList.length,
        itemBuilder: (context, index) {
          var entry = settingController.companionList[index];
          return ListTile(
            title: Text(entry.key),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if(await connectionProvider.compDeleteRequest(settingController.companionList[index].value)){
                  settingController.deleteCompList(entry.key);
                }
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("오류"),
                        content: Text("알 수 없는 오류로 삭제에 실패하였습니다. 잠시 후 다시 시도해주세요."),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddCompanionScreen();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddCompanionScreen() async {
    // async를 추가하여 추가 화면 닫힌 후에 setState가 실행되도록 변경
    await Navigator.push( // await 추가
      context,
      MaterialPageRoute(builder: (context) => AddCompanionScreen()),
    );
    setState(() {}); // setState 추가
  }
}


class AddCompanionScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ConnectionProvider connectionProvider = ConnectionProvider();

  @override
  Widget build(BuildContext context) {
   final settingController = Provider.of<SettingEnvironmentController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('동행자 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '동행자의 앱 ID를 입력하세요',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                //입력되면 앱 ID 를 기반으로 DB에서 유저 검색해서 SEC에서 저장 response.body의 구조 : User Name: kimjian
                String companionId = _controller.text.trim();
                String searhcedName = '122@34gfasw2';
                if(settingController.companionMap.containsValue(companionId)){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("오류"),
                        content: Text("이미 연락처에 존재하는 이용자입니다."),
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
                }// 존재하는 User 추가시
                else if(companionId == settingController.userID){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("오류"),
                        content: Text("본인을 동행자로 추가할 수 없습니다."),
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
                }// 본인 추가시
                else{
                  searhcedName = await connectionProvider.sendSearchRequest(companionId);
                  if(searhcedName.compareTo('error')!=0){
                    connectionProvider.sendCompanionAddRequest(companionId);
                    RegExp regExp = RegExp(r'User Name: (.+)');
                    Match? match = regExp.firstMatch(searhcedName);
                    if(match!=null){
                      String realName = decryptData(match.group(1)!, aeskey);
                      settingController.updateCompList(realName, companionId);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("성공"),
                            content: Text("추가성공"),
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
                  }//searched
                  else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("검색 실패"),
                          content: Text("입력된  앱 ID로 사용자를 찾을 수 없습니다. 다시 시도해주세요."),
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
              child: const Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
