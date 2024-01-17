class CollectionDetails {
  int? id;
  String? cscode;
  int? item;
  double? liters;
  double? kilogram;
  double? metrolac;
  double? dryWeight;
  double? temperature;
  double? nh3;
  double? tz;
  String? remarks;
  int? trlnNumber;
  String? typeAmmonia;
  String? container;
  double? longitude;
  double? latitude;
  String? initializedDate;

  CollectionDetails({
    this.id,
    this.cscode,
    this.item,
    this.liters,
    this.kilogram,
    this.metrolac,
    this.dryWeight,
    this.temperature,
    this.nh3,
    this.tz,
    this.remarks,
    this.trlnNumber,
    this.typeAmmonia,
    this.container,
    this.longitude,
    this.latitude,
    this.initializedDate,
  });

  factory CollectionDetails.fromJson(Map<String, dynamic> json) {
    return CollectionDetails(
      id: json['id'],
      cscode: json['cscode'],
      initializedDate: json['initializedDate'],
      liters: json['liters'],
      kilogram: json['kilogram'],
      item: json['item'],
      metrolac: json['metrolac'],
      dryWeight: json['dryWeight'],
      temperature: json['temperature'],
      nh3: json['nh3'],
      tz: json['tz'],
      remarks: json['remarks'],
      trlnNumber: json['trlnNumber'],
      typeAmmonia: json['typeAmmonia'],
      container: json['container'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cscode': cscode,
      'initializedDate': initializedDate,
      'liters': liters,
      'kilogram': kilogram,
      'item': item,
      'metrolac': metrolac,
      'dryWeight': dryWeight,
      'temperature': temperature,
      'nh3': nh3,
      'tz': tz,
      'remarks': remarks,
      'trlnNumber': trlnNumber,
      'typeAmmonia': typeAmmonia,
      'container': container,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  void toMap() {}
}
