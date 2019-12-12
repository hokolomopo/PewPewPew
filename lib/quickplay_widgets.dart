import 'package:flutter/material.dart';


class Terrain {
  final String name;
  final String imgName;
  final String levelObject;
  final String backgroundPath;
  final String terrainColor;
  final double gravity;

  Terrain({this.name, this.imgName, this.levelObject, this.backgroundPath, this.terrainColor, this.gravity});

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return new Terrain(
      name: json['name'] as String,
      imgName: json['imgName'] as String,
      levelObject: json['levelObject'] as String,
      backgroundPath: json['backgroundPath'] as String,
      terrainColor: json['terrainColor'] as String,
      gravity: json['gravity'] as double,
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
      width: 300,
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
                  child: Stack(
                    children: <Widget>[
                      // Stroked text as border.
                      Text(
                        terrain.name,
                        style: TextStyle(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        terrain.name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
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