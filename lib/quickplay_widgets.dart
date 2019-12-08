import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';


class Terrain {
  final String name;
  final String imgName;
  String levelObject;

  Terrain({this.name, this.imgName, this.levelObject});

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return new Terrain(
      name: json['name'] as String,
      imgName: json['imgName'] as String,
      levelObject: json['levelObject'] as String,
    );
  }
}

class TerrainScrollableList extends StatelessWidget {
  final List<Terrain> terrains;
  final Terrain selectedTerrain;
  final Function onTap;

  TerrainScrollableList(this.terrains, {this.selectedTerrain, this.onTap, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: terrains == null ? 0 : terrains.length,
          itemBuilder: (context, index) {
            return customTerrainRadio(terrains[index], selectedTerrain == null ? false : selectedTerrain.name == terrains[index].name);
          },
        ),
      ),
    );
  }

  Widget customTerrainRadio(Terrain terrain, bool selected) {
    Border selectionBorder;
    if (selected)
      selectionBorder =  Border.all(color: Colors.red, width: 3.0);

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          border: selectionBorder,
          image: DecorationImage(
            image:
            AssetImage('assets/graphics/backgrounds/' + terrain.imgName),
            fit: BoxFit.fill,
          )),
      child: InkWell(
        onTap: () => onTap(terrain),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: AutoSizeText(
                    terrain.name,
                    maxLines: 1,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}