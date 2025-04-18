class Event {
  Event({
    required this.eventId,
    required this.title,
    required this.location,
    required this.date,
    required this.organizerId,
    required this.participants,
  });

  late String eventId;
  late String title;
  late String location;
  late String date;  // Date of the event
  late String organizerId;  // NGO that organizes the event
  late List<String> participants; // List of user IDs (both NGOs and Public users)

  Event.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'] ?? '';
    title = json['title'] ?? '';
    location = json['location'] ?? '';
    date = json['date'] ?? '';
    organizerId = json['organizer_id'] ?? '';
    participants = List<String>.from(json['participants'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'location': location,
      'date': date,
      'organizer_id': organizerId,
      'participants': participants,
    };
  }
}
