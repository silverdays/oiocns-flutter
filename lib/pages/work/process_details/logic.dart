import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/controller/setting/setting_controller.dart';
import 'package:orginone/dart/core/getx/base_controller.dart';
import 'package:orginone/dart/core/thing/base/form.dart';
import 'package:orginone/pages/work/network.dart';
import 'package:orginone/util/toast_utils.dart';
import 'package:orginone/widget/loading_dialog.dart';

import 'state.dart';

class ProcessDetailsController extends BaseController<ProcessDetailsState> with GetTickerProviderStateMixin{
  final ProcessDetailsState state = ProcessDetailsState();

  ProcessDetailsController(){
    state.tabController = TabController(length: tabTitle.length, vsync: this);
  }

  SettingController get controller => Get.find();

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    LoadingDialog.showLoading(context);

    state.workInstance ??= await WorkNetWork.getFlowInstance(state.todo);
    state.define ??= await WorkNetWork.getFlowDefine(state.todo);
    await loadDataInfo();
    LoadingDialog.dismiss(context);
  }

  void showAllProcess() {
    state.hideProcess.value = false;
  }

  Future<void> loadDataInfo() async {

    if (state.workInstance == null) {
      return;
    }
    if (state.define == null) {
      return;
    }

    Map<String, dynamic> data = jsonDecode(state.workInstance!.data ?? "");
    if (data.isEmpty) {
      return;
    }

    WorkNodeModel? node = await state.define!.loadWorkNode();
    List<IForm> forms = await state.define!.workItem.loadForms();

    if(node?.forms!=null){
      var formIds = node?.forms?.map((i) => i.id).toList();
      for (var form in node?.forms??[]) {
        try{
          var iForm = forms.firstWhere((element) => formIds?.contains(element.metadata.id)??false);
          form.attributes = await iForm.loadAttributes();
          state.useForm.add(form);
        }catch(e){

        }
      }
    }


    for (var form in forms) {
      try{
        var item = node?.forms?.firstWhere((element) => element.id == form.metadata.id);
        if(item!=null){
          state.useForm.add(item);
        }
      }catch(e){

      }
    }
    for (var form in state.useForm) {
      // for (var item in form.items??[]) {
      //   data['formData'].forEach((key, value) {
      //     if(item.attrId == key){
      //       item.value = value;
      //     }
      //   });
      // }
    }
    state.useForm.refresh();
  }


}
