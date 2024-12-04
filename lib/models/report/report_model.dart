class ReportCategory {
  final int id;
  final String type;
  final String name;

  ReportCategory({
    required this.id,
    required this.type, 
    required this.name,
  });

  factory ReportCategory.fromMap(Map<String, dynamic> map) {
    return ReportCategory(
      id: map['id'] ?? 0,
      type: map['type'] ?? '',
      name: map['name'] ?? '',
    );
  }

  static List<ReportCategory> fromMapList(List<dynamic> list) {
    return list.map((item) => ReportCategory.fromMap(item)).toList();
  }
}

class ReportResponse {
  final int id;
  final int senderId;
  final String senderName; 
  final int targetId;
  final String targetName;
  final String reportCategoryType;
  final String reportCategoryName;
  final DateTime createDate;
  final String description;
  final bool status;

  ReportResponse({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.targetId,
    required this.targetName,
    required this.reportCategoryType,
    required this.reportCategoryName,
    required this.createDate,
    required this.description,
    required this.status,
  });

  factory ReportResponse.fromMap(Map<String, dynamic> map) {
    return ReportResponse(
      id: map['id'] ?? 0,
      senderId: map['senderId'] ?? 0,
      senderName: map['senderName'] ?? '',
      targetId: map['targetId'] ?? 0, 
      targetName: map['targetName'] ?? '',
      reportCategoryType: map['reportCategoryType'] ?? '',
      reportCategoryName: map['reportCategoryName'] ?? '',
      createDate: DateTime.parse(map['createDate'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
      status: map['status'] ?? false,
    );
  }
}
class ReportRequest {
  final int targetId;
  final int reportCategoryId;
  final String description;

  ReportRequest({
    required this.targetId,
    required this.reportCategoryId,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'targetId': targetId,
      'reportCategoryId': reportCategoryId,
      'description': description,
    };
  }
}