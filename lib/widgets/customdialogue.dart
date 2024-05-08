import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText, imagepath;
  final bool isMobile;

  // final Image image;

  CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.imagepath,
    required this.isMobile,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // var smallestDimension = MediaQuery.of(context).size.shortestSide;
    // useMobileLayout = smallestDimension < 600;

    // print("useMobileLayout");

    // print(useMobileLayout);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,

        Container(
          width: isMobile
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 1.5,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 24.0 : 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16.0 : 24.0,
                ),
              ),
              SizedBox(height: 24.0),
              isMobile
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // To close the dialog
                        },
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                50, 50) // put the width and height you want
                            ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // To close the dialog
                        },
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        //...top circlular image part,

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: CircleAvatar(
              backgroundImage: AssetImage(imagepath.toString()),
              radius: Consts.avatarRadius, //26,
            ),
            // child: Image.asset(
            //   'assets/images/successstar.gif',
            //   height: 50.0,
            //   width: 50.0,
            // ),
          ),
        ),
      ],
    );
  }
}

class CustomConfirmDialog extends StatelessWidget {
  final String title, description, buttonText, imagepath;
  final bool isMobile;

  // final Image image;

  CustomConfirmDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.imagepath,
    required this.isMobile,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
//       var smallestDimension = MediaQuery.of(context).size.shortestSide;
//  isMobile = smallestDimension < 600;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,

        Container(
          width: isMobile
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 2.2,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // To close the dialog
                    },
                    child: Text("Yes"),
                  ),
                  SizedBox(width: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // To close the dialog
                    },
                    child: Text("No"),
                  ),
                ],
              ),
            ],
          ),
        ),
        //...top circlular image part,

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: CircleAvatar(
              backgroundImage: AssetImage(imagepath.toString()),
              radius: 96,
            ),
            // child: Image.asset(
            //   'assets/images/successstar.gif',
            //   height: 50.0,
            //   width: 50.0,
            // ),
          ),
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class customAlertMessageDialog extends StatelessWidget {
  final String title, description, buttonText, imagepath;
  final bool isMobile;

  // final Image image;

  customAlertMessageDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.imagepath,
    required this.isMobile,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
//       var smallestDimension = MediaQuery.of(context).size.shortestSide;
//  isMobile = smallestDimension < 600;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,

        Container(
          width: isMobile
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 2.2,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16.0 : 22,
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),
        //...top circlular image part,

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: CircleAvatar(
              backgroundImage: AssetImage(imagepath.toString()),
              radius: 96,
            ),
            // child: Image.asset(
            //   'assets/images/successstar.gif',
            //   height: 50.0,
            //   width: 50.0,
            // ),
          ),
        ),
      ],
    );
  }
}

class CustomAlertMessageDialogNew extends StatelessWidget {
  final String description, buttonText, imagepath;
  final bool isMobile;

  // final Image image;

  CustomAlertMessageDialogNew({
    required this.description,
    required this.buttonText,
    required this.imagepath,
    required this.isMobile,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,

        Container(
          width: isMobile
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 2.0,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16.0 : 22,
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // To close the dialog
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: CircleAvatar(
              backgroundImage: AssetImage(imagepath.toString()),
              radius: 96,
            ),
            // child: Image.asset(
            //   'assets/images/successstar.gif',
            //   height: 50.0,
            //   width: 50.0,
            // ),
          ),
        ),
      ],
    );
  }
}

class CustomAlertMessageDialogNewV2 extends StatelessWidget {
  final String description, buttonText, imagepath, highlightedText;
  final bool isMobile;

  // final Image image;

  CustomAlertMessageDialogNewV2({
    required this.description,
    required this.buttonText,
    required this.imagepath,
    required this.isMobile,
    required this.highlightedText,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,

        Container(
          width: isMobile
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width / 2.0,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              SizedBox(height: 16.0),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: description.substring(
                          0, description.indexOf(highlightedText)),
                      style: TextStyle(

                        color: Colors.black, // Change the color here
                      ),
                    ),
                    TextSpan(
                      text: highlightedText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Change the color here
                      ),
                    ),
                    TextSpan(
                      text: description.substring(
                          description.indexOf(highlightedText) +
                              highlightedText.length),
                      style: TextStyle(

                        color: Colors.black, // Change the color here
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: highlightedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Token copied to clipboard')),);

                  Navigator.of(context).pop(true); // To close the dialog
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: Consts.avatarRadius,
            child: CircleAvatar(
              backgroundImage: AssetImage(imagepath.toString()),
              radius: 96,
            ),
            // child: Image.asset(
            //   'assets/images/successstar.gif',
            //   height: 50.0,
            //   width: 50.0,
            // ),
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0; // 24.0 ;
  static const double avatarRadius = 96; //48.0;
}
