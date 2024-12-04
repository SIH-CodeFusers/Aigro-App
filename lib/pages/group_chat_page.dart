import 'dart:math';
import 'dart:convert';
import 'package:aigro/widgets/posts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/utils/translate.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  const GroupChatPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late IO.Socket socket; 
  final TextEditingController _messageController = TextEditingController();
  final Map<String, TextEditingController> _commentControllers = {};

  late Map<String, dynamic> group = {};
  List<dynamic> _messages = [];
  final infobox = Hive.box("BasicInfo-db");
  final languageBox = Hive.box("Language_db");
  BasicDB bdb = BasicDB();
  LanguageDB ldb = LanguageDB();

  List<String> colors = [
    "FF9C66",  // Lighter Red
    "668BFF",  // Lighter Blue
    "FF66D1",  // Lighter Pink
    "B166FF",  // Lighter Purple
    "66FFFF",  // Lighter Aqua Blue
    "FFB366",  // Lighter Orange
    "FF6666",  // Lighter Red
  ];

  Color getRandomColor() {
    final random = Random();
    String colorHex = colors[random.nextInt(colors.length)];
    return Color(int.parse('0xFF$colorHex'));
  }

  String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  late List<bool> _isCommentsVisible;

  @override
  void initState() {
    super.initState();
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
    } else {
      ldb.loadLang();
    }
    print("hello");

  
    fetchGroups(widget.groupId).then((_) {
      // After fetchGroups completes, initialize the _messages and _isCommentsVisible list
      setState(() {
        _messages = group['messages'] ?? [];
        _isCommentsVisible = List<bool>.filled(_messages.length, false);
      });
    });

    // Load other data (assuming this is a synchronous operation)
    bdb.loadDataInfo();

    // Initialize socket
    initializeSocket();
  }

  Future<void> fetchGroups(String groupId) async {
    print(groupId);
    const String apiUrl = '$CHAT_BACKEND/yourgroups/$BACKEND_UID';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print(response);
        final data = jsonDecode(response.body);
        setState(() {
          group = data['groups'].firstWhere(
            (group) => group['_id'] == groupId,
            orElse: () => null, 
          ) ?? {};  // Default to empty map if no group is found
          _messages = group['messages'] ?? [];
        });
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (error) {
      print('Error fetching groups: $error');
      setState(() {
        group = {};  // Handle error case
      });
    }
  }

  void initializeSocket() {
    socket = IO.io(
      CHAT_BACKEND, 
      IO.OptionBuilder()
        .setTransports(['websocket'])  
        .disableAutoConnect()     
        .build(),
    );

    socket.connect(); 
    print('Attempting to connect...');
    
    socket.on('connect', (_) {
      print('Socket connected: ${socket.id}');
      socket.emit('joinGroup', {'groupId': group['_id']});
    });

    socket.on('connect_error', (error) {
      print('Connection failed: $error');
    });

    socket.on('newMessage', (data) {
      final decoded = _decodeMessage(data);
      setState(() {
        _messages.add(decoded['message']);
      });
    });

    socket.on('newCommentgrp', (data) {
      final decoded = _decodeMessage(data);
      setState(() {
        _messages = _messages.map((msg) {
          if (msg['_id'] == decoded['messageId']) {
            msg['comments'].add(decoded['newComment']);
          }
          return msg;
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final messageData = {
      'groupId': group['_id'],
      'message': message,
      'sender': BACKEND_UID,
      'comments': [],
      'name': bdb.userName,
      'image': null,
    };

    try {
      socket.emit('createMessage', messageData);
      _messageController.clear();
      refreshPage();
    } catch (error) {
      print('Error sending message: $error');
    }

  }

  void _addComment(String messageId) {
    final comment = _commentControllers[messageId]?.text.trim();
    if (comment == null || comment.isEmpty) return;

    socket.emit('addCommentGroup', _buildCommentJson(messageId, comment));

    final commentData = {
      'groupId': group['_id'],
      'messageId': messageId,
      'sender': BACKEND_UID,
      "comment": {
        "comment": comment,
        "commenterName": bdb.userName
      }
    };

    try {
      socket.emit('addCommentGroup', commentData);
      _messageController.clear();

    } catch (error) {
      print('Error sending message: $error');
    }
    _commentControllers[messageId]?.clear();
    refreshPage();
  }

  Map<String, dynamic> _decodeMessage(String data) {
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (_) {
      return {};
    }
  }

  String _buildCommentJson(String messageId, String comment) {
    return '''
    {
      "groupId": "${group['_id']}",
      "messageId": "$messageId",
      "comment": {
        "comment": "$comment",
        "commenterName": "Current User"
      }
    }
    ''';
  }

  void _toggleCommentsVisibility(int indx) {
    setState(() {
      _isCommentsVisible[indx] = !_isCommentsVisible[indx];
    });
  }

  void refreshPage(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatPage(groupId: widget.groupId,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: translateTextInput('Chat', ldb.language),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Chat');
          },
        ),
        actions: [
           Padding(
             padding: const EdgeInsets.only(right: 20),
             child: IconButton(
              icon: Icon(Icons.refresh, color: context.theme.primaryColorDark),
                onPressed: () {
                  refreshPage();
                },
              ),
           ),
          
        ]   
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final messageId = message['_id'];
                _commentControllers.putIfAbsent(
                  messageId,
                  () => TextEditingController(),
                );

                return Container(
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), 
                        offset: Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: getRandomColor(),
                                radius: 22,
                                child: FutureBuilder<String>(
                                  future: translateTextInput(
                                    getInitials(message['name'] ?? 'Unknown User'),
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? getInitials(message['name'] ?? 'Unknown User'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                FutureBuilder<String>(
                                  future: translateTextInput(
                                    message['name'] ?? 'Unknown',
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? message['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                                SizedBox(width: 8),
                                FutureBuilder<String>(
                                  future: translateTextInput(
                                    DateFormat('MMM dd, yyyy').format(
                                      DateTime.parse(message['createdAt']).toLocal()
                                    ),
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? DateFormat('MMM dd, yyyy').format(
                                        DateTime.parse(message['createdAt']).toLocal()
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500]
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                                SizedBox(height: 10,),
                                FutureBuilder<String>(
                                  future: translateTextInput(
                                    message['message'] ?? 'No message',
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? message['message'] ?? 'No message',
                                      style: TextStyle(fontSize: 16),
                                    );
                                  },
                                ),
                                SizedBox(height: 15,),

                                if(message['comments']?.length != 0)
                                  GestureDetector(
                                    onTap: () {
                                      _toggleCommentsVisibility(index);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          FeatherIcons.eye,
                                          color: context.theme.cardColor,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        FutureBuilder<String>(
                                          future: translateTextInput(
                                            _isCommentsVisible[index] ? 'View Less' : 'View Comments',
                                            ldb.language
                                          ),
                                          builder: (context, snapshot) {
                                            return Text(
                                              snapshot.data ?? (_isCommentsVisible[index] ? 'View Less' : 'View Comments'),
                                              style: TextStyle(
                                                color: context.theme.cardColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          if (_isCommentsVisible[index])
                          ...List.generate(
                            message['comments']?.length ?? 0,
                            (i) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: context.theme.focusColor,
                                    radius: 16,
                                    child: FutureBuilder<String>(
                                      future: translateTextInput(
                                        getInitials(message['comments'][i]['commenterName'] ?? 'Unknown User'),
                                        ldb.language
                                      ),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? getInitials(message['comments'][i]['commenterName'] ?? 'Unknown User'),
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FutureBuilder<String>(
                                        future: translateTextInput(
                                          '${message['comments'][i]['commenterName'] ?? 'Unknown'}: ${message['comments'][i]['comment'] ?? 'No comment'}',
                                          ldb.language
                                        ),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? '${message['comments'][i]['commenterName'] ?? 'Unknown'}: ${message['comments'][i]['comment'] ?? 'No comment'}',
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_isCommentsVisible[index])
                            SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentControllers[messageId],
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      hintStyle: TextStyle(color: Colors.grey[500]),
                                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(           
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.theme.cardColor,
                                  ),
                                  child: IconButton(
                                    onPressed: () => _addComment(messageId),
                                    icon: Icon(
                                      FeatherIcons.arrowRight,
                                      size: 18,
                                      color: context.theme.highlightColor,
                                    ),
                                  ), 
                                )                
                              ],
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: context.theme.cardColor,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your post...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.theme.primaryColorDark,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.theme.cardColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: context.theme.cardColor,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: context.theme.highlightColor,
                    ),
                    style: TextStyle(color: context.theme.primaryColorDark),
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    color: context.theme.highlightColor,
                    icon: const Icon(FeatherIcons.arrowUpRight, size: 18),
                    onPressed: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _sendMessage();
                        _messageController.clear();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}