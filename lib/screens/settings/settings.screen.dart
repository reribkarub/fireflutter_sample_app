import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter_sample_app/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loadingFirebase = true;
  StreamSubscription firebaseSubscription;
  Map<String, dynamic> public;
  @override
  void initState() {
    super.initState();

    firebaseSubscription = ff.firebaseInitialized.listen((re) async {
      public = await ff.userPublicData();
      setState(() => loadingFirebase = false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    firebaseSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your languages:'),
          DropdownButton<String>(
            value: ff.userLanguage,
            items: [
              DropdownMenuItem(value: 'ko', child: Text('Korean')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (String value) {
              ff.updateProfile({'language': value});
            },
          ),
          Text('Notify me new comments under my post'),
          loadingFirebase
              ? CircularProgressIndicator()
              : Switch(
                  value: public[notifyPost] ?? false,
                  onChanged: (value) async {
                    try {
                      /// @attention update screen first, then save it firestore later.
                      setState(() => public[notifyPost] = value);
                      ff.updateUserMeta({
                        'public': {
                          notifyPost: value,
                        },
                      });
                      Get.snackbar('Update', 'Settings updated!');
                    } catch (e) {
                      Get.snackbar('Error', e.toString());
                    }
                  },
                ),
          Text('Notify me new comments under my comments'),
          loadingFirebase
              ? CircularProgressIndicator()
              : Switch(
                  value: public[notifyComment] ?? false,
                  onChanged: (value) async {
                    try {
                      /// @attention update screen first, then save it firestore later.
                      setState(() => public[notifyComment] = value);
                      ff.updateUserMeta({
                        'public': {
                          notifyComment: value,
                        },
                      });
                      Get.snackbar('Update', 'Settings updated!');
                    } catch (e) {
                      Get.snackbar('Error', e.toString());
                    }
                  },
                ),
        ],
      ),
    );
  }
}
