import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_shop/service/service_method.dart';
import 'dart:convert';//json解析
import '../model/category.dart';
import '../model/categoryGoodsList.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routers/application.dart';

class CategoryPage extends StatefulWidget{
  _CategoryPageState createState() => _CategoryPageState();

}


class _CategoryPageState extends State<CategoryPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('商品分类'),),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[
                RightCategoryNav(),
                CategoryGoodsList(),
              ],
            )
          ],
        ),
      ),
    );
  }

}

//左侧大类导航
class LeftCategoryNav extends StatefulWidget{
  _LeftCategoryNavState createState()=> _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav>{
  List list = [];
  var listIndex = 0;
  @override
  void initState() {
    _getCategory();
    _getGoodsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1,color: Colors.black12)
        )
      ),
      child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (content,index){
            return _leftInkWell(index);
          },
      ),
    );
  }

  // 相当与cell
  Widget _leftInkWell(int index){
    bool isClick = false;
    isClick = index == listIndex;
    return InkWell(
      onTap: (){
        setState(() {
          listIndex = index;
        });
        var childList = list[index].bxMallSubDto;
        var categoryId = list[index].mallCategoryId;
        Provide.value<ChildCategory>(context).getChildCategory(childList,categoryId);
        _getGoodsList(categoryId: categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10,top: 20),
        decoration: BoxDecoration(
          color: isClick? Color.fromRGBO(236, 236, 236, 1) : Colors.white,
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        child: Text(list[index].mallCategoryName,style: TextStyle(fontSize: ScreenUtil().setSp(28)),),
      ),
    );
  }

  void _getCategory() async{
    await request('Category').then((val){
      var data = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
      });
//      list.data.forEach((item)=>print(item.mallCategoryName));
    Provide.value<ChildCategory>(context).getChildCategory(list[0].bxMallSubDto,list[0].mallCategoryId);
    });
  }
      //可选参数
  void _getGoodsList({String categoryId}) async{
    var data = {
      'categoryId':categoryId==null?'4':categoryId,
      'categorySubId':"",
      'page':1
    };

    await request('MallGoods',formData: data).then((val){
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
    });
  }
}

class RightCategoryNav extends StatefulWidget {
  @override
  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {

  List list = ['全部','名酒','宝丰','北京二锅头','舍得','五粮液','茅台','散白'];

  @override
  Widget build(BuildContext context) {
    return Provide<ChildCategory>(
        builder: (context,child,childCategory){
          return Container(
            height: ScreenUtil().setHeight(80),
            width:ScreenUtil().setWidth(570),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 1,color: Colors.black12),
                )
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              itemBuilder: (context,index){
                return _rightInkWell(index,childCategory.childCategoryList[index]);
              },
            ),
          );
        },
    );
  }

  Widget _rightInkWell(int index,BxMallSubDto item){
    bool isClick = false;
    isClick = index == Provide.value<ChildCategory>(context).childIndex;
    return InkWell(
      onTap: (){
        Provide.value<ChildCategory>(context).changeChildIndex(index,item.mallSubId);
        _getGoodsList(item.mallSubId);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Text(
            item.mallSubName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28),color: isClick?Colors.pink:Colors.black),
        ),
      ),
    );
  }

  //可选参数
  void _getGoodsList(String categorySubId) async{
    var data = {
      'categoryId':Provide.value<ChildCategory>(context).categoryId,
      'categorySubId':categorySubId,
      'page':1
    };

    await request('MallGoods',formData: data).then((val){
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if(goodsList.data == null){
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList([]);
      }else{
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
      }
    });
  }
}

//商品列表
class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  GlobalKey<RefreshFooterState> _footerkey = new GlobalKey<RefreshFooterState>();
  var scrollController = new ScrollController();


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provide<CategoryGoodsListProvide>(
      builder: (context,child,data){
        try{
          if(Provide.value<ChildCategory>(context).page == 1){
            //列表位置，放在最上边
            scrollController.jumpTo(0.0);
          }
        }catch(e){
          print('进入页面第一次初始化${e}');
        }

        if(data.goodsList.length>0){
          return  Expanded(
              child: Container(
                width: ScreenUtil().setWidth(570),
                child: EasyRefresh(
                  refreshFooter: ClassicsFooter(
                  key: _footerkey,
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                  moreInfoColor: Colors.pink,
                  showMore: true,
                  noMoreText: Provide.value<ChildCategory>(context).noMoreText,
                  moreInfo: '加载中',
                  loadReadyText: '上拉加载....',
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: data.goodsList.length,
                  itemBuilder: (context,index){
                    return _ListWidget(data.goodsList,index);
                  },
                ),
                   loadMore: () async{
                    print('上拉加载更多');
                    _getMoreList();
                  },
                )
              )
          );
        }else{
          return Text('暂时没有数据');
        }
      },
    );

  }

  //可选参数
  void _getMoreList() async{
    Provide.value<ChildCategory>(context).addPage();
    var data = {
      'categoryId':Provide.value<ChildCategory>(context).categoryId,
      'categorySubId':Provide.value<ChildCategory>(context).subId,
      'page':Provide.value<ChildCategory>(context).page
    };

    await request('MallGoods',formData: data).then((val){
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if(goodsList.data == null){
        Fluttertoast.showToast(
            msg: '已经到底了',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0
        );
        Provide.value<ChildCategory>(context).changeNoMore('没有更多');
      }else{
        Provide.value<CategoryGoodsListProvide>(context).getMoreList(goodsList.data);
      }
    });
  }

  Widget _goodsImage(List newList,int index){
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(newList[index].image),
    );
  }

  Widget _goodsName(List newList,int index){
    return Container(
      padding: EdgeInsets.all(5),
      width: ScreenUtil().setWidth(370),
      child: Text(
        newList[index].goodsName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: ScreenUtil().setSp(28)),
      ),
    );
  }

  Widget _goodsPrice(List newList,int index){
    return Container(
      margin: EdgeInsets.only(top: 30),
        width: ScreenUtil().setWidth(370),
      child: Row(
        children: <Widget>[
          Text('价格：#${newList[index].presentPrice}',
            style: TextStyle(color: Colors.pink,fontSize:ScreenUtil().setSp(30) ),
          ),
          Text('#${newList[index].oriPrice}',
            style: TextStyle(color: Colors.black26,decoration: TextDecoration.lineThrough),
          ),
        ],
      )
    );
  }

  Widget _ListWidget(List newList,int index){
    return InkWell(
      onTap: (){

        Application.router.navigateTo(context, "/detail?id=${newList[index]['goodsId']}");
      },
      child: Container(
        padding: EdgeInsets.only(top: 5,bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        child: Row(
          children: <Widget>[
            _goodsImage(newList,index),
            Column(
              children: <Widget>[
                _goodsName(newList,index),
                _goodsPrice(newList,index)
              ],
            )
          ],
        ),
      ),
    );

  }

}
