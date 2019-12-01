import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // json codec

class WeaponDescription extends StatelessWidget {
  WeaponDescription({
    Key key,
    this.name,
    this.price,
    this.damage,
    this.radius,
    this.knockback,
  }) : super(key: key);

  final String name;
  final String price;
  final String damage;
  final String radius;
  final String knockback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                '$name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              AutoSizeText(
                '$price',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(
                'DMG: $damage',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
                minFontSize: 6,
                maxLines: 1,
              ),
              AutoSizeText(
                'RADIUS: $radius',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
                minFontSize: 6,
                maxLines: 1,
              ),
              AutoSizeText(
                'KNOCKBACK: $knockback',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
                minFontSize: 6,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomListItem extends StatelessWidget {
  CustomListItem(
      {Key key,
      this.sprite,
      this.name,
      this.price,
      this.damage,
      this.radius,
      this.knockback,
      this.fct,
      this.colors})
      : super(key: key);

  final Widget sprite;
  final String name;
  final String price;
  final String damage;
  final String radius;
  final String knockback;
  final void Function() fct;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 150,
          child: Container(
            decoration: BoxDecoration(
                gradient: RadialGradient(
                    center: Alignment(0.6, 0.0),
                    radius: 3,
                    stops: [0.0, 0.5, 0.7, 1.0],
                    colors: colors)),
            child: FractionallySizedBox(
              heightFactor: 0.9,
              widthFactor: 0.9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: sprite,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 0.0),
                      child: WeaponDescription(
                        name: name,
                        price: price,
                        damage: damage,
                        radius: radius,
                        knockback: knockback,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: fct,
    );
  }
}

class ShopList extends StatefulWidget {
  // For Json reading : list of item and constructor
  final List<Item> items;

  // To track sold items
  SharedPreferences prefs;

  ShopList({Key key, this.items, this.prefs}) : super(key: key);

  @override
  ShopListState createState() {
    return new ShopListState();
  }
}

class ShopListState extends State<ShopList> {
  var _money = 50000;
  List<Item> items;
  SharedPreferences prefs;

  // To track actual sorting policy of the list
  int activeSort = 1; // Alphabetical sort first

  //ShopListState({this.items}) ;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    prefs = widget.prefs;
    if (prefs.containsKey("money")) _money = prefs.getInt("money");
  }

  @override
  Widget build(BuildContext context) {
    return _shopList(context);
  }

  void _reducePortofolio(int price, String item) async {
    this._money -= price;
    await this.prefs.setInt("money", this._money);
    // Mark the item as SOLD
    await this.prefs.setInt(item, 0);
    // Set state applied here to be sure that changes were done before rebuilding the list
    setState(() {});
  }

  void _sortByName() {
    setState(() {
      if (activeSort == 1) {
        activeSort = 0;
        items.sort((a, b) {
          return b.name
              .toLowerCase()
              .compareTo(a.name.toLowerCase()); // alphabetical reverse order
        });
      } else {
        activeSort = 1;
        items.sort((a, b) {
          return a.name
              .toLowerCase()
              .compareTo(b.name.toLowerCase()); // alphabetical reverse order
        });
      }
    });
  }

  void _sortByPrice() {
    setState(() {
      if (activeSort == 2) {
        activeSort = 0;
        items.sort((a, b) {
          // Check if the items are in an SOLD state or not
          if (prefs.containsKey(a.name) && prefs.containsKey(b.name))
            return 0;
          else if (prefs.containsKey(a.name))
            return 1;
          else if (prefs.containsKey(b.name))
            return -1;
          else
            return b.price - a.price; // // For highest to lowest sorting
        });
      } else {
        activeSort = 2;
        items.sort((a, b) {
          // Check if the items are in an SOLD state or not
          if (prefs.containsKey(a.name) && prefs.containsKey(b.name))
            return 0;
          else if (prefs.containsKey(a.name))
            return -1;
          else if (prefs.containsKey(b.name))
            return 1;
          else
            return a.price - b.price; // For lowest to highest sorting
        });
      }
    });
  }

  Widget _shopList(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 20.0, top: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Avalable Cash Asset: " + _money.toString() + "\$",
                style: TextStyle(color: Colors.green),
              )
            ],
          ),
        ),
        AutoSizeText(
          "Sort by",
          style: TextStyle(color: Colors.deepPurpleAccent),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: new BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Column(children: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buttonOutline("Name", Colors.white, Colors.white70, Colors.white70, Colors.deepPurple, Colors.white70, 20.0, _sortByName),
                    _buttonOutline("\$", Colors.white, Colors.white70, Colors.white70, Colors.deepPurple, Colors.white70, 20.0, _sortByPrice),
                  ],
                ),
              ]),
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: ListView.builder(
                    // Because already in scrollable body
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    // Because of column
                    primary: false,
                    itemCount: items == null ? 0 : items.length,
                    itemBuilder: (context, index) {
                      if (prefs.containsKey(items[index].name)) {
                        return CustomListItem(
                          sprite: Image(
                              image: AssetImage('assets/graphics/shop/' +
                                  items[index].imgName)),
                          name: items[index].name,
                          price: "SOLD",
                          damage: "damage",
                          radius: "radius",
                          knockback: "knockback",
                          colors: [
                            Colors.blue[800],
                            Colors.blue[600],
                            Colors.blue[500],
                            Colors.blue[300]
                          ],
                          fct: () {
                            _confirmBox(
                              "Buy Item?",
                              "Do you want to buy \"" +
                                  items[index].name +
                                  "\" for " +
                                  items[index].price.toString() +
                                  "\$?",
                              "No",
                              "Get Poorer",
                              context,
                                  () {
                                _reducePortofolio(
                                    items[index].price, items[index].name);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      }
                      if (items[index].price > _money) {
                        return CustomListItem(
                          sprite: Image(
                              image: AssetImage('assets/graphics/shop/' +
                                  items[index].imgName)),
                          name: items[index].name,
                          price: items[index].price.toString() + "\$",
                          damage: "damage",
                          radius: "radius",
                          knockback: "knockback",
                          colors: [
                            Colors.red[800],
                            Colors.red[600],
                            Colors.red[500],
                            Colors.red[300]
                          ],
                          fct: () {
                            _confirmBox(
                              "Buy Item?",
                              "Do you want to buy \"" +
                                  items[index].name +
                                  "\" for " +
                                  items[index].price.toString() +
                                  "\$?",
                              "No",
                              "Get Poorer",
                              context,
                                  () {
                                _reducePortofolio(
                                    items[index].price, items[index].name);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      } else {
                        return CustomListItem(
                          sprite: Image(
                              image: AssetImage('assets/graphics/shop/' +
                                  items[index].imgName)),
                          name: items[index].name,
                          price: items[index].price.toString() + "\$",
                          damage: "damage",
                          radius: "radius",
                          knockback: "knockback",
                          colors: [
                            Colors.green[800],
                            Colors.green[600],
                            Colors.green[500],
                            Colors.green[300]
                          ],
                          fct: () {
                            _confirmBox(
                              "Buy Item?",
                              "Do you want to buy \"" +
                                  items[index].name +
                                  "\" for " +
                                  items[index].price.toString() +
                                  "\$?",
                              "No",
                              "Get Poorer",
                              context,
                              () {
                                _reducePortofolio(
                                    items[index].price, items[index].name);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                )))
      ],
    );
  }
}

List<Item> parseJson(String response) {
  if (response == "null") {
    // If the future reading operation is not done yet (connection waiting with initial data)
    return [];
  }
  final parsed = json.decode(response.toString()).cast<Map<String, dynamic>>();
  return parsed.map<Item>((json) => new Item.fromJson(json)).toList();
}

// Class for JSON representing shop items
class Item {
  final String name;
  int price;
  final String imgName;

  Item({this.name, this.price, this.imgName});

  factory Item.fromJson(Map<String, dynamic> json) {
    return new Item(
      name: json['name'] as String,
      price: json['price'] as int,
      imgName: json['imgName'] as String,
    );
  }
}

void _confirmBox(String title, String mess, String neg, String pos,
    BuildContext context, void function()) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(mess),
        actions: <Widget>[
          new FlatButton(
            // Negative choice button
            child: new Text(
              neg,
              style: new TextStyle(fontWeight: FontWeight.normal),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            // Positive choice button
            child: new Text(
              pos,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              function();
            },
          ),
        ],
      );
    },
  );
}

Widget _buttonOutline(
    String text,
    Color textColor,
    Color bordersColor,
    Color highlightColor,
    Color fillColor,
    Color splashColor,
    num borderRadius,
    void function()) {
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
    child: AutoSizeText(
      text,
      style: TextStyle(
          height: 1.7,
          fontWeight: FontWeight.bold,
          color: textColor),
    ),
    onPressed: () {
      function();
    },
  );
}
