import 'package:emarket_server/src/wishlist/wishlist_service.dart';
import 'package:serverpod/serverpod.dart';

class CustomerWishlistEndpoint extends Endpoint {
  CustomerWishlistEndpoint({WishlistService? service})
    : service = service ?? WishlistService();

  final WishlistService service;
}
