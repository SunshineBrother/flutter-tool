/// @author: jiangjunhui
/// @date: 2024/12/30
library;
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_appBar_widget.dart';
class kkTest2RouterPage extends StatefulWidget {
  final Map<String, dynamic>? queryParam;
  const kkTest2RouterPage({super.key, required this.queryParam});
  @override
  State<kkTest2RouterPage> createState() => _kkTest2RouterPageState();
}

class _kkTest2RouterPageState extends State<kkTest2RouterPage> {
  String _queryParam = "";
  void getParam() {
    String text = widget.queryParam.toString();
    setState(() {
      _queryParam =
      "上级界面传入参数：$text";
    });
  }

  @override
  void initState() {
    super.initState();
    print("===========================");
    getParam();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title: '第二个页面',
        actions: const [],
        onBackPressed: () {
          // Handle back button press, if needed
          Navigator.pop(context,"我是第二个页面返回的字符串");
        },
      ),
      body: SizedBox(
        height: 400,
        child: Text(_queryParam),
      ),
    );
  }
}
