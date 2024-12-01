import 'package:aigro/pages/group_chat_page.dart';
import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
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
          ? Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(child: Text('No groups found'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "View Your Groups",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
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
