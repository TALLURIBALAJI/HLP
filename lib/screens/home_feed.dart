import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../models/dummy.dart';
import '../theme.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String query = '';
  String categoryFilter = 'All Categories';

  @override
  Widget build(BuildContext context) {
    final items = DummyData.requests.where((r) {
      final matchesQuery = query.isEmpty || r.title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = categoryFilter == 'All Categories' || r.category == categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nearby Help Requests', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Find ways to make a difference in your community', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(children: [
              TextField(decoration: InputDecoration(hintText: 'Search help requests...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: categoryFilter,
                onChanged: (v) => setState(() => categoryFilter = v ?? 'All Categories'),
                items: ['All Categories', 'Food', 'Books', 'Clothes', 'Medical', 'Elderly', 'Education', 'Emergency']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white),
              )
            ]),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final r = items[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withAlpha(180)), borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.white, child: Text(r.user?.substring(0, 1) ?? 'A')),
                        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(r.description ?? ''),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)), child: Text(r.urgency)), const SizedBox(height: 8), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('Offer Help'))]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'fab_post',
            onPressed: () => Navigator.pushNamed(context, '/post'),
            backgroundColor: AppTheme.warmGradient.colors.first,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          const EmergencyFloatingButton(),
        ],
      ),
      bottomNavigationBar: const HelpLinkBottomNav(index: 0),
    );
  }
}
