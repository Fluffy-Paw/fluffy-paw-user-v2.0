class TrackingFile {
  final int id;
  final String file;
  final DateTime createDate;
  final bool status;

  TrackingFile({
    required this.id,
    required this.file,
    required this.createDate,
    required this.status,
  });

  factory TrackingFile.fromMap(Map<String, dynamic> map) {
    return TrackingFile(
      id: map['id'] ?? 0,
      file: map['file'] ?? '',
      createDate: DateTime.parse(map['createDate']),
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file,
      'createDate': createDate.toIso8601String(),
      'status': status,
    };
  }
}

class TrackingInfo {
  final int id;
  final int bookingId;
  final DateTime uploadDate;
  final String description;
  final bool status;
  final List<TrackingFile> files;

  TrackingInfo({
    required this.id,
    required this.bookingId,
    required this.uploadDate,
    required this.description,
    required this.status,
    required this.files,
  });

  factory TrackingInfo.fromMap(Map<String, dynamic> map) {
    return TrackingInfo(
      id: map['id'] ?? 0,
      bookingId: map['bookingId'] ?? 0,
      uploadDate: DateTime.parse(map['uploadDate']),
      description: map['description'] ?? '',
      status: map['status'] ?? false,
      files: (map['files'] as List<dynamic>?)
              ?.map((x) => TrackingFile.fromMap(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'status': status,
      'files': files.map((x) => x.toMap()).toList(),
    };
  }
}