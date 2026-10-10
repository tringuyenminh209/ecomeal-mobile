import 'package:ecomeal_mobile/features/favorites/favorite_stops.dart';

// Gateway giả giữ danh sách trong bộ nhớ — giống server: set true thêm (nếu chưa có), false thì bỏ.
class FakeFavoriteStopsGateway implements FavoriteStopsGateway {
  FakeFavoriteStopsGateway(this.favorites);
  final List<FavoriteStop> favorites;
  final calls = <(String, bool)>[];
  Object? error;

  @override
  Future<List<FavoriteStop>> fetchMyFavorites() async => List.of(favorites);

  @override
  Future<void> setFavorite(String stopLocationId, {required bool isFavorite}) async {
    calls.add((stopLocationId, isFavorite));
    final e = error;
    if (e != null) throw e;
    if (isFavorite) {
      favorites.add(FavoriteStop(stopLocationId: stopLocationId, name: '地点'));
    } else {
      favorites.removeWhere((f) => f.stopLocationId == stopLocationId);
    }
  }
}
