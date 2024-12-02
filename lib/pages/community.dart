import 'dart:convert';
import 'dart:io';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/group_chat_home.dart';
import 'package:aigro/pages/your_posts.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/posts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:velocity_x/velocity_x.dart';


class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  late Future<List<dynamic>> posts;
  final TextEditingController _postController = TextEditingController();
  File? _uploadedImagePath;
  final ImagePicker _picker = ImagePicker();
  late final IO.Socket socket;
  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

  @override
  void initState() {
    super.initState();
    posts = fetchPosts();
    initializeSocket();
    bdb.loadDataInfo(); 
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
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

    Future<void> handleCreatePost(String message, String? imageUrl) async {
    try {
      final url = Uri.parse('$CHAT_BACKEND/api/create-message');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "name": bdb.userName,
          "sender": BACKEND_UID,
          "image": imageUrl ?? null,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        socket.emit("newPost", responseData);
        
      } else {
        throw Exception('Failed to create post');
      }
    } catch (error) {
      print("Error creating post: $error");
    }
  }

  void showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: context.theme.canvasColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: translateHelper('Create Post',const TextStyle(),ldb.language)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _postController,
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
              SizedBox(height: 12),
              if (_uploadedImagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Image.file(
                    _uploadedImagePath!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _pickImage().then((_) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: context.theme.highlightColor,
                        ),
                        SizedBox(width: 8),
                        translateHelper("Upload Image", TextStyle(
                            color: context.theme.highlightColor,
                            fontSize: 16,
                          ), ldb.language)
                      ],
                    ),
                  ),
                ),

            ],
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
                  String imgURL = await uploadImage(_uploadedImagePath!);
                  handleCreatePost(_postController.text,imgURL);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Community()),
                    (Route<dynamic> route) => route.isFirst, 
                  );   
                },
                child: Text('Post', style: TextStyle(color: context.theme.highlightColor)),
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
                  _postController.clear();
                  setState(() {
                    _uploadedImagePath = null;
                  });
                },
                child: Text('Close', style: TextStyle(color: context.theme.highlightColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Future<String> uploadImage(File file) async {
    try {
      final String fileName = 'Test/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload is $progress% done');
      });

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      throw Exception("Something went wrong: $error");
    }
  }


  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String? mimeType = lookupMimeType(file.path);
      if (mimeType != null && (mimeType.contains("jpg") || mimeType.contains("jpeg") || mimeType.contains("png"))) {
        if (await file.length() <= 500 * 1024) {
          setState(() {
            _uploadedImagePath = file;
          });
        } else {
          _showAlert("File size exceeds 500kb limit.");
        }
      } else {
        _showAlert("Please select a correct Image Format.");
      }
    }
  }


  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('${CHAT_BACKEND}/api/messages'));
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
        title:translateHelper('Community', const TextStyle(), ldb.language)
      ),
      body: FutureBuilder<List<dynamic>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: context.theme.primaryColorDark,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Stack(
              children: [
                Center(
                  child: Text('No posts available.')
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: bottomButtonsCommunity(context),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(bottom: 120.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    return PostWidget(post: post);
                  },
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: bottomButtonsCommunity(context),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Column bottomButtonsCommunity(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: GestureDetector(
                  onTap: () {
                    showCreatePostDialog();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.theme.primaryColorDark,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          translateHelper('Create Post', TextStyle(color: context.theme.highlightColor, fontSize: 14),ldb.language),
                          SizedBox(width: 5,),
                          Icon(FeatherIcons.plus,size: 16,color: context.theme.highlightColor,)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        
            SizedBox(width: 10,),
            
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YourPosts()),
                      
                    );  
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.theme.primaryColorDark,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          translateHelper('Your Posts', TextStyle(color: context.theme.highlightColor, fontSize: 14),ldb.language),                
                          SizedBox(width: 5,),
                          Icon(FeatherIcons.users,size: 16,color: context.theme.highlightColor,)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupChatHome()),
                
              );  
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: context.theme.primaryColorDark,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    translateHelper('View Groups', TextStyle(color: context.theme.highlightColor, fontSize: 14),ldb.language),                
                    SizedBox(width: 5,),
                    Icon(FeatherIcons.messageCircle,size: 16,color: context.theme.highlightColor,)
                  ],
                ),
              ),
            ),
          ),
        ),                  
      ],
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

