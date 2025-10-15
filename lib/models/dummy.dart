class HelpRequest {
  final String title;
  final String? description;
  final String category;
  final String urgency;
  final double distanceKm;
  final String? user;

  HelpRequest({required this.title, this.description, required this.category, required this.urgency, required this.distanceKm, this.user});
}

class DummyData {
  static final requests = [
    HelpRequest(title: 'Need textbooks for grade 6', description: 'Looking for complete set of grade 6 textbooks (Math, Science, English). Willing to pick up nearby.', category: 'Books', urgency: 'Medium', distanceKm: 1.2, user: 'Maria'),
    HelpRequest(title: 'Grocery support this week', description: 'Running low on staples. Any grocery help appreciated.', category: 'Food', urgency: 'High', distanceKm: 0.8, user: null),
    HelpRequest(title: 'Math tutoring for high schooler', description: 'Help needed for algebra and calculus basics twice a week.', category: 'Education', urgency: 'Low', distanceKm: 2.5, user: 'James'),
  ];
}
