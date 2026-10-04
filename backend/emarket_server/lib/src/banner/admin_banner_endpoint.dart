import 'package:emarket_server/src/banner/banner_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminBannerEndpoint extends Endpoint {
  AdminBannerEndpoint({BannerService? service})
    : service = service ?? BannerService();

  final BannerService service;
}
