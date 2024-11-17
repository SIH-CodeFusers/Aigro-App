import 'package:hive/hive.dart';


class StartPointer{

  bool startHome=false;

  final startbox = Hive.box("Start_db");

  void createTheme() {
    startHome = false;
  }

  void loadTheme() {
    startHome = startbox.get("START");
  }

  void updateTheme() {
    startbox.put("START", startHome);
  }

}

class BasicDB {
  final infobox = Hive.box("BasicInfo-db");

  String userName = "";
  String userPhn = "";
  String userCountry = "";
  String userState = "";
  String userDistrict = "";
  String userBlock = "";
  String userPin = "";
  List<String> userCrops = [];


  void createInitialInfo() {
    userName = "Admin";
    userPhn = "000000";
    userCountry = "";
    userState = "";
    userDistrict = "";
    userBlock = "";
    userPin = "";
    userCrops = [];
  }


  void loadDataInfo() {
    userName = infobox.get("NAMEDB") ?? "";
    userPhn = infobox.get("PHNDB") ?? "";
    userCountry = infobox.get("COUNTRYDB") ?? "";
    userState = infobox.get("STATEDB") ?? "";
    userDistrict = infobox.get("DISTRICTDB") ?? "";
    userBlock = infobox.get("BLOCKDB") ?? "";
    userPin = infobox.get("PINDB") ?? "";
    userCrops = List<String>.from(infobox.get("CROPSDB") ?? []);
  }

  void updateDbInfo() {
    infobox.put("NAMEDB", userName);
    infobox.put("PHNDB", userPhn);
    infobox.put("COUNTRYDB", userCountry);
    infobox.put("STATEDB", userState);
    infobox.put("DISTRICTDB", userDistrict);
    infobox.put("BLOCKDB", userBlock);
    infobox.put("PINDB", userPin);
    infobox.put("CROPSDB", userCrops); 
  }

  // // Optional: Method to update crops data
  // void updateCrops(List<String> crops) {
  //   userCrops = crops;
  //   updateDbInfo();  // Save updated crops info
  // }
}