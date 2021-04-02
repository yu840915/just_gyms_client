import 'package:where_gym/gym.dart';
import 'package:intl/intl.dart';

class PriceFormat {
  PriceFormat._();
  static String format(Price price) {
    return NumberFormat.simpleCurrency(
      name: price.currency.toUpperCase(),
      decimalDigits: 0,
    ).format(price.amount);
  }
}

class FareFormat {
  FareFormat._();
  static String format(Fare fare) {
    return PriceFormat.format(fare.price) +
        '/${fare.amount}' +
        fare.timeUnit.displayName;
  }
}
