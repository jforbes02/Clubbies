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
    };
  }
}
