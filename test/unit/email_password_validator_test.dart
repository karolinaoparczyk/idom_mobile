import 'package:idom/utils/validators.dart';
import 'package:test/test.dart';

void main(){

  /// tests if empty email is not validated
  test('empty email returns error string', () {
    var result = EmailFieldValidator.validate('');
    expect(result, 'Podaj login');
  });

  /// tests if non-empty email is validated
  test('non-empty email returns null', () {
    var result = EmailFieldValidator.validate('email@mail.com');
    expect(result, null);
  });

  /// tests if empty password is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('');
    expect(result, 'Podaj hasło');
  });

  /// tests if non-empty password is validated
  test('non-empty password returns null', () {
    var result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });
}