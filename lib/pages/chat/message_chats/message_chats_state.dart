import 'package:orginone/dart/core/chat/session.dart';
import 'package:orginone/dart/core/getx/submenu_list/base_submenu_state.dart';

class MessageChatsState extends BaseSubmenuState<MessageFrequentlyUsed> {
  @override
  //
  String get tag => "沟通";
}

class MessageFrequentlyUsed extends FrequentlyUsed {
  late ISession chat;

  MessageFrequentlyUsed(
      {super.id, super.name, super.avatar, required this.chat});
}
