import 'package:where_gym/gym.dart';
import 'package:intl/intl.dart';

class PriceFormat {
  static String format(Price price) {
    return NumberFormat.simpleCurrency(
      name: price.currency.toUpperCase(),
      decimalDigits: 0,
    ).format(price.amount);
  }
}
