import 'package:flutter/material.dart';

class BodyLayout extends StatefulWidget {
  @override
  BodyLayoutState createState() {
    return new BodyLayoutState();
  }
}

class BodyLayoutState extends State<BodyLayout> {

  final shopItem = ["Agents of Doom", "Annihilator", "Bouncer", "Disc Blade Gun", "Flux Rifle", "Holoshield Glove", "Infector","Lava Gun", "Suck Cannon", "Bla", "Bla2", "Bla3", "Bla4"];
  final shopPrices = [200, "SOLD", 230, "SOLD", 240, 245, 250, 260 , 270, "SOLD", 360, 458, 579];
  final exemple = [[1,2],["Hello",3,4]];
  var _money = 3265;

  @override
  Widget build(BuildContext context) {
    return _shopList(context);
  }

  Widget _shopList(BuildContext context) {

    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(bottom: 20.0, top: 20.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("Avalable Cash Asset: "+_money.toString() + "\$", style: TextStyle(color: Colors.green),)],),),
        Row(children: <Widget>[FittedBox(fit: BoxFit.contain,child: Text("TODO (all/weapon/utility)"))],),
        Container(child: ListView.builder(
          physics: NeverScrollableScrollPhysics(), // Because already in scrollable body
          scrollDirection: Axis.vertical,
          shrinkWrap: true, // Because of column
          primary: false,
          itemCount: shopItem.length,
          itemBuilder: (context, index){
            if(shopPrices[index] == "SOLD"){return Card( color: Colors.red, child: ListTile(leading: CircleAvatar(backgroundImage: AssetImage('graphics/shop/ratchet.jpg'),),subtitle: Text(shopPrices[index].toString() ), title: Text(shopItem[index])),);}
            return Card( color: Colors.green, child: ListTile(leading: CircleAvatar(backgroundImage: AssetImage('graphics/shop/ratchet.jpg'),),subtitle: Text(shopPrices[index].toString() + "\$"), title: Text(shopItem[index]), onLongPress: () {setState(() {_money -= shopPrices[index]; shopPrices[index] = "SOLD";});},),); // _turorialConfirm("Buy Item?", "Do you want to buy \""+ shopItem[index] + "\" for " + shopPrices[index].toString() + "\$?\n(" + _money.toString() + "\$ remaining)", "No", "Get Poorer");
          },
        ),)
      ],
    );
  }
}