import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todomate/models/signup_model.dart';
import 'package:todomate/screens/chat/chat.dart';
import 'package:todomate/screens/chat_room/chat_room_provider.dart';
import 'package:todomate/screens/chat_room/test_models.dart';
import 'package:todomate/screens/chat_room/chat_room_detail.dart';
import 'package:todomate/screens/chat_room/create_chat_room.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final DatabaseHelper db = DatabaseHelper();
  late Future<List<ChatRoomModel>> chatRooms;
  late Future<List<TopicModel>> topics;
  late Future<String> topicName;
  late Future<String> topicDetail;
  late String nameString;
  late int topicId;
  final List<int> _selectedTopics = [];

  @override
  void initState() {
    super.initState();

    // chatRooms = db.getChatRoom();
    Provider.of<ChatRoomProvider>(context, listen: false).getChatRoomList();

    // topics = db.getTopic();
    Provider.of<ChatRoomProvider>(context, listen: false).getTopicList();
  }

  // 채팅방 상세 페이지로 이동
  void _onChatRoomDetailTap(ChatRoomModel detail) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ChatRoomDetailScreen(chatRoomDetail: detail),
      ),
    )
        .then((onValue) {
      if (onValue) {
        Provider.of<ChatRoomProvider>(context, listen: false).getChatRoomList();
        // chatRooms = db.getChatRoom();
        setState(() {});
      }
    });
  }

  // 채팅방 등록
  void _onCreateChatRoomTap() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CreateChatRoomScreen(),
      ),
    )
        .then((onValue) {
      if (onValue) {
        Provider.of<ChatRoomProvider>(context, listen: false).getChatRoomList();
        setState(() {});
      }
    });
  }

  // 채팅방 참여
  void _onParticipateChatTap() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    )
        .then((onValue) {
      if (onValue) {
        Provider.of<ChatRoomProvider>(context, listen: false).getChatRoomList();
        setState(() {});
      }
    });
  }

  // 토픽 선택
  void _onTopicDetailTap(TopicModel detail) {
    topicId = detail.id!.toInt();

    setState(() {
      if (_selectedTopics.where((item) => item == topicId).isEmpty) {
        _selectedTopics.add(topicId);
      } else {
        _selectedTopics.remove(topicId);
      }
    });
    print(_selectedTopics);
  }

  Future<String> _topicName(int id) async {
    topicName = db.getTopicDetailName(topicId: id);
    nameString = await topicName;
    return nameString.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('채팅방 목록'),
          actions: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.filter,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: SizedBox(
                        height: 170,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    '주제를 선택하세요.',
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Consumer<ChatRoomProvider>(
                                  builder: (context, topicProvider, child) {
                                final topicList = topicProvider.topics;
                                return Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: topicList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.black12),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: GestureDetector(
                                          onTap: () => _onTopicDetailTap(
                                              topicList[index]),
                                          child: Center(
                                            child: Text(
                                              topicList[index].name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // FutureBuilder(
                        //   future: chatRooms,
                        //   builder: (context, snapshot) {
                        //     if (snapshot.connectionState ==
                        //         ConnectionState.waiting) {
                        //       return const CircularProgressIndicator();
                        //     } else if (snapshot.hasError) {
                        //       return Text('Error: ${snapshot.error}');
                        //     } else {
                        //       List<ChatRoomModel> chatRoomList =
                        //           snapshot.data as List<ChatRoomModel>;
                        //       return ListView.builder(
                        //         itemCount: chatRoomList.length,
                        //         itemBuilder: (context, index) {
                        //           return GestureDetector(
                        //             onTap: () => _onChatRoomDetailTap(
                        //                 chatRoomList[index]),
                        //             child: ListTile(
                        //               title: Container(
                        //                 height: 155,
                        //                 decoration: BoxDecoration(
                        //                   border: Border.all(
                        //                       color: Colors.grey.shade300),
                        //                 ),
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                     horizontal: 15,
                        //                     vertical: 10,
                        //                   ),
                        //                   child: Column(
                        //                     children: [
                        //                       Row(
                        //                         children: [
                        //                           // 주제를 비동기적으로 받아오는 FutureBuilder
                        //                           FutureBuilder<String>(
                        //                             future: _topicName(
                        //                                 chatRoomList[index]
                        //                                     .topicId),
                        //                             builder: (context,
                        //                                 topicSnapshot) {
                        //                               if (topicSnapshot
                        //                                       .connectionState ==
                        //                                   ConnectionState
                        //                                       .waiting) {
                        //                                 return const Text(
                        //                                     '주제: 불러오는 중...');
                        //                               } else if (topicSnapshot
                        //                                   .hasError) {
                        //                                 return Text(
                        //                                     '주제: 오류 발생 - ${topicSnapshot.error}');
                        //                               } else if (topicSnapshot
                        //                                   .hasData) {
                        //                                 return Text(
                        //                                     '주제: ${topicSnapshot.data}');
                        //                               } else {
                        //                                 return const Text(
                        //                                     '주제: 데이터 없음');
                        //                               }
                        //                             },
                        //                           ),
                        //                         ],
                        //                       ),
                        //                       Row(
                        //                         children: [
                        //                           Text(
                        //                               '방이름: ${chatRoomList[index].name}'),
                        //                         ],
                        //                       ),
                        //                       Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.end,
                        //                         children: [
                        //                           Container(
                        //                             width: 70,
                        //                             height: 30,
                        //                             decoration: BoxDecoration(
                        //                               border: Border.all(
                        //                                   color: Colors
                        //                                       .grey.shade300),
                        //                             ),
                        //                             child: const Center(
                        //                                 child: Text('예약')),
                        //                           )
                        //                         ],
                        //                       ),
                        //                       Row(
                        //                         children: [
                        //                           Text(
                        //                               '시작: ${chatRoomList[index].startDate}'),
                        //                         ],
                        //                       ),
                        //                       Row(
                        //                         children: [
                        //                           Text(
                        //                               '종료: ${chatRoomList[index].endDate}'),
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           );
                        //         },
                        //       );
                        //     }
                        //   },
                        // ),
                        Consumer<ChatRoomProvider>(
                          builder: (context, chatRoomProvider, child) {
                            final chatRoomList = chatRoomProvider.chatRooms;
                            return ListView.builder(
                              itemCount: chatRoomList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () =>
                                      _onChatRoomDetailTap(chatRoomList[index]),
                                  child: ListTile(
                                    title: Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 15,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                // 주제를 비동기적으로 받아오는 FutureBuilder
                                                FutureBuilder<String>(
                                                  future: _topicName(
                                                      chatRoomList[index]
                                                          .topicId),
                                                  builder:
                                                      (context, topicSnapshot) {
                                                    if (topicSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                          '주제: 불러오는 중...');
                                                    } else if (topicSnapshot
                                                        .hasError) {
                                                      return Text(
                                                          '주제: 오류 발생 - ${topicSnapshot.error}');
                                                    } else if (topicSnapshot
                                                        .hasData) {
                                                      return Text(
                                                          '주제: ${topicSnapshot.data}');
                                                    } else {
                                                      return const Text(
                                                          '주제: 데이터 없음');
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    '방이름: ${chatRoomList[index].name}'),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed:
                                                      _onParticipateChatTap,
                                                  child: const Center(
                                                      child: Text('참여')),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {},
                                                  child: const Center(
                                                      child: Text('예약')),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    '시작: ${chatRoomList[index].startDate}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    '종료: ${chatRoomList[index].endDate}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: IconButton(
                            onPressed: _onCreateChatRoomTap,
                            icon: const FaIcon(
                              FontAwesomeIcons.circlePlus,
                              size: 70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // bottomNavigationBar: const BottomAppBar(),
            ),
          ],
        ));
  }
}
