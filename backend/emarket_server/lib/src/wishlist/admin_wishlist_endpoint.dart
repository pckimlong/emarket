import 'package:emarket_server/src/wishlist/wishlist_service.dart';
import 'package:serverpod/serverpod.dart';

class AdminWishlistEndpoint extends Endpoint {
  AdminWishlistEndpoint({WishlistService? service})
    : service = service ?? WishlistService();

  final WishlistService service;
}
