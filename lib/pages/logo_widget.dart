import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Logolar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Container(
              child: Image.asset(
                "assets/images/istanbul.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              child: Image.asset(
                "assets/images/nils.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
