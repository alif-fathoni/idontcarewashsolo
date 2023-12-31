import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:flutter/material.dart';

class ShopProduct extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const ShopProduct(
    this.product, {
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
          children: <Widget>[
            ShopProductDisplay(
              product,
              onPressed: onRemove,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkGrey,
                ),
              ),
            ),
            Text(
              '\Rp ${product.price}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkGrey, fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ],
        ));
  }
}

class ShopProductDisplay extends StatelessWidget {
  final Product product;
  final VoidCallback onPressed;

  const ShopProductDisplay(this.product, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 200,
      child: Stack(children: <Widget>[
        Positioned(
          left: 45,
          top: 15,
          child: SizedBox(
              height: 50,
              width: 50,
              child: Image.network(
                '${product.image}',
                fit: BoxFit.contain,
              )),
        ),
        Positioned(
          right:125,
          bottom: 42,
          child: Align(
            child: IconButton(
              icon: Image.asset('assets/red_clear.png'),
              onPressed: onPressed,
            ),
          ),
        )
      ]),
    );
  }
}
