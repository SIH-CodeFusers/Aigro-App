import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GovernmentSchemes extends StatefulWidget {
  const GovernmentSchemes({super.key});

  @override
  State<GovernmentSchemes> createState() => _GovernmentSchemesState();
}

class _GovernmentSchemesState extends State<GovernmentSchemes> {
  late Future<List<Map<String, dynamic>>> schemes;
  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.setLanguage("en-US"); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }



  @override
  void initState() {
    super.initState();
    schemes = loadSchemes();
  }

  Future<List<Map<String, dynamic>>> loadSchemes() async {
    final String response = await rootBundle.loadString('assets/others/schemes.json');
    return List<Map<String, dynamic>>.from(json.decode(response));
  }

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text('Schemes for Farmers 🌱'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
    future: schemes,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error loading schemes: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No schemes available'));
      } else {
        List<Map<String, dynamic>> allSchemes = snapshot.data!;
        List<Map<String, dynamic>> filteredData = selectedFilter == 'All'
            ? allSchemes
            : allSchemes.where((scheme) => scheme['state'] == selectedFilter).toList();
              return Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      width: 220,
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        border: Border.all(color: context.theme.primaryColorDark, width: 2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilter = newValue!;
                          });
                        },
                        items: <String>['All','All States', 'Assam', 'Harayana','Odisha','Andhra Pradesh','Tamil Nadu', 'Telangana']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: schemeCard(context, filteredData, index),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }


  Container schemeCard(BuildContext context, List<Map<String, dynamic>> filteredData, int index) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.highlightColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 57, 59, 57).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),     
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  height: 200,
                  width: double.infinity,
                  filteredData[index]['image'] as String,
                  fit: BoxFit.cover,
                )
              ),
              Positioned(
                top: 8,
                right: 8, 
                child: GestureDetector(
                  onTap: (){
                    _speak("${filteredData[index]['title']}. ${filteredData[index]['description']} ");
                  },
                  child: voiceIcon(context),
                )
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.alertCircle,
                  size: 20,
                  color:context.theme.primaryColorDark
                ),
                const SizedBox(width: 1,),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        filteredData[index]['title'] as String,
                        maxLines:1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(                          
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color:context.theme.primaryColorDark
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    FeatherIcons.shield,
                    size: 16,
                    color:context.theme.primaryColorDark
                  ),
                ),
                const SizedBox(width: 4,),
                Expanded(    
                  child: Text(
                    filteredData[index]['description'] as String,
                    style: TextStyle(                          
                      fontSize: 16, 
                      color:Colors.grey[600]
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3, 
                  ),   
                ),  
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.theme.canvasColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (filteredData[index]['key_points'] as List<dynamic>).map((keyPoint) {
                  return Row(
                    children: [
                      Icon(
                        FeatherIcons.disc,
                        size: 14,
                        color:context.theme.primaryColorDark,
                      ),
                      const SizedBox(width: 8,),
                      Flexible(child: Text(keyPoint,style: const TextStyle(fontWeight: FontWeight.w600),)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    FeatherIcons.mapPin,
                    size: 16,
                    color:context.theme.primaryColorDark
                  ),
                ),
                const SizedBox(width: 4,),
                Expanded(    
                  child: Text(
                    'State: ${filteredData[index]['state'] as String}',
                    style: TextStyle(                          
                      fontSize: 16, 
                      color:context.theme.primaryColorDark
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3, 
                  ),   
                ),  
              ],
            ),
          ),

          const SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    FeatherIcons.user,
                    size: 16,
                    color:context.theme.primaryColorDark
                  ),
                ),
                const SizedBox(width: 4,),
                Expanded(    
                  child: Text(
                    'Owner: ${filteredData[index]['owner_of_scheme'] as String}',
                    style: TextStyle(                          
                      fontSize: 16, 
                      color:context.theme.primaryColorDark
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3, 
                  ),   
                ),  
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector( 
              onTap: (){
                _launchURL(filteredData[index]['link'] as String);
              },
              child: Container(
                width: 150,
                height: 48,
                decoration: BoxDecoration(
                  color: context.theme.primaryColorDark,
                  borderRadius: BorderRadius.circular(5),
                ),   
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Visit Here',
                      style: TextStyle(color: context.theme.highlightColor, fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        FeatherIcons.arrowUpRight,
                        size: 16,
                        color:context.theme.highlightColor
                      ),
                    ),
                  ],
                ),                     
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  void _launchURL(String s) async {
    final Uri url = Uri.parse(s);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}