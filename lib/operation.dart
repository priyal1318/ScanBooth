import 'prog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:scanbot_sdk/common_data.dart' as c;
import 'package:scanbot_sdk/cropping_screen_data.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:scanbot_sdk/scanbot_sdk_ui.dart';
import 'utils.dart';

import 'pages_repo.dart';
import 'filter.dart';
import 'pages_wid.dart';

class PageOperations extends StatelessWidget {
  c.Page _page;
  final PageRepository _pageRepository;

  PageOperations(this._page, this._pageRepository);

  @override
  Widget build(BuildContext context) {
    imageCache.clear();
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.indigo,
          title: const Text('Image Preview',
              style: TextStyle(inherit: true, color: Colors.white)),
        ),
        body: PagesPreviewWidget(_page, _pageRepository));
  }
}

class PagesPreviewWidget extends StatefulWidget {
  c.Page page;
  final PageRepository _pageRepository;

  PagesPreviewWidget(this.page, this._pageRepository);

  @override
  State<PagesPreviewWidget> createState() {
    return new PagesPreviewWidgetState(page, this._pageRepository);
  }
}

class PagesPreviewWidgetState extends State<PagesPreviewWidget> {
  c.Page page;
  final PageRepository _pageRepository;

  PagesPreviewWidgetState(this.page, this._pageRepository);

  void _updatePage(c.Page page) {
    imageCache.clear();
    _pageRepository.updatePage(page);
    setState(() {
      this.page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Center(child: PageWidget(page.documentImageFileUri)))),
        BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                color: Colors.indigo,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.crop, color: Colors.white),
                    Container(width: 4),
                    Text('Crop & Rotate',
                        style: TextStyle(inherit: true, color: Colors.white)),
                  ],
                ),
                onPressed: () {
                  startCroppingScreen(page);
                  // _settingModalBottomSheet(context, page);
                },
              ),
              FlatButton(
                color: Colors.indigo,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.filter,color: Colors.white),
                    Container(width: 4),
                    Text('Filter',
                        style: TextStyle(inherit: true, color: Colors.white)),
                  ],
                ),
                onPressed: () {
                  showFilterPage(page);
                  // _settingModalBottomSheet(context, page);
                },
              ),
              FlatButton(
                color: Colors.indigo,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.delete, color: Colors.white),
                    Container(width: 4),
                    Text('Delete',
                        style: TextStyle(inherit: true, color: Colors.white)),
                  ],
                ),
                onPressed: () {
                  deletePage(page);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  deletePage(c.Page page) async {
    try {
      await ScanbotSdk.deletePage(page);
      this._pageRepository.removePage(page);
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }

  rotatePage(c.Page page) async {
    //if (!await checkLicenseStatus(context)) { return; }

    try {
      var dialog = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      dialog.style(message: "Processing ...");
      dialog.show();
      var updatedPage = await ScanbotSdk.rotatePageClockwise(page, 1);
      dialog.hide();
      if (updatedPage != null) {
        setState(() {
          _updatePage(updatedPage);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  showFilterPage(c.Page page) async {
    //if (!await checkLicenseStatus(context)) { return; }

    var resultPage = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PageFiltering(page)),
    );
    if (resultPage != null) {
      _updatePage(resultPage);
    }
  }

  startCroppingScreen(c.Page page) async {
    //if (!await checkLicenseStatus(context)) { return; }

    try {
      var config = CroppingScreenConfiguration(
        bottomBarBackgroundColor: Colors.indigo,
        topBarBackgroundColor: Colors.indigo,
        polygonColor: Colors.indigo,
        // polygonLineWidth: 10,
        cancelButtonTitle: "Cancel",
        doneButtonTitle: "Save",
        // ...
      );
      var result = await ScanbotSdkUi.startCroppingScreen(page, config);
      if (isOperationSuccessful(result) && result.page != null) {
        setState(() {
          _updatePage(result.page);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}