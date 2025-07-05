
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/qrcode_dealer.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCameraScanner extends StatefulWidget {
  const QRCameraScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCameraScannerState();
}

class _QRCameraScannerState extends State<QRCameraScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool qrDone = false;
  bool granted = false;

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      granted = await PermissionUtil().requestPermission(context: context, permission: Permission.camera, info: '希望获取相机权限用于扫描二维码');
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          granted ?
          _buildQrView(context) :
          Positioned.fill(
            child: Container(
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            child: InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(204, 204, 204, 0.5),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20))
                ),
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.arrow_back_ios_new, color: ThemeUtil.foregroundColor,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if(result != null && result!.code != null){
        if(qrDone){
          return;
        }
        qrDone = true;
        QRCodeDealer.deal(result!.code!);
        if(mounted && context.mounted){
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无权限')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
