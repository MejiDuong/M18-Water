import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';

class CartIcon extends StatelessWidget {
  final int itemCount;

  const CartIcon({Key? key, required this.itemCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              'assets/vectors/ic_cart.svg',
              fit: BoxFit.contain,
            ),
          ),
          if (itemCount > 0)
            Positioned(
              top: -12,
              right: -10,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
