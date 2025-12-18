class Review {
  final int reviewId;
  final double? rating;  // Nullable for replies
  final DateTime createdAt;
  final int userId;
  final int venueId;
  final String? reviewText;
  final String username;
  final String venueName;
  final int? parentReviewId;  // Null for main reviews, has value for replies
  final int replyCount;

  Review({
    required this.reviewId,
    this.rating,
    required this.createdAt,
    required this.userId,
    required this.venueId,
    this.reviewText,
    required this.username,
    required this.venueName,
    this.parentReviewId,
    this.replyCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      venueId: json['venue_id'],
      reviewText: json['review_text'],
      username: json['username'],
      venueName: json['venue_name'],
      parentReviewId: json['parent_review_id'],
      replyCount: json['reply_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'venue_id': venueId,
      'review_text': reviewText,
      'username': username,
      'venue_name': venueName,
      'parent_review_id': parentReviewId,
      'reply_count': replyCount,
    };
  }

  // Helper to check if this is a reply
  bool get isReply => parentReviewId != null;
}