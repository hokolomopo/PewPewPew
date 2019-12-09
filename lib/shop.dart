import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // json codec

class ShopList extends StatefulWidget {
  // For Json reading : list of item and constructor
  final List<Item> items;

  // To track sold items
  final SharedPreferences prefs;

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

  @override
  void initState() {
    super.initState();
    items = widget.items;
    prefs = widget.prefs;
    if (prefs.containsKey("money")) _money = prefs.getInt("money");
  }


  /// Function called when selling an item. Will reduce the money and set the item as sold
  void _sellItem(int price, String item) async {
    this._money -= price;
    await this.prefs.setInt("money", this._money);
    // Mark the item as SOLD
    await this.prefs.setInt(item, 0);
    // Set state applied here to be sure that changes were done before rebuilding the list
    setState(() {});
  }

  /// Sort items by name
  void _sortByName() {
    setState(() {
        items.sort((a, b) {
          return a.name
              .toLowerCase()
              .compareTo(b.name.toLowerCase()); // alphabetical reverse order
        });
    });
  }

  /// Sort items by price
  void _sortByPrice() {
    setState(() {
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
    });
  }

  /// Widget containing buttons to sort the shop
  Widget _sortBox(BuildContext context){
    return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                "Sort by:",
                style: TextStyle(color: Colors.white),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buttonOutline("Name", Colors.white, Colors.white70, Colors.white70, Colors.deepPurple, Colors.white70, 20.0, _sortByName),
                  _buttonOutline("\$", Colors.white, Colors.white70, Colors.white70, Colors.deepPurple, Colors.white70, 20.0, _sortByPrice),
                ],
              )]
    );
  }

  /// Widget displaying the money the user has
  Widget _moneyContainer(BuildContext context){
    return Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.4,
        child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                side: BorderSide(
                  width: 2.0,
                  color: Colors.white,
                ),
              ),
              color: Colors.deepPurple,
              shadows:  [BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 0), // changes position of shadow
              )],
            ),
            child: Center(
                child : Padding(
                    padding: EdgeInsets.only(top:7.0),
                    child:Text(
                      _money.toString() + "\$",
                      style: TextStyle(color: Colors.white),
            ))),
        ),
    );
  }

  /// List of items in the Shop
  Widget _shopList(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
              child: ListView.builder(
                // Because already in scrollable body
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                // Because of column
                primary: false,
                itemCount: items == null ? 0 : items.length,

                itemBuilder: (context, index) {

                  bool sold = prefs.containsKey(items[index].name);

                  return CustomListItem(
                    sprite: Image(
                        image: AssetImage('assets/graphics/shop/' +
                            items[index].imgName)),
                    name: items[index].name,
                    price: sold ? "SOLD" : items[index].price.toString() + "\$",
                    damage: "damage",
                    radius: "radius",
                    knockback: "knockback",
                    onTap: () {
                      if(sold)
                        _simpleAlertDialog("Item Already Sold", context);
                      else if(_money < items[index].price)
                        _simpleAlertDialog("Not Enough Money !", context);
                      else{
                        _confirmSaleAlertBox(
                          "Buy Item?",
                          "Do you want to buy \"" + items[index].name + "\" for " +
                              items[index].price.toString() + "\$?",
                          context,
                              () {
                            _sellItem(
                                items[index].price, items[index].name);
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
                center: Alignment(0.0, 0.0),
                radius: 3,
                colors: [Colors.blue[800], Colors.blue[500], Colors.blue[400], Colors.blue[100]])
        ),
        child :Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[800],
                border: Border(
                  bottom: BorderSide(width: 3.0, color: Colors.white),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10.0)),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(),
                    ),
                    _moneyContainer(context),
                    Padding(padding: EdgeInsets.only(right: 10.0)),
                  ],
                ),
              ),
            ),
            _shopList(context),
            Container(
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  border: Border(
                    top: BorderSide(width: 3.0, color: Colors.white),
                  ),
                ),
                child: _sortBox(context)
            )
          ],
        )
    );
  }

  /// Alert dialog to confirm a sale
  void _confirmSaleAlertBox(String title, String mess,
      BuildContext context, void function()) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(
              width: 7.0,
              color: Colors.white,
            ),
          ),
          title: new Text(title, style: TextStyle(color: Colors.white)),
          content: new Text(mess, style: TextStyle(height: 1.5, color: Colors.white),),
          actions: <Widget>[
            new FlatButton(
              // Negative choice button
              child: new Text(
                "No",
                style: new TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              // Positive choice button
              child: new Text(
                "Yes",
                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              onPressed: () {
                function();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Simple Alert dialog
  void _simpleAlertDialog(String text, BuildContext context){

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(
              width: 0.0,
              color: Colors.blue[800],
            ),
          ),
          content: new Text(text, style: TextStyle(height: 1.5, color: Colors.white),),
        );
      },
    );
  }

  /// Button with an outline
  Widget _buttonOutline(String text, Color textColor, Color bordersColor,
      Color highlightColor, Color fillColor, Color splashColor, num borderRadius, void function()) {

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
}


/// Class for JSON representing shop items
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

  static List<Item> parseJsonItemList(String response) {
    if (response == "null") {
      // If the future reading operation is not done yet (connection waiting with initial data)
      return [];
    }
    final parsed = json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<Item>((json) => new Item.fromJson(json)).toList();
  }

}


/// Class for an item in the shop
class CustomListItem extends StatelessWidget {
  CustomListItem({Key key, this.sprite, this.name, this.price, this.damage,
    this.radius, this.knockback, this.onTap, this.colors}) : super(key: key);

  final Widget sprite;
  final String name;
  final String price;
  final String damage;
  final String radius;
  final String knockback;
  final void Function() onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: SizedBox(
          height: 150,
          child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  side: BorderSide(
                    width: 9.0,
                    color: Colors.blue[800],
                  ),
                ),
                gradient: RadialGradient(
                    colors: [Colors.blue[200], Colors.blue[300]]
                ),
                shadows:  [BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 7), // changes position of shadow
                )],
              ),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      side: BorderSide(
                        width: 7.0,
                        color: Colors.white,
                      ),
                    )
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.8,
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
              )
          ),
        ),
      ),
    );
  }
}

/// Class for the description of a weapon
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

