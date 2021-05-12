import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/painting.dart';

import '../Application_Intialization/Initialization.dart';
import '../GlobalVariables.dart';
import './AppTile.dart';

class System extends StatefulWidget {
  @override
  _SystemState createState() => _SystemState();
}

class _SystemState extends State<System> with AutomaticKeepAliveClientMixin {
  // List<Application> apps;

  //Get apps on the device and sort them according to their name

  //REFRESHING THE PAGE
  Future<void> _pullRefresh() async {
    getSystemApps();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: systemapps == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                color: Colors.white,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: systemapps.length,
                  itemBuilder: (BuildContext ctx, int i) {
                    ApplicationWithIcon app = systemapps[i];
                    return AppTile(app: app);
                  },
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
