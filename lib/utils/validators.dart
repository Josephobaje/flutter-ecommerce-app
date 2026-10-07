String? validateRequired(String? v, String field) => (v == null || v.trim().isEmpty) ? '$field is required' : null;

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  return RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim()) ? null : 'Enter a valid email';
}

/// Nigerian mobile numbers: 080..., 070..., 090..., 081..., or +234 format.
String? validateNigerianPhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Phone number is required';
  final cleaned = v.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^(\+234|0)[789][01]\d{8}$').hasMatch(cleaned) ? null : 'Enter a valid Nigerian phone number';
}
