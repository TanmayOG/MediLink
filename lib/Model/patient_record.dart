import 'package:web3dart/web3dart.dart';

class Record {
  String id;
  String infoUrl;
  String dateTime;
  // String uploaderAddress;

  Record({
    required this.id,
    required this.infoUrl,
    required this.dateTime,
    // required this.uploaderAddress,
  });

  factory Record.fromList(List<dynamic> list) {
    return Record(
      id: list[0].toString(),
      infoUrl: list[1].toString(),
      dateTime: list[2].toString(),
      // uploaderAddress: EthereumAddress.fromHex(list[3]).hex.toString(),
    );
  }

  @override
  String toString() {
    return 'Record{id: $id, infoUrl: $infoUrl, dateTime: $dateTime,}';
  }
}
