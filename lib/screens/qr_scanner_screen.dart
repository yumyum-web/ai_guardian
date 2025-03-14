import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  void _handleBarcode(BarcodeCapture barcodes) {
    for (var barcode in barcodes.barcodes) {
      if (barcode.format == BarcodeFormat.qrCode && barcode.rawValue != null) {
        Map<String, dynamic> data = jsonDecode(barcode.rawValue!);
        print(data);
        if (data['uid'] != null && data['name'] != null) {
          Navigator.pop(context, {
            'uid': data['uid'],
            'name': data['name'],
          });
          return;
        }
      }
    }
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          Container(
            alignment: Alignment.bottomCenter,
            height: 100,
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [Expanded(child: Center(child: Placeholder()))],
            ),
          ),
        ],
      ),
    );
  }
}
