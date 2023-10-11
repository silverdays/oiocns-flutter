import 'package:flutter/material.dart';
import 'package:orginone/dart/core/getx/breadcrumb_nav/base_breadcrumb_nav_item.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/pages/chat/message_routers.dart';

class MessageBreadcrumbNavItem
    extends BaseBreadcrumbNavItem<ChatBreadcrumbNav> {
  final PopupMenuItemSelected? onSelected;

  const MessageBreadcrumbNavItem({
    required super.item,
    super.onTap,
    super.onNext,
    super.key,
    this.onSelected,
  });

  @override
  List<PopupMenuItem> popupItems() {
    if (item.type == ChatType.list) {
      return super.popupItems();
    }
    PopupMenuItem popupMenuItem;
    //TODO:没有此方法 isMostUsed
    // if (settingCtrl.chat.isMostUsed(item.target!)) {
    //   popupMenuItem = const PopupMenuItem(
    //     value: PopupMenuKey.removeCommon,
    //     child: Text("移除常用"),
    //   );
    // } else {
    popupMenuItem = const PopupMenuItem(
      value: PopupMenuKey.setCommon,
      child: Text("设为常用"),
    );
    // }
    return [
      popupMenuItem,
    ];
  }

  @override
  void onSelectPopupItem(key) {
    onSelected?.call(key);
  }
}
