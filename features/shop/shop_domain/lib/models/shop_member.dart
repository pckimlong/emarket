import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_member.freezed.dart';

@freezed
abstract class ShopMember with _$ShopMember {
  const ShopMember._();

  const factory ShopMember() = _ShopMember;
}
