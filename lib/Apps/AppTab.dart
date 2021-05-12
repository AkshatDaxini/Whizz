import 'package:flutter/material.dart';

import 'Installed.dart';
import 'System.dart';

class Apps extends StatefulWidget {
  Apps({Key key}) : super(key: key);

  @override
  _AppsState createState() => _AppsState();
}

class _AppsState extends State<Apps> with TickerProviderStateMixin {
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
            Tab(text: 'Installed'),
            Tab(text: 'System'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _nestedTabController,
            children: [
              Installed(),
              System(),
            ],
          ),
        ),
      ],
    );
  }
}
