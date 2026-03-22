import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pro komunikaci s Supabase
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Načte všechny restaurace s jejich jídly
  static Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final response = await _client
          .from('restaurants')
          .select()
          .order('created_at', ascending: false);

      // Pro každou restauraci načteme její jídla
      List<Map<String, dynamic>> restaurants = [];
      for (var restaurant in response) {
        final dishes = await _client
            .from('dishes')
            .select()
            .eq('restaurant_id', restaurant['id']);

        restaurant['dishes'] = dishes;
        restaurants.add(restaurant);
      }

      return restaurants;
    } catch (e) {
      throw Exception('Chyba při načítání restaurací: $e');
    }
  }

  /// Přidá novou restauraci s jejími jídly
  static Future<void> addRestaurant({
    required String name,
    required List<Map<String, dynamic>> dishes,
    required String atmosphereComment,
    required double serviceRating,
    required double atmosphereRating,
  }) async {
    try {
      // Nejdříve přidáme restauraci
      final restaurantResponse = await _client
          .from('restaurants')
          .insert({
            'name': name,
            'atmosphere_comment': atmosphereComment,
            'service_rating': serviceRating,
            'atmosphere_rating': atmosphereRating,
          })
          .select();

      final restaurantId = restaurantResponse[0]['id'];

      // Potom přidáme jídla
      for (var dish in dishes) {
        await _client.from('dishes').insert({
          'restaurant_id': restaurantId,
          'name': dish['name'],
          'rating': dish['rating'],
          'comment': dish['comment'] ?? '',
        });
      }
    } catch (e) {
      throw Exception('Chyba při přidávání restaurace: $e');
    }
  }

  /// Aktualizuje existující restauraci a její jídla
  static Future<void> updateRestaurant({
    required int restaurantId,
    required String name,
    required List<Map<String, dynamic>> dishes,
    required String atmosphereComment,
    required double serviceRating,
    required double atmosphereRating,
  }) async {
    try {
      // Aktualizujeme základní údaje restaurace
      await _client.from('restaurants').update({
        'name': name,
        'atmosphere_comment': atmosphereComment,
        'service_rating': serviceRating,
        'atmosphere_rating': atmosphereRating,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', restaurantId);

      // Smažeme všechna stará jídla
      await _client.from('dishes').delete().eq('restaurant_id', restaurantId);

      // Přidáme nová jídla
      for (var dish in dishes) {
        await _client.from('dishes').insert({
          'restaurant_id': restaurantId,
          'name': dish['name'],
          'rating': dish['rating'],
          'comment': dish['comment'] ?? '',
        });
      }
    } catch (e) {
      throw Exception('Chyba při aktualizaci restaurace: $e');
    }
  }

  /// Smaže restauraci a její jídla
  static Future<void> deleteRestaurant(int restaurantId) async {
    try {
      await _client.from('restaurants').delete().eq('id', restaurantId);
    } catch (e) {
      throw Exception('Chyba při mazání restaurace: $e');
    }
  }
}
