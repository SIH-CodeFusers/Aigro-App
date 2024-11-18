import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final startbox = Hive.box("Start_db");
  StartPointer db = StartPointer();

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
  }

  saveForm() {
    setState(() {
      db.startHome = false;
    });

    db.updateTheme();
    Navigator.pushNamed(context, Myroutes.getStartedRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                   children: [
                     Text(
                        "🌱 Profile Page",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: context.theme.primaryColorDark,
                        ),
                      ),
                      GestureDetector(
                      onTap: () => saveForm(),
                      child: Center(
                        child:  Container(
                          decoration: BoxDecoration(
                            color: context.theme.highlightColor,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.grey[700],size: 20,),
                          ), 
                        ),
                      ),
                    ),
                   ],
                 ),
                
                SizedBox(height: 30),
                _buildProfileInfo(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        pages: pages,
        selectedInd: 2,
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _buildListTile("Name", bdb.userName),
        _buildListTile("Phone", bdb.userPhn),
        _buildListTile("Country", bdb.userCountry),
        _buildListTile("State", bdb.userState),
        _buildListTile("District", bdb.userDistrict),
        _buildListTile("Block", bdb.userBlock),
        _buildListTile("Pin Code", bdb.userPin),
        _buildListTile("Selected Crops", bdb.userCrops.join(", ")),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(subtitle),
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        Icons.info_outline,
        color: context.theme.cardColor,
      ),
    );
  }
}
