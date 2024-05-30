import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'package:encrypt/encrypt.dart' as encrypt;

const String aeskey = "";
const String salt = "";

String sha256Hash(String data) {
  var bytes = utf8.encode(data+salt); // data to bytes
  var digest = sha256.convert(bytes); // bytes to SHA-256 hash
  return digest.toString();
}

String encryptData(String data, String key) {
  final keyBytes = utf8.encode(key).sublist(0, 32); // AES-256 key is 32 bytes long
  final iv = encrypt.IV.fromUtf8(""); // Fixed 16 bytes IV for AES

  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(keyBytes), mode: encrypt.AESMode.cbc));

  final encrypted = encrypter.encrypt(data, iv: iv);
  return base64Url.encode(encrypted.bytes);
}

String decryptData(String encryptedData, String key) {
  final keyBytes = utf8.encode(key).sublist(0, 32); // AES-256 key is 32 bytes long
  final iv = encrypt.IV.fromUtf8(""); // Fixed 16 bytes IV for AES

  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(keyBytes), mode: encrypt.AESMode.cbc));

  // URL-safe Base64 decoding
  final encryptedBytes = base64Url.decode(encryptedData);
  final encrypted = encrypt.Encrypted(encryptedBytes);

  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}
