import 'dart:convert';

import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/main/main_page.dart';
import 'package:ecommerce_int2/screens/product/product_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class RecommendedList extends StatelessWidget {

  var category;

  RecommendedList({
    required this.category
  });

  @override
  Widget build(BuildContext context) {

    return ProductList(category:category);

  }

}

class ProductList extends StatefulWidget {
  var category;

  ProductList({
    required this.category
  });

  @override
  _ProductListState createState() => _ProductListState(category:category);
}

class _ProductListState extends State<ProductList> {

  var category;

  _ProductListState({
    required this.category
  });

  var isLoadingData = false;

  List<Product> products = [];

  @override
  Future<void> getProduct() async {

    isLoadingData = true;
    products.clear();


    final response = await http.post(
      Uri.parse(global.appUrl+"/produk.php"),
      body: {
        'kategori' : category,
        'param' : 'getByKategori'
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body.toString());

    // print(result);

    if (response.statusCode == 201) {
      result['data'].forEach((element) {
        // print(element);
        products.add(Product(element['gambar'], element['nama'], element['keterangan'], element['harga'], element['stok'], element['id_produk']));
      });
      isLoadingData = false;

    }

  }

  @override
  void initState(){
    super.initState();
    // getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration.zero, () => getProduct()),
        builder: (context, snapshot) {

          if(isLoadingData){
            return DefaultTextStyle(
              style: Theme.of(context).textTheme.displayMedium!,
              textAlign: TextAlign.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CircularProgressIndicator(
                      semanticsLabel: 'Circular progress indicator',
                    ),
                  ]
              ),
            );
          };

          return Column(
            children: <Widget>[
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                  child: MasonryGridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    crossAxisCount: 4,
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) => new ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProductPage(product: products[index]))),
                        child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                  colors: [
                                    Colors.grey.withOpacity(0.3),
                                    Colors.grey.withOpacity(0.7),
                                  ],
                                  center: Alignment(0, 0),
                                  radius: 0.6,
                                  focal: Alignment(0, 0),
                                  focalRadius: 0.1),
                            ),
                            child: Hero(
                                tag: "img"+products[index].id,
                                child: Image.network(products[index].image))),
                      ),
                    ),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                ),
              ),
            ],
          );
        });
  }

}