class Supplier {
  int id;
  String name;
  String estate;
  String cscode;
  int cat01;

  Supplier(this.id, this.name, this.estate, this.cscode, this.cat01);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estate': estate,
      'cscode': cscode,
      'cat01': cat01
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(json['id'], json['name'], json['estate'], json['cscode'],
        json['cat01']);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier && runtimeType == other.runtimeType && id == other.id;
}
