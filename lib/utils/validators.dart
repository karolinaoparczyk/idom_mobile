class EmailFieldValidator{
  static String validate(String value){
    return value.isEmpty ? 'Podaj login' : null;
  }
}

class PasswordFieldValidator{
  static String validate(String value){
    return value.isEmpty ? 'Podaj hasło' : null;
  }
}