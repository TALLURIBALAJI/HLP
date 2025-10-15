import 'package:flutter/material.dart';

class BookExchangeScreen extends StatefulWidget {
  const BookExchangeScreen({super.key});

  @override
  State<BookExchangeScreen> createState() => _BookExchangeScreenState();
}

class _BookExchangeScreenState extends State<BookExchangeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Book Exchange'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Donate Books'), Tab(text: 'Request Books')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Donate Books tab — currently empty state
          Center(child: _buildEmptyState('No posts yet — be the first to donate a book!')),
          // Request Books tab — currently empty state
          Center(child: _buildEmptyState('No requests yet — post one to get help!')),
        ],
      ),
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }

  Widget _buildEmptyState(String text) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use SvgPicture if available
          SizedBox(height: 160, child: Image.asset('assets/illustrations/empty.svg', fit: BoxFit.contain)),
          const SizedBox(height: 18),
          Text(text),
        ],
      );
}
