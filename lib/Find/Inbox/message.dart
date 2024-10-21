// message.dart
class Message {
  final String from;
  final String to;
  final String content;
  final String time;
  final bool read;

  Message({
    required this.from,
    required this.to,
    required this.content,
    required this.time,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      from: json['from'].toString(),
      to: json['to'].toString(),
      content: json['message'].toString(),
      time: json['time'].toString(),
      read: json['read'],
    );
  }
}
