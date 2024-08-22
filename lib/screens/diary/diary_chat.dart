import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DiaryChatScreen extends StatefulWidget {
  final String roomId;
  const DiaryChatScreen({super.key, required this.roomId});

  @override
  _DiaryChatScreenState createState() => _DiaryChatScreenState();
}

class _DiaryChatScreenState extends State<DiaryChatScreen> with ScrollControllerMixin {
  late Socket socket; // 별칭 없이 직접 사용
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  List<String> _messages = [];
  String socketId = '';
  String appState = '';

  @override
  void initState() {
    super.initState();
    _roomController.text = widget.roomId;
    _connectSocket();
  }

  void _connectSocket() {
    // IP 등록
    socket = io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
      // roomId로 룸 가입
      socket.emit('joinRoom', widget.roomId);
    });

    socket.on('receiveMessage', (message) {
      print('$message');
      setState(() {
        _messages.add(message);
        scrollToBottom();
      });
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _roomController.text.isNotEmpty) {
      // emit할 때 배열로 인자 2개(message, roomId) 안 넣으면 receiveMessage가 안 옴 -> 룸 안에 있는 사람에게 전역으로 receiveMessage를 주기 때문
      socket.emit('sendMessage', [_messageController.text, widget.roomId]);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Socket.IO Chat')),
      body: Column(
        children: [
          TextField(
            controller: _roomController,
            decoration: InputDecoration(labelText: 'Room'),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_messages[index]));
              },
            ),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Message',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

mixin ScrollControllerMixin {
  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
}
