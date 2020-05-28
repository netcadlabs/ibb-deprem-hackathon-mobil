import 'package:depremhackathon/services/authenction_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../locator.dart';
import './main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String errorMessage = "";
  final AuthenticationService _auth = locator<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    "Uygulama Adı?",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Uygulama hakkında kısa kısa açıklama..",
                    style: TextStyle(fontSize: 21),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            formSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  signIn(String identity) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    _auth.registerUserAsDevice(identity, androidDeviceInfo.id).then((authUser) {
      if (authUser != null) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      } else {
        Fluttertoast.showToast(
            msg: "Giriş bilgileri geçersiz",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      String message = "Bir hata oluştu";
      if (error != null) message = error.toString();
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  Container buttonSection() {
    return Container(
      child: RaisedButton(
        onPressed: () {
          if (identityNumberController.text == "") return null;
          if (_isLoading) return;

          setState(() {
            _isLoading = true;
          });
          signIn(identityNumberController.text);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Başla", style: TextStyle(color: Colors.black)),
            Icon(Icons.arrow_forward),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController identityNumberController =
      new TextEditingController();

  Container formSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: identityNumberController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              icon: Icon(Icons.confirmation_number, color: Colors.red),
              hintText: "Kimlik No",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple)),
            ),
          ),
//          SizedBox(height: 30.0),
//          TextFormField(
//            controller: passwordController,
//            obscureText: true,
//            style: TextStyle(color: Colors.black),
//            decoration: InputDecoration(
//              icon: Icon(Icons.lock, color: Colors.deepPurple),
//              hintText: "Password",
//              border: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Colors.deepPurple)),
//            ),
//          ),
        ],
      ),
    );
  }
}
