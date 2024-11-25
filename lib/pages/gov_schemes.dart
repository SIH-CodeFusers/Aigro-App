import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class GovernmentSchemes extends StatefulWidget {
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
        title: const Text('Schemes for Farmers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: 200,
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
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black87), 
                ),
              ),
            ),
            
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: context.theme.highlightColor,
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(filteredData[index]['image'] as String),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            filteredData[index]['title'] as String,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(filteredData[index]['description'] as String),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Key Points:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (filteredData[index]['key_points'] as List<String>).map((keyPoint) {
                              return Text("• $keyPoint");
                            }).toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text('State: '),
                              Text(filteredData[index]['state'] as String),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text('Owner: '),
                              Text(filteredData[index]['owner_of_scheme'] as String),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the scheme's link
                              _launchURL(filteredData[index]['link'] as String);
                            },
                            child: const Text('Learn More'),
                          ),
                        ),
                      ],
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

  // Method to launch the URL when a scheme is tapped
  void _launchURL(String url) {
    // You can use the `url_launcher` package to open the link
    // Example: launch(url);
  }
}