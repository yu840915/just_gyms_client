import 'package:intl/intl.dart';

class DistanceFormat {
  static final NumberFormat _km = _createKMFormat();
  static final NumberFormat _m = _createMeterFormat();

  static NumberFormat _createKMFormat() {
    final format = NumberFormat.decimalPattern();
    format.maximumFractionDigits = 1;
    format.minimumFractionDigits = 1;
    return format;
  }

  static NumberFormat _createMeterFormat() {
    final format = NumberFormat.decimalPattern();
    format.maximumFractionDigits = 0;
    format.minimumFractionDigits = 0;
    return format;
  }

  static String format(num meter) {
    if (meter > 100) {
      return _km.format(meter / 1000) + '公里';
    }
    return _m.format(meter) + '公尺';
  }
}
