import 'package:depremhackathon/pages/login.dart';
import 'package:depremhackathon/pages/main_page.dart';
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
      title: 'Deprem Hackathon',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Deprem Hackathon Home Page'),
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
  RegisteredUser authUser;
  SharedPreferences sharedPreferences;
  final AuthenticationService _auth = locator<AuthenticationService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth.currentRegisteredUser().then((RegisteredUser authUser) {
      setState(() {
        if (authUser == null || authUser.identity == null) {
          this.authStatus = AuthStatus.notSignedIn;
        } else if (authUser != null && authUser.identity != null) {
          this.authStatus = AuthStatus.signedIn;
          this.authUser = authUser;
        } else {
          this.authStatus = AuthStatus.notDetermined;
        }
      });
      if (this.authUser != null) {
        NDUApiProvider.init(this.authUser.identity);
//        _pushNotificationService.initialise(authUser: this.authUser);
//        _pushNotificationService.subscribeTopicsForUser(this.authUser);
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
