class LandmarkData {
  final int id;
  final String name;
  final double egyptianTicketPrice;
  final double egyptianStudentTicketPrice;
  final double foreignTicketPrice;
  final double foreignStudentTicketPrice;
  final String description;
  final String openTime;
  final String closeTime;
  final double longitude;
  final double latitude;
  final List<String>? images;

  LandmarkData({
    required this.id,
    required this.name,
    required this.egyptianTicketPrice,
    required this.egyptianStudentTicketPrice,
    required this.foreignTicketPrice,
    required this.foreignStudentTicketPrice,
    required this.description,
    required this.openTime,
    required this.closeTime,
    required this.longitude,
    required this.latitude,
    this.images,
  });

  factory LandmarkData.fromJson(Map<String, dynamic> json) {
    return LandmarkData(
      id: json['id'],
      name: json['name'],
      egyptianTicketPrice: json['egyptianTicketPrice'],
      egyptianStudentTicketPrice: json['egyptianStudentTicketPrice'],
      foreignTicketPrice: json['foreignTicketPrice'],
      foreignStudentTicketPrice: json['foreignStudentTicketPrice'],
      description: json['description'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      images: json['imagesUrl'] != null ? List<String>.from(json['imagesUrl']) : null,
    );
  }
  @override
  String toString() {
    return 'LandmarkData{id: $id, name: $name, egyptianTicketPrice: $egyptianTicketPrice}';
    // Include other properties as needed
  }
}
