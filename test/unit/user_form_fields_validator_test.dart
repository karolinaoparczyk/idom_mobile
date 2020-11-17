import 'package:test/test.dart';

import 'package:idom/utils/validators.dart';

void main() {
  ///Username
  ///
  /// tests if empty username is not validated
  test('empty username returns error string', () {
    var result = UsernameFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if non-empty username is validated
  test('non-empty username returns null', () {
    var result = UsernameFieldValidator.validate('login');
    expect(result, null);
  });

  /// tests if username with space is not validated
  test('username with space returns error string', () {
    var result = UsernameFieldValidator.validate('log in');
    expect(result, 'Login nie może zawierać spacji');
  });

  /// tests if username not longer than 25 characters
  test('username longer than 25 characters returns error string', () {
    var result = UsernameFieldValidator.validate('loginloginloginloginlogin1');
    expect(result, 'Login nie może zawierać więcej niż 25 znaków');
  });

  ///Password
  ///
  /// tests if empty password is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if non-empty password is validated
  test('non-empty password returns null', () {
    var result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });

  /// tests if password shorter that 8 is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('pass');
    expect(result, 'Hasło musi zawierać przynajmniej 8 znaków');
  });

  /// tests if password longer that 8 is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('passwordpasswordpassword1234');
    expect(result, 'Hasło nie może zawierać więcej niż 25 znaków');
  });

  ///Email
  ///
  /// tests if empty email is not validated
  test('empty email returns error string', () {
    var result = EmailFieldValidator.validate('');
    expect(result, 'Pole wymagane');
  });

  /// tests if invalid email is not validated
  test('invalid email returns error string', () {
    var result = EmailFieldValidator.validate('emailemail');
    expect(result, 'Podaj poprawny adres email');
  });

  /// tests if valid email is validated
  test('valid email returns null', () {
    var result = EmailFieldValidator.validate('email@ema.il');
    expect(result, null);
  });

  ///Telephone
  ///
  /// tests if empty telephone is validated
  test('empty telephone returns null', () {
    var result = TelephoneFieldValidator.validate('');
    expect(result, null);
  });

  /// tests if too short telephone is not validated
  test('too short telephone returns error string', () {
    var result = TelephoneFieldValidator.validate('65789');
    expect(result,
        'Podaj numer telefonu postaci +XX XXX XXX XXX');
  });

  /// tests if too long telephone is not validated
  test('too long telephone returns error string', () {
    var result = TelephoneFieldValidator.validate('6657787654335');
    expect(result,
        'Podaj numer telefonu postaci +XX XXX XXX XXX');
  });

  /// tests if telephone without country number is not validated
  test('telephone without country number returns error string', () {
    var result = TelephoneFieldValidator.validate('667787654335');
    expect(result,
        'Podaj numer telefonu postaci +XX XXX XXX XXX');
  });

  /// tests if telephone with country number is validated
  test('telephone with country number returns null', () {
    var result = TelephoneFieldValidator.validate('+67787654335');
    expect(result, null);
  });
}
