class Driver {
  int id;
  String userName;

  Driver(this.id, this.userName);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      json['id'],
      json['userName'],
    );
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver && runtimeType == other.runtimeType && id == other.id;
}
