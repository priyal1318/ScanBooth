import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class MenuItemWidget extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;
  final IconData startIcon;
  final IconData endIcon;

  MenuItemWidget(this.title, {this.onTap, this.startIcon, this.endIcon});

  @override
  Widget build(BuildContext context) {
    var listTile = ListTile(
      leading: startIcon!=null?Icon(startIcon,color: Colors.indigo):null,
      trailing: endIcon!=null?Icon(endIcon,color: Colors.indigo):null,
      title: Text(
        title,
        style: TextStyle(inherit: true, fontSize: 16.0, color: Colors.indigo),
      ),
      onTap: this.onTap,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        listTile,
        Divider(
          color: Colors.black26,
          height: 0,
          endIndent: 16,
          indent: 16,
        ),
      ],
    );
  }
}

