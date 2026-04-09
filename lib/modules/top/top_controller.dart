import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:untitled/base/base_controller.dart';
import '../../models/product.dart';
import '../../provider/main_provider.dart';

class TopController extends BaseController {
  final name = 'Hoang Anh';
  RxInt productCount = 10.obs;
  final RxList<Product> sales = [
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm A',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
  ].obs;
  final RxList<Product> news = [
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm A',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
    Product(
        imageUrl: 'https://via.placeholder.com/150',
        name: 'Sản phẩm B',
        prace: '10.00'),
  ].obs;

  MainProvider mainProvider = MainProvider();
}
