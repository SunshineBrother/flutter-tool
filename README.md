# 参考文章

- [flutter 流(Stream)介绍&结合RxDart使用](https://juejin.cn/post/7477921821285433384)
- [Flutter dio 手把手教你封装一个实用网络工具](https://juejin.cn/post/7475651131449819136)
- [Flutter 混合架构方案：多引擎](https://juejin.cn/post/7474995524337500212)
- [Flutter 一招教你解决json_annotation类型解析失败问题](https://juejin.cn/post/7472785299732496418)
- [Flutter go_router 路由管理详解&封装](https://juejin.cn/post/7472230420470759424)
- [Flutter中你需要知道的WidgetsFlutterBinding](https://juejin.cn/post/7472188108366643235)
- [一文教你更安全更简单的使用event_bus](https://juejin.cn/post/7468898013546512384)
- [Flutter 状态管理(Provider)](https://juejin.cn/post/6940814394234241038)







![Flutter跟原生混编架构](./Flutter_image.png)

# 业务层

业务层我采取的是借助**MVVM（Model-View-ViewModel）模式** ，定义抽象类`BaseViewModel`帮我统一管理`ViewModel`，定义抽象类`BaseWidgetPage`帮我统一管理`WidgetPage`的生命周期

**BaseViewModel**

- 1、**数据绑定**通过 `ChangeNotifier` + `Provider` 实现自动响应式更新
- 2、**状态管理**：内置标准状态机（loading/error/success），统一处理异步操作状态
- 3、**生命周期管理**：自动处理资源释放，避免内存泄漏
- 4、**错误处理中心化**：通过 `handleError` 统一捕获和处理异常

**BaseWidgetPage**

- 1、UI管理
  - 统一APPBar
  - AppBar 标题
  - pageID
  - buildBody：构建页面主体内容
- 2、声明周期管理
  - 1、onPageInit：可以被子类重写的初始化方法
  - 2、onPageDispose：可以被子类重写的资源释放方法
  - 3、onPageVisible：页面变为可见
  - 4、onPageHidden：页面变为隐藏
  - 5、didChangeAppLifecycleState：应用回到前台页面可见，应用进入后台页面隐藏

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core/baseWidget)



# 数据层

## Flutter跟原生通讯ChannelHandler

 **MyAppMethodChannelHandler统一 Channel 管理类**

`MyAppMethodChannelHandler`主要提供两个函数`setMethodCallHandler`和`callNativeMethod`

我还定义了一个`APPChannelModel` 类，这是一个数据模型类，用于封装从原生代码接收或发送到原生代码的数据。它包含三个属性：`code`、`message` 和 `data`，并提供了 `fromJson` 和 `toJson` 方法，用于 JSON 数据和 `APPChannelModel` 对象之间的转换。

### 使用案例

**flutter向原生传值,接收到返回值**

```
void _postData() async {
    APPChannelModel _model = APPChannelModel(code: "0", message: "传值成功",data: {"one":"1"});
    APPChannelModel? _resultModel =  await MyAppMethodChannelHandler.callNativeMethod(method: "post_data", model: _model);
    print("flutter向原生传值,接收到返回值:${_resultModel.toJson()}");
  }
```

**监听原生向flutter发送消息**

```
MyAppMethodChannelHandler.setMethodCallHandler(Router_Page_Method,
    (model, method) async {
  print(model.toString());
  print(method);
});
```

## 外观管理

**`ColorManager`：适配暗黑模式**

```
// 定义颜色模式枚举
enum ColorMode {
  light,
  dark,
}

// 颜色管理类
class ColorManager {}
```

**`TextSizeManager`不同屏幕文字大小适配**

```
class TextSizeManager {
  // 设计稿基准宽度，根据实际设计稿修改
  static const double baseWidth = 375;

  // 根据设备宽度计算适配后的文字大小
  static double getAdaptiveTextSize(BuildContext context, double originalSize) {
    // 获取当前设备的屏幕宽度
    double screenWidth = MediaQuery.of(context).size.width;
    // 计算缩放比例
    double scale = screenWidth / baseWidth;
    // 返回适配后的文字大小
    return originalSize * scale;
  }

  // 提供不同字号的获取方法
  static double getSmallTextSize(BuildContext context) {
    return getAdaptiveTextSize(context, 12);
  }

  static double getMediumTextSize(BuildContext context) {
    return getAdaptiveTextSize(context, 16);
  }

  static double getLargeTextSize(BuildContext context) {
    return getAdaptiveTextSize(context, 20);
  }
}
```

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/app/global/constants)



# 底座业务组件

## 1、基于dio的网络封装

**实现功能**

- 1、get、post请求
- 2、自定义RequestOptions
- 3、dio请求管理队列，用于统一管理请求
- 4、HttpClient链接管理，用于获取解析DNS时间、TCP连接开始时间、SSL握手开始时间（如果是HTTPS）、首包时间
- 5、json转model
- 6、缓存管理
- 7、日志管理拦截器
- 8、数据转换管理拦截器
- 9、loading拦截器
- 10、token续租拦截器
- 11、错误处理拦截器

 [参考文章：Flutter dio 手把手教你封装一个实用网络工具](https://juejin.cn/post/7475651131449819136)

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core/http)

## 2、基于cached_network_image图片缓存库

### 1、CachedImageWidget图片缓存widget

```
CachedImageWidget(imageUrl: _imageUrl, onSuccess: (image,iconUrl){
              print("图片下载成功：${image},=====${iconUrl}");
            },onError: (error,iconUrl){
              print("图片下载失败：${error},=====${iconUrl}");
            }),
```

### 2、MyCacheImageManager图片缓存管理

- 1、指定缓存目录，缓存有效期、最大缓存数量

  ```
  MyCustomCacheManager._()
        : super(Config(
            key,
            stalePeriod: const Duration(days: 30), // 缓存有效期
            maxNrOfCacheObjects: 100, // 最大缓存数量
            repo: JsonCacheInfoRepository(databaseName: key),
          ));
  ```

- 2、`getFilePath(String imageUrl)` 获取本地目录

  ```
  /// 获取图片本地路径
    static Future<String?> getFilePath(String imageUrl) async {
      final FileInfo? fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      return fileInfo?.file.path;
    }
  ```

- 3、`clearImageCache(String imageUrl)` 移除指定路径下图片

  ```
  /// 移除指定路径下图片
    static Future<void> clearImageCache(String imageUrl) async {
      // 移除单个文件的缓存
      try {
        await _cacheManager.removeFile(imageUrl);
        print(' 移除指定路径下图片已成功移除');
      } catch (e) {
        print(' 移除指定路径下图片缓存时出错: $e');
      }
    }
  ```

- 4、`clearAllCache()`  移除所有图片

  ```
  /// 移除所有图片
    static Future<void> clearAllCache() async {
      try {
        await _cacheManager.emptyCache();
        print('移除所有图片缓存已成功移除');
      } catch (e) {
        print('移除所有图片缓存时出错: $e');
      }
    }
  ```

- 5、`getCacheSize()`  获取缓存大小

  ```
  /// 获取缓存大小
    static Future<String> getCacheSize() async {
      int size = await _cacheManager.store.getCacheSize();
      double cacheSize = size / 1024 / 1024;
      return cacheSize.toStringAsFixed(2);
    }
  ```

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core/cacheImage)

## 3、ToastUtil

- 1、showToast：普通提示信息

  ```
  /// 提示信息
    static void showToast(
        {required String msg, int duration = 2000, bool dismissOnTap = false}) {
      EasyLoading.showToast(msg,
          duration: Duration(milliseconds: duration),
          toastPosition: EasyLoadingToastPosition.center,
          dismissOnTap: dismissOnTap);
    }
  ```

- 2、showLoading：loading加载框

  ```
  /// 加载框
    static void showLoading({String? msg, bool dismissOnTap = false}) {
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.ring
        ..loadingStyle = EasyLoadingStyle.dark
        ..radius = 5.0
        ..maskColor = Colors.white.withOpacity(0.1);
  
      EasyLoading.show(
          status: msg,
          maskType: EasyLoadingMaskType.custom,
          dismissOnTap: dismissOnTap);
    }
  ```

- 3、dismiss：隐藏loading

  ```
  /// 隐藏loading
    static void dismiss() {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss(animation: true);
      }
    }
  ```

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core/toast)



## 4、弹窗队列管理器

**弹窗类型枚举**

```
// 弹窗类型枚举
enum DialogType {
  center, // 中间弹窗
  bottom, // 底部弹窗
}
```

**弹窗队列实现**

```
// 添加弹窗到队列
  void add({
    required BuildContext context,
    required WidgetBuilder builder,
    DialogType type = DialogType.center,
    VoidCallback? onDismiss,
    Color? backgroundColor, // 底部弹窗专用参数
    ShapeBorder? shape, // 底部弹窗专用参数
  }) {
    _queue.add(DialogConfig(
      context: context,
      builder: builder,
      type: type,
      onDismiss: onDismiss,
      backgroundColor: backgroundColor,
      shape: shape,
    ));

    _checkNext();
  }
```

**使用案例**

```
void _showQueueDiaLog() {
    // // 在任意位置添加弹窗
    DialogQueue().add(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示1'),
        content: const Text('这是第一个弹窗'),
        actions: [
          TextButton(
            child: const Text('关闭'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      onDismiss: () => print('第一个弹窗关闭'),
    );

    // 添加底部弹窗
    DialogQueue().add(
        context: context,
        type: DialogType.bottom,
        builder: (_) => CustomBottomSheetContent(),
        backgroundColor: Colors.grey[100],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))));

    DialogQueue().add(
      context: context,
      builder: (BuildContext context) {
        return const CustomDialog();
      },
      type: DialogType.center,
      onDismiss: () {
        print('自定义弹窗已关闭');
      },
    );
  }
```

[具体实现代码，请参考这里](https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core/dialog)



## 5、刷新组件

刷新组件基于`pull_to_refresh_flutter3` 封装，支持onRefresh和onLoading回调，是否启用上拉加载，以及子内容。

```
// 封装的刷新组件
class CustomRefreshWidget<T> extends StatelessWidget {
  final RefreshController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoading;
  final List<T> dataList;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const CustomRefreshWidget({
    Key? key,
    required this.controller,
    required this.onRefresh,
    this.onLoading,
    required this.dataList,
    required this.itemBuilder,
  }) : super(key: key);

  Widget headerBuilder(BuildContext context, RefreshStatus? mode) {
    Widget body;
    if (mode == RefreshStatus.idle) {
      body = const Text("下拉刷新", style: TextStyle(fontSize: 16));
    } else if (mode == RefreshStatus.refreshing) {
      body = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      );
    } else if (mode == RefreshStatus.canRefresh) {
      body = const Text("释放立即刷新", style: TextStyle(fontSize: 16));
    } else if (mode == RefreshStatus.completed) {
      body = const Text("刷新完成", style: TextStyle(fontSize: 16));
    } else if (mode == RefreshStatus.failed) {
      body = const Text("刷新失败", style: TextStyle(fontSize: 16));
    } else {
      body = const Text("未知状态", style: TextStyle(fontSize: 16));
    }
    return Container(
      height: 80.0,
      alignment: Alignment.center,
      color: Colors.white, // 设置背景颜色
      child: body,
    );
  }

  Widget footerBuilder(BuildContext context, LoadStatus? mode) {
    Widget body;
    if (mode == LoadStatus.idle) {
      body = const Text(
        "上拉加载",
        style: TextStyle(fontSize: 16),
      );
    } else if (mode == LoadStatus.loading) {
      body = const CircularProgressIndicator();
    } else if (mode == LoadStatus.failed) {
      body = const Text("加载失败！点击重试！", style: TextStyle(fontSize: 16));
    } else if (mode == LoadStatus.canLoading) {
      body = const Text("释放加载更多", style: TextStyle(fontSize: 16));
    } else {
      body = const Text("没有更多数据了", style: TextStyle(fontSize: 16));
    }
    return SizedBox(
      height: 55.0,
      child: Center(child: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      springDescription:
          const SpringDescription(stiffness: 200, damping: 20, mass: 2.0),
      // 调整弹簧动画属性
      maxOverScrollExtent: 80,
      // 减少最大下拉距离
      maxUnderScrollExtent: 0,
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: false,
      enableBallisticLoad: true,
      child: SmartRefresher(
        controller: controller,
        enablePullDown: true,
        enablePullUp: onLoading != null,
        header: CustomHeader(builder: headerBuilder),
        footer: CustomFooter(builder: footerBuilder),
        onRefresh: onRefresh,
        onLoading: onLoading,
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
```



# 底座数据层

## 1、数据库

### 1、db封装

**1、插入数据**

```
/*
  int id = await dbHelper.insert({'name': 'Alice'}, 'my_table');
  print('Inserted with ID: $id');
  * */
  // 插入数据
  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    Database db = await database;
    return await db.insert(tableName, row);
  }
```

**2、 查询所有数据**

```
/*
  List<Map<String, dynamic>> allRows = await dbHelper.queryAll('my_table');
  print('All rows: $allRows');
  * */
  // 查询所有数据
  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await database;
    return await db.query(tableName);
  }
```

**3、根据条件查询数据**

```
/*
  // 根据条件查询数据
  List<Map<String, dynamic>> filteredRows = await dbHelper.query(
    'my_table',
    where: 'name = ?',
    whereArgs: ['Alice'],
  );
  print('Filtered rows: $filteredRows');
  * */
  // 根据条件查询数据
  Future<List<Map<String, dynamic>>> query(String tableName,
      {String? where,
      List<dynamic>? whereArgs,
      String? orderBy,
      int? limit,
      int? offset}) async {
    Database db = await database;
    return await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
```

**4、更新数据**

```
/*
  int updatedRows = await dbHelper.update(
    'my_table',
    {'name': 'Bob'},
    'id = ?',
    whereArgs: [id],
  );
  print('Updated $updatedRows rows');
  * */
  // 更新数据
  Future<int> update(String tableName, Map<String, dynamic> row, String where,
      {List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.update(
      tableName,
      row,
      where: where,
      whereArgs: whereArgs,
    );
  }
```

**5、删除数据**

```
/*
  int deletedRows = await dbHelper.delete(
    'my_table',
    'id = ?',
    whereArgs: [id],
  );
  print('Deleted $deletedRows rows');
  * */
  // 删除数据
  Future<int> delete(String tableName, String where,
      {List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.delete(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

```

**6、关闭数据库**

```
// 关闭数据库
  Future close() async {
    Database db = await database;
    return db.close();
  }
```

### 2、file文件读写

**1、写入文件**

```
/// 写入文件
  Future<void> writeFile({required String fileName,required String content, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      Log.debug("文件地址：${file.path}");
      // 等待写入操作完成
      await file.writeAsString(content);
    } on PlatformException catch (e) {
      Log.debug('写入文件时发生平台异常: ${e.message}');
      rethrow;
    } on FileSystemException catch (e) {
      Log.debug('文件系统写入出错: ${e.message}');
      rethrow;
    } catch (e) {
      Log.debug('文件写入失败: $e');
      rethrow;
    }
  }
```

**2、追加内容到文件**

```
 // 追加内容到文件
  Future<void> appendToFile({required String fileName,required String content, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      // 以追加模式写入内容
      await file.writeAsString(content, mode: FileMode.append);
      Log.debug('内容已成功追加到文件: ${file.path}');
    } on PlatformException catch (e) {
      Log.debug('追加内容时发生平台异常: ${e.message}');
      rethrow;
    } on FileSystemException catch (e) {
      Log.debug('文件系统操作出错: ${e.message}');
      rethrow;
    } catch (e) {
      Log.debug('追加内容到文件时出现未知错误: $e');
      rethrow;
    }
  }
```

**3、读取文件**

```
/// 读取文件
  Future<String?> getFile({required String fileName, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      Log.debug("读取文件路径：${file.path}");
      String contents = await file.readAsString();
      return contents;
    } on PlatformException catch (e) {
      Log.debug('读取文件时发生平台异常: ${e.message}');
      return null;
    } on FileSystemException catch (e) {
      Log.debug('文件系统读取出错: ${e.message}');
      return null;
    } catch (e) {
      Log.debug('文件读取失败: $e');
      return null;
    }
  }
```

**4、移除指定文件**

```
/// 移除指定文件
  Future<bool> removeFilePath({required String fileName, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName,moduleName: moduleName);
      // 检查文件是否存在
      if (await file.exists()) {
        // 移除文件
        await file.delete();
        Log.debug('文件删除成功: ${file.path}');
        return true;
      } else {
        Log.debug('文件不存在，无需删除: ${file.path}');
        return false;
      }
    } on PlatformException catch (e) {
      Log.debug('删除文件时发生平台异常: ${e.message}');
      return false;
    } on FileSystemException catch (e) {
      Log.debug('文件系统删除出错: ${e.message}');
      return false;
    } catch (e) {
      Log.debug('移除文件时出现未知错误: $e');
      return false;
    }
  }
```



### 3、基于shared_preferences封装小数据读写

 ```
 class PreferencesHelper {
   /// 异步设置字符串值
   static Future<void> setString(String key, String value) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString(key, value);
   }
 
   /// 异步获取字符串值，带默认值
   static Future<String?> getString(String key) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String? value = prefs.getString(key);
     return value;
   }
 
   /// 异步设置整数值
   static Future<void> setInt(String key, int value) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setInt(key, value);
   }
 
   /// 异步获取整数值，带默认值
   static Future<int?> getInt(String key) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int? value = prefs.getInt(key);
     return value;
   }
 
   /// 异步设置布尔值
   static Future<void> setBool(String key, bool value) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setBool(key, value);
   }
 
   /// 异步获取布尔值，带默认值
   static Future<bool?> getBool(String key) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     bool? value = prefs.getBool(key);
     return value;
   }
 
 /// 异步设置双精度浮点数值
   static Future<void> setDouble(String key, double value) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setDouble(key, value);
   }
 
   /// 异步获取双精度浮点数值，带默认值
   static Future<double?> getDouble(String key) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     double? value = prefs.getDouble(key);
     return value;
   }
 
   /// get keys.
   /// 获取sp中所有的key
   static Future<Set<String>> getKeys() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     return prefs.getKeys();
   }
 
   /// remove.
   /// 移除sp中key的值
   static Future<bool> remove(String key) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     return await prefs.remove(key);
   }
 
   /// 清除所有键值对
   static Future<void> clear() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.clear();
   }
 }
 
 ```

## 2、jsonConverter类型解析失败问题

主要扩展了下面几个类型转换器

- 1、JsonTypeAdapter
- 2、SafeConvertModel
- 3、SafeDateTimeConverter
- 4、SafeListConverter
- 5、SafeMapConverter
- 6、SafeNumConverter

[参考文章：Flutter 一招教你解决json_annotation类型解析失败问题](https://juejin.cn/post/7472785299732496418)



## 3、日志Log

日志Log是基于`logger`封装实现的，主要实现一下功能

1. **多级别日志支持**：
   - Verbose (详细)
   - Debug (调试)
   - Info (信息)
   - Warning (警告)
   - Error (错误)
   - WTF (严重错误)
2. **配置选项**：
   - 控制堆栈跟踪显示行数
   - 自定义输出颜色
   - 设置日志行长度
   - 显示打印时间
   - 表情符号开关
3. **性能优化**：
   - 支持全局日志开关
   - 生产环境默认过滤敏感信息
   - 自动处理对象转字符串
4. **错误处理**：
   - 支持携带错误对象
   - 可记录堆栈跟踪信息
   - 错误日志显示更多上下文

```
/// 日志配置选项
class LogOptions {
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;

  LogOptions({
    this.methodCount = 0,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
  });
}
```



## 4、crypto加解密封装

- 1、MD5 加密
- 2、SHA-256 加密
- 3、AES 加密解密



## 5、router路由组件

### 1、跳转工具类

**1、路由跳转**

```
static Future<T?> router<T extends Object?>(
      {required RouterURL routerURL,
      required BuildContext context,
      Map<String, dynamic>? param,
      MyRouterEnum routerType = MyRouterEnum.push}) {
    final name = routerURL.name;
    Map<String, dynamic> queryParameters = param ?? Map<String, dynamic>();
    if (routerType == MyRouterEnum.push) {
      return context.pushNamed(name, queryParameters: queryParameters);
    } else {
      context.goNamed(name, queryParameters: queryParameters);
      return Future.value();
    }
  }
```

**2、pop 返回**

```
 static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop(result);
    } else {
      assert(false, '不能pop');
    }
  }
```

**3、返回到指定界面**

```
static void popUntil(
      {required BuildContext context, required RouterURL routerURL}) {
    try {
      List<Route<dynamic>> list = getAllRoutes();
      bool isCanPop = false;
      for (Route _router in list) {
        if(_router.settings.name == routerURL.name) {
          isCanPop = true;
        }
      }

      if (isCanPop) {
        final name = routerURL.name;
        Navigator.popUntil(context, ModalRoute.withName(name));
      } else {
        assert(false, '不能pop');
      }

    } catch (e) {
      Log.error("返回到指定界面错误：${e.toString()}");
    }
  }
```

**4、获取当前路由栈里面的全部路由**

 ```
 /// 获取当前路由栈里面的全部路由
   static List<Route<dynamic>> getAllRoutes() {
     final MyRouteObserver routeObserver = MyRouteObserver();
     List<Route<dynamic>> routes = routeObserver.routeStack;
     return routes;
   }
 ```



### 2、添加路由观察者

```
class MyRouteObserver extends NavigatorObserver {
  static final MyRouteObserver _instance = MyRouteObserver._internal();

  factory MyRouteObserver() {
    return _instance;
  }

  MyRouteObserver._internal();

  final List<Route<dynamic>> routeStack = [];
  final Map<Route<dynamic>, List<RouteAware>> _routeAwareSubscriptions = {};

  /// 订阅路由变化
  void subscribe(RouteAware routeAware, Route<dynamic> route) {
    _routeAwareSubscriptions.putIfAbsent(route, () => []).add(routeAware);
  }

  /// 取消订阅路由变化
  void unsubscribe(RouteAware routeAware) {
    for (final route in _routeAwareSubscriptions.keys) {
      _routeAwareSubscriptions[route]?.remove(routeAware);
    }
  }

  /// 当一个新的路由被推送到导航栈时，此方法会被调用。
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route);
    Log.debug(
        '新的路由被推送到导航栈: ${route.settings.name} param:${route.settings.arguments}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(previousRoute, route);
  }

  /// 当一个路由从导航栈中弹出时，此方法会被调用。route 参数表示被弹出的路由，previousRoute 参数
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route);
    Log.debug(
        '路由被弹出，当前路由堆栈: ${route.settings.name},param:${route.settings.arguments}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(route, previousRoute);
  }

  /// 当一个路由从导航栈中被移除时，此方法会被调用。移除路由和弹出路由不同，移除操作可以移除导航栈中任意位置的路由，而弹出操作只能移除栈顶的路由。
  /// route 参数表示被移除的路由，previousRoute 参数表示在该路由移除后，其下一个路由（如果存在的话）。
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route);

    Log.debug(
        '路由被移除，当前路由堆栈: ${route.settings.name}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      routeStack.remove(oldRoute);
    }
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    Log.debug(
        '路由被替换，当前路由堆栈: new= ${newRoute?.settings.name}, old= ${oldRoute?.settings.name}');
    _handleRouteVisibility(oldRoute, newRoute);
  }

  /// 当用户开始进行一个导航手势（如在 iOS 上从屏幕边缘向左滑动返回上一页）时，此方法会被调用。
  /// route 参数表示当前正在操作的路由，previousRoute 参数表示在手势操作后可能会显示的前一个路由（如果存在的话）。
  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    Log.debug('手势事件 didStartUserGesture: ${route.settings.name}, '
        'previousRoute= ${previousRoute?.settings.name}');
  }

  /// 用户结束导航手势时，此方法会被调用。无论手势是否成功完成导航操作，只要手势结束，就会触发这个方法。
  @override
  void didStopUserGesture() {
    Log.debug('手势结束：didStopUserGesture');
  }

  /// 处理路由可见性变化
  void _handleRouteVisibility(
      Route<dynamic>? oldRoute, Route<dynamic>? newRoute) {
    if (oldRoute != null) {
      _notifyRouteAware(oldRoute, false);
    }
    if (newRoute != null) {
      _notifyRouteAware(newRoute, true);
    }
  }

  /// 通知订阅者路由可见性变化
  void _notifyRouteAware(Route<dynamic> route, bool isVisible) {
    final routeAwares = _routeAwareSubscriptions[route];
    if (routeAwares != null) {
      for (final routeAware in routeAwares) {
        if (isVisible) {
          routeAware.didPush();
        } else {
          routeAware.didPopNext();
        }
      }
    }
  }
}
```

### 3、定义路由映射url

```
/// 路由映射url
class RouterURL {
  /// 名称
  final String name;
  /// 路径
  final String path;

  const RouterURL({required this.name, required this.path});
}

```



## 6、eventBus封装

- 1、**单例模式**：全局唯一事件总线实例，通过 `AppEventBus.instance` 访问核心功能
- 2、**类型安全**：强类型事件处理，编译时类型检查
- 3、**生命周期管理**：
  - 通过 `EventBusMixin` 自动取消订阅
  - 手动订阅返回 `StreamSubscription` 便于管理
- 4、**安全防护**
  - 异常捕获机制防止事件处理崩溃
  - 错误处理回调支持

```
// 封装后的高级事件总线
class AppEventBus {
  static final EventBus _instance = EventBus();

  // 私有构造，确保单例
  AppEventBus._internal();

  /// 获取单例实例
  static EventBus get instance => _instance;

  /// 发送事件
  static void sendEvent<T>(T event) {
    if (kDebugMode) {
      print('[EventBus] Firing event: ${event.runtimeType}');
    }
    instance.fire(event);
  }

  /// 订阅事件，返回可取消的订阅对象
  static StreamSubscription<T> on<T>(void Function(T event) handler, {
    bool handleError = true,
    ErrorCallback? onError,
  }) {
    final subscription = instance.on<T>().listen((event) {
      if (kDebugMode) {
        print('[EventBus] Received event: ${event.runtimeType}');
      }
      _safeRun(() => handler(event), onError: onError);
    }, onError: handleError ? (error, stack) {
      _safeRun(() => onError?.call(error, stack));
    } : null);

    return subscription;
  }

  static void _safeRun(void Function() action, {ErrorCallback? onError}) {
    try {
      action();
    } catch (e, s) {
      if (kDebugMode) {
        print('[EventBus] Handler error: $e\n$s');
      }
      onError?.call(e, s);
    }
  }
}

/// Flutter Widget 集成扩展
mixin EventBusMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _eventSubscriptions = [];

  /// 安全订阅事件，自动管理生命周期
  void subscribe<Event>(void Function(Event event) handler, {
    bool handleError = true,
    ErrorCallback? onError,
  }) {
    _eventSubscriptions.add(
        AppEventBus.on<Event>(handler, handleError: handleError, onError: onError)
    );
  }

  @override
  void dispose() {
    for (final sub in _eventSubscriptions) {
      sub.cancel();
    }
    if (kDebugMode) {
      print('[EventBus] Canceled ${_eventSubscriptions.length} subscriptions');
    }
    super.dispose();
  }
}

typedef ErrorCallback = void Function(Object error, StackTrace stackTrace);
```



## 7、Stream结合RxDart封装

Stream可以简单的处理数据流，但遇到更复杂的需求时，发现原生Stream的操作符不够用。这个时候我们就可以借助于RxDart。RxDart可以提供更多的操作符的链式调用、错误处理、流的组合。

```
class RxStream<T> {
  final BehaviorSubject<T> _subject = BehaviorSubject<T>();

  Stream<T> get stream => _subject.stream;

  // 添加数据
  void add(T value) => _subject.sink.add(value);

  // 链式操作符示例：防抖 + 过滤空值
  Stream<T> debounceAndFilter(Duration duration) {
    return stream
        .debounceTime(duration) // 防抖
        .where((value) => value != null); // 过滤空值
  }

  // 合并多个流（例如：搜索输入 + 筛选条件）
  static Stream<R> combineStreams<A, B, R>(
      Stream<A> streamA,
      Stream<B> streamB,
      R Function(A, B) combiner,
      ) {
    return Rx.combineLatest2(streamA, streamB, combiner);
  }

  // 关闭资源
  void dispose() => _subject.close();
}

```

[参考文章：flutter 流(Stream)介绍&结合RxDart使用](https://juejin.cn/post/7477921821285433384)



# 底座基础组件

## 1、布局类

### ScreenAdapter屏幕适配

```
class ScreenAdapter {
  // 初始化屏幕适配
  static void init(BuildContext context, {double width = 375, double height = 812}) {
    ScreenUtil.init(
      context,
      designSize: Size(width, height),
    );
  }

  // 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  // 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  // 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  // 获取底部安全区高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // 适配宽度
  static double setWidth(double width) {
    return width.w;
  }

  // 适配高度
  static double setHeight(double height) {
    return height.h;
  }

  // 适配字体大小
  static double setSp(double fontSize) {
    return fontSize.sp;
  }
}
```

### IntScreenExtensions&DoubleScreenExtensions

```
// 为 int 类型添加扩展
extension IntScreenExtensions on int {
  /// 转换为适配后的像素值
  double get px => toDouble().w;

  /// 转换为适配后的响应式像素值（这里使用与 px 相同逻辑，可按需调整）
  double get rpx => toDouble().w;
}

// 为 double 类型添加扩展
extension DoubleScreenExtensions on double {
  /// 转换为适配后的像素值
  double get px => w;

  /// 转换为适配后的响应式像素值（这里使用与 px 相同逻辑，可按需调整）
  double get rpx => w;
}
 
```



## 2、utils工具

### date_untils时间工具

- 1、获取当前时间戳（毫秒）
- 2、获取当前时间
- 3、将某个格式时间转化成时间戳（毫秒）
- 4、将某个格式时间转化为指定格式时间
- 5、获取当前年、月、日



### DoubleExtension

- 1、保留指定小数位数

### StringExtension

- 1、md5加密
- 2、将字符串转换为 Map<String, dynamic>
- 3、Base64 编码、Base64 解码
- 4、截取指定长度字符串
- 5、 按索引范围替换字符串



### ExtensionList

- 1、 将list转化为json字符串
- 2、判断对象是否为null
- 3、字符串拼接
- 4、列表元素去重

### ExtensionMap

- 1、将map转化为json字符串
- 2、合并两个 Map
- 3、筛选符合条件的键值对
- 4、将 Map 的值转换为另一种类型
- 5、获取 Map 中第一个满足条件的键值对

### ColorExtension

- 1、十六进制颜色设置
- 2、 hex颜色设置
- 3、取随机颜色

### WidgetExtension

- 1、切圆角
- 2、点击事件
- 3、 长按事件

### ImageExtension

- 1、根据指定的角度旋转图片
- 2、图片灰度



### TextFieldExtension

- 1、自动获取焦点

- 2、限制长度

- 3、手机号格式化

  

### JsonUtils

- 1、将 Map 转换为 String

- 2、 将 String 转换为 Map

- 3、 将 List 转换为 String

- 4、将 String 转换为 List

  

























































































































