
import 'package:get/get.dart';

class CircleController extends GetxController {
  var selectedName = "OULTA".obs;

  void selectCircle(String name) {
    selectedName.value = name;
  }
}
