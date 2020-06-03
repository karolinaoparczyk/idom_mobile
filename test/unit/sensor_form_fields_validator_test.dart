import 'package:idom/utils/validators.dart';
import 'package:test/test.dart';

void main() {
  ///Name
  ///
  /// tests if empty name is not validated
  test('empty name returns error string', () {
    var result = SensorNameFieldValidator.validate('');
    expect(result, 'Podaj nazwę');
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
}
