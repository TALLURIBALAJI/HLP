import 'package:flutter/material.dart';
// ...existing code...

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = [
      {'name': 'Education', 'emoji': '📚', 'count': 12},
      {'name': 'Food', 'emoji': '🍛', 'count': 8},
      {'name': 'Clothes', 'emoji': '👕', 'count': 4},
      {'name': 'Medical', 'emoji': '💊', 'count': 3},
      {'name': 'Elderly', 'emoji': '👵', 'count': 6},
      {'name': 'Emergency', 'emoji': '🚨', 'count': 1},
      {'name': 'Books', 'emoji': '📖', 'count': 5},
      {'name': 'Others', 'emoji': '🔧', 'count': 7},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help Categories')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 2,
          children: cats.map((c) => GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/home', arguments: {'category': c['name']}),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(children: [
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.cyan.shade300]), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(10), child: Text((c['emoji'] as String), style: const TextStyle(fontSize: 20))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text((c['name'] as String), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('${c['count']} active', style: const TextStyle(color: Colors.black54))])),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26)
                ]),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
