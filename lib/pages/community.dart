import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  late Future<List<dynamic>> posts;

  @override
  void initState() {
    super.initState();
    posts = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('https://chat.thefuturetech.xyz/api/messages'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];
                return PostWidget(post: post);
              },
            );
          }
        },
      ),
    );
  }
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

  void toggleComments() {
    setState(() {
      showComments = !showComments;
    });
  }

  void addComment(String commentText) {
    if (commentText.isNotEmpty) {
      setState(() {
        widget.post['comments'] ??= [];
        widget.post['comments'].add({
          'commenterName': 'User', // Replace with actual username if available
          'comment': commentText,
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // void showAddCommentDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Add a Comment'),
  //       content: TextField(
  //         controller: _commentController,
  //         decoration: const InputDecoration(hintText: 'Enter your comment here'),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             addComment(_commentController.text);
  //           },
  //           child: const Text('Submit'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             _commentController.clear();
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
              // onTap: showAddCommentDialog,
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
