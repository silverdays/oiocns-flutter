import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/base/model.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/controller/setting/setting_controller.dart';
import 'package:orginone/dart/core/enum.dart';
import 'package:orginone/dart/core/getx/base_controller.dart';
import 'package:orginone/pages/work/network.dart';
import 'package:orginone/widget/loading_dialog.dart';
import 'package:orginone/model/thing_model.dart' as thing;
import 'state.dart';

class ProcessDetailsController extends BaseController<ProcessDetailsState> with GetTickerProviderStateMixin{
  final ProcessDetailsState state = ProcessDetailsState();

  ProcessDetailsController(){
    state.tabController = TabController(length: tabTitle.length, vsync: this);
  }

  SettingController get controller => Get.find();

  SettingController get setting => Get.find<SettingController>();
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
    List<XForm> forms = node?.forms??[];
    state.workForm.value =
        forms.firstWhere((element) => element.typeName == SpeciesType.work.label);
    state.thingForm.value =
        forms.where((element) => element.typeName == SpeciesType.thing.label).toList();
    if(state.workForm.value!=null){
      var iForm = forms
          .firstWhere((element) => state.workForm.value!.id == element.id);
      state.workForm.value!.attributes = await setting.provider.work!
          .loadAttributes(iForm.id, state.define!.workItem.belongId);
      for (var element in state.workForm.value!.attributes??[]) {
        element.value = data['forms']?['headerData']?[element.id]??'';
      }
    }

    for (var form in state.thingForm) {
      try {
        var iForm = forms.firstWhere((element) => form.id == element.id);
        form.attributes = await setting.provider.work!
            .loadAttributes(iForm.id, state.define!.workItem.belongId);

        if(data['forms']?['formData']?[form.id]!=null){
          Map<String,dynamic> resourceData = jsonDecode(data['forms']?['formData']?[form.id]['resourceData']);
          if(resourceData['data']!=null){
            resourceData['data'].forEach((json){
              form.things.add(thing.ThingModel.fromJson(json));
            });
          }
        }

      } catch (e) {

      }
    }
    state.subTabController = TabController(length: state.thingForm.length, vsync: this);
    state.workForm.refresh();
    state.thingForm.refresh();
  }


}
