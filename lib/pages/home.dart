import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/utils/food_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:aigro/widgets/sparkling_animation.dart';
import 'package:velocity_x/velocity_x.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<Map<String, dynamic>> dashboardData = [
    {
      'color': Colors.blueAccent,
      'text': 'Disease Forecasting',
      'image': 'assets/images/image1.png',
    },
    {
      'color': Colors.greenAccent,
      'text': 'Weather Report',
      'image': 'assets/images/image2.png',
    },
    {
      'color': Colors.orangeAccent,
      'text': 'Community',
      'image': 'assets/images/image3.png',
    },
    {
      'color': Colors.purpleAccent,
      'text': 'Learning Resources',
      'image': 'assets/images/image4.png',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,   
      appBar: AppBar(
         automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.theme.highlightColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: context.theme.cardColor,
                  child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          width: 30,
                          height: 30,
                          "assets/images/boy.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
        
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black,size: 16,),
                Text(
                  'Kolkata, India',
                  style: TextStyle(color: Colors.black,fontSize: 16), 
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: context.theme.highlightColor,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.bell, color: Colors.black,size: 22,),
              ), 
            ),
          ],
        ), 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TextField(
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(Icons.search),
                //     suffixIcon: Padding(
                //       padding: const EdgeInsets.only(right: 10),
                //       child: CircleAvatar(
                //         radius: 20,
                //         backgroundColor: context.theme.canvasColor,
                //         child: Icon(Icons.filter_list,color: context.theme.splashColor,)
                //       ),
                //     ),
                //     hintText: 'Search by food name',
                //     hintStyle: TextStyle(fontSize: 14),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(20),
                //       borderSide: BorderSide.none
                //     ),
         
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(20),
                //       borderSide: BorderSide(width: 1.5, color: context.theme.cardColor)
                //     ),
                //     filled: true,
                //     fillColor: context.theme.highlightColor
                //   ),
                // ),

                // SizedBox(height: 20,),
                SizedBox(height: 10,),
               
                Container(
                  width: double.infinity,
                  height: 155,
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      SparklingAnimation(
                        child: Positioned(
                          right: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 155,
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: context.theme.focusColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(50, 70),
                                bottomLeft: Radius.elliptical(50, 70),
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Text(
                                    "Detect and Treat Diseases with a Simple Image Upload",
                                    style: TextStyle(
                                      color: context.theme.highlightColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.pushNamed(context, '/findRecipe');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.25, // 25% of screen width
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: context.theme.highlightColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Analyse Now",
                                        style: TextStyle(color: context.theme.cardColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Image.asset(
                            width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                            height: 155,
                            "assets/images/woman_chef.png",
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
          

                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),                  
                    child: GridView.builder(    
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 1, 
                      ),
                      itemCount: 4, 
                      itemBuilder: (context, index) {
                        final dashboardInfo = dashboardData[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: dashboardInfo['color'], 
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              dashboardInfo['text'],
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        );
                      },
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(), 
                    ),   
                  ), 

              ],
            ),
          ),
        )
      ),
      bottomNavigationBar: BottomNav(
          pages: pages,
          selectedInd: 0,
      ),
    );
  }
}




