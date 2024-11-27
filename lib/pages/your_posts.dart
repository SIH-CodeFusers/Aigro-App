import 'dart:convert';

import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/widgets/posts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class YourPosts extends StatefulWidget {
  const YourPosts({super.key});

  @override
  State<YourPosts> createState() => _YourPostsState();
}

class _YourPostsState extends State<YourPosts> {
  late Future<List<dynamic>> posts;
  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
    posts = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('$CHAT_BACKEND/api/messages/$BACKEND_UID'));
    if (response.statusCode == 200) {
     
      List<dynamic> allPosts = json.decode(response.body);

      List<dynamic> filteredPosts = allPosts.where((post) {
        return post['name'] ==bdb.userName; 
      }).toList();

      return filteredPosts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text('Your Posts'),
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
            return const Center(child: Text('No posts available.'));
          } else {
            return 
              ListView.builder(
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