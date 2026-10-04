import 'package:emarket_client/emarket_client.dart';

extension UuidValueConverter on String {
  UuidValue toUuidValue() => UuidValue.fromString(this);
}
