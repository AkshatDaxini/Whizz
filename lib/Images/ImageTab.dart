import 'package:whizz/Images/ImageAlbum.dart';
import 'package:flutter/material.dart';
import 'Recent.dart';

class Images extends StatefulWidget {
  Images({Key key}) : super(key: key);

  @override
  _ImagesState createState() => _ImagesState();
}

class _ImagesState extends State<Images> with TickerProviderStateMixin {
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
          // isScrollable: true,
          tabs: [
            Tab(text: 'Recent'),
            Tab(text: 'Album'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _nestedTabController,
            children: [
              Recent(),
              ImageAlbum(),
            ],
          ),
        ),
      ],
    );
  }
}
