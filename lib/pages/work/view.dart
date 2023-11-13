import 'package:flutter/material.dart';
import 'package:orginone/dart/core/getx/submenu_list/base_submenu_page_view.dart';
import 'package:orginone/components/widgets/keep_alive_widget.dart';

import 'logic.dart';
import 'state.dart';
import 'work_sub/view.dart';

class WorkPage extends BaseSubmenuPage<WorkController, WorkState> {
  const WorkPage({super.key});

  @override
  Widget buildPageView(String type) {
    return KeepAliveWidget(child: WorkSubPage(type));
  }
}
