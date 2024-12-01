import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/group_chat_page.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:velocity_x/velocity_x.dart';

class GroupChatHome extends StatefulWidget {
  const GroupChatHome({super.key});

  @override
  State<GroupChatHome> createState() => _GroupChatHomeState();
}

class _GroupChatHomeState extends State<GroupChatHome> {
  List<dynamic> _groups = [];
  bool _isLoading = true;
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    await flutterTts.setLanguage(ldb.language); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }
  

  @override
  void initState() {
    super.initState();
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    const String apiUrl = '$CHAT_BACKEND/yourgroups/$BACKEND_UID';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _groups = data['groups'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (error) {
      print('Error fetching groups: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: Text('Group Chats'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
            color: context.theme.primaryColorDark,
          ))
          : _groups.isEmpty
              ? Center(child: Text('No groups found'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                     
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "View Your Groups",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 20,),
                             GestureDetector(
                              onTap: () {
                                _speak("View all your groups here");
                              },
                              child: voiceIcon(context),
                            ),
                          ],
                        ),
                      
                      SizedBox(height: 20),
                      ..._groups.map((group) {
                        return Card(
                          color: Theme.of(context).highlightColor,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).cardColor,
                              child: Text(
                                group['diseaseName'][0],
                                style: TextStyle(color: context.theme.highlightColor, fontSize: 18),
                              ),
                            ),
                            title: Text(
                              group['diseaseName'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Pincode: ${group['pincode']}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupChatPage(groupId: group['_id']),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                )
    );
  }
}
