import 'dart:convert';

import 'package:aigro/secret.dart';
import 'package:aigro/widgets/posts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class YourPosts extends StatefulWidget {
  const YourPosts({super.key});

  @override
  State<YourPosts> createState() => _YourPostsState();
}

class _YourPostsState extends State<YourPosts> {
  late Future<List<dynamic>> posts;

  @override
  void initState() {
    super.initState();
    posts = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('${CHAT_BACKEND}/api/messages/${BACKEND_UID}'));
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
        title: Text('Your Posts'),
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