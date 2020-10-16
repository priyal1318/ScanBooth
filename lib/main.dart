import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:splashscreen/splashscreen.dart';
import 'preview_doc.dart';
import 'prog_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanbot_sdk/barcode_scanning_data.dart';
import 'package:scanbot_sdk/common_data.dart';
import 'package:scanbot_sdk/document_scan_data.dart';
import 'package:scanbot_sdk/ehic_scanning_data.dart';
import 'package:scanbot_sdk/mrz_scanning_data.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:scanbot_sdk/scanbot_sdk_models.dart';
import 'package:scanbot_sdk/scanbot_sdk_ui.dart';

import 'pages_repo.dart';
import 'menu_item.dart';
import 'utils.dart';

import 'package:image_picker/image_picker.dart';

void main() => runApp(new MaterialApp(
  home: new BeforeSplash(),
));

class BeforeSplash extends StatefulWidget{
  _BeforeSplash createState() =>new _BeforeSplash();
}
class _BeforeSplash extends State<BeforeSplash>{
  @override
  Widget build(BuildContext context) {

    return new SplashScreen(
      seconds: 8,
      navigateAfterSeconds: MyApp(),
      image: new Image.asset(
          'assets/loading.gif',
          fit: BoxFit.fill,
          color: Colors.indigo,
      ),
      backgroundColor: Colors.white,
      loadingText: new Text("MADE IN INDIA",style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,

      ),),
      photoSize: 150.0,
      //onClick: () => print("Flutter Egypt"),
      loaderColor: Colors.white,
    );
  }
}



const SCANBOT_SDK_LICENSE_KEY =  "aVBGPNbMvzEhxgiTs46xdfUz6WiWg5" +
    "Bwb887bmfqMxqHpH9RyJFmVM8oUc2y" +
    "Dc5OtUhop4XSTkgjrCXhQpIQM03ZKF" +
    "R7MjXyq9CZVScvqztrVCfrFOJqv2PC" +
    "JCEOu4YhSOvmjjSdpDbsZpmf6CIias" +
    "3QbWh6b8QjyhBQjYAy8whVcs5XQdzu" +
    "kCZQPpQHtyW5uApZiGgE7bte2Ir/Vk" +
    "XFEz0s2GqH53eM0Nrzu5uj1KqwDXFj" +
    "CxByXWVRQ9vN6bFqNRUrrZSYlc/aVS" +
    "PQm5OyDk8ojoH2SUvG0KUQLGyR/vwe" +
    "EDA6AvmF8T13I1l8EypGfrbxbNGXn0" +
    "pIifzQT1x4uQ==\nU2NhbmJvdFNESw" +
    "pjb20uc2Nhbl9ib290aC5mbHV0dGVy" +
    "X2FwcAoxNjAzODQzMTk5CjU5MAoz\n";

initScanbotSdk() async {
  var customStorageBaseDirectory = await getDemoStorageBaseDirectory();

  var config = ScanbotSdkConfig(
    loggingEnabled: true,
    licenseKey: SCANBOT_SDK_LICENSE_KEY,
    imageFormat: ImageFormat.JPG,
    imageQuality: 80,
    storageBaseDirectory: customStorageBaseDirectory,
  );

  try {
    await ScanbotSdk.initScanbotSdk(config);
  } catch (e) {
    print(e);
  }
}
Future<String> getDemoStorageBaseDirectory() async {
  Directory storageDirectory;
  if (Platform.isAndroid) {
    storageDirectory = await getExternalStorageDirectory();
  }
  else if (Platform.isIOS) {
    storageDirectory = await getApplicationDocumentsDirectory();
  }
  else {
    throw("Unsupported platform");
  }

  return "${storageDirectory.path}/my-custom-storage";
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() {
    initScanbotSdk();
    return _MyAppState();
  }
}
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPageWidget());
  }
}

class MainPageWidget extends StatefulWidget {
  @override
  _MainPageWidgetState createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  PageRepository _pageRepository = PageRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: Image.asset(
            'assets/sb_logo.jpg',

        ),
        title: Text('ScanBooth',
            style: TextStyle(inherit: false,fontSize: 20 ,color: Colors.white)),

      ),
      body: ListView(
        children: <Widget>[
          MenuItemWidget(
            "Scan Document",
            startIcon: Icons.camera,
            onTap: () {
              startDocumentScanning();

            },

          ),
          MenuItemWidget(
            "Import Image",
            startIcon: Icons.image,
            onTap: () {
              importImage();

            },
          ),
          MenuItemWidget(
            "View Image Results",
            startIcon: Icons.view_carousel,
            endIcon: Icons.keyboard_arrow_right,
            onTap: () {
              gotoImagesView();
            },
          ),
          MenuItemWidget(
            "Scan Barcode",
            startIcon: Icons.scanner,
            onTap: () {
              startBarcodeScanner();
            },
          ),
          MenuItemWidget(
            "Scan QR code",
            startIcon: Icons.compare,
            onTap: () {
              startQRScanner();
            },
          ),
        ],
      ),
    );
  }

  importImage() async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      await createPage(image.uri);
      gotoImagesView();
    } catch (e) {
      print(e);
    }
  }

  createPage(Uri uri) async {
    //if (!await checkLicenseStatus(context)) { return; }

    var dialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    dialog.style(message: "Processing");
    dialog.show();
    try {
      var page = await ScanbotSdk.createPage(uri, false);
      page = await ScanbotSdk.detectDocument(page);
      this._pageRepository.addPage(page);
    } catch (e) {
      print(e);
    } finally {
      dialog.hide();
    }
  }

  startDocumentScanning() async {
    //if (!await checkLicenseStatus(context)) { return; }

    DocumentScanningResult result;
    try {
      var config = DocumentScannerConfiguration(
        bottomBarBackgroundColor: Colors.indigo,
        userGuidanceTextColor: Colors.white,
        ignoreBadAspectRatio: true,
        multiPageEnabled: true,
        polygonColor: Colors.indigo,
        shutterButtonAutoInnerColor: Colors.indigo,
        shutterButtonAutoOuterColor: Colors.white,
        //maxNumberOfPages: 3,
        //flashEnabled: true,
        //autoSnappingSensitivity: 0.7,
        cameraPreviewMode: CameraPreviewMode.FILL_IN,
        orientationLockMode: CameraOrientationMode.PORTRAIT,
        //documentImageSizeLimit: Size(2000, 3000),
        cancelButtonTitle: "Cancel",
        shutterButtonIndicatorColor: Colors.white,
        pageCounterButtonTitle: "%d Page(s)",
        textHintOK: "Capture",
        topBarBackgroundColor: Colors.indigo,
        bottomBarButtonsColor: Colors.white,
        textHintNothingDetected: "Nothing",
        // ...
      );
      result = await ScanbotSdkUi.startDocumentScanner(config);
    } catch (e) {
      print(e);
    }

    if (isOperationSuccessful(result)) {
      _pageRepository.addPages(result.pages);
      gotoImagesView();
    }
  }

  startBarcodeScanner() async {
    //if (!await checkLicenseStatus(context)) { return; }

    try {
      var config = BarcodeScannerConfiguration(
        topBarBackgroundColor: Colors.indigo,
        finderLineColor: Colors.indigo,
        finderTextHintColor: Colors.indigo,
        topBarButtonsColor: Colors.white,
        cancelButtonTitle: "Cancel",
        finderTextHint: "Align Properly",
        // ...
      );
      var result = await ScanbotSdkUi.startBarcodeScanner(config);
      _showBarcodeScanningResult(result);
    } catch (e) {
      print(e);
    }


  }

  startQRScanner() async {
    //if (!await checkLicenseStatus(context)) { return; }

    try {
      var config = BarcodeScannerConfiguration(
        barcodeFormats: [BarcodeFormat.QR_CODE],
        finderLineColor: Colors.indigo,
        topBarButtonsColor: Colors.white,
        topBarBackgroundColor: Colors.indigo,
        cancelButtonTitle: "Cancel",
        finderTextHintColor: Colors.indigo,
        finderTextHint: "Align Properly",
        // ...
      );
      var result = await ScanbotSdkUi.startBarcodeScanner(config);
      _showqrcodeScanningResult(result);

    } catch (e) {
      print(e);
    }
  }

  _showBarcodeScanningResult(final BarcodeScanningResult result) {
    if (isOperationSuccessful(result)) {
      showAlertDialog(context,
          result.text,
          title: "Barcode Result:"
      );
    }
  }
  _showqrcodeScanningResult(final BarcodeScanningResult result) {
    if (isOperationSuccessful(result)) {
      showAlertDialog(context,
          result.text,
          title: "QR code Result:"
      );
    }
  }


  gotoImagesView() async {
    imageCache.clear();
    return await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DocumentPreview(_pageRepository)),
    );
  }

}