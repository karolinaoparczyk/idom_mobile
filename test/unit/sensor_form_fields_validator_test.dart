

import 'package:flutter_test/flutter_test.dart';
import 'package:idom/utils/validators.dart';

void main() {
  ///Name
  ///
  /// tests if empty name is not validated
  test('empty name returns error string', () {
    var result = SensorNameFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if non-empty name is validated
  test('non-empty name returns null', () {
    var result = SensorNameFieldValidator.validate('name');
    expect(result, null);
  });

  /// tests if name with spaces is validated
  test('name with spaces returns null', () {
    var result = SensorNameFieldValidator.validate('name with spaces');
    expect(result, null);
  });

  /// tests if empty frequency value incorrect
  test('empty frequency value incorrect', () {
    var result = SensorFrequencyFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if not empty frequency value correct
  test('not empty frequency value correct', () {
    var result = SensorFrequencyFieldValidator.validate('45');
    expect(result, null);
  });

}
