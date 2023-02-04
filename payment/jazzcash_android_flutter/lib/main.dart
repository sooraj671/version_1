import 'dart:convert';

import 'package:flutter/material.dart';
// For accessing the Platform Channel functionality
import 'package:flutter/services.dart';
// For use in the hashing function
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// Reference to the PlatformChannel
  // com.<YOUR_APPLICATION_NAME>/<YOUR_FUNCTION_NAME>
  static const platform = const MethodChannel('com.payment_app/performPayment');
// Integrity Salt given by JazzCash
  // The salt is used in coordination with the hashing function
  static const integritySalt = '##########';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ElevatedButton(
              onPressed: pay,
              child: Text('Pay'),
            ),
          ),
        ),
      ),
    );
  }

  String hashingFunc(Map<String, String> data) {
    Map<String, String> temp2 = {};
    data.forEach((k, v) {
      if (v != "") v += "&";
      temp2[k] = v;
    });
    var sortedKeys = temp2.keys.toList(growable: false)
      ..sort((k1, k2) => k1.compareTo(k2));
    Map<String, String> sortedMap = Map.fromIterable(sortedKeys,
        key: (k) => k,
        value: (k) {
          return temp2[k]!;
        });

    var values = sortedMap.values;
    String toBePrinted = values.reduce((str, ele) => str += ele);
    toBePrinted = toBePrinted.substring(0, toBePrinted.length - 1);
    toBePrinted = integritySalt + '&' + toBePrinted;
    var key = utf8.encode(integritySalt);
    var bytes = utf8.encode(toBePrinted);
    var hash2 = Hmac(sha256, key);
    var digest = hash2.convert(bytes);
    var hash = digest.toString();
    data["pp_SecureHash"] = hash;
    String returnString = "";
    data.forEach((k, v) {
      returnString += k + '=' + v + '&';
    });
    returnString = returnString.substring(0, returnString.length - 1);

    return returnString;
  }

  Future<void> pay() async {
    // Transaction Start Time
    final currentDate = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    // Transaction Expiry Time
    final expDate = DateFormat('yyyyMMddHHmmss')
        .format(DateTime.now().add(Duration(minutes: 5)));
    final refNo = 'T' + currentDate.toString();

    // The json map that contains our key-value pairs
    var data = {
      "pp_Amount": "<YOUR_AMMOUNT_GOES_HERE>",
      "pp_BillReference": "billRef",
      "pp_Description": "Description of transaction",
      "pp_Language": "EN",
      "pp_MerchantID": "######",
      "pp_Password": "########",
      "pp_ReturnURL": "http//localhost/case.php",
      "pp_TxnCurrency": "PKR",
      "pp_TxnDateTime": currentDate,
      "pp_TxnExpiryDateTime": expDate,
      "pp_TxnRefNo": refNo,
      "pp_TxnType": "",
      "pp_Version": "1.1",
      "pp_BankID": "TBANK",
      "pp_ProductID": "RETL",
      "ppmpf_1": "1",
      "ppmpf_2": "2",
      "ppmpf_3": "3",
      "ppmpf_4": "4",
      "ppmpf_5": "5",
    };
    String postData = hashingFunc(data);
    String responseString;

    try {
      // Trigger native code through channel method
      // The first arguemnt is the name of method that is invoked
      // The second argument is the data passed to the method as input
      final result =
          await platform.invokeMethod('performPayment', {"postData": postData});

      // Await for response from above before moving on
      // The response contains the result of the transaction
      responseString = result.toString();
    } on PlatformException catch (e) {
      // On Channel Method Invocation Failure
      print("PLATFORM_EXCEPTION: ${e.message.toString()}");
    }

//     // Parse the response now
//     List<String> responseStringArray = responseString.split('&');
//     Map<String, String> response = {};
//     responseStringArray.forEach((e) {
//       if (e.length > 0) {
//         e.trim();
//         final c = e.split('=');
//         response[c[0]] = c[1];
//       }
//     });

// // Use the transaction response as needed now
//     print(response);
  }
}
