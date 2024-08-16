import 'package:flutter/material.dart';

class My extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyReservedChatsPage(),
    );
  }
}

class MyReservedChatsPage extends StatelessWidget {
  final List<Map<String, String>> reservedChats = [
    {'title': 'Flutter Study', 'time': '2024-08-15 15:54'},
    {'title': 'Work Group', 'time': '2024-08-16 10:00'},
    // 추가적인 채팅방 정보는 여기에 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('내가 예약한 채팅방', style: TextStyle(fontSize: 18.0)),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: reservedChats.length,
        itemBuilder: (context, index) {
          final chat = reservedChats[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat['title']!,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        chat['time']!,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 플로팅 액션 버튼 액션 구현
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}
