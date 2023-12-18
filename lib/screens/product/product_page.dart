import 'dart:convert';

import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toast/toast.dart';

import '../auth/welcome_back_page.dart';
import '../shop/check_out_page.dart';
import 'components/product_display.dart';
import 'view_product_page.dart';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final Product product;



  ProductPage({required this.product});

  @override
  _ProductPageState createState() => _ProductPageState(product);
}

class _ProductPageState extends State<ProductPage> {
  final Product product;

  _ProductPageState(this.product);
  var color_stock;

  var sessionManager = SessionManager();

  void getSessionLogin() async {
    var isLoggedIn = await sessionManager.get("isLoggedIn");



    if (isLoggedIn == null){
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => WelcomeBackPage()));
    }
  }



  @override
  Future<void> addToCart() async {

    var id_user = await sessionManager.get("id");

    final response = await http.post(
      Uri.parse(global.appUrl+"/add_cart.php"),
      body: {
        'id_produk' : product.id,
        'id_pembeli' : id_user.toString()
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 201) {
      showToast("Tambah ke cart berhasil", gravity: Toast.bottom);

      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CheckOutPage()));

    } else if(response.statusCode == 401) {
      return showToast(result['message'], gravity: Toast.bottom);
    }else{
      return showToast("Proses Gagal, Periksa Koneksi !", gravity: Toast.bottom);
    }
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    ToastContext().init(context);
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    getSessionLogin();

    color_stock = (int.parse(product.stock) > 0)? const TextStyle(
        color: const Color(0xFFFEFEFE),
        fontWeight: FontWeight.w600,
        fontSize: 20.0) : const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w600,
        fontSize: 20.0);

    Widget viewProductButton = InkWell(
      onTap: () async {
        await addToCart();
      },
      child: Container(
        height: 80,
        width: width / 1.5,
        decoration: BoxDecoration(
            gradient: mainButton,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                offset: Offset(0, 5),
                blurRadius: 10.0,
              )
            ],
            borderRadius: BorderRadius.circular(9.0)),
        child: Center(
          child: Text("Tambah Ke Cart",
              style: const TextStyle(
                  color: const Color(0xfffefefe),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0)),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: yellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: darkGrey),
        actions: <Widget>[
          IconButton(
            icon: new SvgPicture.asset(
              'assets/icons/search_icon.svg',
              fit: BoxFit.scaleDown,
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SearchPage())),
          )
        ],
        title: Text(
          '',
          style: const TextStyle(
              color: darkGrey, fontWeight: FontWeight.w500, fontSize: 18.0),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                ProductDisplay(
                  product: product,
                ),
                SizedBox(
                  height: 0.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 16.0),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                        color: const Color(0xFFFEFEFE),
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 17),
                  child: Text("Stok : "+product.stock,
                    style: color_stock,
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 90,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(253, 192, 84, 1),
                          borderRadius: BorderRadius.circular(4.0),
                          border:
                              Border.all(color: Color(0xFFFFFFFF), width: 0.5),
                        ),
                        child: Center(
                          child: new Text("Detail",
                              style: const TextStyle(
                                  color: const Color(0xeefefefe),
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12.0)),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                    padding:
                        EdgeInsets.only(left: 20.0, right: 40.0, bottom: 130),
                    child: new Text(product.description,
                        style: const TextStyle(
                            color: const Color(0xfefefefe),
                            fontWeight: FontWeight.w800,
                            fontFamily: "NunitoSans",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0)))
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                  top: 8.0, bottom: bottomPadding != 20 ? 20 : bottomPadding),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Color.fromRGBO(255, 255, 255, 0),
                    Color.fromRGBO(253, 192, 84, 0.5),
                    Color.fromRGBO(253, 192, 84, 1),
                  ],
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter)),
              width: width,
              height: 120,
              child: Center(child: viewProductButton),
            ),
          ),
        ],
      ),
    );
  }
}
