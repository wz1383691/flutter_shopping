import 'package:flutter/material.dart';
import './pages/index_page.dart';
import 'package:provide/provide.dart';
import './provide/counter.dart';
import './provide/child_category.dart';
import './provide/category_goods_list.dart';
import './provide/details_info.dart';
import './provide/cart.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_shop/routers/routers.dart';
import 'package:flutter_shop/routers/application.dart';
import './provide/currentIndex.dart';


void main(){
  var counter = Counter();
  var childCategory = ChildCategory();
  var providers = Providers();
  var categoryGoodsListProvide = CategoryGoodsListProvide();
  var detailInfoProvide = DetailsInfoProvide();
  var cartProvide = CartProvide();
  var currenIndexProvide = CurrentIndexProvide();

  providers
    ..provide(Provider<Counter>.value(counter))
    ..provide(Provider<ChildCategory>.value(childCategory))
    ..provide(Provider<CategoryGoodsListProvide>.value(categoryGoodsListProvide))
    ..provide(Provider<DetailsInfoProvide>.value(detailInfoProvide))
    ..provide(Provider<CartProvide>.value(cartProvide))
    ..provide(Provider<CurrentIndexProvide>.value(currenIndexProvide));
  runApp(ProviderNode(child: MyApp(), providers: providers));

  final router = Router();

}

class MyApp extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
      final router = Router();
      Routes.configureRoutes(router);
      Application.router = router;
    // TODO: implement build
    return Container(
      child: MaterialApp(
        title:'百姓生活+',
        onGenerateRoute: Application.router.generator,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.pink
        ),
        home: IndexPage()
      ),

    );
  }
}