import 'dart:convert';

class PatientModel {
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String address;
  final String age;
  final String id;
  final String wId;

  PatientModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.address,
    required this.age,
    required this.id,
    required this.wId,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      bloodGroup: json['Blood Group'],
      address: json['address'],
      age: json['age'],
      id: json['id'],
      wId: json['wId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'Blood Group': bloodGroup,
      'address': address,
      'age': age,
      'id': id,
      'wId': wId,
    };
  }
}
