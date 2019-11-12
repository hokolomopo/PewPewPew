import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShopList extends StatefulWidget {
  // For Json reading : list of item and constructor
  final List<Item> items;
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
        Row(
          children: <Widget>[
            FittedBox(fit: BoxFit.contain, child: Text(" "))
            // Place for sorting buttons for list
          ],
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
                        return Card(
                          color: Colors.blue,
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/graphics/shop/' +
                                        items[index].imgName),
                              ),
                              subtitle: Text("SOLD"),
                              title: Text(items[index].name)),
                        );
                      }
                      if (items[index].price > _money) {
                        return Card(
                          color: Colors.red,
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/graphics/shop/' +
                                        items[index].imgName),
                              ),
                              subtitle:
                                  Text(items[index].price.toString() + "\$"),
                              title: Text(items[index].name)),
                        );
                      }
                      return Card(
                          color: Colors.green,
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/graphics/shop/' +
                                        items[index].imgName),
                              ),
                              subtitle:
                                  Text(items[index].price.toString() + "\$"),
                              title: Text(items[index].name),
                              onTap: () {
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
                              }));
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
