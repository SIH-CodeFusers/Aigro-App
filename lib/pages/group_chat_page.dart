import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  BasicDB bdb = BasicDB();

  @override
  void initState() {
    print("helllllo");
    super.initState();
    fetchGroups(widget.groupId); 
    bdb.loadDataInfo(); 
    initializeSocket();
    _messages = group['messages'] ?? [];
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
      // 'name': bdb.userName,
      // 'image': null,
    };

    try {
      socket.emit('addCommentGroup', commentData);
      _messageController.clear();
    } catch (error) {
      print('Error sending message: $error');
    }
    _commentControllers[messageId]?.clear();
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

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.isNotEmpty ? '${group['diseaseName'] ?? 'Group'} Chat' : 'Chat'),
      ),
      body: Column(
        children: [
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

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${message['name'] ?? 'Unknown'}: ${message['message'] ?? 'No message'}'),
                        ...List.generate(
                          message['comments']?.length ?? 0,
                          (i) => Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('- ${message['comments'][i]['comment'] ?? 'No comment'}'),
                          ),
                        ),
                        TextField(
                          controller: _commentControllers[messageId],
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () => _addComment(messageId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
