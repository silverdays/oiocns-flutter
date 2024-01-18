import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orginone/components/base/group_nav_list/index.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/pages/store/models/store_tree_nav_model.dart';
import 'package:orginone/pages/store/widgets/index.dart';

import 'index.dart';

///目录层级界面  树形
class StoreTreePage
    extends BaseGroupNavListPage<StoreTreeController, StoreTreeState> {
  StoreTreePage({super.key});

  @override
  Widget buildPageView(String type, String label) {
    return _pageView(type, label);
  }

  _pageView(String type, String label) {
    return Obx(() {
      List<StoreTreeNavModel> datas = [];
      var children = state.model.value!.children;
      datas = children.where((nav) {
        List<String> groupTags = nav.source != null
            ? nav.source.groupTags ?? []
            : nav.space?.groupTags ?? [];
        if (type == '全部') {
          return true;
        }
        return groupTags.contains(type);
      }).toList();
      datas = datas
          .where((element) => element.name.contains(state.keyword.value))
          .toList();

      return ListView.builder(
          itemCount: datas.length,
          itemBuilder: (BuildContext context, int index) {
            var item = datas[index];
            return StoreNavItem(
              item: item,
              onTap: () {
                controller.jumpDetails(item);
              },
              onNext: () {
                controller.onNext(item);
              },
              onSelected: (key, item) {
                controller.operation(key, item);
              },
            );
          });
    });
  }

  @override
  StoreTreeController getController() {
    return StoreTreeController();
  }

  @override
  String tag() {
    return hashCode.toString();
  }

  @override
  List<PopupMenuItem<PopupMenuKey>> popupMenuItems() {
    if (state.model.value!.spaceEnum == SpaceEnum.directory &&
        state.model.value!.source == null) {
      return super.popupMenuItems();
    }

    List<PopupMenuKey> items = [PopupMenuKey.shareQr];
    return items
        .map((e) => PopupMenuItem(
              value: e,
              child: Text(e.label),
            ))
        .toList();
  }
}
