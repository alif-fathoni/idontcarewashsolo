import 'dart:convert';

import 'package:ecommerce_int2/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'category_card.dart';
import 'recommended_list.dart';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

var sessionManager = SessionManager();
class TabView extends StatelessWidget {

  List<String> category = <String>[];
  List<String> product = <String>[];

  final TabController tabController;

  TabView({
    required this.tabController,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> categories = <Widget>[];
    category.forEach((element) => categories.add(
        Column(children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Flexible(child:  RecommendedList(category:element))
        ])
    ));
    //
    // print(categories);

    // print(MediaQuery.of(context).size.height / 9);
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: categories,
    );
  }
}
