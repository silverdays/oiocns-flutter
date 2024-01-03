import 'package:get/get.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/getx/base_get_state.dart';
import 'package:orginone/pages/relation/home/state.dart';

class AttributeInfoState extends BaseGetState {
  late RelationNavModel data;

  var propertys = <XProperty>[].obs;

  AttributeInfoState() {
    data = Get.arguments['data'];
  }
}
