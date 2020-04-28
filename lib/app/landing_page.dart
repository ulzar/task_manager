import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/app/home/home_page.dart';
import 'package:task_manager/app/sign_in/sign_in_page.dart';
import 'package:task_manager/services/auth.dart';
import 'package:task_manager/services/database.dart';
import 'package:task_manager/services/day_controller.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // By doing listen false, we perform less rebuilds and potentially prevent that main page from rebuilding while in another sub child
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User>(
        stream: auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User user = snapshot.data;
            if (user == null) {
              return SignInPage.create(context);
            }
             return MultiProvider(
              providers: [
                Provider<Database>.value(value: FirestoreDatabase(uid: user.uid)),
                Provider<DayController>.value(value: DayController()),
              ],
              child: HomePage(),
            );
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
