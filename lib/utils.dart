import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanbot_sdk/common_data.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAlertDialog(BuildContext context, String textToShow, {String title}) async {
  Widget text = SimpleDialogOption(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child:Text(textToShow)
    ),
  );

  // set up the SimpleDialog
  AlertDialog dialog = AlertDialog(
    title: title != null ? Text(title) : null,
    content:text,
    contentPadding: EdgeInsets.all(0),
    actions: <Widget>[
      FlatButton(
        textColor: Colors.white,
        color: Colors.indigo,
        child: Text('Copy'),
        onPressed: (){
          Clipboard.setData(ClipboardData(text: textToShow));
        },
      ),
      FlatButton(
        textColor: Colors.white,
        color: Colors.indigo,
        child: Text('Ok'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )

    ],
  );



  // show the dialog
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}




bool isOperationSuccessful(Result result) {
  return result.operationResult == OperationResult.SUCCESS;
}