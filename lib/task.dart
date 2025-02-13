class MessageBubble {
  MessageBubble({required this.isDone, this.name});
  String? name;
  bool isDone;

  void toggleDone() {
    isDone = !isDone;
  }
}
