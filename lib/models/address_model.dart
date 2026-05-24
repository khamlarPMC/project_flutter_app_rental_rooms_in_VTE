class Address {
  final int? addressId;
  final String? village;
  final String? district;
  final String? province;

  Address({
    this.addressId,
    this.village,
    this.district,
    this.province,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'],
      village: json['village'],
      district: json['district'],
      province: json['province'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'village': village,
      'district': district,
      'province': province,
    };
  }
}
