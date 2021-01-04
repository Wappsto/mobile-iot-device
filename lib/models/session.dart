class Session {
  final String id;
  final String username;

  Session({this.id, this.username});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      username: json['username'],
      id: json['meta']['id'],
    );
  }

  String toString() {
    return "Session $id for $username";
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Session &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    username == other.username;

  @override
  int get hashCode => id.hashCode ^ username.hashCode;
}
