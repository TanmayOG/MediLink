class Doctor {
  final String name;
  final String email;
  final String phone;
  final String age;
  final String qualification;
  final String id;
  final String wId;

  Doctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.qualification,
    required this.id,
    required this.wId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age']?.toString() ?? '',
      qualification: json['qualification'] ?? '',
      id: json['id'] ?? '',
      wId: json['wId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'qualification': qualification,
      'id': id,
      'wId': wId,
    };
  }
}
