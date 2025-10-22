import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/help_request_api_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String query = '';
  String categoryFilter = 'All Categories';
  List<dynamic> _helpRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHelpRequests();
  }

  Future<void> _loadHelpRequests() async {
    setState(() => _isLoading = true);
    
    try {
      // Get ALL help requests (no status filter to show all posts)
      final requests = await HelpRequestApiService.getAllHelpRequests(
        limit: 50,
      );
      
      if (mounted) {
        setState(() {
          _helpRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading help requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter requests based on search query and category
    final items = _helpRequests.where((r) {
      final title = r['title']?.toString() ?? '';
      final category = r['category']?.toString() ?? '';
      final matchesQuery = query.isEmpty || title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = categoryFilter == 'All Categories' || category == categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          // scale factor: on narrow phones, reduce sizes slightly
          final scale = (width / 400).clamp(0.85, 1.0);

          return Column(
        children: [
          // Large header with gradient (web-like)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 16 * scale),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nearby Help Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) * scale)),
                        SizedBox(height: 6 * scale),
                        Text('Find ways to make a difference in your community', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadHelpRequests,
                  ),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(children: [
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: InputDecoration(
                  hintText: 'Search help requests...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12 * scale),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No help requests yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to post a request!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: RefreshIndicator(
                            onRefresh: _loadHelpRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final r = items[i];
                                final title = r['title']?.toString() ?? 'No title';
                                final description = r['description']?.toString() ?? '';
                                final urgency = r['urgency']?.toString() ?? 'Medium';
                                final category = r['category']?.toString() ?? 'Other';
                                
                                // Get first letter for avatar
                                final firstLetter = title.isNotEmpty ? title[0].toUpperCase() : 'A';
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.primary.withAlpha(180)),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    dense: false,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                                      child: Text(
                                        firstLetter,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getUrgencyColor(urgency),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                urgency,
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                category,
                                                style: TextStyle(fontSize: 11, color: AppTheme.primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Navigate to help request details
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text(
                                        'Help',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      );
    }),
  ),
      // HomeShell will provide the floatingActionButton and bottomNavigationBar
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
