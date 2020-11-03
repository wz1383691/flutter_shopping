import 'package:flutter/material.dart';
import 'package:flutter_shop/service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../routers/application.dart';

class HomePage extends StatefulWidget{
  _HomePageState createState()=> _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{

  int page = 1;
  List<Map> hotGoodsList = [];

  GlobalKey<RefreshFooterState> _footerkey = new GlobalKey<RefreshFooterState>();

  @override
  bool get wantKeepAlive => true;

  String homePageContent = '正在获取数据';
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('百姓生活+')),
      body: FutureBuilder(
        future: request('Content'),
        builder: (context,snapshot){
          if(snapshot.hasData){
            var data = json.decode(snapshot.data.toString());
            List<Map> swiper = (data['data']['slides'] as List).cast();
            print("swiperid:${swiper}");
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage = data['data']['shopInfo']['leaderImage'];
            String leaderPhone = data['data']['shopInfo']['leaderPhone'];
            List<Map> recommendList = (data['data']['recommend'] as List).cast();
            String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
            String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
            String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
            List<Map> floor1 = (data['data']['floor1'] as List).cast();
            List<Map> floor2 = (data['data']['floor2'] as List).cast();
            List<Map> floor3 = (data['data']['floor3'] as List).cast();

            return EasyRefresh(
                refreshFooter: ClassicsFooter(
                  key: _footerkey,
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                  moreInfoColor: Colors.pink,
                  showMore: true,
                  noMoreText: '',
                  moreInfo: '加载中',
                  loadReadyText: '上拉加载....',
                ),
                child: ListView(
                  children: <Widget>[
                    SwiperDiy(swiperDateList: swiper),
                    TopNavigator(navigatorList: navigatorList),
                    AdBanner(adPicture: adPicture),
                    LeaderPhone(leaderImage: leaderImage,leaderPhone: leaderPhone),
                    Recommed(recommendList: recommendList),
                    FloorTitle(picture_address: floor1Title),
                    FloorContent(floorGoodsList: floor1),
                    FloorTitle(picture_address: floor2Title),
                    FloorContent(floorGoodsList: floor2),
                    FloorTitle(picture_address: floor3Title),
                    FloorContent(floorGoodsList: floor3),
                    _hotGoods(),
                  ],
                ),
              loadMore: ()async{
                  print('开始加载更多');
                await request('Below', formData: page).then((val){
                  var data = json.decode(val.toString());
                  List<Map> newGoodsList = (data['data'] as List).cast();
                  setState(() {
                    hotGoodsList.addAll(newGoodsList);
                    page++;
                  });
                });
              }
            );

          }else{
            return Center(
              child: Text('加载中'),
            );
          }
        },
      )
    );
  }


  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    alignment: Alignment.center,
    color: Colors.transparent,
    child: Text('火爆专区'),
  );

  Widget _wrapList(){
   if(hotGoodsList.length!=0){
     List<Widget> listWidget = hotGoodsList.map((val){
       return InkWell(
         onTap: (){
           Application.router.navigateTo(context, "/detail?id=${val['goodsId']}");

         },
         child: Container(
           width: ScreenUtil().setWidth(372),
           color: Colors.white,
           padding: EdgeInsets.all(5.0),
           margin: EdgeInsets.only(bottom: 3.0),
           child: Column(
             children: <Widget>[
               Image.network(val['image'],width: ScreenUtil().setWidth(370),),
               Text(
                 val['name'],
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
                 style: TextStyle(color: Colors.pink,fontSize: ScreenUtil().setSp(26)),
               ),
               Row(
                 children: <Widget>[
                   Text('#${val['mallPrice']}'),
                   Text(
                     '#${val['price']}',
                     style: TextStyle(color: Colors.black26,decoration: TextDecoration.lineThrough),
                   ),
                 ],
               ),
             ],
           ),
         ),
       );
     }).toList();

     return Wrap(
       spacing: 2,
       children: listWidget,
     );
   }else{
     return Text('');
   }
  }

  Widget _hotGoods(){
   return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList(),

        ],
      ),
   );
  }


}

//首页轮播组件
class SwiperDiy extends StatelessWidget{
  final List swiperDateList;
  SwiperDiy({this.swiperDateList});

  @override
  Widget build(BuildContext context){

   return Container(
     height: ScreenUtil().setHeight(333),
     width: ScreenUtil().width,
     child: Swiper(
       itemBuilder: (BuildContext context,int index){
         return InkWell(
           onTap: (){
             print("单个的数据:${swiperDateList[index]}");
            Application.router.navigateTo(context, "/detail?id=${swiperDateList[index]['goodsId']}");
           },
           child: Image.network("${swiperDateList[index]['image']}",fit: BoxFit.fill),
         );

       },
        itemCount: swiperDateList.length ,
        pagination: SwiperPagination() ,
       autoplay: true,

     ),
   ) ;
  }
}

//中部分类
class TopNavigator extends StatelessWidget{
  final List navigatorList;

  TopNavigator({Key key,this.navigatorList}) : super(key:key);

  Widget _gridViewItemUI(BuildContext context,item){

    return InkWell(
      onTap:(){print('点击了导航');} ,
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width: ScreenUtil().setWidth(95),),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(navigatorList.length>10){
        navigatorList.removeRange(10, navigatorList.length);
    }
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          padding: EdgeInsets.all(5.0),
          children: navigatorList.map((item){
            return _gridViewItemUI(context,item);
          }).toList(),
      ),
    );
  }

}

//广告banner
class AdBanner extends StatelessWidget{
  final String adPicture;

  AdBanner({Key key ,this.adPicture}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Image.network(adPicture),
    );
  }
}

//店长电话模块
class LeaderPhone extends StatelessWidget{
  final String leaderImage;
  final String leaderPhone;

  LeaderPhone({Key key ,this.leaderImage,this.leaderPhone}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
//    String url = 'tel:' +leaderPhone;
    String url = 'http://baidu.com';
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'url不能进行访问，异常';
    }
  }
}

//商品推荐
class Recommed extends StatelessWidget{

  final List recommendList;
  Recommed({Key key ,this.recommendList}) : super(key:key);

  Widget _titleWidget(){
    return Expanded(
        child:Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: 1,color: Colors.black12),
              )
          ),
          child: Text(
            '商品推荐',
            style: TextStyle(color: Colors.pink),
          ),
        )
    );
  }

  //商品单独项方法
  Widget _item(context,index){
    return InkWell(
      onTap: (){
        Application.router.navigateTo(context, "/detail?id=${recommendList[index]['goodsId']}");
      },
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 0.5,color: Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('#${recommendList[index]['mallPrice']}'),
            Text('#${recommendList[index]['price']}',style: TextStyle(
                decoration: TextDecoration.lineThrough,
              color: Colors.grey
            ),
            ),
          ],
        ),
      ),
    );
  }

  //横向列表方法
  Widget _recommendList(){
    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context,index){
          return _item(context,index);
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(380),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
         children: <Widget>[
           _titleWidget(),
           _recommendList()
         ],
      ),
    );
  }


}

//楼层标题
class FloorTitle extends StatelessWidget{
  final String picture_address;
  FloorTitle({Key key ,this.picture_address}) : super(key:key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(picture_address),
    );
  }
}

//楼层商品列表
class FloorContent extends StatelessWidget{
  final List floorGoodsList;
  FloorContent({Key key ,this.floorGoodsList}) : super(key:key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: Column(
          children: <Widget>[
            _firstRow(context),
            _otherGoods(context)
          ],
        ),
    );
  }

  Widget _firstRow(BuildContext context){
    return Row(
      children: <Widget>[
        _goodsItem(context,floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(context,floorGoodsList[1]),
            _goodsItem(context,floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _otherGoods(BuildContext context){
    return Row(
      children: <Widget>[
        _goodsItem(context,floorGoodsList[3]),
        _goodsItem(context,floorGoodsList[4]),
      ],
    );
  }

  Widget _goodsItem(BuildContext context, Map goods){
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: (){
          Application.router.navigateTo(context, "/detail?id=${goods['goodsId']}");
          },
        child: Image.network(goods['image']),
      ),
    );
  }
}

//热销商品推荐
class HotGoods extends StatefulWidget{
  _HotGoodsState createState() => _HotGoodsState();
}



class _HotGoodsState extends State<HotGoods>{

  void initState(){
    super.initState();
    request('Below').then((val){
      print(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Text('test'),
    );
  }
}