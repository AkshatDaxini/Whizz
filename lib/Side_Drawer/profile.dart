import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../GlobalVariables.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var myFocusNode = FocusNode();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 27,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // height: 400,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // A grid view with 3 items per row
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: 7,
              itemBuilder: (_, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      profileImage = "photos/${index + 1}.jpeg";
                      userData.writeAsStringSync("$userName:photos/${index + 1}.jpeg", mode: FileMode.write);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: new BoxDecoration(
                        border: Border.all(
                          color: profileImage == "photos/${index + 1}.jpeg" ? Colors.blue : Colors.white,
                          width: profileImage == "photos/${index + 1}.jpeg" ? 5 : 0,
                        ),
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new AssetImage("photos/${index + 1}.jpeg"),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // ProfileImageGrid(),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              focusNode: myFocusNode,
              controller: nameController,
              // maxLength: 25,
              maxLines: 1,
              minLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: userName,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  userName = value;
                  userData.writeAsStringSync("$userName:$profileImage");
                  setState(() {});
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    height: 50,
                    width: 160,
                    // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        myFocusNode.unfocus();
                        if (nameController.text.isNotEmpty) {
                          userName = nameController.text;
                          userData.writeAsStringSync("${nameController.text}:$profileImage");
                          showDialog(context: context, builder:(context) {
                            return AlertDialog(
                              content: Text("Saved Successfully"),
                              actions: [
                                ElevatedButton(onPressed: (){
                                  Navigator.pop(context);
                                }, child: Text("OK")),
                              ],
                            );
                          },);
                          setState(() {});
                        }
                      },
                    )),
                Container(
                  height: 50,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      nameController.text = modelName;
                    },
                    child: Text("Reset"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
