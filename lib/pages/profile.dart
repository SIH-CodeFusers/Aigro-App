import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/home.dart';
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

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

  String selectedLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
  }

   saveLang() {
    setState(() {
      ldb.language = selectedLanguageCode;  
    });
    ldb.updateLang();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false, 
    );
   }

  saveForm() {
     setState(() {
      db.startHome = true;
    });
    db.updateTheme();
    Navigator.pushNamed(context, Myroutes.getStartedRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.theme.highlightColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.grey[700], size: 20),
                          ), 
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30),
                SizedBox(height: 30),
                _buildProfileInfo(),
                SizedBox(height: 10),
                _buildLanguageDropdown(),
                SizedBox(height: 20),

                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: GestureDetector(
                    onTap: () {
                      saveLang();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorDark,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Update Form',
                          style: TextStyle(color: context.theme.highlightColor, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
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


  Widget _buildLanguageDropdown() {
    return Container(
      padding:  EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      width: double.infinity,
       decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8), 
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Language",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87, 
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
           
            child: DropdownButton<String>(
              value: selectedLanguageCode,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                DropdownMenuItem(value: 'bn', child: Text('Bengali')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguageCode = newValue!;
                });
              },
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87, 
              ),
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.black87), 
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildListTile("Name", bdb.userName)),
            SizedBox(width: 10),
            Expanded(child: _buildListTile("Phone", bdb.userPhn)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildListTile("Country", bdb.userCountry)),
            SizedBox(width: 10),
            Expanded(child: _buildListTile("State", bdb.userState)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildListTile("District", bdb.userDistrict)),
            SizedBox(width: 10),
            Expanded(child: _buildListTile("Block", bdb.userBlock)),
          ],
        ),
        SizedBox(height: 10),
        _buildListTile("Pin Code", bdb.userPin),
        SizedBox(height: 10),
        _buildListTile("Your Crops", bdb.userCrops.join(", ")),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
    );
  }
}
