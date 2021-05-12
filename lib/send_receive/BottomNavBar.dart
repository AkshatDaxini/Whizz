import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './connectionSettings.dart';
import '../GlobalVariables.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final _selectedItems = Provider.of<SelectedItems>(context);
    final _conn = Provider.of<Connection>(context);

    if (_conn.peerListLength > 0)
      return Container(
        // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        height: MediaQuery.of(context).size.height * .13,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(DialogRoute(
                context: context,
                builder: (_) => SelectedItemList(),
              )),
              child: ClipOval(
                child: Container(
                  width: MediaQuery.of(context).size.width * .1,
                  height: MediaQuery.of(context).size.width * .1,
                  color: Colors.blue,
                  child: Center(child: Text(_selectedItems.count.toString())),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .80,
              child: ElevatedButton(
                child: Text('SEND'),
                onPressed: () async => sendButton(context),
              ),
            ),
          ],
        ),
      );
    else if (_selectedItems.count == 0)
      return Container(
        //send receive button
        height: MediaQuery.of(context).size.height * .13,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ClipOval(
              child: Material(
                color: Colors.blue, // button color
                child: InkWell(
                  splashColor: Colors.black38, // inkwell color
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height * .10,
                    height: MediaQuery.of(context).size.height * .10,
                    child: Icon(
                      Icons.upload_sharp,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.height * .08,
                    ),
                  ),
                  onTap: () async => sendButton(context),
                ),
              ),
            ),
            ClipOval(
              child: Material(
                color: Colors.blue, // button color
                child: InkWell(
                  splashColor: Colors.black38, // inkwell color
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height * .10,
                    height: MediaQuery.of(context).size.height * .10,
                    child: Icon(
                      Icons.download_sharp,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.height * .08,
                    ),
                  ),
                  onTap: () async => receiveButton(context),
                ),
              ),
            ),
          ],
        ),
      );
    else
      return Container(
        //no devices connected
        // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        height: MediaQuery.of(context).size.height * .13,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(DialogRoute(
                context: context,
                builder: (_) => SelectedItemList(),
              )),
              child: ClipOval(
                child: Container(
                  width: MediaQuery.of(context).size.width * .1,
                  height: MediaQuery.of(context).size.width * .1,
                  color: Colors.blue,
                  child: Center(child: Text(_selectedItems.count.toString())),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .80,
              child: ElevatedButton(
                child: Text('SEND'),
                onPressed: () async => sendButton(context),
              ),
            ),
          ],
        ),
      );
  }
}

class SelectedItemList extends StatelessWidget {
  const SelectedItemList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _selectedItems = Provider.of<SelectedItems>(context);
    return Dialog(
      child: Container(
          height: MediaQuery.of(context).size.height * .70,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectedItems.clear();
                },
                child: Text('Clear List'),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, index) {
                    return Divider();
                  },
                  itemCount: _selectedItems.count,
                  itemBuilder: (_, i) {
                    String title = _selectedItems.selectedItems[i].toString().split('/').last;
                    return ListTile(
                      title: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}
