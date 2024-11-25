class BookingRating {
  final int id;
  final int bookingId;
  final int petOwnerId;
  final int vote;
  final String? description;

  BookingRating({
    required this.id,
    required this.bookingId,
    required this.petOwnerId,
    required this.vote,
    this.description,
  });

  factory BookingRating.fromMap(Map<String, dynamic> map) {
    return BookingRating(
      id: map['id'] as int,
      bookingId: map['bookingId'] as int,
      petOwnerId: map['petOwnerId'] as int,
      vote: map['vote'] as int,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'petOwnerId': petOwnerId,
      'vote': vote,
      'description': description,
    };
  }
}

class BookingRatingRequest {
  final int vote;
  final String? description;

  BookingRatingRequest({
    required this.vote,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'Vote': vote,
      'Description': description,
    };
  }

  // Factory constructor for testing
  factory BookingRatingRequest.test() {
    return BookingRatingRequest(
      vote: 5,
      description: 'Test rating',
    );
  }
}