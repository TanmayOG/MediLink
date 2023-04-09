// import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

// import 'dart:convert';
// import 'package:pointycastle/export.dart';

// class MyEncryptionDecryption {
//   static const BLOCK_SIZE = 16;
//   var _key;

//   static Uint8List encryptAES(String plainText) {
//     final key = utf8.encode("");
//     final iv = utf8.encode(.substring(0, 16));
//     final encrypter =
//         encrypt.AES(encrypt.Key(encrypt.key), mode: encrypt.AESMode.cbc);
//     final encrypted =
//         encrypter.encrypt(utf8.encode(plainText), iv: encrypt.IV(iv));
//     return encrypted.bytes;
//   }
// }
encryptWithAESKey(String data, String key) {
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key)));
  if (data.isNotEmpty) {
    encrypt.Encrypted encryptedData =
        encrypter.encrypt(data, iv: encrypt.IV.fromLength(16));
    return encryptedData.base64;
  } else if (data.isEmpty) {
    // ignore: avoid_print
    print('Data is empty');
  }
}

decryptWithAESKey() {
  String data2 =
      'utz04Fdf3nU817Zr/mXUFScrpg3Nm5VWAbpIBFvhyyGg1cNvlsxf7xdmaCmqVKEEWhQNAMGeWIJbPIb+loD2';
  String key = '4gl9oknqqokjxlds4c62t5oeb33ht56c';

  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key)));
  encrypt.Encrypted encrypted = encrypt.Encrypted.fromBase64(data2);
  if (data2.isNotEmpty) {
    String decryptedData =
        encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
    print('Decrypted data: $decryptedData');
    return decryptedData;
  } else if (data2.isEmpty) {
    print('Chats is empty');
  }
}
