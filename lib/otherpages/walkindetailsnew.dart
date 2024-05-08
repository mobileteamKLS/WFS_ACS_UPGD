import 'dart:convert';
import 'package:luxair/dashboards/homescreen.dart';
import 'package:luxair/datastructure/slotbooking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:luxair/datastructure/vehicletoken.dart';
import 'package:luxair/otherpages/walkinnew.dart';
import 'package:luxair/widgets/customdialogue.dart';
import 'package:luxair/widgets/headerclipper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:toggle_switch/toggle_switch.dart';

import '../constants.dart';
import '../datastructure/airwaybill.dart';
import '../global.dart';
import '../widgets/headers.dart';

class WalkInAwbDetailsNew extends StatefulWidget {
  //
  // final List<WalkinMain> walkinTable;
  WalkInAwbDetailsNew({
    Key? key,
  }) : super(key: key);

  @override
  State<WalkInAwbDetailsNew> createState() => _WalkInAwbDetailsNewState();
}

class _WalkInAwbDetailsNewState extends State<WalkInAwbDetailsNew> {
  int modeSelected = 0;
  String selectedMawbNo = "", selectedOrigin = "", selectedPrefix = "";
  bool useMobileLayout = false,
      isLoading = false,
      isSavingData = false,
      isVerified = false;
  TextEditingController txtOriginM = new TextEditingController();
  TextEditingController txtPrefixM = new TextEditingController();
  TextEditingController txtMawbnoM = new TextEditingController();
  TextEditingController txthawbnoM = new TextEditingController();
  TextEditingController txtpickupnopM = new TextEditingController();
  TextEditingController txtgrwtnopM = new TextEditingController();
  TextEditingController txtnatureofgoodsM = new TextEditingController();
  TextEditingController txtff = new TextEditingController();

  TextEditingController txtOriginH = new TextEditingController();
  TextEditingController txtPrefixH = new TextEditingController();
  TextEditingController txtMawbnoH = new TextEditingController();
  TextEditingController txthawbnoH = new TextEditingController();
  TextEditingController txtpickupnopH = new TextEditingController();
  TextEditingController txtgrwtnopH = new TextEditingController();
  TextEditingController txtnatureofgoodsH = new TextEditingController();

  List<AWB> hawbListToBind = [];
  List<AWB> mawbList = [];

  // List<AWB> mawbListPickUP = [];
  List<AWB> hawbList = [];
  List<AWB> verifiedMawbList = [];
  List<AWB> verifiedHawbList = [];
  List<AWB> filteredHawbList = [];

  List<MAWB> mawbListSave = [];
  List<MAWBDropoff> mawbDropOffListSave = [];
  List<HAWB> hawbListSave = [];
  List<String> requestIdList=[];

  String shipmentTypeSelected = "Select";
  String commoditySelected = "Select";
  int commoditySelectedID = 0;
  String errMsgText = "";
  String modeName = "Drop-off";
  Map<String, String> rspErrorCodes = {
    "WH":
        "The HAWB No does not exists. Kindly amend the necessary changes and save again.",
    "NA":
        "This AWB or part of this AWB is already delivered. Please try again later.",
    "NP": "All available PCs have been delivered.",
    "NF": "No record found for this AWB.",
    "LH":
        "The partial delivery of MAWB No. is already completed outside ACS. In order to proceed this AWB enter HAWB’s details.",
    "LM":
        "The HAWB No. partially delivered at MAWB level outside ACS. In order to proceed this AWB change shipment type from CONSOL to DIRECT.\N Do you want to proceed to change shipment type to DIRECT ? ",
    "PF":
        "You cannot book slot till payment is completed for the selected shipment.",
    "BF":
        "You cannot book slot till breakdown is completed for the selected shipment.",
    "WL": "The location you've entered does not match the freight location.",
  };

  static Future<List<AirlinesPrefix>> getSuggestionsPrefix(String query) async {
    List<AirlinesPrefix> matches = [];
    matches.addAll(airlinesPrefixList);
    matches.retainWhere((AirlinesPrefix s) =>
        s.AirlinePrefix.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  static Future<List<Airport>> getSuggestionsOrgDest(String query) async {
    List<Airport> matches = [];
    matches.addAll(airportList);
    matches.retainWhere(
        (Airport s) => s.CityCode.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  getPrefix() async {
    var queryParams = {'GHABranchId': selectedBaseStationBranchID.toString()};
    await Global()
        .postData(
      Settings.SERVICES['GetAirlinePrefixList'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);

      var msg = json.decode(response.body)['d'];
      var resp = json.decode(msg).cast<Map<String, dynamic>>();

      airlinesPrefixList = resp
          .map<AirlinesPrefix>((json) => AirlinesPrefix.fromJson(json))
          .toList();

      print("length baseStationList = " + airlinesPrefixList.length.toString());
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  getAirport() async {
    var queryParams = {};
    await Global()
        .postData(
      Settings.SERVICES['GetAiportsList'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);

      var msg = json.decode(response.body)['d'];
      var resp = json.decode(msg).cast<Map<String, dynamic>>();

      airportList =
          resp.map<Airport>((json) => Airport.fromJson(json)).toList();

      print("length baseStationList = " + airportList.length.toString());
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  deleteShipment(requestId) async {
    var queryParams = {"WFSRequestId": requestId};
    await Global()
        .postData(
      Settings.SERVICES['DeleteShipment'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);
      var msg = json.decode(response.body)['d'];
      var resp = json.decode(msg).cast<Map<String, dynamic>>();
      print("length baseStationList = " + airportList.length.toString());
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  verifyAirline() async {
    List<String> mawbPrefixes = [];
    String mode = "";
    errMsgText = "";
    String responseTextUpdated = "";
    bool isValid = false;

    //Export or Drop off
    if (modeSelected == 0) {
      mode = "E";
      for (AWB u in mawbList) {
        mawbPrefixes.add(u.prefix);
      }
    } else {
      mode = "I";
      for (AWB u in verifiedMawbList) {
        mawbPrefixes.add(u.prefix);
      }
    }
    var queryParams = {
      "Mode": mode,
      "TerminalId": selectedBaseStationBranchID.toString(),
      "MAWBPrefix": mawbPrefixes
    };
    await Global()
        .postData(
      Settings.SERVICES['VerifyAirline'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);

      if (json.decode(response.body)['d'] != null) {
        var msg = json.decode(response.body)['d'];
        var resp = json.decode(msg).cast<Map<String, dynamic>>();

        List<VerificationMsg> rspMsg = [];
        rspMsg = resp
            .map<VerificationMsg>((json) => VerificationMsg.fromJson(json))
            .toList();
        if (rspMsg.isNotEmpty) if (rspMsg[0].Status == "S") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalkInCustomerNew(
                      mawbList: mawbList,
                      mode: modeSelected,
                    requestIdList:requestIdList,
                    )),
          );
        } else {
          responseTextUpdated = rspMsg[0].StrMessage.toString();
          responseAlert(rspMsg[0].StrMessage.toString());
        }
      }
      //
      // airportList =
      //     resp.map<Airport>((json) => Airport.fromJson(json)).toList();
      //
      // print("length baseStationList = " + airportList.length.toString());
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  responseAlert(errorCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomAlertMessageDialogNew(
          description: errorCode,
          buttonText: "Okay",
          imagepath: 'assets/images/warn.gif',
          isMobile: useMobileLayout),
    );
  }

  verifyAWBDetails() async {
    String masterList = "",
        houseList = "",
        mawbPickUpTableString = "",
        shiptype = "",
        natureofgoods = "",
        finalHawbTableString = "",
        hawbTableString = "";
    int mawbIndex = 0;

    for (AWB u in mawbList) {
      String a = "{\"MAWBId\":\"${u.index}\"," +
          "\"shipmentType\":\"${u.shiptype.toLowerCase()}\"," +
          "\"origin\":\"${u.origin}\"," +
          "\"destination\":\"$selectedBaseStation\"," +
          "\"prefix\":\"${u.prefix}\"," +
          "\"mawbNo\":\"${u.mawbno}\"," +
          "\"NoP\":\"${u.nop}\"," +
          "\"GrWt\":\"${u.grwt}\"," +
          "\"NatureOfGoods\":\"goods\"," +
          "\"freightForwarder\":\"ff\"," +
          "\"CommodityIds\":\"${u.natureofgoods}\"," +
          "\"GHABranchID\":\"$selectedBaseStationBranchID\" }";
      mawbIndex = u.index;
      shiptype = u.shiptype;
      natureofgoods = u.natureofgoods;
      mawbPickUpTableString = mawbPickUpTableString + a;
    }

    if (hawbList.length > 0) {
      int iHawb = 0;

      for (AWB u in hawbList) {
        String a = "{\"MAWBId\":\"$mawbIndex\"," +
            "\"HAWBId\":\"${u.index}\"," +
            "\"shipmentType\":\"$shiptype\"," +
            "\"origin\":\"${u.origin}\"," +
            "\"destination\":\"$selectedBaseStation\"," +
            "\"prefix\":\"${u.prefix}\"," +
            "\"mawbNo\":\"${u.mawbno}\"," +
            "\"hawbNo\":\"${u.hawbno}\"," +
            "\"NoP\":\"${u.nop}\"," +
            "\"GrWt\":\"${u.grwt}\"," +
            "\"NatureOfGoods\":\"goods\"," +
            "\"freightForwarder\":\"ff\"," +
            "\"CommodityIds\":\"$natureofgoods\"," +
            "\"GHABranchID\":\"$selectedBaseStationBranchID\" }";
        if (iHawb == 0)
          hawbTableString = hawbTableString + a;
        else
          hawbTableString = hawbTableString + "," + a;

        iHawb++;
      }
    }

    masterList = "[" + mawbPickUpTableString + "]";
    houseList = "[" + hawbTableString + "]";
    var queryParams = {
      "MAWBData": json.decode(masterList),
      "HAWBData": json.decode(houseList)
    };
    await Global()
        .postData(
      Settings.SERVICES['VerifyImportShipment'],
      queryParams,
    )
        .then((response) {
      print("data received ");
      print(json.decode(response.body)['d']);

      if (json.decode(response.body)['d'] != null) {
        var msg = json.decode(response.body)['d'];
        var resp = json.decode(msg).cast<Map<String, dynamic>>();
        print(resp);
        List<VerificationResponseMsg> rspMsg = [];
        rspMsg = resp
            .map<VerificationResponseMsg>(
                (json) => VerificationResponseMsg.fromJson(json))
            .toList();
        if (rspMsg.isNotEmpty) {
          if (rspMsg[0].errorCode == "WH") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "NA") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "NP") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "NF") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "LH") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "LM") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "PF") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "BF") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else if (rspMsg[0].errorCode == "WL") {
            responseAlert(rspErrorCodes[rspMsg[0].errorCode]!);
            deleteShipment(rspMsg[0].requestId);
          } else {
            if(!verifiedMawbList.any((awb) => awb.mawbno == mawbList[0].mawbno)){
              verifiedMawbList.add(mawbList[0]);
            }
            if(hawbList.isNotEmpty){
              verifiedHawbList.add(hawbList[0]);
            }
            requestIdList.add(rspMsg[0].requestId);
            setState(() {
              isVerified = true;
            });

            print(isVerified);
          }
        }
      }
      //
      // airportList =
      //     resp.map<Airport>((json) => Airport.fromJson(json)).toList();
      //
      // print("length baseStationList = " + airportList.length.toString());
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      // setState(() {
      //   isLoading = false;
      // });
      print(onError);
    });
  }

  addMawb() async {
    txtOriginM.text = "";
    txtPrefixM.text = "";
    txtOriginM.text = "";
    txtMawbnoM.text = "";
    txthawbnoM.text = "";
    txtpickupnopM.text = "";
    txtgrwtnopM.text = "";
    txtnatureofgoodsM.text = "";
    txtff.text = "";

    shipmentTypeSelected = "Select";
    commoditySelected = "Select";
    if (modeSelected == 0) {
      var masterAdded = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return buildMawbPopUpIpad();
          });

      print("masterAdded");
      print(masterAdded);
    } else {
      var masterAdded = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return buildMawbPopUpIpad();
          });

      print("masterAdded");
      print(masterAdded);

      if (masterAdded != null) if (masterAdded == "y" &&
          shipmentTypeSelected != "Direct") {
        var userSelection = await showDialog(
          context: context,
          builder: (BuildContext context) => CustomConfirmDialog(
              title: "ADD HOUSE ?",
              description:
                  "Would you like Proceed to add House in this Master ",
              buttonText: "Okay",
              imagepath: 'assets/images/question.gif',
              isMobile: useMobileLayout),
        );
        print("userSelection ==" + userSelection.toString());

        if (userSelection != null) if (userSelection == true) {
          txtMawbnoH.text = selectedMawbNo;
          txtPrefixH.text = selectedPrefix;
          txtOriginH.text = selectedOrigin;

          txthawbnoH.text = "";
          txtpickupnopH.text = "";
          txtgrwtnopH.text = "";
          txtnatureofgoodsH.text = "";

          txtff.text = "";

          shipmentTypeSelected = "Select";
          commoditySelected = "Select";

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return buildHawbPopUpIpad();
              });
        }
      }
    }
  }

  // List<AWB> mawbList = [
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "BOM",
  //       prefix: "prefix",
  //       mawbno: "333-22222222",
  //       hawbno: "--",
  //       nop: "15",
  //       grwt: "1567.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "GT freight",
  //       isselect: false,
  //       index: 0),
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "CLB",
  //       prefix: "prefix",
  //       mawbno: "454-22222222",
  //       hawbno: "--",
  //       nop: "15",
  //       grwt: "1567.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "GT freight",
  //       isselect: false,
  //       index: 1),
  // ];
  // List<AWB> hawbList = [
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "TRN",
  //       prefix: "prefix",
  //       mawbno: "333-22222222",
  //       hawbno: "888-09090909",
  //       nop: "15",
  //       grwt: "1567.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "GDK freight",
  //       isselect: false,
  //       index: 0),
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "YYZ",
  //       prefix: "prefix",
  //       mawbno: "333-22222222",
  //       hawbno: "HAWB 2",
  //       nop: "150",
  //       grwt: "15670.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "INT freight",
  //       isselect: false,
  //       index: 1),
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "BOS",
  //       prefix: "prefix",
  //       mawbno: "454-22222222",
  //       hawbno: "HAWB 3",
  //       nop: "25",
  //       grwt: "2567.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "Global freight",
  //       isselect: false,
  //       index: 2),
  //   AWB(
  //       shiptype: "shiptype",
  //       origin: "ATL",
  //       prefix: "prefix",
  //       mawbno: "454-22222222",
  //       hawbno: "HAWB 4",
  //       nop: "120",
  //       grwt: "67569.89",
  //       natureofgoods: "natureofgoods",
  //       ff: "Star freight",
  //       isselect: false,
  //       index: 3),
  // ];

  @override
  void initState() {
    hawbListToBind = hawbList;
    super.initState();
    getPrefix();
    getAirport();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addMawb();
    });
  }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = smallestDimension < 600;
    return Scaffold(
      floatingActionButton: (mawbList.length != 0)
          ? modeSelected == 0 || isVerified
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    verifyAirline();
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: const Text('Next',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.white)),
                  ),
                  backgroundColor: Color(0xFF11249F),
                )
              : FloatingActionButton.extended(
                  onPressed: () async {
                    verifyAWBDetails();
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: const Text('Verify',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.white)),
                  ),
                  backgroundColor: Color(0xFF11249F),
                )
          : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ClipPath(
            //   clipper: MyClippers1(),
            //   child: Container(
            //     padding: EdgeInsets.only(left: 40, top: 50, right: 20),
            //    height: MediaQuery.of(context).size.height / 5.2,
            //     width: MediaQuery.of(context).size.width, //180,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topRight,
            //         end: Alignment.bottomLeft,
            //         colors: [
            //           Color(0xFF3383CD),
            //           Color(0xFF11249F),
            //         ],
            //       ),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.only(top: 20.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Column(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(
            //                 children: [
            //                   GestureDetector(
            //                     onTap: () {
            //                       Navigator.of(context).pop();
            //                     },
            //                     child: Center(
            //                       child: Icon(
            //                         Icons.chevron_left,
            //                         size: MediaQuery.of(context).size.width / 18,//56,
            //                         color: Colors.white,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(width: 20),
            //                   Text(
            //                     "Enter AWB Details",
            //                     style: TextStyle(
            //                         fontSize: MediaQuery.of(context).size.width / 18,//48,
            //                         fontWeight: FontWeight.normal,
            //                         color: Colors.white),
            //                   ),
            //                 ],
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.only(left: 72.0),
            //                 child: Text(
            //                   " Mode : " + widget.modeSelected,
            //                   style: TextStyle(
            //                       fontSize: MediaQuery.of(context).size.width / 25,//32,
            //                       fontWeight: FontWeight.normal,
            //                       color: Colors.white),
            //                 ),
            //               ),
            //             ],
            //           ),
            //           SizedBox(width: 108),
            //           if (mawbList.length > 0)
            //             ElevatedButton(
            //               style: ElevatedButton.styleFrom(
            //                   elevation: 4,
            //                   shape: const CircleBorder(),
            //                   primary: Colors.red),
            //               child: Container(
            //                 width: 100,
            //                 height: 100,
            //                 alignment: Alignment.center,
            //                 // decoration:
            //                 //     const BoxDecoration(shape: BoxShape.circle),
            //                 decoration: BoxDecoration(
            //                   shape: BoxShape.circle,
            //                   border: Border.all(
            //                     width: 3,
            //                     color: Colors.white,
            //                   ),
            //                   // borderRadius: BorderRadius.circular(10),
            //                   gradient: LinearGradient(
            //                     begin: Alignment.topRight,
            //                     end: Alignment.bottomLeft,
            //                     colors: [
            //                       // Color(0xFF19D2CA),
            //                       // Color(0xFF0EB5A9),

            //                       Color(0xFF1220BC),
            //                       Color(0xFF3540E8),
            //                     ],
            //                   ),
            //                 ),
            //                 child: const Text(
            //                   'Submit',
            //                   style: TextStyle(
            //                       fontSize: 20,
            //                       fontWeight: FontWeight.bold,
            //                       color: Colors.white),
            //                 ),
            //               ),
            //               onPressed: () {
            //                 showDialog(
            //                   context: context,
            //                   builder: (BuildContext context) => CustomDialog(
            //                     title: "Success",
            //                     description: "AWB Details saved successfully. ",
            //                     buttonText: "Okay",
            //                     imagepath: 'assets/images/successchk.gif',
            //                   ),
            //                 );
            //               },
            //             )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // HeaderClipperWaveMultilineNew(
            //     color1: Color(0xFF3383CD),
            //     color2: Color(0xFF11249F),
            //     headerText: "Enter AWB Details",
            //     modeText: modeSelected ,
            //     isMobile: useMobileLayout,
            //     isWeb: kIsWeb),
            ClipPath(
              //upper clippath with less height
              clipper: WaveClipper(), //set our custom wave clipper.
              child: Container(
                padding: EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF3383CD), //  Color(0xFF3383CD),
                      Color(0xFF11249F), //   Color(0xFF11249F),
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height / 5,
                //180,
                alignment: Alignment.center,

                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Icon(
                                  Icons.chevron_left,
                                  size: useMobileLayout
                                      ? 40
                                      : kIsWeb
                                          ? 40
                                          : MediaQuery.of(context).size.width /
                                              18, //56,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "Enter AWB Details", // "Walk-in Details ",
                              style: TextStyle(
                                  fontSize: kIsWeb
                                      ? 48
                                      : MediaQuery.of(context).size.width /
                                          18, //48,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(
                          //   width: isWeb ?  MediaQuery.of(context).size.width / 10 :  MediaQuery.of(context).size.width / 7 ,
                          //   child: Text(
                          //     " ", // "Walk-in Details ",
                          //     style: TextStyle(
                          //         fontSize:isWeb ? 48:
                          //             MediaQuery.of(context).size.width / 18, //48,
                          //         fontWeight: FontWeight.normal,
                          //         color: Colors.white),
                          //   ),
                          // ),
                          SizedBox(width: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: Text(
                              " Mode : $modeName ",
                              style: TextStyle(
                                  fontSize: kIsWeb
                                      ? 32
                                      : MediaQuery.of(context).size.width /
                                          22, //48,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
            // useMobileLayout
            //     ? Padding(
            //         padding: const EdgeInsets.only(
            //             top: 0.0, bottom: 10.0, left: 10.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             SizedBox(
            //               width: MediaQuery.of(context).size.width / 1.6,
            //               child: Text(
            //                   //  (mawbList.length == 0) ? "" : " MAWB Entered",
            //                   "MAWB List",
            //                   style: mobileHeaderFontStyle),
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.only(left: 00.0),
            //               child: ElevatedButton(
            //                 onPressed: () async {
            //                   txtOriginM.text = "";
            //                   txtPrefixM.text = "";
            //                   txtOriginM.text = "";
            //                   txtMawbnoM.text = "";
            //                   txthawbnoM.text = "";
            //                   txtpickupnopM.text = "";
            //                   txtgrwtnopM.text = "";
            //                   txtnatureofgoodsM.text = "";

            //                   if (widget.modeSelected
            //                       .toLowerCase()
            //                       .contains("drop")) {
            //                   } else {
            //                     var masterAdded = await showDialog(
            //                         barrierDismissible: false,
            //                         context: context,
            //                         builder: (context) {
            //                           return buildMawbPopUpMobile();
            //                         });

            //                     if (masterAdded != null) if (masterAdded ==
            //                         "y") {
            //                       var userSelection = await showDialog(
            //                         context: context,
            //                         builder: (BuildContext context) =>
            //                             CustomConfirmDialog(
            //                                 title: "ADD HOUSE ?",
            //                                 description:
            //                                     "Would you like Proceed to add House in this Master ",
            //                                 buttonText: "Okay",
            //                                 imagepath:
            //                                     'assets/images/question.gif',
            //                                 isMobile: useMobileLayout),
            //                       );
            //                       print("userSelection ==" +
            //                           userSelection.toString());

            //                       if (userSelection !=
            //                           null) if (userSelection == true) {
            //                         txtMawbnoH.text = selectedMawbNo;
            //                         txtPrefixH.text = selectedPrefix;
            //                         txtOriginH.text = selectedOrigin;

            //                         txthawbnoH.text = "";
            //                         txtpickupnopH.text = "";
            //                         txtgrwtnopH.text = "";
            //                         txtnatureofgoodsH.text = "";

            //                         showDialog(
            //                             barrierDismissible: false,
            //                             context: context,
            //                             builder: (context) {
            //                               return buildHawbPopUpMobile();
            //                             });
            //                       }
            //                     }
            //                   }
            //                 },
            //                 style: ElevatedButton.styleFrom(
            //                   elevation: 4.0,
            //                   shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(10.0)), //
            //                   padding: const EdgeInsets.all(0.0),
            //                 ),
            //                 child: Container(
            //                   height: 40,
            //                   width: 120,
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(10),
            //                     gradient: LinearGradient(
            //                       begin: Alignment.topRight,
            //                       end: Alignment.bottomLeft,
            //                       colors: [
            //                         Color(0xFF1220BC),
            //                         Color(0xFF3540E8),
            //                       ],
            //                     ),
            //                   ),
            //                   child: Padding(
            //                     padding: const EdgeInsets.only(
            //                         top: 8.0, bottom: 8.0),
            //                     child: Align(
            //                       alignment: Alignment.center,
            //                       child: Text('Add MAWB',
            //                           style: buttonWhiteFontStyleSmall),
            //                     ),
            //                   ),
            //                 ),
            //                 //Text('CONTAINED BUTTON'),
            //               ),
            //             ),
            //           ],
            //         ),
            //       )
            //     :
            if (!useMobileLayout)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 42.0, top: 8.0, bottom: 16.0),
                    child: ToggleSwitch(
                      minWidth: useMobileLayout
                          ? MediaQuery.of(context).size.width / 3
                          : MediaQuery.of(context).size.width / 4.5,
                      //  width: useMobileLayout ?  MediaQuery.of(context).size.width / 1.4: MediaQuery.of(context).size.width / 2.2,
                      minHeight: 65.0,
                      initialLabelIndex: modeSelected,
                      cornerRadius: 20.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      customTextStyles: [
                        TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                        TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        )
                      ],
                      labels: ['Drop-off ', ' Pick-up'],
                      icons: [
                        Icons.south,
                        Icons.north,
                      ],
                      iconSize: 22.0,
                      activeBgColors: [
                        // [Colors.blueAccent, Colors.blue],
                        // [Colors.blueAccent, Colors.blue],

                        [Color(0xFF1220BC), Color(0xFF3540E8)],
                        [Color(0xFF1220BC), Color(0xFF3540E8)],
                      ],
                      // animate: true,
                      // with just animate set to true, default curve = Curves.easeIn
                      curve: Curves.bounceInOut,
                      // animate must be set to true when using custom curve
                      onToggle: (index) {
                        print('switched to: $index');

                        setState(() async {
                          //selectedText = "";
                          if ((mawbList.length == 0)) {
                            modeSelected = index!;
                            addMawb();
                          }
                          print("$modeSelected====");
                          if (modeSelected == 0) {
                            setState(() {
                              modeName = "Drop-off";
                            });

                            print("$modeName");
                          } else {
                            setState(() {
                              modeName = "Pick-up";
                            });

                            print("$modeName");
                          }
                        });
                      },
                      changeOnTap: mawbList.length == 0 ? true : false,
                    ),
                  ),
                  (mawbList.length == 0 || (!isVerified && modeSelected != 0))
                      ? SizedBox()
                      : Container(
                          padding: EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              addMawb();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)), //
                              padding: const EdgeInsets.all(0.0),
                            ),
                            child: Container(
                              height: 50,
                              width: 150,
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
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Add MAWB',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
            if (isSavingData)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Container(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator())),
                  SizedBox(height: 10),
                  Text(
                    "Saving Data",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ],
              ),
            if (!isSavingData)
              Padding(
                padding:
                    const EdgeInsets.only(top: 0.0, bottom: 10.0, left: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Text(
                        (mawbList.length == 0) ? "" : " MAWB List",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11249F),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 10.0),
                    //   child: ElevatedButton(
                    //     onPressed: () async {
                    //       txtOriginM.text = "";
                    //       txtPrefixM.text = "";
                    //       txtOriginM.text = "";
                    //       txtMawbnoM.text = "";
                    //       txthawbnoM.text = "";
                    //       txtpickupnopM.text = "";
                    //       txtgrwtnopM.text = "";
                    //       txtnatureofgoodsM.text = "";
                    //       txtff.text = "";
                    //
                    //       shipmentTypeSelected = "Select";
                    //       commoditySelected = "Select";
                    //       if (modeSelected == 0) {
                    //         var masterAdded = await showDialog(
                    //             barrierDismissible: false,
                    //             context: context,
                    //             builder: (context) {
                    //               return buildMawbPopUpIpad();
                    //             });
                    //
                    //         print("masterAdded");
                    //         print(masterAdded);
                    //       }
                    //       else {
                    //         var masterAdded = await showDialog(
                    //             barrierDismissible: false,
                    //             context: context,
                    //             builder: (context) {
                    //               return buildMawbPopUpIpad();
                    //             });
                    //
                    //         print("masterAdded");
                    //         print(masterAdded);
                    //
                    //         if (masterAdded != null) if (masterAdded == "y") {
                    //           var userSelection = await showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) =>
                    //                 CustomConfirmDialog(
                    //                     title: "ADD HOUSE ?",
                    //                     description:
                    //                         "Would you like Proceed to add House in this Master ",
                    //                     buttonText: "Okay",
                    //                     imagepath: 'assets/images/question.gif',
                    //                     isMobile: useMobileLayout),
                    //           );
                    //           print("userSelection ==" +
                    //               userSelection.toString());
                    //
                    //           if (userSelection != null) if (userSelection ==
                    //               true) {
                    //             txtMawbnoH.text = selectedMawbNo;
                    //             txtPrefixH.text = selectedPrefix;
                    //             txtOriginH.text = selectedOrigin;
                    //
                    //             txthawbnoH.text = "";
                    //             txtpickupnopH.text = "";
                    //             txtgrwtnopH.text = "";
                    //             txtnatureofgoodsH.text = "";
                    //
                    //             txtff.text = "";
                    //
                    //             shipmentTypeSelected = "Select";
                    //             commoditySelected = "Select";
                    //
                    //             showDialog(
                    //                 barrierDismissible: false,
                    //                 context: context,
                    //                 builder: (context) {
                    //                   return buildHawbPopUpIpad();
                    //                 });
                    //           }
                    //         }
                    //       }
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 4.0,
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10.0)), //
                    //       padding: const EdgeInsets.all(0.0),
                    //     ),
                    //     child: Container(
                    //       height: 50,
                    //       width: 150,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(10),
                    //         gradient: LinearGradient(
                    //           begin: Alignment.topRight,
                    //           end: Alignment.bottomLeft,
                    //           colors: [
                    //             Color(0xFF1220BC),
                    //             Color(0xFF3540E8),
                    //           ],
                    //         ),
                    //       ),
                    //       child: Padding(
                    //         padding:
                    //         const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    //         child: Align(
                    //           alignment: Alignment.center,
                    //           child: Text(
                    //             'Add MAWB',
                    //             style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.normal,
                    //                 color: Colors.white),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     //Text('CONTAINED BUTTON'),
                    //   ),
                    // ),
                  ],
                ),
              ),
            //SizedBox(height: 10),
            if (mawbList.length > 0)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: useMobileLayout
                    ? Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          height: 128,
                          width: MediaQuery.of(context).size.width / 1.03,
                          child: Card(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.19,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext, index) {
                                  AWB _awblist = mawbList.elementAt(index);
                                  return buildMawbListMobile(_awblist, index);
                                },
                                itemCount: mawbList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(5),
                              ),
                            ),
                          ),
                        ),
                      )
                    : modeSelected ==
                            1 // widget.modeSelected.toLowerCase().contains("pick")
                        ? isVerified
                            ? Padding(
                                padding: EdgeInsets.only(left: 40, right: 20),
                                child: Container(
                                  height: 150,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0, left: 40.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.19,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          //rphysics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext, index) {
                                            AWB _awblist = verifiedMawbList
                                                .elementAt(index);
                                            return buildMawbListIpad12(
                                                _awblist, index);
                                          },
                                          itemCount: verifiedMawbList.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(left: 40, right: 20),
                                child: Container(
                                  height: 180,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0, left: 40.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.19,
                                        child: ListView.builder(
                                          //scrollDirection: Axis.horizontal,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext, index) {
                                            AWB _awblist =
                                                mawbList.elementAt(index);
                                            return buildMawbListIpad(
                                                _awblist, index);
                                          },
                                          itemCount: mawbList.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                        : Padding(
                            padding: EdgeInsets.only(left: 40, right: 20),
                            child: Container(
                              // height: 150,
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.19,
                                child: ListView.builder(
                                  // scrollDirection: Axis.horizontal,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext, index) {
                                    AWB _awblist = mawbList.elementAt(index);
                                    return buildMawbListIpad(_awblist, index);
                                  },
                                  itemCount: mawbList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(5),
                                ),
                              ),
                            ),
                          ),
              ),
            SizedBox(height: 10),

            // useMobileLayout
            //     ? Expanded(
            //         flex: 0,
            //         child: Padding(
            //           padding: const EdgeInsets.only(
            //               top: 2.0, bottom: 0.0, left: 0.0),
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.start,
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   SizedBox(
            //                     width:
            //                         MediaQuery.of(context).size.width / 1.6,
            //                     child: (hawbListToBind.length == 0)
            //                         ? Container()
            //                         : selectedMawbNo == ""
            //                             ? Text("HAWB List for selectedMawbNo")
            //                             : Text(
            //                                 " HAWB List for " +
            //                                     selectedMawbNo,
            //                                 style: mobileHeaderFontStyle),
            //                   ),
            //                   Padding(
            //                     padding: const EdgeInsets.only(left: 10.0),
            //                     child: ElevatedButton(
            //                       onPressed: () {
            //                         txtMawbnoH.text = selectedMawbNo;
            //                         txtPrefixH.text = selectedPrefix;
            //                         txtOriginH.text = selectedOrigin;

            //                         txthawbnoH.text = "";
            //                         txtpickupnopH.text = "";
            //                         txtgrwtnopH.text = "";
            //                         txtnatureofgoodsH.text = "";

            //                         showDialog(
            //                             barrierDismissible: false,
            //                             context: context,
            //                             builder: (context) {
            //                               return buildHawbPopUpMobile();
            //                             });
            //                       },
            //                       style: ElevatedButton.styleFrom(
            //                         elevation: 4.0,
            //                         shape: RoundedRectangleBorder(
            //                             borderRadius:
            //                                 BorderRadius.circular(10.0)), //
            //                         padding: const EdgeInsets.all(0.0),
            //                       ),
            //                       child: Container(
            //                         height: 40,
            //                         width: 120,
            //                         decoration: BoxDecoration(
            //                           borderRadius: BorderRadius.circular(10),
            //                           gradient: LinearGradient(
            //                             begin: Alignment.topRight,
            //                             end: Alignment.bottomLeft,
            //                             colors: [
            //                               Color(0xFF1220BC),
            //                               Color(0xFF3540E8),
            //                             ],
            //                           ),
            //                         ),
            //                         child: Padding(
            //                           padding: const EdgeInsets.only(
            //                               top: 8.0, bottom: 8.0),
            //                           child: Align(
            //                               alignment: Alignment.center,
            //                               child: Text(
            //                                 'Add HAWB',
            //                                 style: buttonWhiteFontStyleSmall,
            //                               )),
            //                         ),
            //                       ),
            //                       //Text('CONTAINED BUTTON'),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               //SizedBox(height: 10),
            //               // SizedBox(
            //               //   width: MediaQuery.of(context).size.width / 1.1,
            //               //   child: Card(
            //               //     child: Container(
            //               //       width: MediaQuery.of(context).size.width / 1.1,
            //               //       color: Colors.white,
            //               //       // height: 248,
            //               //     ),
            //               //   ),
            //               // ),
            //             ],
            //           ),
            //         ),
            //       )
            //     :

            if ((mawbList.length > 0) && modeSelected == 1)
              Expanded(
                flex: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 2.0, bottom: 0.0, left: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: (hawbListToBind.length == 0)
                                ? Container()
                                : selectedMawbNo == ""
                                    ? Text(" ")
                                    : Text(
                                        " HAWB List for MAWB# " +
                                            selectedMawbNo,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F),
                                        ),
                                      ),
                          ),
                          shipmentTypeSelected != "Direct"
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      txtMawbnoH.text = selectedMawbNo;
                                      txtPrefixH.text = selectedPrefix;
                                      txtOriginH.text = selectedOrigin;

                                      txthawbnoH.text = "";
                                      txtpickupnopH.text = "";
                                      txtgrwtnopH.text = "";
                                      txtnatureofgoodsH.text = "";

                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return buildHawbPopUpIpad();
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)), //
                                      padding: const EdgeInsets.all(0.0),
                                    ),
                                    child: Container(
                                      height: 50,
                                      width: 150,
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
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Add HAWB',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //Text('CONTAINED BUTTON'),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.1,
                            color: Colors.white,
                            // height: 248,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (mawbList.length > 0)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: useMobileLayout
                      ? Padding(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.03,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.19,
                              child: ListView.builder(
                                // scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext, index) {
                                  AWB _awblist =
                                      hawbListToBind.elementAt(index);

                                  return buildHawbListMobile(_awblist, index);
                                },
                                itemCount: hawbListToBind.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.all(5),
                              ),
                            ),
                          ),
                        )
                      : isVerified
                          ? Padding(
                              padding: EdgeInsets.only(left: 40, right: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.19,
                                  child: ListView.builder(
                                    // scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext, index) {
                                      AWB _awblist =
                                      filteredHawbList.elementAt(index);

                                      return buildHawbListIpad(_awblist, index);
                                    },
                                    itemCount: filteredHawbList.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(5),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 40, right: 20),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.19,
                                  child: ListView.builder(
                                    // scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext, index) {
                                      AWB _awblist =
                                          hawbListToBind.elementAt(index);

                                      return buildHawbListIpad(_awblist, index);
                                    },
                                    itemCount: hawbListToBind.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(5),
                                  ),
                                ),
                              ),
                            ),
                ),
              ),
          ]),
    );
  }

  buildMawbListIpad12(AWB _awb, index) {
    // return Container(
    //   height: 200,
    //   color: Colors.yellow.shade100,
    //   child: Text(_awb.mawbno),
    // );

    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            // txtMawbnoM.text = _awb.mawbno;
            // txtPrefixM.text = _awb.prefix;
            // txtOriginM.text = _awb.origin;
            // txtpickupnopM.text = _awb.nop;
            // txtgrwtnopM.text = _awb.grwt;
            // txtnatureofgoodsM.text = _awb.natureofgoods;
            //
            // commoditySelected = _awb.natureofgoods;
            //
            // showDialog(
            //     barrierDismissible: false,
            //     context: context,
            //     builder: (context) {
            //       return useMobileLayout
            //           ? buildMawbPopUpMobile()
            //           : buildMawbPopUpIpad();
            //     });
          },
          onTap: () {
            runFilter(_awb.mawbno, _awb.origin, _awb.prefix);
          },
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 16.0, right: 0.0, bottom: 0),
            child: Container(
              height: MediaQuery.of(context).size.width / 7,
              width: MediaQuery.of(context).size.width / 7, //180
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: shipmentTypeSelected != "Direct"
                      ? [
                    Color(0xFFfd6607), Color(0xFFfd7f07)
                          // selectedMawbNo == _awb.mawbno
                          //     ? Color(0xFFfd6607)
                          //     : Color(0xFF076cfd),
                          // selectedMawbNo == _awb.mawbno
                          //     ? Color(0xFFfd7f07)
                          //     : Color(0xFF0785fd),
                        ]
                      : [Color(0xFFfd6607), Color(0xFFfd7f07)],
                ),
                  border: Border.all(
                    color: selectedMawbNo == _awb.mawbno
                        ? Color(0xFF11249F)
                        : Colors.transparent,
                    width: 4
                  )),

              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${_awb.prefix}\n${_awb.mawbno}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () async {
              var userSelection = await showDialog(
                context: context,
                builder: (BuildContext context) => CustomConfirmDialog(
                    title: "Are you sure ?",
                    description: "Are you sure you want to delete this Master ",
                    buttonText: "Okay",
                    imagepath: 'assets/images/warn.gif',
                    isMobile: useMobileLayout),
              );

              // Navigator.pop(context);
              //print(userSelection);

              if (userSelection == true) {
                print("_awb.mawbno ==" + _awb.mawbno);
                print("userSelection ==" + userSelection.toString());

                // print("mawbList.length after delete =" +
                //     mawbList.length.toString());

                mawbList.removeWhere((element) {
                  return element.mawbno == _awb.mawbno;
                });

                hawbList.removeWhere((element) {
                  return element.mawbno == _awb.mawbno;
                });

                // print("mawbList.length after delete =" +
                //     mawbList.length.toString());

                setState(() {
                  hawbListToBind = hawbList;
                  if (hawbListToBind.length == 0) {
                    selectedMawbNo = "";
                    selectedOrigin = "";
                    selectedPrefix = "";
                  }
                });
              }
            },
            child: isVerified
                ? Container()
                : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.white,
                        ),
                        color: Colors.red,
                        shape: BoxShape.circle),
                    child: Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
            // ),
          ),
        ),
      ],
    );
  }

  buildMawbListMobile(AWB _awb, index) {
    // return Container(
    //   height: 200,
    //   color: Colors.yellow.shade100,
    //   child: Text(_awb.mawbno),
    // );

    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            txtMawbnoM.text = _awb.mawbno;
            txtPrefixM.text = _awb.prefix;
            txtOriginM.text = _awb.origin;
            txtpickupnopM.text = _awb.nop;
            txtgrwtnopM.text = _awb.grwt;
            txtnatureofgoodsM.text = _awb.natureofgoods;

            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return useMobileLayout
                      ? buildMawbPopUpMobile()
                      : buildMawbPopUpIpad();
                });
          },
          onTap: () {
            runFilter(_awb.mawbno, _awb.origin, _awb.prefix);
          },
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 16.0, right: 0.0, bottom: 0),
            child: Container(
              height: MediaQuery.of(context).size.width / 4.5,
              width: MediaQuery.of(context).size.width / 4.5, //180
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    selectedMawbNo == _awb.mawbno
                        ? Color(0xFFfd6607)
                        : Color(0xFF076cfd),
                    selectedMawbNo == _awb.mawbno
                        ? Color(0xFFfd7f07)
                        : Color(0xFF0785fd),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _awb.mawbno.substring(0, 3) +
                        " \n " +
                        _awb.mawbno.substring(4, _awb.mawbno.length),
                    textAlign: TextAlign.center,
                    style: walkinMasterTextFontStyleWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () async {
              var userSelection = await showDialog(
                context: context,
                builder: (BuildContext context) => CustomConfirmDialog(
                    title: "Are you sure ?",
                    description: "Are you sure you want to delete this Master ",
                    buttonText: "Okay",
                    imagepath: 'assets/images/warn.gif',
                    isMobile: useMobileLayout),
              );

//  showDialog(
//                         context: context,
//                         builder: (BuildContext context) => CustomDialog(
//                           title: widget.vtNumber,
//                           description: "Dock-in for VT# " +
//                               widget.vtNumber +
//                               " has been completed successfully",
//                           buttonText: "Okay",
//                           imagepath: 'assets/images/successchk.gif',
//                         ),
//                       );

              // Navigator.pop(context);
              print("_awb.mawbno ==" + _awb.mawbno);
              print("userSelection ==" + userSelection.toString());

              if (userSelection == true) {
                mawbList.removeWhere((element) {
                  return element.mawbno == _awb.mawbno;
                });

                hawbList.removeWhere((element) {
                  return element.mawbno == _awb.mawbno;
                });

                setState(() {
                  hawbListToBind = hawbList;
                  if (hawbListToBind.length == 0) {
                    selectedMawbNo = "";
                    selectedOrigin = "";
                    selectedPrefix = "";
                  }
                });
              }
            },
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                  color: Colors.red,
                  shape: BoxShape.circle),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 18,
              ),
            ),
            // ),
          ),
        ),
      ],
    );
  }

  buildHawbListIpad(AWB _awb, index) {
    //  print(_awb.mawbno + "   " + _awb.hawbno);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            txtMawbnoH.text = _awb.mawbno;
            txthawbnoH.text = _awb.hawbno;
            txtPrefixH.text = _awb.prefix;
            txtOriginH.text = _awb.origin;
            txtpickupnopH.text = _awb.nop;
            txtgrwtnopH.text = _awb.grwt;
            txtnatureofgoodsH.text = _awb.natureofgoods;

            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return buildHawbPopUpIpad(index);
                });
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              // color: Color(0xFFF7CECE),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Hawb No.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.hawbno,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Destination',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.origin,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Drop NoP',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.nop,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Drop NoP Gross Wt.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.grwt,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 1.2,
                    color: Color(0xFF0461AA),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 8.0, left: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.72,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text('Dock No.'),
                              Text('Nature of goods',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                              SizedBox(height: 3),
                              Text(
                                _awb.natureofgoods,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text('Dock No.'),
                              Text('Freight Forawarder (Opt.)',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                              SizedBox(height: 3),
                              Text(
                                _awb.ff,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight, //Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () async {
              var userSelection = await showDialog(
                context: context,
                builder: (BuildContext context) => CustomConfirmDialog(
                    title: "Are you sure ?",
                    description: "Are you sure you want to delete this House ",
                    buttonText: "Okay",
                    imagepath: 'assets/images/warn.gif',
                    isMobile: useMobileLayout),
              );

              // Navigator.pop(context);
              print("_awb.mawbno ==" + _awb.mawbno);
              print("userSelection ==" + userSelection.toString());

              if (userSelection == true) {
                // hawbList.removeWhere((element) {
                //   return element.hawbno == _awb.hawbno;
                // });
                print("^^^^^^ $index");
                hawbListToBind.removeAt(index);
                hawbList.removeAt(index);
                setState(() {});
              }
            },
            child:isVerified?SizedBox(): Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.white,
                  ),
                  color: Colors.red,
                  shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // ),
          ),
        ),
      ],
    );
  }

  buildMawbListIpad(AWB _awb, index) {
    //  print(_awb.mawbno + "   " + _awb.hawbno);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            txtMawbnoM.text = _awb.mawbno;
            txtPrefixM.text = _awb.prefix;
            txtOriginM.text = _awb.origin;
            txtpickupnopM.text = _awb.nop;
            txtgrwtnopM.text = _awb.grwt;
            txtnatureofgoodsM.text = _awb.natureofgoods;
            commoditySelected = _awb.natureofgoods;
            print(_awb.natureofgoods);
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return useMobileLayout
                      ? buildMawbPopUpMobile()
                      : buildMawbPopUpIpad(index);
                });
            print("@@@@ $index");
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              // color: Color(0xFFF7CECE),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Mawb No.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    "${_awb.prefix}-${_awb.mawbno}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Destination',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.origin,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('Drop NoP',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.nop,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Text('Dock No.'),
                                  Text('NoP Gross Wt.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF11249F))),
                                  SizedBox(height: 3),
                                  Text(
                                    _awb.grwt,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 1.2,
                    color: Color(0xFF0461AA),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 8.0, left: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.72,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text('Dock No.'),
                              Text('Commodity',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                              SizedBox(height: 3),
                              Text(
                                _awb.natureofgoods,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text('Dock No.'),
                              Text('Freight Forawarder (Opt.)',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                              SizedBox(height: 3),
                              Text(
                                _awb.ff,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight, //Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () async {
              var userSelection = await showDialog(
                context: context,
                builder: (BuildContext context) => CustomConfirmDialog(
                    title: "Are you sure ?",
                    description: "Are you sure you want to delete this Master ",
                    buttonText: "Okay",
                    imagepath: 'assets/images/warn.gif',
                    isMobile: useMobileLayout),
              );

              // Navigator.pop(context);

              if (userSelection == true) {
                print("_awb.mawbno ==" + _awb.mawbno);
                print("userSelection ==" + userSelection.toString());

                // mawbList.removeWhere((element) {
                //   return element.mawbno == _awb.mawbno;
                // });
                mawbList.removeAt(index);
                setState(() {});
              }
            },
            child: isVerified?SizedBox():Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.white,
                  ),
                  color: Colors.red,
                  shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // ),
          ),
        ),
      ],
    );
  }

  buildHawbListMobile(AWB _awb, index) {
    //  print(_awb.mawbno + "   " + _awb.hawbno);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            txtMawbnoH.text = _awb.mawbno;
            txthawbnoH.text = _awb.hawbno;
            txtPrefixH.text = _awb.prefix;
            txtOriginH.text = _awb.origin;
            txtpickupnopH.text = _awb.nop;
            txtgrwtnopH.text = _awb.grwt;
            txtnatureofgoodsH.text = _awb.natureofgoods;

            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return buildHawbPopUpMobile();
                });
          },
          child: Card(
            // color: Color(0xFFF7CECE),
            //clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpansionTile(
                  trailing: Visibility(
                      visible: false, child: Icon(Icons.arrow_downward)),
// iconColor: Colors.white,
// collapsedIconColor: Colors.pink,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.6,
                              child: Text('Hawb No.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text('Destination',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.6,
                              child: Text(
                                _awb.hawbno,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                _awb.origin,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                          ]),
                      SizedBox(height: 5),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.6,
                              child: Text('Drop NoP',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.8,
                              child: Text('Drop NoP GR. WT.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11249F))),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.6,
                              child: Text(
                                _awb.nop,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.8,
                              child: Text(
                                _awb.grwt,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                          ]),
                    ],
                  ),

                  children: <Widget>[
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width / 1.2,
                      color: Color(0xFF0461AA),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 8.0, left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.72,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text('Dock No.'),
                                Text('Nature of goods',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF11249F))),
                                SizedBox(height: 3),
                                Text(
                                  _awb.natureofgoods,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text('Dock No.'),
                                Text('Freight Forawarder (Opt.)',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF11249F))),
                                SizedBox(height: 3),
                                Text(
                                  _awb.ff,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight, //Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () async {
              var userSelection = await showDialog(
                context: context,
                builder: (BuildContext context) => CustomConfirmDialog(
                    title: "Are you sure ?",
                    description: "Are you sure you want to delete this House ",
                    buttonText: "Okay",
                    imagepath: 'assets/images/warn.gif',
                    isMobile: useMobileLayout),
              );

              // Navigator.pop(context);
              print("_awb.mawbno ==" + _awb.mawbno);
              print("userSelection ==" + userSelection.toString());

              if (userSelection == true) {
                hawbList.removeWhere((element) {
                  return element.hawbno == _awb.hawbno;
                });

                setState(() {});
              }
            },
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.white,
                  ),
                  color: Colors.red,
                  shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            // ),
          ),
        ),
      ],
    );
  }

  buildMawbPopUpIpad([int? itemIndex]) {
    return Container(
      height: MediaQuery.of(context).size.height / 5.2, // height: 250,
      width: MediaQuery.of(context).size.width / 6,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add MAWB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11249F),
                )),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            // ),
          ],
        ), // To display the title it is optional
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (modeSelected == 1)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "Shipment/Pick-up type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
              ],
            ),
            if (modeSelected == 1) SizedBox(height: 10),
            Row(
              children: [
                if (modeSelected == 1)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Container(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        isDense: true,
                        //isExpanded: true,
                        decoration: InputDecoration(
                          //labelText: 'select option',
                          contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          // filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        value:
                            itemIndex != null ? shipmentTypeSelected : 'Select',
                        items: ['Select', 'Direct', 'Consol']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            print("$shipmentTypeSelected----");
                            shipmentTypeSelected = value.toString();
                            print("$shipmentTypeSelected=====");
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
            if (modeSelected == 1) SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 9,
                  child: Text(
                    "Prefix",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.2,
                  child: Text(
                    "MAWB No.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 9,
                  child: Text(
                    modeSelected == 1 ? "Origin" : "Destination",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // SizedBox(
                //   width: MediaQuery.of(context).size.width /
                //       10, // hard coding child width
                //   child: Container(
                //     height: 40,
                //     width: MediaQuery.of(context).size.width / 10,
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: Colors.grey.withOpacity(0.5),
                //         width: 1.0,
                //       ),
                //       borderRadius: BorderRadius.circular(4.0),
                //     ),
                //     child: TextField(
                //         keyboardType: TextInputType.number,
                //         maxLength: 3,
                //         controller: txtPrefixM,
                //         decoration: InputDecoration(
                //           border: InputBorder.none,
                //           counterText: "",
                //           hintText: "Enter prefix",
                //           hintStyle: TextStyle(color: Colors.grey),
                //           contentPadding:
                //               EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                //           isDense: true,
                //         ),
                //         style: TextStyle(
                //           fontSize: 18.0,
                //           color: Colors.black,
                //         ),
                //         onChanged: (str) {
                //           // print(str);
                //           // txtMawbnoM.text = str + "-";
                //         }),
                //   ),
                // ),

                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      10, // hard coding child width
                  child: SingleChildScrollView(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TypeAheadField(
                          //he
                          textFieldConfiguration: TextFieldConfiguration(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]')),
                              ],
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              //  keyboardType: TextInputType.number,
                              maxLength: 3,
                              controller: txtPrefixM,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                                hintText: "Select prefix",
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                              ),

                              // enabled: false,
                              onChanged: (txt) {}),
                          suggestionsCallback: (pattern) async {
                            return getSuggestionsPrefix(pattern);
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          itemBuilder: (context, AirlinesPrefix suggestion) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 2.0),
                              child: Text(
                                suggestion.AirlinePrefix.toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          },
                          //suggestionsBoxDecoration: ,
                          onSuggestionSelected: (AirlinesPrefix suggestion) {
                            this.txtPrefixM.text =
                                suggestion.AirlinePrefix.toString();

                            // bookingDetailsSave['Mode'] = suggestion.toString();
                          }),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      //   keyboardType: TextInputType.text,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      maxLength: 8,
                      controller: txtMawbnoM,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter MAWB No.",
                        counterText: "",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      10, // hard coding child width
                  child: SingleChildScrollView(
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 10,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TypeAheadField(
                          //he
                          textFieldConfiguration: TextFieldConfiguration(
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              // ),
                              keyboardType: TextInputType.text,
                              maxLength: 3,
                              controller: txtOriginM,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                                hintText: "Select origin",
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                              ),
                              onChanged: (txt) {}),
                          suggestionsCallback: (pattern) async {
                            return getSuggestionsOrgDest(pattern);
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          itemBuilder: (context, Airport suggestion) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 2.0),
                              child: Text(
                                suggestion.CityCode.toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          },
                          // suggestionsBoxDecoration: ,
                          onSuggestionSelected: (Airport suggestion) {
                            this.txtOriginM.text =
                                suggestion.CityCode.toString();

                            // bookingDetailsSave['Mode'] = suggestion.toString();
                          }),

                      // TextField(
                      //   keyboardType: TextInputType.text, maxLength: 3,
                      //   // inputFormatters: [FilteringTextInputFormatter.allow(filterPattern),
                      //   controller: txtOriginM,
                      //   //inputFormatters: [UpperCaseTextFormatter()],
                      //   textCapitalization: TextCapitalization.characters,
                      //   decoration: InputDecoration(
                      //     border: InputBorder.none,
                      //     hintText: "Enter origin",
                      //     counterText: "",
                      //     hintStyle: TextStyle(color: Colors.grey),
                      //     contentPadding:
                      //         EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      //     isDense: true,
                      //   ),
                      //   style: TextStyle(
                      //     fontSize: 18.0,
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // SizedBox(
                //   width: MediaQuery.of(context).size.width / 3.8,
                //   child: Text(
                //     "HAWB No.",
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.normal,
                //       color: Color(0xFF11249F),
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 6.4,
                  child: Text(
                    (modeSelected == 1) ? "Pick-up NoP" : "Drop-off NoP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  child: Text(
                    "NoP Gross Wt.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                //     SizedBox(width: 10),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width /
                //       4, // hard coding child width
                //   child: Container(
                //     height: 40,
                //     width: MediaQuery.of(context).size.width / 4,
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: Colors.grey.withOpacity(0.5),
                //         width: 1.0,
                //       ),
                //       borderRadius: BorderRadius.circular(4.0),
                //     ),
                //     child: TextField(
                //       keyboardType: TextInputType.number,
                //       controller: txthawbnoM,
                //       decoration: InputDecoration(
                //         border: InputBorder.none,
                //         hintText: "Enter HAWB No.",
                //         hintStyle: TextStyle(color: Colors.grey),
                //         contentPadding:
                //             EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                //         isDense: true,
                //       ),
                //       style: TextStyle(
                //         fontSize: 18.0,
                //         color: Colors.black,
                //       ),
                //     ),
                //   ),
                // ),

                // SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      7, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      //keyboardType: TextInputType.number,
                      maxLength: 8,
                      controller: txtpickupnopM,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                        hintText: (modeSelected == 1)
                            ? "Enter pick-up NoP"
                            : "Enter drop-off NoP",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      6, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      maxLength: 8,
                      controller: txtgrwtnopM,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                        hintText: "Enter NoP gross wt.",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  child: Text(
                    "Kgs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            if (modeSelected == 0) SizedBox(height: 10),
            if (modeSelected == 0)
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "Freight Forwarder(Opt.)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
            if (modeSelected == 0) SizedBox(height: 10),

            if (modeSelected == 0)
              Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Container(
                        // height: 40,
                        // width: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,

                          //keyboardType: TextInputType.number,
                          controller: txtff,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Freight forwarder",
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      )),
                ],
              ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Text(
                    "Commodity",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Container(
                    //width: MediaQuery.of(context).size.width / 5,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        // filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      hint: Text("---- Select ----", style: iPadTextFontStyle),
                      dropdownColor: Colors.white,
                      value: itemIndex != null
                          ? commoditySelectedID
                          : selectedBaseForCommId,
                      // "Select",
                      items: commodityList
                          .map((comm) => DropdownMenuItem(
                                value: comm.shcId,
                                child: Text(
                                  comm.specialHandlingCode.trim(),
                                  style: iPadTextFontStyle,
                                ),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        setState(() {
                          commoditySelected = value.toString();
                          commoditySelectedID = value!;
                          print(commoditySelected);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

//             Container(
//               height: 80,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey.withOpacity(0.5),
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(4.0),
//               ),
//               child: TextField(
//                 //  expands: true,
//                 // minLines: 1,
//                 minLines: 1,
//                 maxLines: 2, // allow user to enter 5 line in textfield
//                 keyboardType: TextInputType
//                     .multiline, // user keyboard will have a button to move cursor to next line
// maxLength:50,
//                 controller: txtnatureofgoodsM,
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                     counterText: "",
//                   hintText: "Enter nature of goods",
//                   hintStyle: TextStyle(color: Colors.grey),
//                   contentPadding:
//                       EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   isDense: true,
//                 ),
//                 style: TextStyle(
//                   fontSize: 20.0,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
          ],
        ), // Message which will be pop up on the screen
        // Action widget which will provide the user to acknowledge the choice
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
                height: 50,
                width: 150,
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
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF11249F)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: ElevatedButton(
              //textColor: Colors.black,
              onPressed: () {
                var masterNo = txtMawbnoM.text.substring(0, 7);
                var modValue = int.parse(masterNo) % 7;
                var validMaster = masterNo + modValue.toString();
                if (txtMawbnoM.text.length != 8 ||
                    txtMawbnoM.text != validMaster) {
                  txtMawbnoM.text = "";
                  return;
                }
                AWB _newMawbRow;
                if (modeSelected == 1) {
                  _newMawbRow = new AWB(
                      shiptype: shipmentTypeSelected,
                      origin: txtOriginM.text,
                      prefix: txtPrefixM.text,
                      mawbno: txtMawbnoM.text,
                      hawbno: "",
                      nop: txtpickupnopM.text,
                      grwt: txtgrwtnopM.text,
                      natureofgoods: commoditySelected,
                      ff: "",
                      isselect: false,
                      index: mawbList.length);
                } else {
                  _newMawbRow = new AWB(
                      shiptype: "",
                      origin: txtOriginM.text,
                      prefix: txtPrefixM.text,
                      mawbno: txtMawbnoM.text,
                      hawbno: "",
                      nop: txtpickupnopM.text,
                      grwt: txtgrwtnopM.text,
                      natureofgoods: commoditySelected,
                      ff: txtff.text,
                      isselect: false,
                      index: mawbList.length);
                }

                // AWB _newMawbRow = new AWB(
                //     shiptype: "shiptype",
                //     origin: txtOriginM.text,
                //     prefix: txtPrefixM.text,
                //     mawbno: txtMawbnoM.text,
                //     hawbno: txthawbnoM.text,
                //     nop: txtpickupnopM.text,
                //     grwt: txtgrwtnopM.text,
                //     natureofgoods: txtnatureofgoodsM.text,
                //     ff: "GT freight",
                //     isselect: false,
                //     index: mawbList.length);

                print("_newMawbRow.index ==" + _newMawbRow.index.toString());
                if (modeSelected == 1) {
                  // mawbList = [];
                  // hawbList = [];
                  if (itemIndex != null) {
                    mawbList[itemIndex] = _newMawbRow;
                  } else {
                    mawbList = [];
                    hawbList = [];
                    mawbList.add(_newMawbRow);
                  }
                  isVerified = false;
                  print("Added $isVerified");
                } else {
                  print("+++++ $itemIndex");
                  if (itemIndex != null) {
                    mawbList[itemIndex] = _newMawbRow;
                    print("edit");
                  } else {
                    mawbList.add(_newMawbRow);
                  }
                }

                setState(() {
                  selectedMawbNo = txtMawbnoM.text;
                  selectedPrefix = txtPrefixM.text;
                  selectedOrigin = txtOriginM.text;
                  print("^^^^^^^^^^$selectedMawbNo");
                  runFilter(selectedMawbNo, selectedOrigin, selectedPrefix);
                  print("$selectedMawbNo ^^^^^^^^^^");
                  txtOriginM.text = "";
                  txtPrefixM.text = "";
                  txtOriginM.text = "";
                  txtMawbnoM.text = "";
                  txthawbnoM.text = "";
                  txtpickupnopM.text = "";
                  txtgrwtnopM.text = "";
                  txtnatureofgoodsM.text = "";
                });

                Navigator.of(context).pop("y");
              },
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)), //
                padding: const EdgeInsets.all(0.0),
              ),
              child: Container(
                height: 50,
                width: 150,
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
                      'Save',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  saveData() async {
    try {
      // return true;
      errMsgText = "";
      String responseTextUpdated = "";
      bool isValid = false;

      setState(() {
        isSavingData = true;
      });

      String walkinTableString = "";
      String finalMawbDropOffTableString = "",
          finalMawbPickUpTableString = "",
          finalHawbTableString = "",
          finalWalkInTableString = "";

      int iWalkIn = 0;

      // for (WalkinMain u in widget.walkinTable) {
      //   String a = "{\"driName\": \"${u.driName}\"," +
      //       "\"driSTA\":\"${u.driSTA}\"," +
      //       "\"lisNo\":\"${u.lisNo}\"," +
      //       "\"mobNo\":\"${u.mobNo}\"," +
      //       "\"email\":\"${u.email}\"," +
      //       "\"mobNoPrefix\":\"352\"," +
      //       "\"terminal\":\"${u.terminal}\"," +
      //       "\"truckCompany\":\"${u.truckCompany}\"," +
      //       "\"vehType\":\"${u.vehType}\"," +
      //       "\"vehNo\":\"${u.vehNo}\" }";
      //   if (iWalkIn == 0)
      //     walkinTableString = walkinTableString + a;
      //   else
      //     walkinTableString = walkinTableString + "," + a;
      //
      //   iWalkIn++;
      // }

      //  finalWalkInTableString = "[" + walkinTableString + "]";
      finalWalkInTableString = walkinTableString;
      //finalWalkInTableString = json.decode(finalWalkInTableString);

      if (modeSelected == 0) {
        String mawbDropOffTableString = "";
        int iMawbDropOff = 0;

        for (AWB u in mawbList) {
          String a = "{\"GrWt\": \"${u.grwt}\"," +
              "\"destination\":\"${u.origin}\"," +
              "\"prefix\":\"${u.prefix}\"," +
              "\"mawbNo\":\"${u.mawbno}\"," +
              "\"MAWBId\":${u.index}," +
              "\"NoP\":\"${u.nop}\"," +
              "\"NatureOfGoods\":\"${u.natureofgoods}\"," +
              "\"freightForwarder\":\"${u.ff}\" }";

          // print("json a");
          // print(a);
          // print(json.decode(a));
          // print(json.encode(a));
          if (iMawbDropOff == 0)
            mawbDropOffTableString = mawbDropOffTableString + a;
          else
            mawbDropOffTableString = mawbDropOffTableString + "," + a;

          iMawbDropOff++;
        }
        finalMawbDropOffTableString = "[" + mawbDropOffTableString + "]";
        //finalWalkInTableString = json.decode(finalWalkInTableString);
      } else {
        String mawbPickUpTableString = "";
        int iMawbPickup = 0;

        for (AWB u in mawbList) {
          String a = "{\"GrWt\": \"${u.grwt}\"," +
              "\"origin\":\"${u.origin}\"," +
              "\"prefix\":\"${u.prefix}\"," +
              "\"mawbNo\":\"${u.mawbno}\"," +
              "\"MAWBId\":${u.index}," +
              "\"NoP\":\"${u.nop}\"," +
              "\"NatureOfGoods\":\"${u.natureofgoods}\"," +
              "\"shipmentType\":\"${u.shiptype}\" }";

          // print("json a");
          // print(a);
          // print(json.decode(a));
          // print(json.encode(a));
          if (iMawbPickup == 0)
            mawbPickUpTableString = mawbPickUpTableString + a;
          else
            mawbPickUpTableString = mawbPickUpTableString + "," + a;

          iMawbPickup++;
        }
        finalMawbPickUpTableString = "[" + mawbPickUpTableString + "]";
        //finalWalkInTableString = json.decode(finalWalkInTableString);
      }

      if (hawbList.length > 0) {
        String hawbTableString = "";
        int iHawb = 0;

        for (AWB u in mawbList) {
          String a = "{\"GrWt\": \"${u.grwt}\"," +
              "\"origin\":\"${u.origin}\"," +
              "\"prefix\":\"${u.prefix}\"," +
              "\"mawbNo\":\"${u.mawbno}\"," +
              "\"MAWBId\":${u.index}," +
              "\"hawbNo\":\"${u.mawbno}\"," +
              "\"NoP\":\"${u.nop}\"," +
              "\"NatureOfGoods\":\"${u.natureofgoods}\"," +
              "\"shipmentType\":\"${u.shiptype}\" }";

          // print("json a");
          // print(a);
          // print(json.decode(a));
          // print(json.encode(a));
          if (iHawb == 0)
            hawbTableString = hawbTableString + a;
          else
            hawbTableString = hawbTableString + "," + a;

          iHawb++;
        }
        finalHawbTableString = "[" + hawbTableString + "]";
        // finalHawbTableString =  hawbTableString ;
        //finalWalkInTableString = json.decode(finalWalkInTableString);
      }

      //import

      print(json.decode(finalWalkInTableString));
      // print("json.decode(finalHawbTableString)");
      // print(json.decode(finalHawbTableString));

      if (modeSelected == 1) {
        print(json.decode(finalMawbPickUpTableString));
        if (!hawbList.isEmpty) print(json.decode(finalHawbTableString));
      } else {
        print(json.decode(finalMawbDropOffTableString));
      }

      if (hawbList.isEmpty) {
        finalHawbTableString = "[]";
      }

      var queryParams = modeSelected == 1
          ? hawbList.isEmpty
              ? {
                  //import
                  "VTData": json.decode(finalWalkInTableString),
                  "MAWBData": json.decode(finalMawbPickUpTableString),
                  "HawbData": json.decode(finalHawbTableString),
                }
              : {
                  //import
                  "VTData": json.decode(finalWalkInTableString),
                  "MAWBData": json.decode(finalMawbPickUpTableString),
                  "HawbData": json.decode(finalHawbTableString),
                }
          : {
              //export
              "VTData": json.decode(finalWalkInTableString),
              "MAWBData": json.decode(finalMawbDropOffTableString),
            };
      await Global()
          .postData(
        modeSelected == 1
            ? Settings.SERVICES['SaveImportShipment']
            : Settings.SERVICES['SaveExportShipment'],
        queryParams,
      )
          .then((response) {
        print("data received ");
        print(json.decode(response.body)['d']);

        if (json.decode(response.body)['d'] != null) {
          var msg = json.decode(response.body)['d'];
          var resp = json.decode(msg).cast<Map<String, dynamic>>();
          isValid = true;

          List<ResponseMsg> rspMsg = [];
          rspMsg = resp
              .map<ResponseMsg>((json) => ResponseMsg.fromJson(json))
              .toList();
          if (rspMsg.isNotEmpty)
            responseTextUpdated = rspMsg[0].StrMessage.toString();
        }

        // if (json.decode(response.body)['d'] == null) {
        //   isValid = true;
        // } else {
        //   var responseText = json.decode(response.body)['d'].toString();

        //   if (responseText.toLowerCase().contains("errormsg")) {
        //     responseTextUpdated =
        //         responseText.toString().replaceAll("ErrorMSG", "");
        //     responseTextUpdated =
        //         responseTextUpdated.toString().replaceAll(":", "");
        //     responseTextUpdated =
        //         responseTextUpdated.toString().replaceAll("\"", "");
        //     responseTextUpdated =
        //         responseTextUpdated.toString().replaceAll("{", "");
        //     responseTextUpdated =
        //         responseTextUpdated.toString().replaceAll("}", "");
        //     print(responseTextUpdated.toString());
        //   }

        //   isValid = false;
        // }

        setState(() {
          isSavingData = false;
          if (responseTextUpdated != "") errMsgText = responseTextUpdated;
        });
      }).catchError((onError) {
        setState(() {
          isSavingData = false;
        });
        print(onError);
      });
      return isValid;
    } catch (Exc) {
      print(Exc);
      return false;
    }
  }

  buildMawbPopUpMobile() {
    return Container(
      //  height: MediaQuery.of(context).size.height / 5.2,// height: 250,
      width: MediaQuery.of(context).size.width,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add MAWB', style: buttonWhiteFontStyleSmall),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // ),
          ],
        ), // To display the title it is optional
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.7,
                    child: Text(
                      "Shipment/Pick-up type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "Origin",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Container(
                      height: 40,
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        isDense: true,
                        //isExpanded: true,
                        decoration: InputDecoration(
                          //labelText: 'select option',
                          contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          // filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        value: 'Direct',
                        items: ['Console', 'Direct', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          shipmentTypeSelected = value.toString();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        5.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 5.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        maxLength: 3,
                        // inputFormatters: [FilteringTextInputFormatter.allow(filterPattern),
                        controller: txtOriginM,
                        //inputFormatters: [UpperCaseTextFormatter()],
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter origin",
                          counterText: "",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width / 4,
                  //   child: Text(
                  //     "  Origin",
                  //     style: TextStyle(
                  //         fontSize: 16,
                  //       fontWeight: FontWeight.normal,
                  //       color: Color(0xFF11249F),
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6.5,
                    child: Text(
                      " Prefix",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "MAWB No.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        7.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          controller: txtPrefixM,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintText: "Enter prefix",
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          onChanged: (str) {
                            // print(str);
                            //txtMawbnoM.text = str + "-";
                          }),
                    ),
                  ),
                  SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        2.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        controller: txtMawbnoM,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter MAWB No.",
                          counterText: "",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Row(
              //   children: [
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width / 4.2,
              //       child: Text(
              //         "MAWB No.",
              //         style: TextStyle(
              //             fontSize: 16,
              //           fontWeight: FontWeight.normal,
              //           color: Color(0xFF11249F),
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width / 4.3,
              //       child: Text(
              //         "HAWB No.",
              //         style: TextStyle(
              //             fontSize: 16,
              //           fontWeight: FontWeight.normal,
              //           color: Color(0xFF11249F),
              //         ),
              //       ),
              //     ),

              //   ],
              // ),

              SizedBox(
                width: MediaQuery.of(context).size.width / 1.8,
                child: Text(
                  "HAWB No.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF11249F),
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width /
                    1.8, // hard coding child width
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: txthawbnoM,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter HAWB No.",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Row(
              //             children: [
              //               SizedBox(
              //                 width: MediaQuery.of(context).size.width /
              //                     4.5, // hard coding child width
              //                 child: Container(
              //                   height: 40,
              //                   width: MediaQuery.of(context).size.width / 2.5,
              //                   decoration: BoxDecoration(
              //                     border: Border.all(
              //                       color: Colors.grey.withOpacity(0.5),
              //                       width: 1.0,
              //                     ),
              //                     borderRadius: BorderRadius.circular(4.0),
              //                   ),
              //                   child: TextField(
              //                     keyboardType: TextInputType.number,
              //                     maxLength: 12,
              //                     controller: txtMawbnoM,
              //                     decoration: InputDecoration(
              //                       border: InputBorder.none,
              //                       hintText: "Enter MAWB No.",
              //                       counterText: "",
              //                       hintStyle: TextStyle(color: Colors.grey),
              //                       contentPadding:
              //                           EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //                       isDense: true,
              //                     ),
              //                     style: TextStyle(
              //                       fontSize: 18.0,
              //                       color: Colors.black,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //               SizedBox(width: 10),
              //               SizedBox(
              //                 width: MediaQuery.of(context).size.width /
              //                     4.5, // hard coding child width
              //                 child: Container(
              //                   height: 40,
              //                   width: MediaQuery.of(context).size.width / 2.5,
              //                   decoration: BoxDecoration(
              //                     border: Border.all(
              //                       color: Colors.grey.withOpacity(0.5),
              //                       width: 1.0,
              //                     ),
              //                     borderRadius: BorderRadius.circular(4.0),
              //                   ),
              //                   child: TextField(
              //                     keyboardType: TextInputType.number,
              //                     controller: txthawbnoM,
              //                     decoration: InputDecoration(
              //                       border: InputBorder.none,
              //                       hintText: "Enter HAWB No.",
              //                       hintStyle: TextStyle(color: Colors.grey),
              //                       contentPadding:
              //                           EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //                       isDense: true,
              //                     ),
              //                     style: TextStyle(
              //                       fontSize: 18.0,
              //                       color: Colors.black,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //            ],
              //           ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "Pick-up NoP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "NoP GR. WT.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        4, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        // keyboardType: TextInputType.number,
//keyboardType:  TextInputType.numberWithOptions(signed: true,decimal: false,) ,
                        controller: txtpickupnopM,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter pick-up NoP",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        3.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 3.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ],
                        controller: txtgrwtnopM,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter NoP gross wt.",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "Nature of Goods",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: TextField(
                  //  expands: true,
                  // minLines: 1,
                  minLines: 1,
                  maxLines: 2,
                  // allow user to enter 5 line in textfield
                  keyboardType: TextInputType.multiline,
                  // user keyboard will have a button to move cursor to next line
                  maxLength: 50,
                  controller: txtnatureofgoodsM,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter nature of goods",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    isDense: true,
                    counterText: "",
                  ),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ), // Message which will be pop up on the screen
        // Action widget which will provide the user to acknowledge the choice
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
                height: 50,
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
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF11249F)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, bottom: 16.0),
            child: ElevatedButton(
              //textColor: Colors.black,
              onPressed: () async {
                var masterNo = txtMawbnoM.text.substring(0, 7);
                var modValue = int.parse(masterNo) % 7;
                var validMaster = masterNo + modValue.toString();
                if (txtMawbnoM.text.length != 8 ||
                    txtMawbnoM.text != validMaster) {
                  txtMawbnoM.text = "";
                  return;
                }
                AWB _newMawbRow = new AWB(
                    shiptype: shipmentTypeSelected,
                    //"shiptype",
                    origin: txtOriginM.text,
                    prefix: txtPrefixM.text,
                    mawbno: txtMawbnoM.text,
                    hawbno: txthawbnoM.text,
                    nop: txtpickupnopM.text,
                    grwt: txtgrwtnopM.text,
                    natureofgoods: txtnatureofgoodsM.text,
                    ff: "GT freight",
                    isselect: false,
                    index: mawbList.length);

                print("_newMawbRow.index ==" + _newMawbRow.index.toString());
                mawbList.add(_newMawbRow);

                setState(() {
                  selectedMawbNo = txtMawbnoM.text;
                  selectedPrefix = txtPrefixM.text;
                  selectedOrigin = txtOriginM.text;
                  runFilter(selectedMawbNo, selectedOrigin, selectedPrefix);
                  txtOriginM.text = "";
                  txtPrefixM.text = "";
                  txtOriginM.text = "";
                  txtMawbnoM.text = "";
                  txthawbnoM.text = "";
                  txtpickupnopM.text = "";
                  txtgrwtnopM.text = "";
                  txtnatureofgoodsM.text = "";
                });

                Navigator.of(context).pop("y");
              },
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)), //
                padding: const EdgeInsets.all(0.0),
              ),
              child: Container(
                height: 50,
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
                      'Save',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildHawbPopUpIpad([int? itemIndex]) {
    return Container(
      height: MediaQuery.of(context).size.height / 5.2,
      width: MediaQuery.of(context).size.width / 6,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add HAWB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11249F),
                )),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            // ),
          ],
        ), // To display the title it is optional
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.2,
                  child: Text(
                    "Origin",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.3,
                  child: Text(
                    "Prefix",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Text(
                    "MAWB No.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      // readOnly: true,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      controller: txtOriginH,
                      maxLength: 3,
                      decoration: InputDecoration(
                        filled: true,
                        counterText: "",
                        fillColor: Colors.grey.shade200,
                        border: InputBorder.none,
                        hintText: "Enter origin",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      //   keyboardType: TextInputType.number,
                      // textCapitalization:
                      //                       TextCapitalization.characters,
                      controller: txtPrefixH,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      // readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: InputBorder.none,
                        hintText: "Enter prefix",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                        counterText: "",
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.characters,
                      controller: txtMawbnoH,
                      // readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: InputBorder.none,
                        hintText: "Enter MAWB No.",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                        counterText: "",
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.2,
                  child: Text(
                    "HAWB No.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.3,
                  child: Text(
                    "Pick-up NoP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Text(
                    "NoP Gross Wt.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      maxLength: 16,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      controller: txthawbnoH,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter HAWB No.",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                        counterText: "",
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      // keyboardType: TextInputType.number,
                      controller: txtpickupnopH,

                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      maxLength: 8,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter pick-up NoP",
                        counterText: "",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4.5, // hard coding child width
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      maxLength: 8,
                      controller: txtgrwtnopH,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                        hintText: "Enter NoP gross wt.",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Text(
                    "Nature of Goods",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF11249F),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: TextField(
                //  expands: true,
                // minLines: 1,
                minLines: 1,
                maxLines: 2,
                // allow user to enter 5 line in textfield
                keyboardType: TextInputType.multiline,
                // user keyboard will have a button to move cursor to next line
                maxLength: 50,
                controller: txtnatureofgoodsH,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter nature of goods",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  isDense: true,
                  counterText: "",
                ),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ), // Message which will be pop up on the screen
        // Action widget which will provide the user to acknowledge the choice
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
                height: 50,
                width: 150,
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
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF11249F)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: ElevatedButton(
              //textColor: Colors.black,

              onPressed: () {
                // var masterNo = txtMawbnoM.text.substring(0, 7);
                // var modValue = int.parse(masterNo) % 7;
                // var validMaster = masterNo + modValue.toString();
                // if (txtMawbnoM.text.length != 8 ||
                //     txtMawbnoM.text != validMaster) {
                //   txtMawbnoM.text = "";
                //   return;
                // }
                AWB _newHawbRow = new AWB(
                    shiptype: shipmentTypeSelected,
                    origin: txtOriginH.text,
                    prefix: txtPrefixH.text,
                    mawbno: txtMawbnoH.text,
                    hawbno: txthawbnoH.text,
                    nop: txtpickupnopH.text,
                    grwt: txtgrwtnopH.text,
                    natureofgoods: txtnatureofgoodsH.text,
                    ff: "GT freight",
                    isselect: false,
                    index: hawbList.length);

                print("_newHawbRow.index ==" + _newHawbRow.index.toString());
                if (itemIndex != null) {
                  hawbList[itemIndex] = _newHawbRow;
                } else {
                  hawbList=[];
                  hawbList.add(_newHawbRow);
                }
                isVerified = false;
                setState(() {
                  txtOriginH.text = "";
                  txtPrefixH.text = "";
                  txtOriginH.text = "";
                  txtMawbnoH.text = "";
                  txthawbnoH.text = "";
                  txtpickupnopH.text = "";
                  txtgrwtnopH.text = "";
                  txtnatureofgoodsH.text = "";
                });
                runFilter(selectedMawbNo, selectedOrigin, selectedPrefix);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)), //
                padding: const EdgeInsets.all(0.0),
              ),
              child: Container(
                height: 50,
                width: 150,
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
                      'Save',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildHawbPopUpMobile() {
    return Container(
      // height: MediaQuery.of(context).size.height / 5.2,
      width: MediaQuery.of(context).size.width,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add HAWB',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11249F),
                )),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // ),
          ],
        ), // To display the title it is optional
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "Origin",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 6.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        controller: txtOriginH,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: InputBorder.none,
                          hintText: "Enter origin",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "Prefix",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "MAWB No.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 6.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: txtPrefixH,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: InputBorder.none,
                          hintText: "Enter prefix",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        2.2, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.2,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: txtMawbnoH,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: InputBorder.none,
                          hintText: "Enter MAWB No.",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5),
              // Row(
              //   children: [
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width /
              //           4.5, // hard coding child width
              //       child: Container(
              //         height: 40,
              //         width: MediaQuery.of(context).size.width / 2.5,
              //         decoration: BoxDecoration(
              //           border: Border.all(
              //             color: Colors.grey.withOpacity(0.5),
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(4.0),
              //         ),
              //         child: TextField(
              //           // readOnly: true,
              //           keyboardType: TextInputType.text,
              //           controller: txtOriginH,
              //           decoration: InputDecoration(
              //             filled: true,
              //             fillColor: Colors.grey.shade200,
              //             border: InputBorder.none,
              //             hintText: "Enter origin",
              //             hintStyle: TextStyle(color: Colors.grey),
              //             contentPadding:
              //                 EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //             isDense: true,
              //           ),
              //           style: TextStyle(
              //             fontSize: 16.0,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width /
              //           4.5, // hard coding child width
              //       child: Container(
              //         height: 40,
              //         width: MediaQuery.of(context).size.width / 2.5,
              //         decoration: BoxDecoration(
              //           border: Border.all(
              //             color: Colors.grey.withOpacity(0.5),
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(4.0),
              //         ),
              //         child: TextField(
              //           keyboardType: TextInputType.number,
              //           controller: txtPrefixH,
              //           // readOnly: true,
              //           decoration: InputDecoration(
              //             filled: true,
              //             fillColor: Colors.grey.shade200,
              //             border: InputBorder.none,
              //             hintText: "Enter prefix",
              //             hintStyle: TextStyle(color: Colors.grey),
              //             contentPadding:
              //                 EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //             isDense: true,
              //           ),
              //           style: TextStyle(
              //             fontSize: 18.0,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width /
              //           4.5, // hard coding child width
              //       child: Container(
              //         height: 40,
              //         width: MediaQuery.of(context).size.width / 2.5,
              //         decoration: BoxDecoration(
              //           border: Border.all(
              //             color: Colors.grey.withOpacity(0.5),
              //             width: 1.0,
              //           ),
              //           borderRadius: BorderRadius.circular(4.0),
              //         ),
              //         child: TextField(
              //           keyboardType: TextInputType.number,
              //           controller: txtMawbnoH,
              //           // readOnly: true,
              //           decoration: InputDecoration(
              //             filled: true,
              //             fillColor: Colors.grey.shade200,
              //             border: InputBorder.none,
              //             hintText: "Enter MAWB No.",
              //             hintStyle: TextStyle(color: Colors.grey),
              //             contentPadding:
              //                 EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //             isDense: true,
              //           ),
              //           style: TextStyle(
              //             fontSize: 18.0,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.8,
                child: Text(
                  "HAWB No.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF11249F),
                  ),
                ),
              ),
              SizedBox(height: 5),

              SizedBox(
                width: MediaQuery.of(context).size.width /
                    1.6, // hard coding child width
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    controller: txthawbnoH,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter HAWB No.",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),

              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.5,
                    child: Text(
                      "Pick-up NoP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Text(
                      "NoP GR. WT.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  //SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        3.5, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 3.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        // keyboardType: TextInputType.number,
                        controller: txtpickupnopH,

                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter pick-up NoP",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 10),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        3.2, // hard coding child width
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 3.2,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ],
                        controller: txtgrwtnopH,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter NoP gross wt.",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(
                      "Nature of Goods",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF11249F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: TextField(
                  //  expands: true,
                  // minLines: 1,
                  minLines: 1,
                  maxLines: 2,
                  // allow user to enter 5 line in textfield
                  keyboardType: TextInputType.multiline,
                  // user keyboard will have a button to move cursor to next line

                  controller: txtnatureofgoodsH,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter nature of goods",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ), // Message which will be pop up on the screen
        // Action widget which will provide the user to acknowledge the choice
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
                height: 50,
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
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF11249F)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: ElevatedButton(
              //textColor: Colors.black,
              onPressed: () {
                var masterNo = txtMawbnoM.text.substring(0, 7);
                var modValue = int.parse(masterNo) % 7;
                var validMaster = masterNo + modValue.toString();
                if (txtMawbnoM.text.length != 8 ||
                    txtMawbnoM.text != validMaster) {
                  txtMawbnoM.text = "";
                  return;
                }
                AWB _newHawbRow = new AWB(
                    shiptype: shipmentTypeSelected,
                    //"shiptype",
                    origin: txtOriginH.text,
                    prefix: txtPrefixH.text,
                    mawbno: txtMawbnoH.text,
                    hawbno: txthawbnoH.text,
                    nop: txtpickupnopH.text,
                    grwt: txtgrwtnopH.text,
                    natureofgoods: txtnatureofgoodsH.text,
                    ff: "GT freight",
                    isselect: false,
                    index: hawbList.length);

                print("_newHawbRow.index ==" + _newHawbRow.index.toString());
                hawbList.add(_newHawbRow);

                setState(() {
                  txtOriginH.text = "";
                  txtPrefixH.text = "";
                  txtOriginH.text = "";
                  txtMawbnoH.text = "";
                  txthawbnoH.text = "";
                  txtpickupnopH.text = "";
                  txtgrwtnopH.text = "";
                  txtnatureofgoodsH.text = "";
                });
                runFilter(selectedMawbNo, selectedOrigin, selectedPrefix);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)), //
                padding: const EdgeInsets.all(0.0),
              ),
              child: Container(
                height: 50,
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
                      'Save',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void runFilter(String enteredKeyword, origin, prefix) {
    print("enteredKeyword = " + enteredKeyword);
    print("hawbList.length = " + hawbList.length.toString());

    List<AWB> results = [];
    List<AWB> results2 = [];
    results.addAll(hawbList);
    // results2.addAll(verifiedHawbList);
    print("results.length r = " + results.length.toString());
    print("results2.length = " + results2.length.toString());
    results.where((AWB element) =>
        element.index==mawbList[0].index);
    results2=verifiedHawbList.where((AWB awb) => awb.mawbno == enteredKeyword).toList();
    print("results.length = " + results.length.toString());
    print("results2.length = " + results2.length.toString());
    results2.forEach((awb) => print("mawbno: ${awb.mawbno}"));
    for (AWB i in results) {
      i.mawbno = enteredKeyword;
      i.nop = mawbList[0].nop;
      i.grwt = mawbList[0].grwt;
      i.prefix = mawbList[0].prefix;
    }

    setState(() {
      hawbListToBind = results;
      filteredHawbList = results2;
      selectedMawbNo = enteredKeyword;
      print("******$selectedMawbNo");
      selectedOrigin = origin;
      selectedPrefix = prefix;
    });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
