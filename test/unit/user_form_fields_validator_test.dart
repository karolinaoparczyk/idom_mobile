import 'package:idom/utils/validators.dart';
import 'package:test/test.dart';

void main() {
  ///Username
  ///
  /// tests if empty username is not validated
  test('empty username returns error string', () {
    var result = UsernameFieldValidator.validate('');
    expect(result, 'Podaj login');
  });

  /// tests if non-empty username is validated
  test('non-empty username returns null', () {
    var result = UsernameFieldValidator.validate('login');
    expect(result, null);
  });

  /// tests if username with space is not validated
  test('username wtih space returns error string', () {
    var result = UsernameFieldValidator.validate('log in');
    expect(result, 'Login nie może zawierać spacji');
  });


  ///Password
  ///
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

  /// tests if empty password is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('');
    expect(result, 'Podaj hasło');
  });

  /// tests if password shorter that 8 is not validated
  test('empty password returns error string', () {
    var result = PasswordFieldValidator.validate('pass');
    expect(result, 'Hasło musi zawierać przynajmniej 8 znaków');
  });


  ///Email
  ///
  /// tests if empty email is not validated
  test('empty email returns error string', () {
    var result = EmailFieldValidator.validate('');
    expect(result, 'Email jest wymagany');
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
        'Numer telefonu musi zawierać kierunkowy postaci +XX oraz 9 cyfr');
  });

  /// tests if too long telephone is not validated
  test('too long telephone returns error string', () {
    var result = TelephoneFieldValidator.validate('6657787654335');
    expect(result,
        'Numer telefonu musi zawierać kierunkowy postaci +XX oraz 9 cyfr');
  });

  /// tests if telephone without country number is not validated
  test('telephone without country number returns error string', () {
    var result = TelephoneFieldValidator.validate('667787654335');
    expect(result,
        'Numer telefonu musi zawierać kierunkowy postaci +XX oraz 9 cyfr');
  });

  /// tests if telephone with country number is validated
  test('telephone with country number returns null', () {
    var result = TelephoneFieldValidator.validate('+67787654335');
    expect(result, null);
  });
}
