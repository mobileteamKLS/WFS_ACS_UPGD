import 'package:flutter/material.dart';

import 'headers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HeaderClipperWave extends StatelessWidget {
  final Color color1;
  final Color color2;
  final String headerText;

  const HeaderClipperWave(
      {Key? key,
      required this.color1,
      required this.color2,
      required this.headerText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useMobileLayout = false;

    if (kIsWeb) {
      // running on the web!
      print("running on the web!");
      useMobileLayout = false;
    } else {
      var smallestDimension = MediaQuery.of(context).size.shortestSide;
      useMobileLayout = smallestDimension < 600;
    }
    return ClipPath(
      //upper clippath with less height
      clipper: kIsWeb
          ? WaveClipper()
          : useMobileLayout
              ? WaveClipperNew()
              : WaveClipper(), //set our custom wave clipper.
      child: Container(
        padding: EdgeInsets.only(
            bottom: kIsWeb
                ? 0
                : useMobileLayout
                    ? 40
                    : 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              color1, //  Color(0xFF3383CD),
              color2, //   Color(0xFF11249F),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height / 6, //180,
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
                              : MediaQuery.of(context).size.width / 18, //56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width:useMobileLayout ?10: 20),
                    Text(
                      headerText, // "Walk-in Details ",
                      style: TextStyle(
                          fontSize: kIsWeb
                              ? 48
                              : MediaQuery.of(context).size.width / 18, //48,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (headerText.contains("multiline"))
                Text(
                  " Mode : Export",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 18, //48,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
            ]),
      ),
    );
  }
}

class HeaderClipperWaveMultiline extends StatelessWidget {
  final Color color1;
  final Color color2;
  final String headerText;
  final String modeText;
  final bool isMobile;
  final bool isWeb;

  const HeaderClipperWaveMultiline(
      {Key? key,
      required this.color1,
      required this.color2,
      required this.headerText,
      required this.modeText,required this.isMobile,required this.isWeb,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      //upper clippath with less height
      clipper: WaveClipper(), //set our custom wave clipper.
      child: Container(
        padding: EdgeInsets.only(bottom: 50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              color1, //  Color(0xFF3383CD),
              color2, //   Color(0xFF11249F),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height / 5, //180,
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
                          size: isMobile
                                          ? 40 : isWeb ?40 : MediaQuery.of(context).size.width / 18, //56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      headerText, // "Walk-in Details ",
                      style: TextStyle(
                          fontSize: isWeb ? 48:
                              MediaQuery.of(context).size.width / 18, //48,
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
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text(
                      " Mode : " + modeText,
                      style: TextStyle(
                          fontSize: isWeb ? 32:MediaQuery.of(context).size.width / 22, //48,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
class HeaderClipperWaveMultilineNew2 extends StatelessWidget {
  final Color color1;
  final Color color2;
  final String headerText;
  final int modeText;
  final bool isMobile;
  final bool isWeb;

  const HeaderClipperWaveMultilineNew2(
      {Key? key,
      required this.color1,
      required this.color2,
      required this.headerText,
      required this.modeText,required this.isMobile,required this.isWeb,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      //upper clippath with less height
      clipper: WaveClipper(), //set our custom wave clipper.
      child: Container(
        padding: EdgeInsets.only(bottom: 50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              color1, //  Color(0xFF3383CD),
              color2, //   Color(0xFF11249F),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height / 5, //180,
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
                          size: isMobile
                                          ? 40 : isWeb ?40 : MediaQuery.of(context).size.width / 18, //56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      headerText, // "Walk-in Details ",
                      style: TextStyle(
                          fontSize: isWeb ? 48:
                              MediaQuery.of(context).size.width / 18, //48,
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
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text(
                      modeText==0?" Mode : Drop-off ":" Mode : Pick-up",
                      style: TextStyle(
                          fontSize: isWeb ? 32:MediaQuery.of(context).size.width / 22, //48,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

class HeaderClipperWaveMultilineNew extends StatefulWidget {
  final Color color1;
  final Color color2;
  final String headerText;
  final int modeText;
  final bool isMobile;
  final bool isWeb;
  const HeaderClipperWaveMultilineNew(
      {Key? key,
        required this.color1,
        required this.color2,
        required this.headerText,
        required this.modeText,required this.isMobile,required this.isWeb,})
      : super(key: key);

  @override
  State<HeaderClipperWaveMultilineNew> createState() => _HeaderClipperWaveMultilineNewState();
}

class _HeaderClipperWaveMultilineNewState extends State<HeaderClipperWaveMultilineNew> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      //upper clippath with less height
      clipper: WaveClipper(), //set our custom wave clipper.
      child: Container(
        padding: EdgeInsets.only(bottom: 50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [
              widget.color1, //  Color(0xFF3383CD),
              widget.color2, //   Color(0xFF11249F),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height / 5, //180,
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
                          size: widget.isMobile
                              ? 40 : widget.isWeb ?40 : MediaQuery.of(context).size.width / 18, //56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      widget.headerText, // "Walk-in Details ",
                      style: TextStyle(
                          fontSize: widget.isWeb ? 48:
                          MediaQuery.of(context).size.width / 18, //48,
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
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text(
                      widget.modeText==0?" Mode : Drop-off ":" Mode : Pick-up",
                      style: TextStyle(
                          fontSize: widget.isWeb ? 32:MediaQuery.of(context).size.width / 22, //48,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

