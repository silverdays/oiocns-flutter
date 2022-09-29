import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orginone/api_resp/message_detail_resp.dart';
import 'package:orginone/api_resp/target_resp.dart';
import 'package:orginone/component/text_tag.dart';
import 'package:orginone/component/unified_scaffold.dart';
import 'package:orginone/component/unified_text_style.dart';
import 'package:orginone/page/home/message/chat/chat_controller.dart';
import 'package:orginone/page/home/message/chat/component/chat_box.dart';
import 'package:orginone/util/date_util.dart';

import '../../../../api_resp/message_item_resp.dart';
import '../../../../component/unified_edge_insets.dart';
import '../../../../enumeration/target_type.dart';
import '../../../../routers.dart';
import '../../../../util/hive_util.dart';
import '../../../../util/widget_util.dart';
import 'component/chat_message_detail.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);

  get _title => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Obx(() => Text(
              controller.titleName.value,
              style: text20,
            )),
        Container(
          margin: left10,
        ),
        TextTag(
          controller.messageItem.label,
          textStyle: text12WhiteBold,
          bgColor: Colors.blueAccent,
          padding: const EdgeInsets.all(4),
        )
      ]);

  get _actions => <Widget>[
        GFIconButton(
            color: Colors.white.withOpacity(0),
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              Map<String, dynamic> args = {
                "spaceId": controller.spaceId,
                "messageItemId": controller.messageItemId,
                "messageItem": controller.messageItem,
                "personList": controller.personList
              };
              Get.toNamed(Routers.messageSetting, arguments: args);
            })
      ];

  Widget _time(DateTime? dateTime) {
    return Container(
      alignment: Alignment.center,
      margin: top10,
      child: Text(
        dateTime != null ? CustomDateUtil.getDetailTime(dateTime) : "",
        style: text10Grey,
      ),
    );
  }

  Widget _chatItem(int index) {
    MessageItemResp messageItem = controller.messageItem;
    MessageDetailResp messageDetail = controller.messageDetails[index];

    TargetResp userInfo = HiveUtil().getValue(Keys.userInfo);
    bool isMy = messageDetail.fromId == userInfo.id;
    bool isMultiple = messageItem.typeName != TargetType.person.name;

    Widget currentWidget =
        ChatMessageDetail(messageItem.id, messageDetail, isMy, isMultiple);

    var time = _time(messageDetail.createTime);
    var item = Column(children: [currentWidget]);
    if (index == 0) {
      item.children.add(Container(margin: EdgeInsets.only(bottom: 5.h)));
    }
    if (index == controller.messageDetails.length - 1) {
      item.children.insert(0, time);
      return item;
    } else {
      MessageDetailResp pre = controller.messageDetails[index + 1];
      if (messageDetail.createTime != null && pre.createTime != null) {
        var difference = messageDetail.createTime!.difference(pre.createTime!);
        if (difference.inSeconds > 60) {
          item.children.insert(0, time);
          return item;
        }
      }
      return item;
    }
  }

  _function(BuildContext context, RelativeRect position) {
    // final RenderBox target = context.findRenderObject()! as RenderBox;
    // final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    // final Offset offset;
    // switch (widget.position) {
    //   case PopupMenuPosition.over:
    //     offset = widget.offset;
    //     break;
    //   case PopupMenuPosition.under:
    //     offset = Offset(0.0, button.size.height - (widget.padding.vertical / 2)) + widget.offset;
    //     break;
    // }
    // final RelativeRect position = RelativeRect.fromRect(
    //   Rect.fromPoints(
    //     button.localToGlobal(offset, ancestor: overlay),
    //     button.localToGlobal(button.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
    //   ),
    //   Offset.zero & overlay.size,
    // );
    // final List<PopupMenuEntry<T>> items = widget.itemBuilder(context);
    // // Only show the menu if there is something to show
    // if (items.isNotEmpty) {
    //   showMenu<T?>(
    //     context: context,
    //     elevation: widget.elevation ?? popupMenuTheme.elevation,
    //     items: items,
    //     initialValue: widget.initialValue,
    //     position: position,
    //     shape: widget.shape ?? popupMenuTheme.shape,
    //     color: widget.color ?? popupMenuTheme.color,
    //     constraints: widget.constraints,
    //   )
    //       .then<void>((T? newValue) {
    //     if (!mounted)
    //       return null;
    //     if (newValue == null) {
    //       widget.onCanceled?.call();
    //       return null;
    //     }
    //     widget.onSelected?.call(newValue);
    //   });
    // }

  }

  get _body => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.getHistoryMsg();
                controller.update();
              },
              child: Container(
                padding: lr10,
                child: GetBuilder<ChatController>(
                  builder: (controller) => ListView.builder(
                    key: ObjectKey(controller.messageScrollKey.value),
                    reverse: true,
                    shrinkWrap: true,
                    controller: controller.messageScrollController,
                    scrollDirection: Axis.vertical,
                    itemCount: controller.messageDetails.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _chatItem(index);
                    },
                  ),
                ),
              ),
            ),
          ),
          ChatBox(controller.sendOneMessage)
        ],
      );

  @override
  Widget build(BuildContext context) {
    return UnifiedScaffold(
      appBarLeading: WidgetUtil.defaultBackBtn,
      appBarTitle: _title,
      appBarActions: _actions,
      body: _body,
    );
  }
}
