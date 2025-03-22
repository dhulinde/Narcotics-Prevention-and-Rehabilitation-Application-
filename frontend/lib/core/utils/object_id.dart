class ObjectId {
  final String value;

  ObjectId(this.value);

  // Create a new ObjectId from a string
  static ObjectId? fromString(String? id) {
    if (id == null || id.isEmpty) return null;
    return ObjectId(id);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}