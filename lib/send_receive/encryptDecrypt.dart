import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aes_crypt/aes_crypt.dart';

final GlobalKey<State> _key = new GlobalKey<State>();

class EncryptData {
  static String password = 'WhiZZ@FiLEsharInG';
  static Future<String> encryptFile(BuildContext context, String path) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String encFilepath;
    try {
      showProgress(context, _key, 0);
      encFilepath = await crypt.encryptFile(path);
      Navigator.of(_key.currentContext, rootNavigator: true).pop();
      print('The encryption has been completed successfully.');
      print('Encrypted file: $encFilepath');
    } catch (e) {
      print('error' + e);
    }
    return encFilepath;
  }

  static Future<String> decryptFile(BuildContext context, String path) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    print("trying to decrypt with password" + password);
    crypt.setPassword(password);
    String decFilepath;
    try {
      showProgress(context, _key, 1);
      decFilepath = await crypt.decryptFile(path);
      Navigator.of(_key.currentContext, rootNavigator: true).pop();
      print('The decryption has been completed successfully.');
      print('Decrypted file 1: $decFilepath');
      print('File content: ' + File(decFilepath).path);
    } catch (e) {
      print('error' + e);
    }
    return decFilepath;
  }

  static showProgress(BuildContext c, GlobalKey k, int process) {
    return showDialog(
      context: c,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: k,
            backgroundColor: Colors.black54,
            children: [
              Center(
                child: Text(
                  process == 0 ? "Encrypting...." : "Decrypting....",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
