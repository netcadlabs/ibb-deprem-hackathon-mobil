import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class CommonWidgetAndStyles {
  static TextStyle appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 17,
  );

  static Text getCommonText(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: appBarTitleStyle,
    );
  }

  static Widget removeListItemBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.close,
              color: Colors.white,
            ),
            Text(
              " Kaldır",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
