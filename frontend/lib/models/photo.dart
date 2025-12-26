class Photo {
  final int photoId;
  final String imgUrl;
  final String? caption;
  final int fileSize;
  final String contentType;
  final int userId;
  final String username;
  final int venueId;
  final String venueName;
  final DateTime uploadedAt;

  Photo({
    required this.photoId,
    required this.imgUrl,
    this.caption,
    required this.fileSize,
    required this.contentType,
    required this.userId,
    required this.username,
    required this.venueId,
    required this.venueName,
    required this.uploadedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photo_id'],
      imgUrl: json['img_url'],
      caption: json['caption'],
      fileSize: json['file_size'] ?? 0,
      contentType: json['content_type'] ?? '',
      userId: json['user_id'],
      username: json['username'],
      venueId: json['venue_id'],
      venueName: json['venue_name'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
      'img_url': imgUrl,
      'caption': caption,
      'file_size': fileSize,
      'content_type': contentType,
      'user_id': userId,
      'username': username,
      'venue_id': venueId,
      'venue_name': venueName,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
