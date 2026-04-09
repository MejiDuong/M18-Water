import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:untitled/base/base_scaffold.dart';
import 'package:untitled/modules/product/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

class ProductScene extends GetView<ProductController> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        body: SafeArea(
            child: Column(
              children: [],)
        )
    );
  }

}