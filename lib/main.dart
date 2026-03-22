import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Inicializuje aplikaci s Supabase
Future<void> main() async {
  // Na webu se .env nenahrává; hodnoty jsou hardcodované
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }
  
  await Supabase.initialize(
    url: kIsWeb 
        ? 'https://ihdtrynxgsxdqbxgumrc.supabase.co'
        : (dotenv.env['SUPABASE_URL'] ?? ''),
    anonKey: kIsWeb
        ? 'sb_publishable_FRCQCSZc7dQwW4X9VPSlqg_ajtxVWsU'
        : (dotenv.env['SUPABASE_ANON_KEY'] ?? ''),
  );

  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nová restaurace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Dish {
  final String name;
  final double rating;
  final String comment;

  Dish({required this.name, required this.rating, required this.comment});

  /// Převede mapu z Supabase na objekt Dish
  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
    );
  }

  /// Převede Dish na mapu pro Supabase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'comment': comment,
    };
  }
}

class Restaurant {
  final int id;
  final String name;
  final List<Dish> dishes;
  final String atmosphereComment;
  final double serviceRating;
  final double atmosphereRating;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.dishes,
    required this.atmosphereComment,
    required this.serviceRating,
    required this.atmosphereRating,
    required this.createdAt,
  });

  /// Převede mapu z Supabase na objekt Restaurant
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    final dishes = (map['dishes'] as List?)
        ?.map((d) => Dish.fromMap(d as Map<String, dynamic>))
        .toList() ?? [];

    return Restaurant(
      id: map['id'],
      name: map['name'] ?? '',
      dishes: dishes,
      atmosphereComment: map['atmosphere_comment'] ?? '',
      serviceRating: (map['service_rating'] ?? 0).toDouble(),
      atmosphereRating: (map['atmosphere_rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;
  final void Function(double) onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starCount = 5,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final starWidth = box.size.width / starCount;
        int index = (localPos.dx / starWidth).floor();
        double newRating = index + 1.0;
        final offsetInStar = localPos.dx - index * starWidth;
        if (offsetInStar < starWidth / 2) {
          newRating = index + 0.5;
        }
        if (newRating < 0) newRating = 0;
        if (newRating > starCount) newRating = starCount.toDouble();
        onRatingChanged(newRating);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(starCount, (i) {
          Icon icon;
          if (rating >= i + 1) {
            icon = Icon(Icons.star, color: color);
          } else if (rating >= i + 0.5) {
            icon = Icon(Icons.star_half, color: color);
          } else {
            icon = Icon(Icons.star_border, color: color);
          }
          return icon;
        }),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Přednačítá data z Supabase pokaždé, když se stránka obnoví
  Future<List<Restaurant>> _loadRestaurants() async {
    final data = await SupabaseService.getRestaurants();
    return data.map((r) => Restaurant.fromMap(r)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recenze restaurací'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _loadRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Chyba: ${snapshot.error}'),
            );
          }

          final restaurants = snapshot.data ?? [];

          if (restaurants.isEmpty) {
            return const Center(
              child: Text(
                'Přidejte první restauraci',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recenze vytvořena: ${restaurant.createdAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...restaurant.dishes.map(
                        (dish) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              StarRating(
                                rating: dish.rating,
                                onRatingChanged: (_) {},
                              ),
                              if (dish.comment.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(dish.comment),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Text('Obsluha:'),
                      StarRating(
                        rating: restaurant.serviceRating,
                        onRatingChanged: (_) {},
                      ),
                      const SizedBox(height: 4),
                      Text('Atmosféra:'),
                      StarRating(
                        rating: restaurant.atmosphereRating,
                        onRatingChanged: (_) {},
                      ),
                      if (restaurant.atmosphereComment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Poznámka: ${restaurant.atmosphereComment}',
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Upravit',
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddRestaurantPage(initial: restaurant),
                            ),
                          );
                          if (updated != null) {
                            setState(() {});
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Smazat',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Potvrzení'),
                              content: Text(
                                'Opravdu chcete smazat ${restaurant.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Zrušit'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await SupabaseService.deleteRestaurant(
                                      restaurant.id,
                                    );
                                    if (mounted) {
                                      Navigator.pop(ctx);
                                      setState(() {});
                                    }
                                  },
                                  child: const Text('Smazat'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRestaurant = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRestaurantPage()),
          );

          if (newRestaurant != null) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddRestaurantPage extends StatefulWidget {
  final Restaurant? initial;

  const AddRestaurantPage({super.key, this.initial});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

/// Pomocná třída pro správu inputs jednoho jídla
class _DishInput {
  final TextEditingController nameController;
  final TextEditingController commentController;
  double rating;

  _DishInput()
    : nameController = TextEditingController(),
      commentController = TextEditingController(),
      rating = 0.0;

  void dispose() {
    nameController.dispose();
    commentController.dispose();
  }
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  final _nameController = TextEditingController();
  final _atmosphereController = TextEditingController();
  final List<_DishInput> _dishes = [];

  double _serviceRating = 0.0;
  double _atmosphereRating = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pokud máme počáteční data, načteme je do formuláře
    if (widget.initial != null) {
      final r = widget.initial!;
      _nameController.text = r.name;
      _atmosphereController.text = r.atmosphereComment;
      _serviceRating = r.serviceRating;
      _atmosphereRating = r.atmosphereRating;
      // Naplníme jídla
      _dishes.clear();
      for (var d in r.dishes) {
        final input = _DishInput();
        input.nameController.text = d.name;
        input.commentController.text = d.comment;
        input.rating = d.rating;
        _dishes.add(input);
      }
    }
    // Pokud nemáme žádné jídlo, přidáme prázdné
    if (_dishes.isEmpty) {
      _addDish();
    }
  }

  void _addDish() {
    setState(() {
      _dishes.add(_DishInput());
    });
  }

  void _removeDish(int index) {
    setState(() {
      _dishes[index].dispose();
      _dishes.removeAt(index);
    });
  }

  Future<void> _saveRestaurant() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadej aspoň název restaurace!')),
      );
      return;
    }

    // Ověř, zda má alespoň jedno jídlo název
    if (_dishes.every((d) => d.nameController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Přidej alespoň jedno jídlo s názvem!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Přípravi seznam jídel pro uložení
      final dishList = _dishes
          .where((d) => d.nameController.text.trim().isNotEmpty)
          .map((d) => {
                'name': d.nameController.text.trim(),
                'rating': d.rating,
                'comment': d.commentController.text.trim(),
              })
          .toList();

      // Pokud upravujeme existující restauraci
      if (widget.initial != null) {
        await SupabaseService.updateRestaurant(
          restaurantId: widget.initial!.id,
          name: _nameController.text,
          dishes: dishList,
          atmosphereComment: _atmosphereController.text,
          serviceRating: _serviceRating,
          atmosphereRating: _atmosphereRating,
        );
      } else {
        // Vytváříme novou restauraci
        await SupabaseService.addRestaurant(
          name: _nameController.text,
          dishes: dishList,
          atmosphereComment: _atmosphereController.text,
          serviceRating: _serviceRating,
          atmosphereRating: _atmosphereRating,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? 'Přidat hodnocení' : 'Upravit hodnocení',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Název restaurace',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jídla',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._dishes.asMap().entries.map((entry) {
                final idx = entry.key;
                final dish = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dish.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Název jídla',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeDish(idx),
                              tooltip: 'Odstranit jídlo',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Hodnocení:'),
                        ),
                        StarRating(
                          rating: dish.rating,
                          onRatingChanged: (r) =>
                              setState(() => dish.rating = r),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: dish.commentController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Poznámka',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addDish,
                icon: const Icon(Icons.add),
                label: const Text('Přidat další jídlo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _atmosphereController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Celkový komentář k prostředí / obsluze',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Hodnocení obsluhy:'),
              ),
              StarRating(
                rating: _serviceRating,
                onRatingChanged: (r) => setState(() => _serviceRating = r),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Hodnocení atmosféry:'),
              ),
              StarRating(
                rating: _atmosphereRating,
                onRatingChanged: (r) => setState(() => _atmosphereRating = r),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveRestaurant,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Ukládání...' : 'Uložit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _atmosphereController.dispose();
    for (var d in _dishes) {
      d.dispose();
    }
    super.dispose();
  }
}
