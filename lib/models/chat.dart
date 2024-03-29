import '../models/chat_user.dart';
import '../models/chat_message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final String groupName;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  List<ChatMessage> messages;
  late final List<ChatUser> _recpients;

  Chat({
    required this.uid,
    required this.currentUserUid,
    required this.groupName,
    required this.messages,
    required this.members,
    required this.activity,
    required this.group,
  }) {
    _recpients = members.where((_i) => _i.uid != currentUserUid).toList();
  }

  List<ChatUser> recepients() {
    return _recpients;
  }

  String title() {
    return !group
        ? _recpients.first.name
        : groupName;
  }

  String imageURL() {
    return !group
        ? _recpients.first.imageURL
        : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
  }

}
