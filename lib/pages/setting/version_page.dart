import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orginone/dart/core/getx/base_list_controller.dart';
import 'package:orginone/config/a_font.dart';
import 'package:orginone/components/widgets/image_widget.dart';
import 'package:orginone/components/widgets/originone_scaffold.dart';
import 'package:orginone/config/unified.dart';
import 'package:orginone/components/widgets/loading_widget.dart';
import 'package:orginone/components/widgets/progress_dialog.dart';
import 'package:orginone/config/enum.dart';
import 'package:orginone/dart/base/model.dart' as model;
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/utils/string_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionPage extends GetView<VersionController> {
  const VersionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrginoneScaffold(
        appBarCenterTitle: true,
        appBarTitle: Text(
          "版本列表",
          style: XFonts.size22Black3,
        ),
        appBarLeading: XWidgets.defaultBackBtn,
        bgColor: XColors.white,
        body: Obx(() {
          return LoadingWidget(
            currStatus: controller.mLoadStatus.value,
            builder: (BuildContext context) {
              return listWidget();
            },
          );
        }),
        resizeToAvoidBottomInset: false);
  }

  ListView listWidget() {
    return ListView.builder(
      itemCount: controller.state.dataList.length,
      itemBuilder: (context, index) {
        return itemInit(context, index, controller.state.dataList[index]);
      },
    );
  }

  Widget itemInit(BuildContext context, int index, VersionMes value) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 0.h),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ImageWidget(value.uploadName?.shareLink ?? '', size: 60.w),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.fromLTRB(70.w, 0.h, 138.w, 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    value.appName ?? "",
                    style: AFont.instance.size22Black3W500,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    children: [
                      Text(
                        "发布时间：${DateUtil.formatDateStr(value.pubTime ?? "", format: "yyyy-MM-dd HH:mm")}",
                        style: AFont.instance.size20Black6,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    "　版本号：${value.version}",
                    style: AFont.instance.size20Black6,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    "版本信息：${value.remark}",
                    style: AFont.instance.size20Black6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 135.w,
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 135.w,
                        height: 42.h,
                        child: GFButton(
                            onPressed: () async {
                              //筛选出当前最新版本
                              PackageInfo packageInfo =
                                  await PackageInfo.fromPlatform();
                              String appName = packageInfo.appName;
                              int versionCode =
                                  int.parse(packageInfo.buildNumber);
                              if (appName == value.appName &&
                                  (value.version ?? 1) <= versionCode) {
                                Fluttertoast.showToast(
                                    msg: "此版本低于当前安装版本，无法安装!");
                                return;
                              }
                              showAnimatedDialog(
                                context: context,
                                barrierDismissible: true,
                                animationType: DialogTransitionType.fadeScale,
                                builder: (BuildContext context) {
                                  return UpdaterDialog(
                                    icon: value.uploadName?.shareLink ?? '',
                                    version: "${value.version ?? ''}",
                                    path: value.shareLink ?? '',
                                    content: value.remark ?? '',
                                  );
                                },
                              );
                            },
                            color: XColors.backColor,
                            text:
                                "更新(${StringUtil.formatFileSize(value.size ?? 0)})",
                            textColor: Colors.white,
                            textStyle: AFont.instance.size18White),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      SizedBox(
                        width: 135.w,
                        height: 42.h,
                        child: GFButton(
                          onPressed: () {},
                          color: XColors.themeColor,
                          text: "查看详情",
                          textStyle: AFont.instance.size18White,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0.w,
            bottom: 0.h,
            child: const Divider(
              height: 1.0,
              color: XColors.lineLight2,
            ),
          )
        ],
      ),
    );
  }
}

class VersionController extends BaseListController {
  var fileCtrl = UpdateController();
  final Rx<LoadStatusX> mLoadStatus = LoadStatusX.loading.obs;

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  @override
  Future<void> loadData({bool isRefresh = false, bool isLoad = false}) async {
    var version = await fileCtrl.versionList();
    if (version != null) {
      List<VersionMes> versionList = [];
      for (var element in (version.versionMes ?? [])) {
        if (Platform.isAndroid && element.platform.toLowerCase() == "android") {
          versionList.add(element);
        } else if (Platform.isIOS && element.platform.toLowerCase() == "ios") {
          versionList.add(element);
        }
      }
      if (versionList.isEmpty) {
        mLoadStatus.value = LoadStatusX.empty;
        update();
        return;
      }
      model.PageResp<VersionMes> pageResp =
          model.PageResp(versionList.length, versionList.length, versionList);
      state.dataList.add(pageResp);
      mLoadStatus.value = LoadStatusX.success;
      update();
    } else {
      mLoadStatus.value = LoadStatusX.error;
      update();
    }
  }

  @override
  void search(String value) {}
}

class VersionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VersionController());
  }
}

class UpdateController extends GetxController {
  Future<Map<String, dynamic>?> apkDetail() async {
    var key = "apkFile";
    var domain = "all";
    //TODO:如何用objectGet替换anystore的get，方法头返回值的问号和return null要去掉.
    // model.ResultType resp = await kernel.anystore.get(key, domain);

    // return resp.data["apk"];
    return null;
  }

  Future<VersionEntity?> versionList() async {
    var key = "version";
    var domain = "all";
    //TODO:如何用objectGet替换anystore的get
    // model.ResultType resp = await kernel.anystore.get(key, domain);
    // if (resp.success) {
    //   return VersionEntity.fromJson(resp.data);
    // }
    return null;
  }
}

class UpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateController());
  }
}
