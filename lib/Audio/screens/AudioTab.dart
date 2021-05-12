import 'package:flutter/material.dart';

import './AudioAlbum.dart';
import './Songs.dart';

class Audio extends StatefulWidget {
  Audio({Key key}) : super(key: key);

  @override
  _AudioState createState() => _AudioState();
}

class _AudioState extends State<Audio> with TickerProviderStateMixin {
  TabController _nestedTabController;

  @override
  void initState() {
    super.initState();
    _nestedTabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _nestedTabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          tabs: [
            Tab(text: 'Songs'),
            Tab(text: 'Album'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _nestedTabController,
            children: [
              Music(),
              AudioAlbum(),
            ],
          ),
        ),
      ],
    );
  }
}
