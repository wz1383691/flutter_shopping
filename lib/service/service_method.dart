import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/service_url.dart';


//网络接口通用方法
Future request(url,{formData}) async{
  try {

    Response response;
    Dio dio = new Dio();
    dio.options.contentType = 'application/x-www-form-urlencoded';

    if(url == 'Content'){
      response = await dio.get('http://baixingliangfan.cn/baixing/bxAppIndex/getHomePageContent?lon=115.075234375&lat=35.776455078125');
    }else if(url == 'Below'){
      String url =  'http://baixingliangfan.cn/baixing/bxAppIndex/getHomePageBelowConten?page=${formData}';
      print('hot数据=======${url}======');
      response = await dio.get(url);
    }else if(url == 'Category'){
      response = await dio.get('http://baixingliangfan.cn/baixing/bxAppIndex/getCategory');
    }else if(url == 'MallGoods'){
//      response = await dio.get('http://baixingliangfan.cn/baixing/bxAppIndex/getMallGoods?categoryId=2c9f6c946cd22d7b016cd732f0f6002f&categorySubId=&page=1');
      response = await dio.get('http://baixingliangfan.cn/baixing/bxAppIndex/getMallGoods',queryParameters: formData);
    }else if(url == 'GoodDetail'){
      response = await dio.get('http://baixingliangfan.cn/baixing/bxAppIndex/getGoodDetailById',queryParameters: formData);
    }


    if(response.statusCode == 200){
      return response.data;
    }else{
      throw Exception('后端接口出现异常');
    }

  }catch(e){
    return print('ERROR:=======${e}');
  }


}
