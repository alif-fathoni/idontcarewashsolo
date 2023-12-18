import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/address/add_address_page.dart';
import 'package:ecommerce_int2/screens/payment/unpaid_page.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import '../auth/welcome_back_page.dart';
import 'components/credit_card.dart';
import 'components/shop_item_list.dart';

class CheckOutPage extends StatefulWidget {
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  SwiperController swiperController = SwiperController();

  var sessionManager = SessionManager();

  List<Product> products = [];

  var isLoadingData = false;

  Future<void> getProduct() async {

    isLoadingData = true;
    products.clear();

    var id_user = await sessionManager.get("id");

    final response = await http.post(
      Uri.parse(global.appUrl+"/cart.php"),
      body: {
        'id_pembeli' : id_user.toString()
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );

    print(id_user);


    var result = jsonDecode(response.body.toString());


    if (response.statusCode == 201) {
      result['data'].forEach((element) {
        // print(element['stok']);
        products.add(Product(element['gambar'], element['nama'], element['keterangan'], element['harga'], element['stok'], element['id_produk']));
      });
    }

    isLoadingData = false;

  }

  void getSessionLogin() async {
    var isLoggedIn = await sessionManager.get("isLoggedIn");



    if (isLoggedIn == null){
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => WelcomeBackPage()));
    }
  }

  @override
  void initState(){
    super.initState();
    getSessionLogin();
    // getProduct();
  }

  @override
  Widget build(BuildContext context) {
    Widget checkOutButton = InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => AddAddressPage())),
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width / 1.5,
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
          child: Text("Check Out",
              style: const TextStyle(
                  color: const Color(0xfffefefe),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0)),
        ),
      ),
    );

    return FutureBuilder(
        future: Future.delayed(Duration.zero, () => getProduct()),
        builder: (context, snapshot) {
          if (isLoadingData) {
            return DefaultTextStyle(
              style: Theme
                  .of(context)
                  .textTheme
                  .displayMedium!,
              textAlign: TextAlign.center,
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            );
          };

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              iconTheme: IconThemeData(color: darkGrey),
              actions: <Widget>[
                IconButton(
                  icon: Image.asset('assets/icons/denied_wallet.png'),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => UnpaidPage())),
                )
              ],
              title: Text(
                'Checkout',
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w500, fontSize: 18.0),
              ),
            ),
            body: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        height: 48.0,
                        color: yellow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              products.length.toString() + ' items',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 500,
                        child: Scrollbar(
                          child: ListView.builder(
                            itemBuilder: (_, index) => ShopItemList(
                              products[index],
                              onRemove: () {
                                setState(() {
                                  products.remove(products[index]);
                                });
                              },
                            ),
                            itemCount: products.length,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom == 0
                                    ? 20
                                    : MediaQuery.of(context).padding.bottom),
                            child: checkOutButton,
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );

        }
    );


  }
}

class Scroll extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    LinearGradient grT = LinearGradient(
        colors: [Colors.transparent, Colors.black26],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
    LinearGradient grB = LinearGradient(
        colors: [Colors.transparent, Colors.black26],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);

    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, 30),
        Paint()
          ..shader = grT.createShader(Rect.fromLTRB(0, 0, size.width, 30)));

    canvas.drawRect(Rect.fromLTRB(0, 30, size.width, size.height - 40),
        Paint()..color = Color.fromRGBO(50, 50, 50, 0.4));

    canvas.drawRect(
        Rect.fromLTRB(0, size.height - 40, size.width, size.height),
        Paint()
          ..shader = grB.createShader(
              Rect.fromLTRB(0, size.height - 40, size.width, size.height)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
