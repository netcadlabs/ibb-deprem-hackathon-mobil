import 'package:depremhackathon/pages/login.dart';
import 'package:depremhackathon/pages/main.dart';
import 'package:depremhackathon/services/authenction_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_models.dart';
import 'api/ndu_api_provider.dart';
import 'locator.dart';

void main() {
  setupLocator();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AuthStatus { notDetermined, notSignedIn, signedIn }

class _MyHomePageState extends State<MyHomePage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  AuthUser authUser;
  SharedPreferences sharedPreferences;
  final AuthenticationService _auth = locator<AuthenticationService>();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth.currentUser().then((AuthUser authUser) {
      setState(() {
        if (authUser == null || authUser.token == null) {
          this.authStatus = AuthStatus.notSignedIn;
        } else if (authUser != null && authUser.token != null) {
          this.authStatus = AuthStatus.signedIn;
          this.authUser = authUser;
        } else {
          this.authStatus = AuthStatus.notDetermined;
        }
      });
      if (this.authUser != null) {
        NDUApiProvider.init(this.authUser.token);
//        _pushNotificationService.initialise(authUser: this.authUser);
//        _pushNotificationService.subscribeTopicsForUser(this.authUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return CircularProgressIndicator();
      case AuthStatus.notSignedIn:
        return LoginPage();
      case AuthStatus.signedIn:
        return MainPage();
      default:
        return LoginPage();
    }
  }
}
