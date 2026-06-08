class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role = 'patient',
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'phone': phone?.trim(),
      'role': role,
    };
  }
}
