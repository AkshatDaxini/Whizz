import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/painting.dart';

import '../GlobalVariables.dart';
import './AppTile.dart';
import '../Application_Intialization/Initialization.dart';

class Installed extends StatefulWidget {
  @override
  _InstalledState createState() => _InstalledState();
}

class _InstalledState extends State<Installed>
    with AutomaticKeepAliveClientMixin {
  // REFRESHING THE PAGE
  Future<void> _pullRefresh() async {
    setState(() {
      getApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: installedapps == null
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
                  itemCount: installedapps.length,
                  itemBuilder: (BuildContext ctx, int i) {
                    ApplicationWithIcon app = installedapps[i];
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
