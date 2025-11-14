class UserDTO {
  final int id;
  final String userName;
  final String shortName;
  final String email;
  final String hash;
  final String role;
  final String token;
  final String createdBy;
  final DateTime createdDate;

  UserDTO({
    required this.id,
    required this.userName,
    required this.shortName,
    required this.email,
    required this.hash,
    required this.role,
    required this.token,
    required this.createdBy,
    required this.createdDate,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      userName: json['userName'] ?? '',
      shortName: json['shortName'] ?? '',
      email: json['email'] ?? '',
      hash: json['hashCode'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userName": userName,
      "shortName": shortName,
      "email": email,
      "role": role,
      "token": token,
      "createdBy": createdBy,
      "createdDate": createdDate.toIso8601String(),
    };
  }
}
