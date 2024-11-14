import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Center(child: Text("Coming Soon Profile"))
      ),
      bottomNavigationBar: BottomNav(
          pages: pages,
          selectedInd: 2,
      ),
    );
  }
}