import 'dart:ui';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
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
        title:   Center(child:translateHelper('Add Comment', const TextStyle(), ldb.language)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
              decoration: BoxDecoration(
                color: context.theme.primaryColorDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  addComment(id,_commentController.text);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Community()),
                    (Route<dynamic> route) => route.isFirst, 
                  );   
                },
                child: Text('Comment', style: TextStyle(color: context.theme.highlightColor)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
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

  Future<String> _translateText(String text) async {
    return await translateTextInput(text, ldb.language);
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
            color: const Color.fromARGB(255, 57, 59, 57).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
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
                  radius: 18,
                  child: Text(getInitials(widget.post['name'] ?? 'Unknown User'),style: TextStyle(color: context.theme.highlightColor),),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    translateHelper(widget.post['name'] ?? 'Unknown User', const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), ldb.language),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(widget.post['createdAt']).toLocal()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: (){
                    _speak("${widget.post['message'] ?? ''}");
                  },
                  child: voiceIcon(context),
                )
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
              child: FutureBuilder<Map<String, String>>(
                future: Future.wait([
                  _translateText(widget.post['name'] as String),
                  _translateText(widget.post['message'] as String? ?? ''),
                ]).then((results) => {'name': results[0], 'message': results[1]}),
                builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Translating name: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextSpan(
                            text: 'Translating message...',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Error loading name: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextSpan(
                            text: 'Error loading message',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${snapshot.data?['name']}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextSpan(
                            text: snapshot.data?['message'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }
                },
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
                      translateHelper(showComments ? 'View Less' : 'View Comments', 
                        TextStyle(
                          color: context.theme.cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                          ),
                        ldb.language
                      )                    
                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                GestureDetector(
                  onTap: () => showAddCommentDialog(widget.post['_id']),
                child: Row(
                    children: [
                      Icon(
                        FeatherIcons.plus,
                        color: context.theme.cardColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      translateHelper('Add Comment', TextStyle(
                          color: context.theme.cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                        ),
                        ldb.language
                      )  
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (showComments && widget.post['comments'] != null)
              for (var comment in widget.post['comments']) CommentWidget(comment: comment,language:ldb.language),
          ],
        ),
      ),
    );
  }
  FutureBuilder<String> translateHelper(String title, TextStyle style, String lang) {
    return FutureBuilder<String>(
      future: translateTextInput(title, lang),
      builder: (context, snapshot) {
        String displayText = snapshot.connectionState == ConnectionState.waiting || snapshot.hasError
            ? title
            : snapshot.data ?? title;

        return Text(displayText, style: style);
      },
    );
  }
}


class CommentWidget extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String language;

  const CommentWidget({Key? key, required this.comment,required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: context.theme.focusColor,
            radius: 15,
            child: Text(getInitials(comment['commenterName'] ?? 'Unknown User'),style: TextStyle(fontSize: 12),),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                translateHelper(comment['commenterName'] ?? 'Anonymous',const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),language),
                translateHelper(comment['comment'] ?? '',const TextStyle(fontSize: 12),language),
                translateHelper(
                  DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(comment['createdAt']).toLocal()), 
                  TextStyle(color: Colors.grey[600], fontSize: 10), 
                  language
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<String> translateHelper(String title, TextStyle style, String lang) {
    return FutureBuilder<String>(
      future: translateTextInput(title, lang),
      builder: (context, snapshot) {
        String displayText = snapshot.connectionState == ConnectionState.waiting || snapshot.hasError
            ? title
            : snapshot.data ?? title;

        return Text(displayText, style: style);
      },
    );
  }
}
