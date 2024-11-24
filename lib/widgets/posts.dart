import 'dart:ui';
import 'package:aigro/local_db/db.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:aigro/pages/community.dart';
import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:math';

const colors = [
  "FF5733",
  "33FF57",
  "3357FF",
  "FF33A1",
  "A133FF",
  "33FFF5",
  "FF8C33",
  "FF3333",
];

String getInitials(String name) {
  List<String> words = name.split(' ');
  String initials = '';
  if (words.isNotEmpty) initials += words[0][0];
  if (words.length > 1) initials += words[1][0];
  return initials.toUpperCase();
}

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool showComments = false;
  final TextEditingController _commentController = TextEditingController();
  late final IO.Socket socket;
  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  @override
  void initState() {
    super.initState();
    initializeSocket();
    bdb.loadDataInfo(); 
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

    socket.onConnect((_) {
      print('Socket connected');
    });

    socket.onConnectError((error) {
      print('Connection Error: $error');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });
  }


  void toggleComments() {
    setState(() {
      showComments = !showComments;
    });
  }

  Future<void> addComment(String postId, String commentText) async {
    if (commentText.trim().isEmpty || postId.isEmpty) return;

    final newCommentData = {
      "messageId": postId,
      "comment": commentText,
      "commentImage": null,
      "commenterName": bdb.userName,
    };

    try {
      socket.emit("addComment", newCommentData);
    } catch (error) {
      print("Error adding comment: $error");
    }
  }


  void showAddCommentDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.theme.highlightColor,
        title:  Center(child: Text('Add Comment')),
        content:  TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Enter your post...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1, color: Colors.grey[400] ?? Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1, color: Colors.grey[400] ?? Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1, color: Colors.grey[400] ?? Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
              decoration: BoxDecoration(
                color: context.theme.primaryColorDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  addComment(id,_commentController.text);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Community()),
                    (Route<dynamic> route) => route.isFirst, 
                  );   
                },
                child: Text('Comment', style: TextStyle(color: context.theme.highlightColor)),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                   Navigator.of(context).pop();
                  _commentController.clear();
                  
                },
                child: Text('Close', style: TextStyle(color: context.theme.highlightColor)),
              ),
            ),
          ],
      ),
    );
  }

  Color getRandomColor() {
    final random = Random();
    String colorHex = colors[random.nextInt(colors.length)];
    return Color(int.parse('0xFF$colorHex'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.theme.highlightColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.theme.canvasColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 57, 59, 57).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getRandomColor(),
                  child: Text(getInitials(widget.post['name'] ?? 'Unknown User'),style: TextStyle(color: context.theme.highlightColor),),
                  radius: 18,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.post['name'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(widget.post['createdAt']).toLocal()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),    
            if (widget.post['image'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.post['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.post['name']}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextSpan(
                      text: widget.post['message'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.post['comments'] != null && widget.post['comments'].isNotEmpty)
                GestureDetector(
                  onTap: toggleComments,
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.eye,
                        color: context.theme.cardColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        showComments ? 'View Less' : 'View Comments',
                        style: TextStyle(
                          color: context.theme.cardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () => showAddCommentDialog(widget.post['_id']),
                child: Row(
                    children: [
                      Icon(
                        FeatherIcons.plus,
                        color: context.theme.cardColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Comment',
                        style: TextStyle(
                          color: context.theme.cardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (showComments && widget.post['comments'] != null)
              for (var comment in widget.post['comments']) CommentWidget(comment: comment),
          ],
        ),
      ),
    );
  }
}


class CommentWidget extends StatelessWidget {
  final Map<String, dynamic> comment;

  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: context.theme.focusColor,
            child: Text(getInitials(comment['commenterName'] ?? 'Unknown User'),style: TextStyle(fontSize: 12),),
            radius: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['commenterName'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  comment['comment'] ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(comment['createdAt']).toLocal())}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
