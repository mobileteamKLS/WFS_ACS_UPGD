import 'dart:async';
import 'dart:convert';

import 'package:luxair/otherpages/bookedslotslist.dart';
import 'package:luxair/otherpages/slotlist.dart';
import 'package:luxair/otherpages/viewslotbooking.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:luxair/dashboards/login.dart';
import 'package:luxair/datastructure/userdetails.dart';
import 'package:luxair/global.dart';
import 'package:luxair/otherpages/cargodrop.dart';
import 'package:luxair/otherpages/cargopickup.dart';
import 'package:luxair/otherpages/dockin.dart';
import 'package:luxair/otherpages/dockout.dart';
import 'package:luxair/otherpages/dockstatus.dart';
import 'package:luxair/otherpages/feedback.dart';
import 'package:luxair/otherpages/recordpodlist.dart';
import 'package:luxair/otherpages/truckeryardcheckinlist.dart';
import 'package:luxair/otherpages/vehiclemovementtrackinglist.dart';
import 'package:luxair/otherpages/vehicletokenlist.dart';
import 'package:luxair/otherpages/warehouseacclist.dart';
import 'package:luxair/widgets/customdialogue.dart';
import 'package:luxair/widgets/headers.dart';
import '../constants.dart';
import '../datastructure/vehicletoken.dart';
import '../widgets/common.dart';
import 'homescreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Dashboards extends StatefulWidget {
  Dashboards({Key? key}) : super(key: key);

  @override
  State<Dashboards> createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  var printDate = ""; //DateFormat('dd-MMM-yyyy hh:mm').format(DateTime.now());
  bool useMobileLayout = false;
  late Timer _timer;
  List<WarehouseBaseStationBranch> dummyList = [
    // WarehouseBaseStationBranch(
    //     organizationId: 0,
    //     organizationBranchId: 0,
    //     orgName: "Select",
    //     orgBranchName: "Select")
  ];
  // String selectedBaseStation = "Select";
  String selectedBaseStationBranch = "Select Terminal";

  @override
  void initState() {
    printDate = DateFormat('dd-MMM-yyyy hh:mm').format(DateTime.now());
    // Timer.periodic(Duration(seconds:1), (Timer t)=>getCurrentDateTime());
    _timer = new Timer.periodic(
        Duration(seconds: 1), (Timer timer) => getCurrentDateTime());
    selectedBaseStationBranchID=0;
    selectedBaseStationID=0;
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool isTerminalSelected() {
    if (selectedBaseStationID == 0 || selectedBaseStationBranchID == 0) {
      return false;
    }
    return true;
  }

  void getCurrentDateTime() {
    setState(() {
      printDate = DateFormat('dd-MMM-yyyy hh:mm').format(DateTime.now());
    });
  }

  changeValue() async {
    await getBaseStationBranch(selectedBaseStationID);
    print("******* ${baseStationBranchList.toString()} ********");
    setState(() {
      dummyList = baseStationBranchList;
    });
  }

  getBaseStationBranch(cityId) async {
    baseStationBranchList = [];
    dummyList = [];
    selectedBaseStationBranchID = 0;
    selectedBaseStationBranch = "Select Terminal";
    var queryParams = {"CityId": cityId, "OrganizationId": loggedinUser.OrganizationId.toString(), "UserId": loggedinUser.CreatedByUserId.toString()};
    await Global()
        .postData(
      Settings.SERVICES['GetBaseStationBranch'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);

      var msg = json.decode(response.body)['d'];
      var resp = json.decode(msg).cast<Map<String, dynamic>>();

      baseStationBranchList = resp
          .map<WarehouseBaseStationBranch>(
              (json) => WarehouseBaseStationBranch.fromJson(json))
          .toList();

      WarehouseBaseStationBranch wt = new WarehouseBaseStationBranch(
          orgName: "",
          organizationId: 0,
          organizationBranchId: 0,
          orgBranchName: "Select");
      // baseStationBranchList.add(wt);
      baseStationBranchList.sort(
              (a, b) => a.organizationBranchId.compareTo(b.organizationBranchId));

      print("length baseStationList = " +
          baseStationBranchList.length.toString());
      print(baseStationBranchList.toString());
      setState(() {});
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  selectTerminalBox() {
    return Container(
      height: MediaQuery.of(context).size.height / 5.2, // height: 250,
      width: MediaQuery.of(context).size.width / 3.2,
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Text(
                      "Select Base Station",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/1.2 ,
                    child: Wrap(
                      spacing: 2.5,
                      children: List<Widget>.generate(
                        baseStationList.length,
                            (int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical :3.0,horizontal: 2.0),
                            child: ChoiceChip(
                              label: Text(' ${baseStationList[index].airportcode}',),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                              padding:const EdgeInsets.symmetric(horizontal: 18.0,vertical: 0.0) ,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Color(0xFF1D24CA),
                              selectedColor: Color(0xfff85927),
                              showCheckmark: false,
                              selected: selectedBaseStationID == baseStationList[index].cityid,
                              onSelected: (bool selected) {
                                setState(() async {
                                  selectedBaseStationID = (selected ? baseStationList[index].cityid : null)!;
                                  selectedBaseStation=baseStationList[index].airportcode;
                                  print(selectedBaseStationID);
                                  await changeValue();
                                  setState(() {});
                                });
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Text(
                      dummyList.length!=0?"Select Terminal":"",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),


                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child:Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          dummyList.length,
                              (int index) {
                            return ChoiceChip(
                              label: Text(' ${dummyList[index].orgBranchName}'),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                              // padding:const EdgeInsets.symmetric(horizontal: 18.0,vertical: 4.0) ,
                              selected: selectedBaseStationBranchID == dummyList[index].organizationBranchId,
                              showCheckmark: false,
                              selectedColor: Color(0xfff85927),
                              backgroundColor: Color(0xFF1D24CA),

                              onSelected: (bool selected) {
                                setState(() {
                                  selectedBaseStationBranchID = (selected ? dummyList[index].organizationBranchId : null)!;
                                  selectedBaseStationBranch = (selected ? dummyList[index].orgBranchName : null)!;

                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  )
                ],
              ),
              // },),

              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                  child: ElevatedButton(
                    //textColor: Colors.black,
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)), //
                      padding: const EdgeInsets.all(0.0),
                    ),
                    child: Container(
                      height: 36,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Clear',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF11249F)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                  child: ElevatedButton(
                    //textColor: Colors.black,
                    onPressed: () {
                      // setState(() {});
                      // if (selectedBaseStationID == 0 || selectedBaseStationBranchID == 0) {
                      //   print("$selectedBaseStationID ======= $selectedBaseStationBranchID");
                      //   return;
                      // }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)), //
                      padding: const EdgeInsets.all(0.0),
                    ),
                    child: Container(
                      height: 36,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFF1220BC),
                            Color(0xFF3540E8),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'OK',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = smallestDimension < 600;
    return Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //     image: NetworkImage(
          //         "https://static.vecteezy.com/system/resources/previews/005/658/973/non_2x/abstract-background-illustration-wallpaper-with-blue-light-color-blue-grid-mosaic-background-creative-design-templates-free-vector.jpg"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(children: [
                  Opacity(
                    //semi red clippath with more height and with 0.5 opacity
                    opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(), //set our custom wave clipper
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF4364F7),
                              Color(0xFFa8c0ff),
                            ],
                          ),
                        ),
                        //color:Colors.deepOrangeAccent,
                        height: MediaQuery.of(context).size.height / 3, //200,
                      ),
                    ),
                  ),
                  ClipPath(
                    //upper clippath with less height
                    clipper: WaveClipper(), //set our custom wave clipper.
                    child: Container(
                      padding: kIsWeb
                          ? EdgeInsets.only(bottom: 56)
                          : EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFF3383CD),
                            Color(0xFF11249F),
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 3.2,
                      //180,
                      alignment: Alignment.center,

                      child: DefaultTextStyle(
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 15, //52,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        child: Padding(
                          padding: useMobileLayout
                              ? const EdgeInsets.only(left: 16.0, right: 16.0)
                              : const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 18.0, left: 8, right: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                          mainAxisAlignment: kIsWeb
                                              ? MainAxisAlignment.center
                                              : useMobileLayout
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.center,
                                          crossAxisAlignment: useMobileLayout
                                              ? CrossAxisAlignment.center
                                              : CrossAxisAlignment.center,
                                          children: [
                                            if (!useMobileLayout)
                                              ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                  child: Image.asset(
                                                      "assets/images/kls.jpg",
                                                      //YVR.png", //WFS_logo.png",
                                                      fit: kIsWeb
                                                          ? BoxFit.fill
                                                          : useMobileLayout
                                                          ? BoxFit.fitWidth
                                                          : BoxFit.fitWidth)),
                                            if (useMobileLayout)
                                              Container(
                                                // decoration: BoxDecoration(
                                                //   border: Border.all(
                                                //       width: 4.0, color: Colors.white),
                                                // ),
                                                height: kIsWeb
                                                    ? 140
                                                    : MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                    6.5,
                                                width: kIsWeb
                                                    ? 300
                                                    : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                    3,
                                                child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(5),
                                                    child: Image.asset(
                                                        "assets/images/kls.jpg",
                                                        //YVR.png", //WFS_logo.png",
                                                        fit: kIsWeb
                                                            ? BoxFit.fill
                                                            : useMobileLayout
                                                            ? BoxFit.fitWidth
                                                            : BoxFit.fitWidth)),
                                              ),
                                            SizedBox(
                                                width: kIsWeb
                                                    ? 24
                                                    : useMobileLayout
                                                    ? 16
                                                    : 32),
                                            Padding(
                                              padding: kIsWeb
                                                  ? const EdgeInsets.only(top: 8.0)
                                                  : useMobileLayout
                                                  ? const EdgeInsets.only(top: 8.0)
                                                  : const EdgeInsets.only(top: 2.0),
                                              child: Column(
                                                mainAxisAlignment: useMobileLayout
                                                    ? MainAxisAlignment.center
                                                    : MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  if (useMobileLayout)
                                                  // Text(
                                                  //   "Welcome",
                                                  //   style: TextStyle(
                                                  //       fontSize: useMobileLayout
                                                  //           ? MediaQuery.of(context)
                                                  //                   .size
                                                  //                   .width /
                                                  //               22
                                                  //           : 28,
                                                  //       fontWeight: FontWeight.bold,
                                                  //       color: Colors.white),
                                                  // ),
                                                    DefaultTextStyle(
                                                      style: TextStyle(
                                                          fontSize:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                              24,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white),
                                                      child: AnimatedTextKit(
                                                        animatedTexts: [
                                                          TyperAnimatedText(
                                                              'Bonjour !!'),
                                                          TyperAnimatedText(
                                                              'Welcome !!'),
                                                          // TyperAnimatedText('Bienvenida !!'),
                                                          // TyperAnimatedText('ਸੁਆਗਤ ਹੈ !!'),
                                                          TyperAnimatedText(
                                                              'नमस्ते !!'),
                                                          TyperAnimatedText(
                                                              'Bienvenida !!'),
                                                          TyperAnimatedText(
                                                              'Welcome !!'),
                                                        ],
                                                      ),
                                                    ),
                                                  useMobileLayout
                                                  ? SizedBox(
                                                      width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2.7,
                                                      child: Text(
                                                        loggedinUser.UserId,
                                                        style: TextStyle(
                                                            fontSize: useMobileLayout
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    20
                                                                : 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white),
                                                      ),
                                                    )
                                                  : Text(
                                                      "Welcome " +
                                                          loggedinUser.UserId,
                                                      style: TextStyle(
                                                        fontSize: useMobileLayout
                                                            ? MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width /
                                                            20
                                                            : 28,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.white),
                                                  ),

                                              if (!useMobileLayout)
                                                Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5.0),
                                                      child: Text(
                                                        printDate,
                                                        //"28 June 2022 23:40 ",
                                                        style: TextStyle(
                                                          fontSize: useMobileLayout
                                                              ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                              25
                                                              : 26,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  useMobileLayout
                                                      ? SizedBox(height: 6)
                                                      : SizedBox(height: 10),
                                                  // if (isGHA)
                                                  //   SizedBox(
                                                  //     width: useMobileLayout
                                                  //         ? MediaQuery.of(context)
                                                  //                 .size
                                                  //                 .width /
                                                  //             2.6
                                                  //         : 230,
                                                  //     height: useMobileLayout
                                                  //         ? MediaQuery.of(context)
                                                  //                 .size
                                                  //                 .height /
                                                  //             18
                                                  //         : 50,
                                                  //     child:
                                                  //         DropdownButtonHideUnderline(
                                                  //       child: Container(
                                                  //         constraints: BoxConstraints(
                                                  //             minHeight: 50),
                                                  //         decoration: BoxDecoration(
                                                  //           border: Border.all(
                                                  //               color: Colors.grey,
                                                  //               width: 0.2),
                                                  //           borderRadius:
                                                  //               BorderRadius.all(
                                                  //                   Radius.circular(5)),
                                                  //           color: Colors.white,
                                                  //         ),
                                                  //         padding: EdgeInsets.symmetric(
                                                  //             horizontal: 10),
                                                  //         child: DropdownButton(
                                                  //           value: selectedTerminalID,
                                                  //           items: terminalsList
                                                  //               .map((terminal) {
                                                  //             return DropdownMenuItem(
                                                  //               child: Text(
                                                  //                   terminal
                                                  //                       .custodianName
                                                  //                       .toUpperCase(),
                                                  //                   style: useMobileLayout
                                                  //                       ? mobileTextFontStyle
                                                  //                       : iPadYellowTextFontStyleBold),
                                                  //               //label of item
                                                  //               value: terminal
                                                  //                   .custudian, //value of item
                                                  //             );
                                                  //           }).toList(),
                                                  //           onChanged: (value) {
                                                  //             setState(() {
                                                  //               selectedTerminal =
                                                  //                   value.toString();
                                                  //               selectedTerminalID =
                                                  //                   int.parse(value
                                                  //                       .toString());
                                                  //             });
                                                  //           },
                                                  //           // items: [
                                                  //           //   "Select",
                                                  //           //   "Two",
                                                  //           //   "Three"
                                                  //           // ]
                                                  //           //     .map((String
                                                  //           // value) =>
                                                  //           //     DropdownMenuItem(
                                                  //           //       value:
                                                  //           //       value,
                                                  //           //       child:
                                                  //           //       Column(
                                                  //           //         mainAxisAlignment:
                                                  //           //         MainAxisAlignment.center,
                                                  //           //         crossAxisAlignment:
                                                  //           //         CrossAxisAlignment.start,
                                                  //           //         children: [
                                                  //           //           Text(
                                                  //           //             value,
                                                  //           //             style: TextStyle(
                                                  //           //               fontSize: 14,
                                                  //           //               fontWeight: FontWeight.normal,
                                                  //           //               color: Colors.black,
                                                  //           //             ),
                                                  //           //           ),
                                                  //           //         ],
                                                  //           //       ),
                                                  //           //     ))
                                                  //           //     .toList(),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                ],
                                              ),
                                            ),

                                            if (kIsWeb)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 40.0, top: 16.0),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        //perform logout
                                                        //clear share prefs
                                                        //go to login screen
                                                        var userSelection =
                                                        await showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                          context) =>
                                                              CustomConfirmDialog(
                                                                  title:
                                                                  "Logout Confirm ?",
                                                                  description:
                                                                  "Are you sure you want to logout ?",
                                                                  buttonText: "Yes",
                                                                  imagepath:
                                                                  'assets/images/question.gif',
                                                                  isMobile:
                                                                  useMobileLayout),
                                                        );
                                                        print("userSelection ==" +
                                                            userSelection.toString());
                                                        if (userSelection !=
                                                            null) if (userSelection == true) {
                                                          SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          prefs.clear();

                                                          loggedinUser = new UserDetails(
                                                              UserId: "",
                                                              OrgName: "",
                                                              Name: "",
                                                              EmailId: "",
                                                              MobileNo: "",
                                                              OrganizationBranchId: 0,
                                                              OrganizationId: 0,
                                                              CreatedByUserId: 0,
                                                              OrganizationTypeId: 0,
                                                              IsWFSIntegration: "",
                                                              OrganizationBranchIdString:
                                                              "",
                                                              OrganizationtypeIdString:
                                                              "");
                                                          selectedTerminal = "";
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    HomeScreen()),
                                                          );
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.home,
                                                        size: 48,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 24.0),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          var userSelection =
                                                          await showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                            context) =>
                                                                CustomConfirmDialog(
                                                                    title:
                                                                    "Logout Confirm ?",
                                                                    description:
                                                                    "Are you sure you want to logout ?",
                                                                    buttonText: "Yes",
                                                                    imagepath:
                                                                    'assets/images/question.gif',
                                                                    isMobile:
                                                                    useMobileLayout),
                                                          );
                                                          print("userSelection ==" +
                                                              userSelection.toString());
                                                          if (userSelection !=
                                                              null) if (userSelection == true) {
                                                            SharedPreferences prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                            prefs.clear();
                                                            loggedinUser = new UserDetails(
                                                                UserId: "",
                                                                OrgName: "",
                                                                Name: "",
                                                                EmailId: "",
                                                                MobileNo: "",
                                                                OrganizationBranchId: 0,
                                                                OrganizationId: 0,
                                                                CreatedByUserId: 0,
                                                                OrganizationTypeId: 0,
                                                                IsWFSIntegration: "",
                                                                OrganizationBranchIdString:
                                                                "",
                                                                OrganizationtypeIdString:
                                                                "");
                                                            selectedTerminal = "";
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LoginPage()),
                                                            );
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.logout,
                                                          size: 48,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            if (!useMobileLayout && !kIsWeb)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 40.0, top: 16.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 0.0),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          var userSelection =
                                                          await showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                            context) =>
                                                                CustomConfirmDialog(
                                                                    title:
                                                                    "Logout Confirm ?",
                                                                    description:
                                                                    "Are you sure you want to logout ?",
                                                                    buttonText: "Yes",
                                                                    imagepath:
                                                                    'assets/images/question.gif',
                                                                    isMobile:
                                                                    useMobileLayout),
                                                          );
                                                          print("userSelection ==" +
                                                              userSelection.toString());
                                                          if (userSelection !=
                                                              null) if (userSelection == true) {
                                                            SharedPreferences prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                            prefs.clear();
                                                            loggedinUser = new UserDetails(
                                                                UserId: "",
                                                                OrgName: "",
                                                                Name: "",
                                                                EmailId: "",
                                                                MobileNo: "",
                                                                OrganizationBranchId: 0,
                                                                OrganizationId: 0,
                                                                CreatedByUserId: 0,
                                                                OrganizationTypeId: 0,
                                                                IsWFSIntegration: "",
                                                                OrganizationBranchIdString:
                                                                "",
                                                                OrganizationtypeIdString:
                                                                "");
                                                            selectedTerminal = "";
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      LoginPage()),
                                                            );
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.logout,
                                                          size: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                              18, //48,

                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            if (useMobileLayout)
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        var userSelection =
                                                        await showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) =>
                                                              CustomConfirmDialog(
                                                                  title: "Logout Confirm ?",
                                                                  description:
                                                                  "Are you sure you want to logout ?",
                                                                  buttonText: "Yes",
                                                                  imagepath:
                                                                  'assets/images/question.gif',
                                                                  isMobile:
                                                                  useMobileLayout),
                                                        );
                                                        print("userSelection ==" +
                                                            userSelection.toString());
                                                        if (userSelection !=
                                                            null) if (userSelection == true) {
                                                          SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          prefs.clear();
                                                          //perform logout
                                                          //clear share prefs
                                                          //go to login screen

                                                          loggedinUser = new UserDetails(
                                                              UserId: "",
                                                              OrgName: "",
                                                              Name: "",
                                                              EmailId: "",
                                                              MobileNo: "",
                                                              OrganizationBranchId: 0,
                                                              OrganizationId: 0,
                                                              CreatedByUserId: 0,
                                                              OrganizationTypeId: 0,
                                                              IsWFSIntegration: "",
                                                              OrganizationBranchIdString:
                                                              "",
                                                              OrganizationtypeIdString: "");

                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    LoginPage()),
                                                          );
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.logout,
                                                        size: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                            13, //48,

                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    // GestureDetector(
                                                    //   onTap: () {
                                                    //     showDialog(
                                                    //         barrierDismissible: false,
                                                    //         context: context,
                                                    //         builder: (context) {
                                                    //           return selectTerminalBox();
                                                    //         });
                                                    //   },
                                                    //   child: Icon(
                                                    //     Icons.add,
                                                    //     size: MediaQuery.of(context)
                                                    //         .size
                                                    //         .width /
                                                    //         13, //48,
                                                    //
                                                    //     color: Colors.white,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),

                                            // Text("Wave clipper", style: TextStyle(
                                            //   fontSize:18, color:Colors.white,
                                            // ),

                                            // )
                                          ]),
                                      useMobileLayout
                                          ? Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left:8.0),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,

                                                child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (context) {
                                                            return selectTerminalBox();
                                                          });
                                                    },
                                                    child: Text(
                                                      selectedBaseStationBranch,
                                                      style: TextStyle(
                                                          fontSize: useMobileLayout
                                                              ? MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  20
                                                              : 28,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    )),
                                              ),
                                            ),
                                          ],
                                          )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),

                              ]),
                        ),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: useMobileLayout ? 0 : 24),
                // if (isTrucker || isGHA)
                //   Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Row(
                //         children: [
                //           SizedBox(
                //             width: MediaQuery.of(context).size.width / 2.1,
                //             child: Center(
                //               child: Text(
                //                 "Select Base Station",
                //                 style: TextStyle(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.normal,
                //                   color: Color(0xFF11249F),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           SizedBox(
                //             height: 2,
                //           ),
                //           SizedBox(
                //             width: MediaQuery.of(context).size.width / 2.1,
                //             child: Center(
                //               child: Text(
                //                 "Select Terminal Name",
                //                 style: TextStyle(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.normal,
                //                   color: Color(0xFF11249F),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(
                //         height: 10,
                //       ),
                //       Row(
                //         children: [
                //           SizedBox(
                //             width: 6,
                //           ),
                //           SizedBox(
                //             width: MediaQuery.of(context).size.width / 2.1,
                //             child: Center(
                //               child: DropdownButtonHideUnderline(
                //                 child: Container(
                //                   constraints: BoxConstraints(minHeight: 50),
                //                   decoration: BoxDecoration(
                //                     border:
                //                     Border.all(color: Colors.grey, width: 0.2),
                //                     borderRadius:
                //                     BorderRadius.all(Radius.circular(5)),
                //                     color: Colors.white,
                //                   ),
                //                   padding: EdgeInsets.symmetric(horizontal: 10),
                //                   child: DropdownButton(
                //                     value: selectedBaseStationID,
                //                     isExpanded: true,
                //                     onChanged: (value) async {
                //                       setState(() {
                //                         // selectedBaseStation = value.toString();
                //                         selectedBaseStationID =
                //                             int.parse(value.toString());
                //                         // getBaseStationBranch(selectedBaseStationID);
                //                         print(";;;;$selectedBaseStationID;;;");
                //                       });
                //                       await changeValue();
                //                       setState(() {});
                //                     },
                //                     items: baseStationList2
                //                         .map((terminal) => DropdownMenuItem(
                //                       value: terminal.cityid,
                //                       child: Column(
                //                         mainAxisAlignment:
                //                         MainAxisAlignment.center,
                //                         crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                         children: [
                //                           Text(
                //                             terminal.airportcode
                //                                 .toUpperCase(),
                //                             style: TextStyle(
                //                               fontSize: 14,
                //                               fontWeight: FontWeight.normal,
                //                               color: Colors.black,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ))
                //                         .toList(),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           SizedBox(
                //             width: 8,
                //           ),
                //           SizedBox(
                //             width: MediaQuery.of(context).size.width / 2.1,
                //             child: Center(
                //               child: DropdownButtonHideUnderline(
                //                 child: Container(
                //                   constraints: BoxConstraints(minHeight: 50),
                //                   decoration: BoxDecoration(
                //                     border:
                //                     Border.all(color: Colors.grey, width: 0.2),
                //                     borderRadius:
                //                     BorderRadius.all(Radius.circular(5)),
                //                     color: Colors.white,
                //                   ),
                //                   padding: EdgeInsets.symmetric(horizontal: 10),
                //                   child: DropdownButton(
                //                     value: selectedBaseStationBranchID,
                //                     isDense: false,
                //                     isExpanded: true,
                //                     onChanged: (_value) {
                //                       setState(() {
                //                         // selectedBaseStationBranch = _value.toString();
                //                         selectedBaseStationBranchID =
                //                             int.parse(_value.toString());
                //                         print(selectedBaseStationBranchID);
                //                         // walkInEnable();
                //                       });
                //                       // print(selectedBaseStationBranch);
                //                     },
                //                     items: dummyList
                //                         .map((value) => DropdownMenuItem(
                //                       value: value.organizationBranchId,
                //                       child: Wrap(
                //                         // mainAxisAlignment:
                //                         //     MainAxisAlignment.center,
                //                         // crossAxisAlignment:
                //                         //     CrossAxisAlignment.start,
                //                         children: [
                //                           Text(
                //                             value.orgBranchName
                //                                 .toUpperCase(),
                //                             style: TextStyle(
                //                               fontSize: 14,
                //                               fontWeight: FontWeight.normal,
                //                               color: Colors.black,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ))
                //                         .toList(),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       )
                //     ],
                //   ),
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isGHA)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.local_shipping,
                          "Dock",
                          "In",
                          DockIn(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isGHA)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.maps_home_work,
                          "W/H",
                          "Acceptance",
                          WarehouseAcceptanceList(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isGHA)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.receipt_long,
                          "Record",
                          "POD",
                          RecordPodList(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isGHA)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.local_shipping,
                          "Dock",
                          "Out",
                          DockOut(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isGHA)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.live_tv,
                          "View Live",
                          "Dock Status",
                          LiveDockStatus(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isTrucker || isTruckerFF)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.check_circle_outline,
                          "Yard",
                          "Check-in",
                          TruckYardCheckInList(),
                          useMobileLayout,
                          isTerminalSelected()),
                    if (isTrucker || isTruckerFF)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.local_activity_outlined,
                          "Vehicle Token",
                          "List",
                          VehicleTokenList(),
                          useMobileLayout,
                          isTerminalSelected()),

                    if (isTrucker || isTruckerFF)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.history_outlined,
                          "Vehicle",
                          "Movement Tracking",
                          VehicleMovementTrackingList(),
                          useMobileLayout,
                          isTerminalSelected()),

                    if (isTrucker || isTruckerFF)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.book_online_outlined,
                          "Book",
                          "Slot",
                          SlotsList(),
                          useMobileLayout,
                          isTerminalSelected()),

                    if (isTrucker || isTruckerFF)
                      DashboardBlocks(
                          Color(0xFFa8c0ff),
                          Color(0xFF4364F7),
                          Icons.fact_check_outlined,
                          "View",
                          "Booked Slots",
                          BookedSlotsList(),
                          useMobileLayout,
                          isTerminalSelected()),

                    if (isTPS)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.local_shipping,
                          "Cargo",
                          "Pick-up",
                          CArgoPickUp(),
                          useMobileLayout,
                          true),

                    if (isTPS)
                      DashboardBlocks(
                          Color(0xFFff9472),
                          Color(0xFFf2709c),
                          Icons.local_shipping,
                          "Cargo",
                          "Drop",
                          CargoDrop(),
                          useMobileLayout,
                          true),
                    // DashboardBlocks(
                    //     Color(0xFF9CECFB),
                    //     Color(0xFF0052D4),
                    //     Icons.help_center_outlined,
                    //     "",
                    //     "Help",
                    //     Help(),
                    //     useMobileLayout),
                    DashboardBlocks(
                        Color(0xFF9CECFB),
                        Color(0xFF0052D4),
                        Icons.reviews_outlined,
                        "",
                        "Feedback",
                        AppFeedback(),
                        useMobileLayout,
                        true),
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //       left: 40.0, right: 10.0, top: 32),
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => RecordPodList()),
                    //       );
                    //     },
                    //     //padding: const EdgeInsets.all(0.0),
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 4.0,
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10.0)), //
                    //       padding: const EdgeInsets.all(0.0),
                    //     ),
                    //     child: Container(
                    //       height: MediaQuery.of(context).size.width / 4.5,
                    //       width: MediaQuery.of(context).size.width / 4.5, //180,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(10),
                    //         gradient: LinearGradient(
                    //           begin: Alignment.topRight,
                    //           end: Alignment.bottomLeft,
                    //           colors: [
                    //             Color(0xFF19D2CA),
                    //             Color(0xFF0EB5A9),
                    //           ],
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Stack(
                    //           // mainAxisAlignment: MainAxisAlignment.end,
                    //           // crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Align(
                    //               alignment: Alignment.topRight,
                    //               child: Icon(
                    //                 Icons.receipt_long,
                    //                 size: 48,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             Column(
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'Record',
                    //                     style: TextStyle(
                    //                         fontSize: 28,
                    //                         fontWeight: FontWeight.normal,
                    //                         color: Colors.white),
                    //                   ),
                    //                   Text('POD',
                    //                       style: TextStyle(
                    //                           fontSize: 28,
                    //                           fontWeight: FontWeight.normal,
                    //                           color: Colors.white)),
                    //                   // Text('Login',
                    //                   //     style: TextStyle(
                    //                   //         fontSize: 28,
                    //                   //         fontWeight: FontWeight.normal,
                    //                   //     color: Colors.white))
                    //                 ]),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     //Text('CONTAINED BUTTON'),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //       left: 32.0, right: 10.0, top: 32),
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => LiveDockStatus()),
                    //       );
                    //     },
                    //     //padding: const EdgeInsets.all(0.0),
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 4.0,
                    //       // side: BorderSide(
                    //       //     color: Colors.yellow,
                    //       //     width: 2.0,
                    //       //     style: BorderStyle.solid), //set border for the button
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10.0)), //
                    //       padding: const EdgeInsets.all(0.0),
                    //     ),
                    //     child: Container(
                    //       height: MediaQuery.of(context).size.width / 4.5,
                    //       width: MediaQuery.of(context).size.width / 4.5, //180,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(10),
                    //         gradient: LinearGradient(
                    //           begin: Alignment.topRight,
                    //           end: Alignment.bottomLeft,
                    //           colors: [
                    //             // Color(0xFF1220BC),
                    //             // Color(0xFF3540E8),
                    //             Color(0xFF19D2CA),
                    //             Color(0xFF0EB5A9),
                    //           ],
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Stack(
                    //           // mainAxisAlignment: MainAxisAlignment.end,
                    //           // crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Align(
                    //               alignment: Alignment.topRight,
                    //               child: Icon(
                    //                 Icons.live_tv,
                    //                 size: 48,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             Column(
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'View Live',
                    //                     style: TextStyle(
                    //                         fontSize: 28,
                    //                         fontWeight: FontWeight.normal,
                    //                         color: Colors.white),
                    //                   ),
                    //                   Text('Dock Status',
                    //                       style: TextStyle(
                    //                           fontSize: 28,
                    //                           fontWeight: FontWeight.normal,
                    //                           color: Colors.white)),
                    //                   // Text('Login',
                    //                   //     style: TextStyle(
                    //                   //         fontSize: 28,
                    //                   //         fontWeight: FontWeight.normal,
                    //                   //     color: Colors.white))
                    //                 ]),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     //Text('CONTAINED BUTTON'),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

class DashboardBlocks extends StatelessWidget {
  DashboardBlocks(this.color1, this.color2, this.lblicon, this.btnText1,
      this.btnText2, this.pageroute, this.isMobile, this.isEnabled);

  final Color color1;
  final Color color2;
  final IconData lblicon;
  final String btnText1;
  final String btnText2;
  final pageroute;
  final bool isMobile;
  final bool isEnabled;

  void _showAlertDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Dialog Title'),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                // Handle the confirm action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 300,
        width: 300,
        color: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  if (isEnabled) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => pageroute),
                    );
                  }
                },
                //padding: const EdgeInsets.all(0.0),
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(180),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ), //
                  padding: const EdgeInsets.all(0.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  // height: MediaQuery.of(context).size.height / 4.2,
                  // width: MediaQuery.of(context).size.width / 3, //180,
                  height: 250,
                  width: 250,
                  //180,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(10),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(180),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topCenter,
                      colors: [color1, color2],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        btnText1, // 'Scan',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                      Text(
                        btnText2, // 'Scan',
                        style: TextStyle(
                            fontSize:
                            30, //MediaQuery.of(context).size.width / 25, //30,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 96.0,
                width: 96.0,
                decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(lblicon, size: 64, color: color1),
              ),
            )
          ],
        ),
      ),
    )
        : !isMobile
        ? Container(
      height: MediaQuery.of(context).size.width / 3.5,
      width: MediaQuery.of(context).size.width / 3.5, //180,
      color: Colors.transparent,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (isEnabled) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => pageroute),
                  );
                }
                if (selectedBaseStationID == 0) {
                  showAlertDialog(
                      context, "Ok", "Alert", "Select Base Station");
                  print("base");
                  return;
                }
                if (selectedBaseStationBranchID == 0) {
                  showAlertDialog(
                      context, "Ok", "Alert", "Select Terminal");
                  print("terminal");
                }
              },
              //padding: const EdgeInsets.all(0.0),
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(120),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ), //
                padding: const EdgeInsets.all(0.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.width / 4,
                width: MediaQuery.of(context).size.width / 4,
                //180,
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(10),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(120),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                    colors: [color1, color2],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      btnText1, // 'Scan',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Text(
                      btnText2, // 'QR code',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              //Text('CONTAINED BUTTON'),
            ),
          ),
          // Positi

          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(lblicon, size: 48, color: color2),
            ),
          )
        ],
      ),
    )
        : Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width / 2.5, //180,
        color: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  if (isEnabled) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => pageroute),
                    );
                  }
                  if (selectedBaseStationID == 0) {
                    showAlertDialog(context, "Ok", "Alert",
                        "Select Base Station");
                    print("base");
                    return;
                  }
                  if (selectedBaseStationBranchID == 0) {
                    showAlertDialog(
                        context, "Ok", "Alert", "Select Terminal");
                    print("terminal");
                  }
                },
                //padding: const EdgeInsets.all(0.0),
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  // side: BorderSide(
                  //     color: Colors.yellow,
                  //     width: 2.0,
                  //     style: BorderStyle.solid), //set border for the button
                  shape: RoundedRectangleBorder(
                    //borderRadius: BorderRadius.circular(10.0)

                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(180),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  //
                  padding: const EdgeInsets.all(0.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  // height: MediaQuery.of(context).size.height / 4.2,
                  // width: MediaQuery.of(context).size.width / 3, //180,
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width / 2.5,
                  //180,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(10),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(180),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topCenter,
                      colors: [
                        // Color(0xFFdd5e89),
                        // Color(0xFFF7BB97),
                        color2, color1
                        // Colors.blue.shade700,
                        // Colors.blue,
                        //Color(0xFF0AA1FA),
                        //Color(0xFF0A92DF),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        btnText1, // 'Scan',
                        style: TextStyle(
                            fontSize: isMobile
                                ? MediaQuery.of(context).size.width /
                                20
                                : MediaQuery.of(context).size.width /
                                25, //30,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                      Text(
                        btnText2, // 'Scan',
                        style: TextStyle(
                            fontSize: isMobile
                                ? MediaQuery.of(context).size.width /
                                20
                                : MediaQuery.of(context).size.width /
                                25,
                            //30, MediaQuery.of(context).size.width / 25, //30,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                //Text('CONTAINED BUTTON'),
              ),
            ),
            // Positioned(
            //   // top: -30,
            //   right: 30,
            //   child: CircleAvatar(
            //     radius: 36.0,
            //   ),
            // ),

            Align(
              alignment: Alignment.topLeft,
              child: Container(
                height:
                MediaQuery.of(context).size.height / 8, // 108.0,
                width:
                MediaQuery.of(context).size.width / 8, // 108.0,
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   width: 2,
                  //   color: Colors.white,
                  // ),
                  // color: Color(0xFF008000),
                    color: Colors.white,
                    //Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle),
                child:

                // Image(
                //   // height: 50.0,
                //   // width: 50.0,
                //   // fit: BoxFit.scaleDown,
                //   image: AssetImage(
                //       'assets/icons/qr-code-3.png'),
                // )

                Icon(lblicon, // Icons.qr_code,
                    size: MediaQuery.of(context).size.width /
                        11, //72,
                    color: color2
                  //  Color(0xFFdd5e89), //Colors.blue.shade700, //Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
