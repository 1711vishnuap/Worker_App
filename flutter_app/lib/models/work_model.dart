// lib/models/work_model.dart

enum WorkStatus {
  posted,
  notified,
  accepted,
  workerOnTheWay,
  arrived,
  started,
  completed,
  cancelled,
}

WorkStatus workStatusFromString(String status) {
  switch (status) {
    case 'POSTED':
      return WorkStatus.posted;
    case 'NOTIFIED':
      return WorkStatus.notified;
    case 'ACCEPTED':
      return WorkStatus.accepted;
    case 'WORKER_ON_THE_WAY':
      return WorkStatus.workerOnTheWay;
    case 'ARRIVED':
      return WorkStatus.arrived;
    case 'STARTED':
      return WorkStatus.started;
    case 'COMPLETED':
      return WorkStatus.completed;
    case 'CANCELLED':
      return WorkStatus.cancelled;
    default:
      return WorkStatus.posted;
  }
}

String workStatusLabel(WorkStatus status) {
  switch (status) {
    case WorkStatus.posted:
      return 'Posted';
    case WorkStatus.notified:
      return 'Finding worker';
    case WorkStatus.accepted:
      return 'Worker assigned';
    case WorkStatus.workerOnTheWay:
      return 'Worker on the way';
    case WorkStatus.arrived:
      return 'Worker arrived';
    case WorkStatus.started:
      return 'In progress';
    case WorkStatus.completed:
      return 'Completed';
    case WorkStatus.cancelled:
      return 'Cancelled';
  }
}

// Backend sends DECIMAL columns as strings (dateStrings config in mysql2),
// so this helper safely parses a value whether it arrives as a String,
// int, or double.
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class WorkModel {
  final int id;
  final int customerId;
  final int categoryId;
  final String? categoryName;
  final int? acceptedWorkerId;
  final String title;
  final String? description;
  final String? photoUrl;
  final double customerLat;
  final double customerLng;
  final WorkStatus status;
  final String? otpCode;
  final String createdAt;
  final double? distanceKm; // only present in "available works" list

  WorkModel({
    required this.id,
    required this.customerId,
    required this.categoryId,
    this.categoryName,
    this.acceptedWorkerId,
    required this.title,
    this.description,
    this.photoUrl,
    required this.customerLat,
    required this.customerLng,
    required this.status,
    this.otpCode,
    required this.createdAt,
    this.distanceKm,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
      acceptedWorkerId: json['accepted_worker_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      customerLat: _toDouble(json['customer_lat']) ?? 0.0,
      customerLng: _toDouble(json['customer_lng']) ?? 0.0,
      status: workStatusFromString(json['status'] as String),
      otpCode: json['otp_code'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
      distanceKm: _toDouble(json['distance_km']),
    );
  }

  WorkModel copyWithStatus(WorkStatus newStatus) => WorkModel(
        id: id,
        customerId: customerId,
        categoryId: categoryId,
        categoryName: categoryName,
        acceptedWorkerId: acceptedWorkerId,
        title: title,
        description: description,
        photoUrl: photoUrl,
        customerLat: customerLat,
        customerLng: customerLng,
        status: newStatus,
        otpCode: otpCode,
        createdAt: createdAt,
        distanceKm: distanceKm,
      );
}

class AssignedWorkerModel {
  final String name;
  final String mobileNumber;
  final double? currentLat;
  final double? currentLng;

  AssignedWorkerModel({
    required this.name,
    required this.mobileNumber,
    this.currentLat,
    this.currentLng,
  });

  factory AssignedWorkerModel.fromJson(Map<String, dynamic> json) {
    return AssignedWorkerModel(
      name: json['name'] as String? ?? 'Worker',
      mobileNumber: json['mobile_number'] as String? ?? '',
      currentLat: _toDouble(json['current_lat']),
      currentLng: _toDouble(json['current_lng']),
    );
  }
}
