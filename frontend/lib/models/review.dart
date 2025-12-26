class Review {
  final int reviewId;
  final DateTime createdAt;
  final int userId;
  final int venueId;
  final String reviewText;
  final String username;
  final String venueName;

  Review({
    required this.reviewId,
    required this.createdAt,
    required this.userId,
    required this.venueId,
    required this.reviewText,
    required this.username,
    required this.venueName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      venueId: json['venue_id'],
      reviewText: json['review_text'],
      username: json['username'],
      venueName: json['venue_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'venue_id': venueId,
      'review_text': reviewText,
      'username': username,
      'venue_name': venueName,
    };
  }
}