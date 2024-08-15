import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todomate/chat/chat_inner_screen/chat_input_section.dart';
import 'package:todomate/chat/chat_inner_screen/models/message_model.dart';
import 'package:todomate/chat/chat_inner_screen/widgets/chat_inner_item_widget.dart';
import 'package:todomate/chat/core/app_export.dart';
import 'package:todomate/chat/core/scroll_controller_mixin.dart';

class ChatInnerScreen extends StatefulWidget {
  final String? chatId;

  const ChatInnerScreen({super.key, this.chatId});

  @override
  _ChatInnerScreenState createState() => _ChatInnerScreenState();
}

class _ChatInnerScreenState extends State<ChatInnerScreen>
    with ScrollControllerMixin {
  // 로그인 사용자 정보
  static const String userNickName = '플로터';
  static const int userId = 1;
  static const String userEmail = 'plot@gmail.com';
  static const String userName = '민수';
  static const String avatarPath = 'assets/images/avata_1.png';
  // 채팅 상대방 정보
  static const String otherNickName = '조이';
  static const int othreUserId = 3;
  static const String otherEmail = 'yoy@gmail.com';
  static const String otherName = '영희';
  static const String otherAvatarPath = 'assets/images/avata_3.png';

  List<MessageModel> messages = [];
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      final String response = await rootBundle.loadString('assets/chat.json');
      final List<dynamic> data = await json.decode(response);
      setState(() {
        messages = data.map((item) => MessageModel.fromJson(item)).toList();
      });
      scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty || _image != null) {
      setState(() {
        messages.add(MessageModel(
          id: messages.length + 1,
          sender: userNickName,
          userId: userId,
          message: _messageController.text,
          avatarImage: avatarPath,
          attachedImage: _image?.path,
          timestamp: DateTime.now(),
          read: false,
        ));
        _messageController.clear();
        _image = null;
      });
      scrollToBottom();
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  String _formatDate(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    final currentDate = messages[index].timestamp;
    final previousDate = messages[index - 1].timestamp;
    return !currentDate.isSameDate(previousDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          toolbarHeight: 110,
          backgroundColor: ColorConstant.fromHex('#FF642D'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(otherAvatarPath),
                radius: 45,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  otherNickName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
          titleSpacing: 20,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isUserMessage = message.userId == userId;

                return Column(
                  children: [
                    if (_shouldShowDateSeparator(index))
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(message.timestamp),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    if (!isUserMessage)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Text(
                            message.sender,
                            style: const TextStyle(
                              color: Color(0xffff642d),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUserMessage)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                  message.avatarImage ?? otherAvatarPath),
                              radius: 20,
                            ),
                          ),
                        Expanded(
                          child: ChatInnerItemWidget(
                            isRight: isUserMessage,
                            highlight: false,
                            message: message,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                  ],
                );
              },
            ),
          ),
          if (_image != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: 8, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ChatInputSection(
            messageController: _messageController,
            focusNode: _focusNode,
            onSendPressed: _sendMessage,
            onImagePressed: getImage,
          ),
        ],
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
