import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orginone/common/index.dart';
import 'package:orginone/components/modules/general_bread_crumbs/index.dart';
import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/core/chat/session.dart';
import 'package:orginone/dart/core/consts.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/dart/core/target/base/target.dart';
import 'package:orginone/dart/core/thing/standard/application.dart';
import 'package:orginone/dart/core/work/task.dart';
import 'package:orginone/main.dart';
import 'package:orginone/pages/store/state.dart';
import 'package:orginone/utils/string_util.dart';

class ListAdapter {
  VoidCallback? callback;

  List<PopupMenuItem> popupMenuItems = [];

  late String title;

  late List<String> labels;

  dynamic image;

  late String content;

  late int noReadCount;

  String? dateTime;

  late bool circularAvatar;

  late bool isUserLabel;

  PopupMenuItemSelected? onSelected;

  String? typeName;

  ListAdapter({
    this.title = '',
    this.labels = const [],
    this.image,
    this.content = '',
    this.dateTime,
    this.isUserLabel = false,
    this.noReadCount = 0,
    this.circularAvatar = false,
    this.callback,
    this.popupMenuItems = const [],
  });

  ListAdapter.chat(ISession chat) {
    labels = chat.chatdata.labels;
    bool isTop = labels.contains("置顶");
    isUserLabel = false;
    typeName = chat.share.typeName;
    popupMenuItems = [
      PopupMenuItem(
        value: isTop ? PopupMenuKey.cancelTopping : PopupMenuKey.topping,
        child: Text(isTop ? "取消置顶" : "置顶"),
      ),
      const PopupMenuItem(
        value: PopupMenuKey.delete,
        child: Text("删除"),
      ),
    ];
    onSelected = (key) async {
      switch (key) {
        case PopupMenuKey.cancelTopping:
          chat.chatdata.labels.remove('置顶');
          await chat.cacheChatData();
          settingCtrl.provider.refresh();
          break;
        case PopupMenuKey.topping:
          chat.chatdata.labels.add('置顶');
          await chat.cacheChatData();
          settingCtrl.provider.refresh();
          break;
        case PopupMenuKey.delete:
          settingCtrl.chats.remove(chat);
          settingCtrl.provider.refresh();
          break;
      }
    };
    circularAvatar = chat.share.typeName == TargetType.person.label;
    noReadCount = chat.chatdata.noReadCount;
    title = chat.chatdata.chatName ?? "";
    dateTime = chat.chatdata.lastMessage?.createTime;
    content = '';
    var lastMessage = chat.chatdata.lastMessage;
    if (lastMessage != null) {
      if (lastMessage.fromId != settingCtrl.user.metadata.id) {
        if (chat.share.typeName != TargetType.person.label) {
          var target = chat.members
              .firstWhere((element) => element.id == lastMessage.fromId);
          content = "${target.name}:";
        } else {
          content = "对方:";
        }
      }
      content = content +
          StringUtil.msgConversion(MsgSaveModel.fromJson(lastMessage.toJson()),
              settingCtrl.user.userId);
    }

    image = chat.share.avatar?.thumbnailUint8List ??
        chat.share.avatar?.defaultAvatar;

    callback = () {
      chat.onMessage((messages) => null);
      Get.toNamed(
        Routers.messageChat,
        arguments: chat,
      );
    };
  }
  ListAdapter.work(IWorkTask work) {
    labels = [work.metadata.createUser!, work.metadata.shareId!];
    isUserLabel = true;
    circularAvatar = false;
    noReadCount = 0;
    title = work.taskdata.title ?? '';
    dateTime = work.metadata.createTime ?? "";
    content = work.taskdata.content ?? "";
    image = ShareIdSet[work.metadata.shareId]?.avatar?.thumbnailUint8List ??
        AssetsImages.iconWorkitem;
    if (work.targets.length == 2) {
      content =
          "${work.targets[0].name}[${work.targets[0].typeName}]申请加入${work.targets[1].name}[${work.targets[1].typeName}]";
    }

    content = "内容:$content";

    callback = () async {
      //加载流程实例数据
      await work.loadInstance();
      //跳转办事详情
      Get.toNamed(Routers.processDetails, arguments: {"todo": work});
    };
  }

  ListAdapter.application(IApplication application, ITarget target) {
    labels = [target.name ?? ""];
    isUserLabel = false;
    circularAvatar = false;
    noReadCount = 0;
    title = application.name ?? "";
    dateTime = application.metadata.createTime ?? "";
    content = "应用说明:${application.metadata.remark ?? ""}";
    image = application.metadata.avatarThumbnail() ?? Ionicons.apps;

    callback = () async {
      var works = await application.loadWorks();
      var nav = GeneralBreadcrumbNav(
          id: application.metadata.id ?? "",
          name: application.metadata.name ?? "",
          source: application,
          spaceEnum: SpaceEnum.applications,
          space: target,
          children: [
            ...works.map((e) {
              return GeneralBreadcrumbNav(
                id: e.metadata.id ?? "",
                name: e.metadata.name ?? "",
                spaceEnum: SpaceEnum.work,
                space: target,
                source: e,
                children: [],
              );
            }).toList(),
            ..._loadModuleNav(application.children, target),
          ]);
      Get.toNamed(Routers.generalBreadCrumbs, arguments: {"data": nav});
    };
  }

  ListAdapter.store(RecentlyUseModel recent) {
    image = recent.avatar ?? Ionicons.clipboard_sharp;
    labels = [recent.thing == null ? "文件" : "物"];
    callback = () {
      if (recent.file != null) {
        RoutePages.jumpFile(file: recent.file!, type: "store");
      }
    };
    title = recent.thing?.id ?? recent.file?.name ?? "";
    isUserLabel = false;
    circularAvatar = false;
    noReadCount = 0;
    content = '';
    dateTime = recent.createTime;
  }

  List<GeneralBreadcrumbNav> _loadModuleNav(
      List<IApplication> app, ITarget target) {
    List<GeneralBreadcrumbNav> navs = [];
    for (var value in app) {
      navs.add(GeneralBreadcrumbNav(
          id: value.metadata.id ?? "",
          name: value.metadata.name ?? "",
          source: value,
          spaceEnum: SpaceEnum.module,
          space: target,
          onNext: (item) async {
            var works = await value.loadWorks();
            List<GeneralBreadcrumbNav> data = [
              ...works.map((e) {
                return GeneralBreadcrumbNav(
                  id: e.metadata.id ?? "",
                  name: e.metadata.name ?? "",
                  spaceEnum: SpaceEnum.work,
                  source: e,
                  space: target,
                  children: [],
                );
              }),
              ..._loadModuleNav(value.children, target),
            ];
            item.children = data;
          },
          children: []));
    }
    return navs;
  }
}
