import 'package:flutter/material.dart';

class CurrentIndexProvide with ChangeNotifier{
    int currenIndex = 0;

    changeIndex(int newIndex){
      currenIndex = newIndex;
      notifyListeners();
    }

}