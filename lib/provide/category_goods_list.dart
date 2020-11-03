import 'package:flutter/material.dart';
import '../model/categoryGoodsList.dart';

class CategoryGoodsListProvide with ChangeNotifier{
  List<CategoryListData> goodsList = [];

  getGoodsList(List<CategoryListData> list){
   goodsList = list;
//   goodsList.addAll(list);
   notifyListeners();
  }

  getMoreList(List<CategoryListData> list){
//   goodsList = list;
    goodsList.addAll(list);
    notifyListeners();
  }

}