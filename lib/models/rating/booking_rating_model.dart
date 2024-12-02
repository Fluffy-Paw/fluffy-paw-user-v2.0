import 'package:image_picker/image_picker.dart';

class BookingRating {
  final int id;
  final int bookingId;
  final int petOwnerId;
  final String? fullName;
  final String? avatar;
   int serviceVote;
   int storeVote;
  final String? description;
  final String? image;

  BookingRating({
    required this.id,
    required this.bookingId,
    required this.petOwnerId,
    this.fullName,
    this.avatar,
    required this.serviceVote,
    required this.storeVote,
    this.description,
    this.image,
  });

  factory BookingRating.fromMap(Map<String, dynamic> map) {
    return BookingRating(
      id: map['id'] ?? 0,
      bookingId: map['bookingId'] ?? 0,
      petOwnerId: map['petOwnerId'] ?? 0,
      fullName: map['fullName'],
      avatar: map['avatar'],
      serviceVote: map['serviceVote'] ?? 0,
      storeVote: map['storeVote'] ?? 0,
      description: map['description'],
      image: map['image'],
    );
  }
}

class BookingRatingRequest {
  final int serviceVote;
  final int storeVote;
  final String? description;
  final XFile? image;

  BookingRatingRequest({
    required this.serviceVote,
    required this.storeVote,
    this.description,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'ServiceVote': serviceVote,
      'StoreVote': storeVote,
      'Description': description,
    };
  }
}