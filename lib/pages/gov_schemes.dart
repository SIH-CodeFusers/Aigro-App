import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class GovernmentSchemes extends StatefulWidget {
  const GovernmentSchemes({super.key});

  @override
  State<GovernmentSchemes> createState() => _GovernmentSchemesState();
}

class _GovernmentSchemesState extends State<GovernmentSchemes> {
  final List<Map<String, Object>> sdata = [
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "One Nation One Fertilizer Scheme",
      'description': "A nationwide initiative to standardize fertilizer branding.",
      'key_points': [
        "Same packaging across India",
        "Affordable fertilizers for farmers",
        "Reduces confusion in purchases",
      ],
      'state': "West Bengal",
      'owner_of_scheme': "Government of India",
      'link': "https://www.adda247.com/jobs/one-nation-one-fertilizer-scheme",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "PM Kisan Samman Nidhi",
      'description': "Financial aid of ₹6000 annually to farmers.",
      'key_points': [
        "Direct benefit transfer",
        "Covers small and marginal farmers",
        "No intermediaries involved",
      ],
      'state': "Tamil Nadu",
      'owner_of_scheme': "Government of India",
      'link': "https://pmkisan.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Telangana Rythu Bandhu Scheme",
      'description': "Investment support for farmers in Telangana.",
      'key_points': [
        "₹5000 per acre per season",
        "Helps with input purchase",
        "Supports small landholders",
      ],
      'state': "Telangana",
      'owner_of_scheme': "Government of Telangana",
      'link': "https://rythubandhu.telangana.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Kisan Credit Card Scheme",
      'description': "Provides easy credit to farmers for input purchases.",
      'key_points': [
        "Low-interest loans",
        "Repayment after harvest",
        "Covers allied activities too",
      ],
      'state': "West Bengal",
      'owner_of_scheme': "Government of India",
      'link': "https://www.pmkisan.gov.in/kcc",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "PM Fasal Bima Yojana",
      'description': "Insurance scheme to protect farmers from crop losses.",
      'key_points': [
        "Low premium for farmers",
        "Covers all crop types",
        "Mitigates weather risks",
      ],
      'state': "Tamil Nadu",
      'owner_of_scheme': "Government of India",
      'link': "https://pmfby.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "e-NAM (National Agriculture Market)",
      'description': "Online trading platform for agricultural produce.",
      'key_points': [
        "Transparent pricing",
        "Connects farmers to buyers",
        "Accessible nationwide",
      ],
      'state': "Telangana",
      'owner_of_scheme': "Government of India",
      'link': "https://enam.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Odisha KALIA Scheme",
      'description': "Financial aid and insurance for Odisha farmers.",
      'key_points': [
        "₹10000 yearly support",
        "Covers input expenses",
        "Includes landless farmers",
      ],
      'state': "West Bengal",
      'owner_of_scheme': "Government of Odisha",
      'link': "https://kalia.odisha.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Andhra Pradesh YSR Rythu Bharosa",
      'description': "Provides investment and crop insurance for farmers.",
      'key_points': [
        "₹13500 annually",
        "Includes tenant farmers",
        "Covers natural disasters",
      ],
      'state': "Tamil Nadu",
      'owner_of_scheme': "Government of Andhra Pradesh",
      'link': "https://ysrrythubharosa.ap.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Haryana Bhavantar Bharpayee Yojana",
      'description': "Price difference compensation for farmers.",
      'key_points': [
        "Supports market-price shortfall",
        "Ensures fair crop value",
        "Incentivizes diversified cropping",
      ],
      'state': "Telangana",
      'owner_of_scheme': "Government of Haryana",
      'link': "https://agriharyana.gov.in",
    },
    {
      'image':
          "https://st.adda247.com/https://www.adda247.com/jobs/wp-content/uploads/sites/4/2022/10/18132922/One-Nation-One-Fertilizer-Scheme.png",
      'title': "Assam CM's Samagra Gramya Unnayan Yojana",
      'description': "Aims to double farmers’ income by 2022.",
      'key_points': [
        "Focus on rural development",
        "Includes infrastructure support",
        "Improves farm practices",
      ],
      'state': "West Bengal",
      'owner_of_scheme': "Government of Assam",
      'link': "https://assam.gov.in",
    },
  ];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object>> filteredData = selectedFilter == 'All'
        ? sdata
        : sdata.where((scheme) => scheme['state'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text('Schemes for Farmers 🌱'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15,),
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
                  items: <String>['All', 'West Bengal', 'Tamil Nadu', 'Telangana']
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
            
            const SizedBox(height: 15,),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    child: Container(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(filteredData[index]['image'] as String)
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
                                children: (filteredData[index]['key_points'] as List<String>).map((keyPoint) {
                                  return Row(
                                    children: [
                                      Icon(
                                        FeatherIcons.disc,
                                        size: 14,
                                        color:context.theme.primaryColorDark,
                                      ),
                                      const SizedBox(width: 8,),
                                      Text(keyPoint,style: const TextStyle(fontWeight: FontWeight.w600),),
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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