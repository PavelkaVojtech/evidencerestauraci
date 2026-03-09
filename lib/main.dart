import 'package:flutter/material.dart';

void main() {
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
}

class Restaurant {
  final String name;
  final List<Dish> dishes;
  final String atmosphereComment;
  final double serviceRating;
  final double atmosphereRating;
  final DateTime createdAt;

  Restaurant({
    required this.name,
    required this.dishes,
    required this.atmosphereComment,
    required this.serviceRating,
    required this.atmosphereRating,
    required this.createdAt,
  });
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
  final List<Restaurant> _restaurants = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recenze restaurací'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _restaurants.isEmpty
          ? const Center(
              child: Text(
                'Přidejte první restauraci',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
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
                            if (updated != null && updated is Restaurant) {
                              setState(() {
                                _restaurants[index] = updated;
                              });
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
                                    onPressed: () {
                                      setState(() {
                                        _restaurants.removeAt(index);
                                      });
                                      Navigator.pop(ctx);
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRestaurant = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRestaurantPage()),
          );

          if (newRestaurant != null && newRestaurant is Restaurant) {
            setState(() {
              _restaurants.add(newRestaurant);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Stránka se formulářem pro přidání nebo úpravu restaurace.
// Volitelný parametr [initial] obsahuje data, která se mají načíst
// pokud upravujeme již existující záznam.
class AddRestaurantPage extends StatefulWidget {
  /// If [initial] is provided, the page will act in edit mode and
  /// pre-populate form fields with the restaurant's data.
  final Restaurant? initial;

  const AddRestaurantPage({super.key, this.initial});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

// Pomocná třída používaná pouze na stránce se zadáváním.
// Uchovává tři věci potřebné pro jedno jídlo: ovladač názvu, komentáře
// a číslo hodnocení. Když formulář zanikne, musíme tyto ovladače uvolnit.
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

  @override
  void initState() {
    super.initState();
    // pokud máme počáteční data, načteme je do polí formuláře
    if (widget.initial != null) {
      final r = widget.initial!;
      _nameController.text = r.name;
      _atmosphereController.text = r.atmosphereComment;
      _serviceRating = r.serviceRating;
      _atmosphereRating = r.atmosphereRating;
      // populate dishes
      _dishes.clear();
      for (var d in r.dishes) {
        final input = _DishInput();
        input.nameController.text = d.name;
        input.commentController.text = d.comment;
        input.rating = d.rating;
        _dishes.add(input);
      }
      if (_dishes.isEmpty) {
        _addDish();
      }
    } else {
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

  void _saveRestaurant() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadej aspoň název restaurace!')),
      );
      return;
    }
    // ensure at least one dish with a name
    if (_dishes.every((d) => d.nameController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Přidej alespoň jedno jídlo s názvem!')),
      );
      return;
    }

    final dishList = _dishes
        .where((d) => d.nameController.text.trim().isNotEmpty)
        .map(
          (d) => Dish(
            name: d.nameController.text.trim(),
            rating: d.rating,
            comment: d.commentController.text.trim(),
          ),
        )
        .toList();

    final newRestaurant = Restaurant(
      name: _nameController.text,
      dishes: dishList,
      atmosphereComment: _atmosphereController.text,
      serviceRating: _serviceRating,
      atmosphereRating: _atmosphereRating,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, newRestaurant);
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
                                decoration: InputDecoration(
                                  labelText: 'Název jídla',
                                  border: const OutlineInputBorder(),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text('Hodnocení:'),
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
                onPressed: _saveRestaurant,
                icon: const Icon(Icons.save),
                label: const Text('Uložit'),
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
