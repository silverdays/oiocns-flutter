import 'package:get/get.dart';
import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/core/getx/breadcrumb_nav/base_breadcrumb_nav_controller.dart';
import 'package:orginone/dart/core/public/enums.dart';
import 'package:orginone/routers.dart';
import 'package:orginone/util/toast_utils.dart';

import 'state.dart';

class InitiateWorkController
    extends BaseBreadcrumbNavController<InitiateWorkState> {
  @override
  final InitiateWorkState state = InitiateWorkState();

  void jumpNext(WorkBreadcrumbNav work) {
    if (work.children.isEmpty) {
      jumpWorkList(work);
    } else {
      Get.toNamed(Routers.initiateWork,
          preventDuplicates: false, arguments: {"data": work});
    }
  }

  void jumpWorkList(WorkBreadcrumbNav work) async {
    if (work.workEnum == WorkEnum.initiationWork) {
      if (work.spaceEnum == SpaceEnum.work) {
        WorkNodeModel? node = await work.source.loadWorkNode();
        if (node != null && node.forms != null && node.forms!.isNotEmpty) {
          Get.toNamed(Routers.createWork, arguments: {
            "work": work.source,
            "node": node,
            'target': work.space
          });
        } else {
          ToastUtils.showMsg(msg: "流程未绑定表单");
        }
      } else {
        Get.toNamed(Routers.initiateWork,
            preventDuplicates: false, arguments: {"data": work});
      }
    } else {
      Get.toNamed(Routers.workList, arguments: {"data": work});
    }
  }
}
