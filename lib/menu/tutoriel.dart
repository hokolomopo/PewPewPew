import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class TutorialWidget extends StatefulWidget{
  @override
  _TutorialWidgetState createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  List images = ["cselect.png", "move.png", "move.png", "jump.png", "wselect.png", "wselect.png", "firing.png", "firing.png"];
  List<double> fontSizes = [15, 15, 12, 15, 13, 13, 13 ,15];
  List texts = [
    "Tap one of your character to select it",
    "Tap a place to move towards it",
    "You only have a limited stamina per turn in the stamina bar",
    "Drag from your character to jump",
    "Stay pressed on your character to select a weapon",
    "The numbers indicate how many munitions you have left",
    "Drag from your character to aim, and let go to fire",
    "The last surviving team wins !"];


  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.15, horizontal: screenSize.width * 0.1),
      child: Scaffold(
        body: Container( // A simplified version of dialog.
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
              side: BorderSide(
                width: 5.0,
                color: Colors.white,
              ),
            ),
            color: Colors.blue,
            shadows: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 0), // changes position of shadow
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 10.0)),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child : Image.asset(
                  'assets/graphics/tutorial/' + images[currentIndex],
                  fit: BoxFit.cover, // this is the solution for border
                  width: screenSize.width * 0.65,
                  height: screenSize.height * 0.32,
                ),
              ),
              Divider(color: Colors.white, thickness: 5, height: 40,),
              SizedBox(
                height: 70,
                child: Text(texts[currentIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSizes[currentIndex], color: Colors.white, height: 1.8),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      setState(() {
                        if(currentIndex > 0)
                          currentIndex--;
                      });
                    },
                    child: new Icon(
                      Icons.chevron_left,
                      color: Colors.blue,
                      size: 35.0,
                    ),
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(15.0),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      setState(() {
                        if(currentIndex < texts.length - 1)
                          currentIndex++;
                      });
                    },
                    child: new Icon(
                      Icons.chevron_right,
                      color: Colors.blue,
                      size: 35.0,
                    ),
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(15.0),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}
