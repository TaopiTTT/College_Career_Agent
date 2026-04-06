import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int userId;
  final String email;
  final String nickname;
  final String? avatarUrl;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.nickname,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String nickname;
  final String password;
  @JsonKey(name: 'verify_code')
  final String verifyCode;

  RegisterRequest({
    required this.email,
    required this.nickname,
    required this.password,
    required this.verifyCode,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'user_id')
  final int userId;
  final String token;

  AuthResponse({
    required this.userId,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class SendCodeRequest {
  final String email;
  final String purpose;

  SendCodeRequest({
    required this.email,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => _$SendCodeRequestToJson(this);
}
