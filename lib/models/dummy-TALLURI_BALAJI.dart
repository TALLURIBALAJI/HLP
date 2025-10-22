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
  static final requests = <HelpRequest>[];
}
