import 'package:flutter_test/flutter_test.dart';
import 'package:shop_ease/utils/currency.dart';
import 'package:shop_ease/utils/validators.dart';

void main() {
  test('formatNaira groups thousands', () {
    expect(formatNaira(0), '₦0');
    expect(formatNaira(950), '₦950');
    expect(formatNaira(389000), '₦389,000');
    expect(formatNaira(1234567), '₦1,234,567');
    expect(formatNaira(-2500), '-₦2,500');
  });

  test('validateNigerianPhone', () {
    for (final ok in ['08031234567', '0703 123 4567', '+2349012345678', '0812-345-6789']) {
      expect(validateNigerianPhone(ok), isNull, reason: ok);
    }
    for (final bad in ['', '12345', '08531234567', '+1 202 555 0101']) {
      expect(validateNigerianPhone(bad), isNotNull, reason: bad);
    }
  });

  test('validateEmail and validateRequired', () {
    expect(validateEmail('ada@example.com'), isNull);
    expect(validateEmail('nope'), isNotNull);
    expect(validateRequired('  ', 'Name'), 'Name is required');
  });
}
