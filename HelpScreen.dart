import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도움말'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('safety_connection'),
            _buildSectionContent(
              'safety connection은 비대면으로 차량이동을 요청할 수 있는 앱입니다.\n'
                  '차량 이동을 개인정보 노출 없이 동행자와 안전하게 진행해보세요!',
            ),
            SizedBox(height: 40),
            ExpansionTile(
              title: Text(
                '사용 절차',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              children: <Widget>[
                _buildSectionContent(
                  '1. 차량에 부착된 QR코드를 스캔하거나 QR코드의 일련번호를 직접 입력하여 차주에게 차량이동 요청 알림을 보냅니다.\n\n'
                      '2. 차량이동 요청을 받은 차주는 푸시메시지를 눌러 동행자들과의 위치, 예상 소요시간을 확인하고 함께 갈 동행자를 선택합니다.',
                ),
                _buildNote(
                  '* 동행자는 위치공유설정을 킨 상태에서만 요청할 수 있습니다.\n',
                ),
                _buildSectionContent(
                  '3. 동행자를 선택하면 해당 동행자에게 동행 요청 알림을 전송합니다.\n\n'
                      '4. 동행자가 요청을 수락하면 나의 위치와 동행자의 위치를 지도상에 띄워줍니다.\n\n'
                      '5. 동행자를 기다리는 동안 차량이동까지 걸리는 예상 소요시간을 설정해 요청자에게 보냅니다.\n\n'
                      '6. 차량이동이 완료되면 차량이동 완료 버튼을 눌러 요청자에게 전송합니다.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildNote(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        note,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
