class Venue {
  final int venueId;
  final String venueName;
  final String address;
  final String hours;
  final List<String> venueType;
  final int ageReq;
  final String? description;
  final String capacity;
  final int price;
  final double averageRating;
  final int reviewCount;

  Venue({
    required this.venueId,
    required this.venueName,
    required this.address,
    required this.hours,
    required this.venueType,
    required this.ageReq,
    this.description,
    required this.capacity,
    required this.price,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      venueId: json['venue_id'],
      venueName: json['venue_name'],
      address: json['address'],
      hours: json['hours'],
      venueType: List<String>.from(json['venue_type']),
      ageReq: json['age_req'],
      description: json['description'],
      capacity: json['capacity'],
      price: json['price'],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'venue_id': venueId,
      'venue_name': venueName,
      'address': address,
      'hours': hours,
      'venue_type': venueType,
      'age_req': ageReq,
      'description': description,
      'capacity': capacity,
      'price': price,
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
  }
}
