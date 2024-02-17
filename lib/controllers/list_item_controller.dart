import 'package:get/get.dart';
import 'package:together_assignment/models/list_item_model.dart';

class ListItemController extends GetxController {
  final RxInt pageNum = 1.obs;
  RxList<Data> list = RxList<Data>();
  final RxBool isLoading = false.obs;
}
