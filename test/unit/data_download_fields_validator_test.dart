import 'package:flutter_test/flutter_test.dart';
import 'package:idom/utils/validators.dart';

void main() {
  /// tests if empty last days amount field is not validated
  test('empty last days amount field', () {
    var result = LastDaysAmountFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if string last days amount field is not validated
  test('string last days amount field', () {
    var result = LastDaysAmountFieldValidator.validate('fff%');
    expect(result, 'Podaj liczbę całkowitą z przedziału 1 - 30');
  });

  /// tests if less than 0 last days amount field is not validated
  test('less than 0 last days amount field', () {
    var result = LastDaysAmountFieldValidator.validate('-10');
    expect(result, 'Podaj liczbę całkowitą z przedziału 1 - 30');
  });

  /// tests if 0 last days amount field is not validated
  test('0 last days amount field', () {
    var result = LastDaysAmountFieldValidator.validate('0');
    expect(result, 'Podaj liczbę całkowitą z przedziału 1 - 30');
  });

  /// tests if more than 30 last days amount field is not validated
  test('more than 30 last days amount field', () {
    var result = LastDaysAmountFieldValidator.validate('31');
    expect(result, 'Podaj liczbę całkowitą z przedziału 1 - 30');
  });
}