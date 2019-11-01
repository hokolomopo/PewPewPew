import 'package:flutter/material.dart';
import 'package:info2051_2018/quick_play.dart';
import 'clipper.dart';
import 'shop.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;
    void initState() {
      super.initState();
    }

    // logo widget
    Widget logo() {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 220.0,
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Container(
                    child: Align(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: new BorderRadius.circular(20.0),
                            color: Color(0xFF8B0000),
                            border: new Border.all(color: Colors.white70, width: 5),
                            boxShadow: [
                            new BoxShadow(
                                color: Colors.red,
                                blurRadius: 3.0,
                            )
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child: FittedBox(fit: BoxFit.contain, child: Text(
                          "Pew Pew Pew !!!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Birdy',
                          ),
                        ),),
                      ),
                    ),
                    height: 154.0,
                  )),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
                bottom: MediaQuery.of(context).size.height * 0.046,
                right: MediaQuery.of(context).size.width * 0.22,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.width * 0.08,
                bottom: 0.0,
                right: MediaQuery.of(context).size.width * 0.32,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    //button widget
    Widget _button(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, num borderRadius, void function()) {
      return RaisedButton(
        highlightElevation: 10.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(borderRadius)),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
          text,
          style: TextStyle(
            height: 1.7,
              fontWeight: FontWeight.normal, color: textColor, fontSize: 20)
        ),),
        onPressed: () {
          function();
        },
      );
    }

    Widget _buttonOutline(String text, Color textColor, Color bordersColor, Color highlightColor,
        Color fillColor, Color splashColor, num borderRadius, void function()){
      return OutlineButton(
        highlightedBorderColor: Colors.white,
        borderSide: BorderSide(color: bordersColor, width: 2.0),
        highlightElevation: 10.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        color: fillColor,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(borderRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            height: 1.7,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }


    //login and register fuctions

    void testFunction() {;}
    
    void _tutorialConfirm(String title, String mess, String neg, String pos){
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: new Text(title),
          content: new Text(mess),
          actions: <Widget>[
            new FlatButton( // Negative choice button
               child: new Text(neg, style: new TextStyle(fontWeight: FontWeight.normal),),
                onPressed: () {Navigator.of(context).pop();
                },
                ),
            new FlatButton(// Positive choice button
              child: new Text(pos, style: new TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () {Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      );
    }

    void _parameters() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10.0,
                          top: 10.0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 140.0,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                child: Align(
                                  child: Container(
                                    width: 130.0,
                                    height: 130.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                              Positioned(
                                child: Container(
                                  child: Text(
                                    "PLAY",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                            ],
                          ),
                        ),
//                        Padding(
//                          padding: EdgeInsets.only(bottom: 20, top: 60),
//                          child: _input(Icon(Icons.email), "EMAIL",
//                              _emailController, false),
//                        ),
                        Parameters()
                      ],
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.05, // / 1.1
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    void _shopSheet() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10.0,
                          top: 10.0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    height: 50.0,
                    width: 50.0,
                  ),
                  Expanded(
                    child: new FutureBuilder(
                        future: DefaultAssetBundle.of(context).loadString('assets/data/shop/items.json'),
                        builder: (context, snapshot) {
                          List<Item> items = parseJson(snapshot.data.toString());
                          return items.isNotEmpty ? new ShopList(items: items) : new Center(child: new CircularProgressIndicator(),);
                        } ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            logo(),
            Padding(
              child: Container(
                child: _button("Quick Play", primary, Colors.white, Colors.white,
                    primary, 30.0, _parameters),
                height: 50.0,
              ),
              padding: EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
            ),
            Padding(
              child: Container(
                child: _buttonOutline("Tutorial", Colors.white, Colors.white, Theme.of(context).primaryColor, Theme.of(context).primaryColor, Colors.white, 30.0, () {_tutorialConfirm("Start tutorial?", "The tutorial is recommanded for new players", "Cancel", "Start");}),
                height: 50.0,
              ),
              padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            ),
            Padding(
              child: Container(
                child: _button("Shop", primary, Colors.white, Colors.white, primary, 30.0, _shopSheet),
                height: 50.0,
              ),
              padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            ),
            Expanded(
              child: Align(
                child: ClipPath(
                  child: Container(
                    color: Colors.white,
                    height: 300.0,
                  ),
                  clipper: BottomWaveClipper(),
                ),
                alignment: Alignment.bottomCenter,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ));
  }
}