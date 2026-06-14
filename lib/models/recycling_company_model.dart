class AcceptedMaterial {
  final String name;
  final double? priceMin;
  final double? priceMax;
  final String? priceNote;
  final String? quality;
  final double? minWeight;
  final bool offersPickup;

  const AcceptedMaterial({
    required this.name,
    this.priceMin,
    this.priceMax,
    this.priceNote,
    this.quality,
    this.minWeight,
    this.offersPickup = false,
  });
}

class RecyclingCompany {
  final String id;
  final String name;
  final String city;
  final String? address;
  final double latitude;
  final double longitude;
  final String? website;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final List<AcceptedMaterial> materials;
  final String? description;
  final List<String> services;
  final double rating;
  final String? imageUrl;
  final String? hours;
  final int? capacityTonsMonth;

  const RecyclingCompany({
    required this.id,
    required this.name,
    required this.city,
    this.address,
    required this.latitude,
    required this.longitude,
    this.website,
    this.phone,
    this.whatsapp,
    this.email,
    required this.materials,
    this.description,
    this.services = const [],
    this.rating = 0,
    this.imageUrl,
    this.hours,
    this.capacityTonsMonth,
  });

  String get materialNames => materials.map((m) => m.name).join(', ');
  String get serviceNames => services.isEmpty ? '' : services.join(', ');
}
