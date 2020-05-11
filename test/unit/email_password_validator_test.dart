import 'package:idom/utils/validators.dart';
import 'package:test/test.dart';

void main(){

  test('empty email returns error string', () {
    var result = EmailFieldValidator.validate('');
    expect(result, 'Podaj login');
  });

  test('non-empty email returns null', () {
    var result = EmailFieldValidator.validate('email@mail.com');
    expect(result, null);
  });

  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('');
    expect(result, 'Podaj hasło');
  });

  test('non-empty password returns null', () {
    var result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });
}