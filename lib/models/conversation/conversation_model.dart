class ConversationModel {
  final int id;
  final int poAccountId;
  final String poName;
  final String poAvatar;
  final int staffAccountId;
  final String? storeName;
  final String? storeAvatar;
  final String lastMessage;
  final String timeSinceLastMessage;
  final bool isOpen;

  ConversationModel({
    required this.id,
    required this.poAccountId,
    required this.poName,
    required this.poAvatar,
    required this.staffAccountId,
    this.storeName,
    this.storeAvatar,
    required this.lastMessage,
    required this.timeSinceLastMessage,
    required this.isOpen,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
  return ConversationModel(
    id: map['id'] ?? 0,
    poAccountId: map['poAccountId'] ?? 0,
    poName: map['poName'] ?? '',
    poAvatar: map['poAvatar'] ?? '',
    staffAccountId: map['staffAccountId'] ?? 0,
    storeName: map['storeName'],
    storeAvatar: map['storeAvatar'],
    lastMessage: map['lastMessage'] ?? '',
    timeSinceLastMessage: map['timeSinceLastMessage'] ?? '',
    isOpen: map['isOpen'] ?? false,
  );
}

  static List<ConversationModel> fromMapList(List<dynamic> list) {
    return list.map((item) => ConversationModel.fromMap(item)).toList();
  }
}