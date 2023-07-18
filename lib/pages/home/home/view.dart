import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/controller/setting/user_controller.dart';
import 'package:orginone/dart/core/getx/base_get_view.dart';
import 'package:orginone/main.dart';
import 'package:orginone/pages/chat/message_chats/message_chats_page.dart';
import 'package:orginone/pages/home/components/user_bar.dart';
import 'package:orginone/pages/home/index/view.dart';
import 'package:orginone/pages/setting/view.dart';
import 'package:orginone/pages/store/view.dart';
import 'package:orginone/pages/work/view.dart';
import 'package:orginone/util/toast_utils.dart';
import 'package:orginone/widget/badge_widget.dart';
import 'package:orginone/widget/gy_scaffold.dart';
import 'package:orginone/widget/keep_alive_widget.dart';
import 'package:orginone/widget/unified.dart';

import 'logic.dart';
import 'state.dart';

class HomePage extends BaseGetView<HomeController, HomeState> {
  @override
  Widget buildView() {
    return WillPopScope(
      onWillPop: () async {
        if (state.lastCloseApp == null ||
            DateTime.now().difference(state.lastCloseApp!) >
                const Duration(seconds: 1)) {
          state.lastCloseApp = DateTime.now();
          ToastUtils.showMsg(msg: '再按一次退出');
          return false;
        }
        return true;
      },
      child: GyScaffold(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          body: Column(
            children: [
              UserBar(),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: state.pageController,
                  children: [
                    KeepAliveWidget(child: MessageChats()),
                    KeepAliveWidget(child: WorkPage()),
                    KeepAliveWidget(child: IndexPage()),
                    KeepAliveWidget(child: StorePage()),
                    KeepAliveWidget(child: SettingPage()),
                  ],
                ),
              ),
              bottomButton(),
            ],
          )),
    );
  }

  Widget bottomButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          button(homeEnum: HomeEnum.chat, path: 'chat', unPath: 'unchat'),
          button(homeEnum: HomeEnum.work, path: 'work', unPath: 'unwork'),
          button(homeEnum: HomeEnum.door, path: 'home', unPath: 'unhome'),
          button(homeEnum: HomeEnum.store, path: 'store', unPath: 'unstore'),
          button(
              homeEnum: HomeEnum.setting, path: 'setting', unPath: 'unsetting'),
        ],
      ),
    );
  }

  Widget button({
    required HomeEnum homeEnum,
    required String path,
    required String unPath,
  }) {
    return Expanded(
      child: Obx(() {
        var isSelected = settingCtrl.homeEnum.value == homeEnum;
        var mgsCount = 0;
        if (homeEnum == HomeEnum.work) {
          mgsCount = settingCtrl.provider.work?.todos.length ?? 0;
        } else if (homeEnum == HomeEnum.chat) {
          var chats = settingCtrl.provider.chat?.allChats;
          chats?.forEach((element) {
            mgsCount += element.chatdata.value.noReadCount;
          });
        }
        return GestureDetector(
          onTap: () {
            state.pageController.jumpToPage(homeEnum.index);
            settingCtrl.setHomeEnum(homeEnum);
          },
          behavior: HitTestBehavior.translucent,
          child: Align(
            alignment: Alignment.center,
            child: BadgeTabWidget(
              imgPath: !isSelected ? unPath : path,
              body: Text(homeEnum.label,
                  style: isSelected ? selectedStyle : unSelectedStyle),
              mgsCount: mgsCount,
            ),
          ),
        );
      }),
    );
  }

  TextStyle get unSelectedStyle =>
      TextStyle(color: XColors.black3, fontSize: 16.sp);

  TextStyle get selectedStyle =>
      TextStyle(color: XColors.selectedColor, fontSize: 16.sp);
}
