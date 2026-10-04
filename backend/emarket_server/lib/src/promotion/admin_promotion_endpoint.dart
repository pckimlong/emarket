import 'package:emarket_server/src/promotion/promotion_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminPromotionEndpoint extends Endpoint {
  AdminPromotionEndpoint({PromotionService? service})
    : service = service ?? PromotionService();

  final PromotionService service;
}
