import 'dart:convert';

import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/custom_background.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/category/category_list_page.dart';
import 'package:ecommerce_int2/screens/notifications_page.dart';
import 'package:ecommerce_int2/screens/profile_page.dart';
import 'package:ecommerce_int2/screens/search_page.dart';
import 'package:ecommerce_int2/screens/shop/check_out_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_svg/svg.dart';
import '../auth/welcome_back_page.dart';
import 'components/custom_bottom_bar.dart';
import 'components/product_list.dart';
import 'components/tab_view.dart';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

var sessionManager = SessionManager();

class MainPage extends StatefulWidget {
  @override

  _MainPageState createState() => _MainPageState();
}


String selectedTimeline = '';



class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin<MainPage> {
  late TabController tabController;
  late TabController bottomTabController;
  var isLoadingData = false;
  List<Widget> categories = [];
  List<String> category = <String>[];
  List<Product> products = [];

  void getSessionLogin() async {
    var isLoggedIn = await sessionManager.get("isLoggedIn");

    if (isLoggedIn == null){
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => WelcomeBackPage()));
    }
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    ToastContext().init(context);
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  @override
  Future<void> getCategory() async {

    isLoadingData = true;
    category.clear();
    categories.clear();

    final response = await http.post(
      Uri.parse(global.appUrl+"/kategori.php"),
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body);

    if (response.statusCode == 201) {

      result['data'].forEach((element) {
        if(category.contains(element["nama_kategori"]) == false ){
          category.add(element["nama_kategori"]);
          categories.add(Tab(text: element["nama_kategori"]));
        }

      });

      tabController = TabController(length: categories.length, vsync: this);


      await getProduct();

      isLoadingData = false;

    } else if(response.statusCode == 401) {
      return showToast(result['message'], gravity: Toast.bottom);
    }else{
      return showToast("Login Gagal", gravity: Toast.bottom);
    }
  }

  @override
  Future<void> getProduct() async {

    isLoadingData = true;
    products.clear();

    final response = await http.post(
      Uri.parse(global.appUrl+"/produk.php"),
      body: {
        'param' : 'getHero'
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );


    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 201) {
      result['data'].forEach((element) {
        // print(element['stok']);
        products.add(Product(element['gambar'], element['nama'], element['keterangan'], element['harga'], element['stok'], element['id_produk']));
      });
    }

    isLoadingData = false;

  }

  @override
  void initState(){
    super.initState();
    getSessionLogin();
    getCategory();
    getProduct();

    // tabController = TabController(length: category.length, vsync: this);
    bottomTabController = TabController(length: 4, vsync: this);

  }



  @override
  Widget build(BuildContext context) {
    Widget appBar = Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => NotificationsPage())),
              icon: Icon(Icons.notifications)),
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SearchPage())),
              icon: SvgPicture.asset('assets/icons/search_icon.svg'))
        ],
      ),
    );


    return Scaffold(
      bottomNavigationBar: CustomBottomBar(controller: bottomTabController),
      body: CustomPaint(
        painter: MainBackground(),
        child:  FutureBuilder(
          future: Future.delayed(Duration.zero, () =>getCategory()),
          builder: (context, snapshot) {



              if(isLoadingData){
                return DefaultTextStyle(
                    style: Theme.of(context).textTheme.displayMedium!,
                    textAlign: TextAlign.center,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                  );
                };

               return TabBarView(
                  controller: bottomTabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    SafeArea(
                      child: NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          // These are the slivers that show up in the "outer" scroll view.
                          return <Widget>[
                            SliverToBoxAdapter(
                              child: appBar,
                            ),
                            SliverToBoxAdapter(
                              child: ProductList(
                                products: products,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: TabBar(
                                tabs: categories,
                                labelStyle: TextStyle(fontSize: 16.0),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 14.0,
                                ),
                                labelColor: darkGrey,
                                unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.5),
                                isScrollable: true,
                                controller: tabController,
                              ),
                            )
                          ];
                        },
                        body: TabView(
                          tabController: tabController,
                          category:category
                        ),
                      ),
                    ),
                    CategoryListPage(),
                    CheckOutPage(),
                    ProfilePage(),

                  ],
                );
          }
       ),
      ),
    );
  }
}
