/**
 * @author: jiangjunhui
 * @date: 2025/5/21
 */
import 'package:flutter/material.dart';
import 'package:my_flutter_demo/provider_demo/page/goods_collection_page.dart';
import 'package:my_flutter_demo/provider_demo/viewmodels/auth_model.dart';
import 'package:my_flutter_demo/provider_demo/page/first_provider_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 注册全局共享的状态（如用户认证、主题）
        ChangeNotifierProvider(create: (_) => AuthModel()),
        // 可添加多个Provider
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  List<String> getData() {
    List<String> data = [
      "测试一级界面",
      "列表实现"
    ];
    return data;
  }

  void _navigateToPage1(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstProviderPage()),
    );
  }

  void _navigateToPage2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoodsCollectionPage()),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async {
        if(index == 0) {
          _navigateToPage1(context);
        } else if (index == 1) {
          _navigateToPage2(context);
        }
      },
      child: Container(
        child: Card(
          color: Colors.white,
          child: Center(
            child: Text(getData()[index],
                style: const TextStyle(color: Colors.black, fontSize: 18)),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Provider Demo')),
        body: Container(
          child: ListView.builder(
              itemExtent: 50.0, //强制高度为50.0
              itemCount: getData().length,
              itemBuilder: _itemBuilder),
        ),
      ),
    );
  }
}
 
 
 
 
 
 
 
 
