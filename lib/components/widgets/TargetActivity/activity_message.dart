import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:orginone/common/index.dart';
import 'package:orginone/components/index.dart';
import 'package:orginone/components/widgets/TargetActivity/list_item_meta.dart';
import 'package:orginone/config/index.dart';
import 'package:orginone/dart/base/model.dart' as model;
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/chat/activity.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/dart/core/work/rules/lib/tools.dart';
import 'package:orginone/main.dart';

import 'activity_comment.dart';
import 'activity_comment_box.dart';
import 'activity_resource.dart';

//渲染动态信息
class ActivityMessageWidget extends StatelessWidget {
  //动态消息
  late Rx<IActivityMessage> item;
  RxBool isDelete = false.obs;
  //动态
  IActivity activity;
  //动态元数据
  model.ActivityType? metadata;
  //隐藏点赞信息和回复信息，只显示统计数量
  bool hideResource;
  ActivityMessageWidget(
      {super.key,
      required IActivityMessage item,
      required this.activity,
      this.hideResource = false}) {
    this.item = item.obs;
    metadata = this.item.value.metadata;
    //订阅数据变更
    item.unsubscribe();
    item.subscribe((key, args) {
      this.item.refresh();
    }, false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Offstage(
        offstage: isDelete.value,
        child: ListItemMetaWidget(
          title: title(),
          avatar: avatar(),
          description: description(context),
          onTap: () {
            Get.toNamed(
              Routers.targetActivity,
              arguments: activity,
            );
          },
        ),
      );
    });
  }

  //渲染标题
  Widget title() {
    return Container(
      child: Row(
        children: [
          Text(activity.metadata.name!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          Padding(padding: EdgeInsets.only(left: 10.h)),
          if (metadata?.tags.isNotEmpty ?? false)
            ...metadata!.tags
                .map((e) => OutlinedButton(onPressed: () {}, child: Text(e)))
                .toList()
        ],
      ),
    );
  }

  //渲染内容
  Widget? renderContent() {
    switch (MessageType.getType(metadata!.typeName)) {
      case MessageType.text:
        return Text(metadata!.content,
            maxLines: 1, overflow: TextOverflow.ellipsis);
      case MessageType.html:
        if (hideResource) {
          return (Offstage(
            offstage: !hideResource,
            child: Text(parseHtmlToText(metadata!.content),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ));
        } else {
          return HtmlWidget(
            metadata!.content,
          );
        }
    }
    return null;
  }

  //渲染头像
  Widget avatar() {
    // return CircleAvatar(
    //   backgroundImage: AssetImage(activity.typeName),
    // );
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      TeamAvatar(
        info: TeamTypeInfo(
            share: activity.metadata.shareIcon() ??
                model.ShareIcon(name: '', typeName: activity.typeName ?? "")),
        size: 65.w,
      ),
    ]);
  }

  //渲染描述
  Widget description(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
            child: renderContent() ?? Container(),
          ),
          if (!hideResource)
            ...ActivityResourceWidget(metadata!.resource, 600).build(context),
          RenderCtxMore(
            activity: activity,
            item: item,
            hideResource: hideResource,
            isDelete: isDelete,
          )
        ],
      ),
    );
  }
}

//渲染动态属性信息
class RenderCtxMore extends StatelessWidget {
  Rx<IActivityMessage> item;
  IActivity activity;
  RxBool isDelete;
  bool hideResource;
  late XEntity? replyTo;
  bool commenting = false;

  RenderCtxMore(
      {super.key,
      required this.activity,
      required this.item,
      required this.hideResource,
      required this.isDelete});

  @override
  Widget build(BuildContext context) {
    if (hideResource) {
      return renderTags();
    }
    return renderOperate(context);
  }

  //判断是否有回复
  Future<void> handleReply([String userId = '']) async {
    replyTo = null;
    if (userId.isNotEmpty) {
      var user = await settingCtrl.user.findEntityAsync(userId);
      replyTo = user;
    }
    commenting = true;
  }

  //渲染操作
  Widget renderOperate(BuildContext context) {
    return Container(child: Obx(() {
      return Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 5.h)),
          Row(
            children: [
              ...getUserAvatar(item.value.metadata.createUser!),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 5.w),
                child: Row(
                  children: [
                    Text(
                      "发布于${showChatTime(item.value.metadata.createTime!)}",
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              Offstage(
                offstage:
                    !item.value.metadata.likes.contains(settingCtrl.user.id),
                child: ButtonWidget.iconTextOutlined(
                  onTap: () async {
                    await item.value.like();
                  },
                  const ImageWidget(
                    AssetsImages.iconLike,
                    size: 18,
                    color: Colors.red,
                  ),
                  '取消',
                  textColor: XColors.black3,
                ),
              ),
              Offstage(
                offstage:
                    item.value.metadata.likes.contains(settingCtrl.user.id),
                child: ButtonWidget.iconTextOutlined(
                  onTap: () async {
                    await item.value.like();
                  },
                  const ImageWidget(
                    AssetsImages.iconLike,
                    size: 18,
                  ),
                  '点赞',
                  textColor: XColors.black3,
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 5.w)),
              ButtonWidget.iconTextOutlined(
                onTap: () async {
                  ShowCommentBoxNotification().dispatch(context);
                },
                const ImageWidget(
                  AssetsImages.iconMsg,
                  size: 18,
                ),
                '评论',
                textColor: XColors.black3,
              ),
              Padding(padding: EdgeInsets.only(left: 5.w)),
              Offstage(
                offstage: !item.value.canDelete,
                child: ButtonWidget.iconTextOutlined(
                  onTap: () async {
                    await item.value.delete();
                    isDelete.value = true;
                    //提醒动态分类更新信息
                    activity.activityList.first.changCallback();
                  },
                  const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: XColors.black3,
                  ),
                  '删除',
                  textColor: XColors.black3,
                ),
              )
            ],
          ),
          Offstage(
            offstage: item.value.metadata.likes.isEmpty &&
                item.value.metadata.comments.isEmpty,
            child: Container(
                alignment: Alignment.centerLeft,
                color: XColors.entryBgColor,
                padding: EdgeInsets.all(5.w),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    const ImageWidget(AssetsImages.iconLike,
                        size: 18, color: Colors.red),
                    for (var e in item.value.metadata.likes) ...getUserAvatar(e)
                  ],
                )),
          ),
          Padding(padding: EdgeInsets.only(left: 5.w)),
          Offstage(
            offstage: item.value.metadata.comments.isEmpty,
            child: Container(
                alignment: Alignment.centerLeft,
                color: XColors.entryBgColor,
                padding: EdgeInsets.all(5.w),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ...item.value.metadata.comments.map((e) => ActivityComment(
                        comment: e,
                        onTap: (comment) => handleReply(comment.userId)))
                  ],
                )),
          )
        ],
      );
    }));
  }

  //渲染发布者信息
  Widget renderTags() {
    XEntity? entity =
        settingCtrl.user.findMetadata<XEntity>(item.value.metadata.createUser!);
    var showLikes = item.value.metadata.likes.isEmpty &&
        item.value.metadata.comments.isEmpty;
    return Container(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 5.h)),
          Row(
            children: [
              TeamAvatar(
                info: TeamTypeInfo(userId: item.value.metadata.createUser!),
                size: 24.w,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 5.w),
                child: Row(
                  children: [
                    Text("${entity?.name}",
                        style: const TextStyle(
                          color: XColors.themeColor,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      "发布于${showChatTime(item.value.metadata.createTime!)}",
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5.h)),
          Offstage(
            offstage: showLikes,
            child: Container(
                color: XColors.entryBgColor,
                padding: EdgeInsets.all(5.w),
                child: Row(
                  children: [
                    Offstage(
                      offstage: item.value.metadata.likes.isEmpty,
                      child: Row(
                        children: [
                          const ImageWidget(AssetsImages.iconLike,
                              size: 18, color: Colors.red),
                          Container(
                              padding: EdgeInsets.only(left: 6.w),
                              child:
                                  Text("${item.value.metadata.likes.length}"))
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 5.w)),
                    Offstage(
                      offstage: item.value.metadata.comments.isEmpty,
                      child: Row(
                        children: [
                          const ImageWidget(AssetsImages.iconMsg,
                              size: 18, color: XColors.themeColor),
                          Container(
                              padding: EdgeInsets.only(left: 6.w),
                              child: Text(
                                  "${item.value.metadata.comments.length}"))
                        ],
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }

  List<Widget> getUserAvatar(String userId) {
    XEntity? entity = settingCtrl.user.findMetadata<XEntity>(userId);
    return [
      Padding(padding: EdgeInsets.only(left: 5.w)),
      TeamAvatar(
        info: TeamTypeInfo(userId: userId),
        size: 24.w,
      ),
      Padding(padding: EdgeInsets.only(left: 5.w)),
      Text(entity?.name ?? "",
          style: const TextStyle(
            color: XColors.themeColor,
            fontWeight: FontWeight.bold,
          ))
    ];
  }
}
