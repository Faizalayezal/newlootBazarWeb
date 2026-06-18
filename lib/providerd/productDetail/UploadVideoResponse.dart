
class UploadVideoResponse {
  final String message;
  final VideoStatus status;

  UploadVideoResponse({required this.message, required this.status});

  factory UploadVideoResponse.fromJson(Map<String, dynamic> json) {
    return UploadVideoResponse(
      message: json['message'] ?? '',
      status: VideoStatus.fromJson(json['status']),
    );
  }
}

class VideoStatus {
  final String id;
  final String userId;
  final String productId;
  final String video;
  final String duration;
  final String publicId;
  final int size;
  final String mimetype;
  final String filename;
  final String expiresAt;
  final String createdAt;

  VideoStatus({
    required this.id,
    required this.userId,
    required this.productId,
    required this.video,
    required this.duration,
    required this.publicId,
    required this.size,
    required this.mimetype,
    required this.filename,
    required this.expiresAt,
    required this.createdAt,
  });

  factory VideoStatus.fromJson(Map<String, dynamic> json) {
    return VideoStatus(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      video: json['video'] ?? '',
      duration: json['duration'] ?? '',
      publicId: json['publicId'] ?? '',
      size: json['size'] ?? 0,
      mimetype: json['mimetype'] ?? '',
      filename: json['filename'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}