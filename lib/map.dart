import 'package:flutter/material.dart';
import 'package:platyplus_app/menu.dart';
import 'package:photo_view/photo_view.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Menu(
        child: PhotoView(
          imageProvider: AssetImage('assets/images/map.png'),
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 3.0,
        ),
      ),
    );
  }
}
