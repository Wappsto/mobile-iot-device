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
}
