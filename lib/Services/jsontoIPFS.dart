// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var baseIpfsUrl = 'https://cloudflare-ipfs.com/ipfs/';
const storageKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDQzNEI5OEVBNTJkN2E1YTBEMWI5MEU5MzcwODZCZDdFNTY5NjU0ZTkiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY1MDcxNTI3NDc2MiwibmFtZSI6IkZsdXR0ZXIgSVBGUyJ9.4P98_N20gBFMxVA1WEW48di_3k4BJUzlpDCjIaUU8Zk';
Future<String> uploadJsonToIpfs(String json) async {
  try {
    final bytes = jsonEncode(json);

    print("bytes: $bytes");

    final response = await http.post(
      Uri.parse('https://api.nft.storage/upload'),
      headers: {
        'Authorization': 'Bearer $storageKey',
        'content-type': 'application/json'
      },
      body: bytes,
    );

    final data = jsonDecode(response.body);

    final cid = data['value']['cid'];

    debugPrint('CID OF IMAGE -> $cid');

    return cid;
  } catch (e) {
    debugPrint('Error at IPFS Service - uploadImage: $e');
    rethrow;
  }
}
