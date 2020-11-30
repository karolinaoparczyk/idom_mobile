import 'package:flutter_test/flutter_test.dart';
import 'package:idom/utils/frequency_calculations.dart';

void main() {
  /// tests only seconds, short version
  test('only seconds, short version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(59);
    expect(result, "59 sekund");
  });

  /// tests only seconds, long version
  test('only seconds, long version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(22);
    expect(result, "22 sekundy");
  });

  /// tests one second
  test('one second', () {
    var result = FrequencyCalculation.calculateFrequencyValue(1);
    expect(result, "1 sekunda");
  });

  /// tests one minute
  test('one minute', () {
    var result = FrequencyCalculation.calculateFrequencyValue(60);
    expect(result, "1 minuta");
  });

  /// tests only minutes, short version
  test('only minutes, short version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(300);
    expect(result, "5 minut");
  });

  /// tests only minutes, long version
  test('only minutes, long version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(120);
    expect(result, "2 minuty");
  });

  /// tests one hour
  test('one hour', () {
    var result = FrequencyCalculation.calculateFrequencyValue(3600);
    expect(result, "1 godzina");
  });

  /// tests only hour, short version
  test('only hour, short version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(21600);
    expect(result, "6 godzin");
  });

  /// tests only hour, long version
  test('only hour, long version', () {
    var result = FrequencyCalculation.calculateFrequencyValue(10800);
    expect(result, "3 godziny");
  });

  /// tests seconds and minutes
  test('seconds and minutes, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(305);
    expect(result, "5 minut 5 sekund");
  });

  /// tests seconds and minutes
  test('seconds and minutes, short, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(302);
    expect(result, "5 minut 2 sekundy");
  });

  /// tests seconds and minutes
  test('seconds and minutes, long, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(125);
    expect(result, "2 minuty 5 sekund");
  });

  /// tests seconds and minutes
  test('seconds and minutes, long, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(122);
    expect(result, "2 minuty 2 sekundy");
  });

  /// tests one second, one minute
  test('one second, one minute', () {
    var result = FrequencyCalculation.calculateFrequencyValue(61);
    expect(result, "1 minuta 1 sekunda");
  });

  /// tests hours and minutes, short, short
  test('hours and minutes, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(18720);
    expect(result, "5 godzin 12 minut");
  });

 /// tests hours and minutes, short, long
  test('hours and minutes, short, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(19980);
    expect(result, "5 godzin 33 minuty");
  });

  /// tests hours and minutes, long, short
  test('hours and minutes, long, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(15540);
    expect(result, "4 godziny 19 minut");
  });

  /// tests hours and minutes, long, long
  test('hours and minutes, long, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(15780);
    expect(result, "4 godziny 23 minuty");
  });

  /// tests one hour one minute
  test('one hour one minute', () {
    var result = FrequencyCalculation.calculateFrequencyValue(3660);
    expect(result, "1 godzina 1 minuta");
  });

 /// tests hours and seconds, short, short
  test('hours and seconds, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(25205);
    expect(result, "7 godzin 5 sekund");
  });

  /// tests hours and seconds, long, short
  test('hours and seconds, long, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(7210);
    expect(result, "2 godziny 10 sekund");
  });

  /// tests hours and seconds, short, long
  test('hours and seconds, short, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(18052);
    expect(result, "5 godzin 52 sekundy");
  });

  /// tests hours and seconds, long, long
  test('hours and seconds, long, long', () {
    var result = FrequencyCalculation.calculateFrequencyValue(7244);
    expect(result, "2 godziny 44 sekundy");
  });

  /// tests one hour one second
  test('one hour one second', () {
    var result = FrequencyCalculation.calculateFrequencyValue(3601);
    expect(result, "1 godzina 1 sekunda");
  });

  /// tests hours, minutes and seconds, short, short, short
  test('hours, minutes and seconds, short, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(18617);
    expect(result, "5 godzin 10 minut 17 sekund");
  });

  /// tests hours, minutes and seconds, short, short, long
  test('hours, minutes and seconds, short, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(18622);
    expect(result, "5 godzin 10 minut 22 sekundy");
  });

  /// tests hours, minutes and seconds, short, long, short
  test('hours, minutes and seconds, short, long, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(19325);
    expect(result, "5 godzin 22 minuty 5 sekund");
  });

  /// tests hours, minutes and seconds, long, short, short
  test('hours, minutes and seconds, long, short, short', () {
    var result = FrequencyCalculation.calculateFrequencyValue(7565);
    expect(result, "2 godziny 6 minut 5 sekund");
  });

  /// tests seconds with 1 at the end
  test(' seconds with 1 at the end', () {
    var result = FrequencyCalculation.calculateFrequencyValue(51);
    expect(result, "51 sekund");
  });

  /// tests minutes with 1 at the end
  test(' minutes with 1 at the end', () {
    var result = FrequencyCalculation.calculateFrequencyValue(1260);
    expect(result, "21 minut");
  });

  /// tests hours with 1 at the end
  test(' hours with 1 at the end', () {
    var result = FrequencyCalculation.calculateFrequencyValue(111600);
    expect(result, "31 godzin");
  });

  /// tests hours with 2 and the end
  test(' hours with 2 at the end', () {
    var result = FrequencyCalculation.calculateFrequencyValue(115200);
    expect(result, "32 godziny");
  });
}