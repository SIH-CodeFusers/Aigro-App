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
      "commenterName": "test user",
    };

    try {
      socket.emit("addComment", newCommentData);
    } catch (error) {
      print("Error adding comment: $error");
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void showAddCommentDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a Comment'),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(hintText: 'Enter your comment here'),
        ),
        actions: [
          TextButton(
            onPressed: () {   
              addComment(id,_commentController.text,);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Community()),
                (Route<dynamic> route) => route.isFirst, 
              );      
            },
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _commentController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
                  backgroundColor: context.theme.focusColor,
                  child: Text(widget.post['name'][0]),
                  radius: 18,
                ),
                SizedBox(width: 10,),
                Text(
                  widget.post['name'] ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 10,),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(widget.post['createdAt']).toLocal()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.post['message'] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (widget.post['image'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
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
            GestureDetector(
              onTap:(){ showAddCommentDialog(widget.post['_id']);},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FeatherIcons.plus, color: context.theme.highlightColor),
                    SizedBox(width: 4,),
                    Text("Add",style: TextStyle(color: context.theme.highlightColor),),
                    SizedBox(width: 4,),
                  ],
                ),            
              ),
            ),

            if (widget.post['comments'] != null && widget.post['comments'].isNotEmpty) ...[
              SizedBox(height: 10,),
              Divider(
                indent: 10,
                endIndent: 10,
                color: Colors.grey[300],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: GestureDetector(
                  onTap: toggleComments,
                  child: Text(
                    showComments ? 'View Less' : 'View Commnets',
                    style: TextStyle(
                      color: context.theme.cardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (showComments) ...[
                for (var comment in widget.post['comments']) CommentWidget(comment: comment),
              ],
            ],
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
            child: Text(comment['commenterName'][0]),
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
                  'Commented at: ${DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(comment['createdAt']).toLocal())}',
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
