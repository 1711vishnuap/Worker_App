// lib/models/user_model.dart

class UserModel {
  final int id;
  final String mobileNumber;
  final String? name;
  final String userType; // 'customer' or 'worker'

  UserModel({
    required this.id,
    required this.mobileNumber,
    required this.name,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      mobileNumber: json['mobile_number'] as String,
      name: json['name'] as String?,
      userType: json['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile_number': mobileNumber,
        'name': name,
        'user_type': userType,
      };

  bool get isCustomer => userType == 'customer';
  bool get isWorker => userType == 'worker';
}
