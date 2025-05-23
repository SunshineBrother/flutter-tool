/// @author: jiangjunhui
/// @date: 2024/12/25
library;
import 'package:flutter/material.dart';
import 'package:flutter_module/app/global/pageRouter/router_guard.dart';
import 'package:flutter_module/app/global/pageRouter/router_path.dart';
import 'package:flutter_module/app/pages/login/login_page.dart';
import 'package:flutter_module/app/pages/test/color_page.dart';
import 'package:flutter_module/app/pages/test/date_page.dart';
import 'package:flutter_module/app/pages/test/db_page.dart';
import 'package:flutter_module/app/pages/test/event_bus_page.dart';
import 'package:flutter_module/app/pages/test/flutter_call_native.dart';
import 'package:flutter_module/app/pages/test/refresh_widget_page.dart';
import 'package:flutter_module/app/pages/test/test_router_page.dart';
import 'package:flutter_module/app/pages/test/toast_utils_page.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/router_observer.dart';
import '../../../core/widgets/Unknown_widget.dart';
import '../../pages/test/cache_image_page.dart';
import '../../pages/test/network_service_page.dart';
import '../../pages/test/test1_router_page.dart';
import '../../pages/test/test2_router_page.dart';
import '../../pages/test/test3_touter_page.dart';
import '../../pages/test/test4_router_page.dart';
import '../../root_pages.dart';

class RouterPages {
  /// 首页
  static RouteBase homeRouter = GoRoute(
      name: PagesURL.rootrUrl.name,
      path: PagesURL.rootrUrl.path,
      pageBuilder: (_, GoRouterState state) => CustomTransitionPage(
          child: const RootPages(),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child)));

  ///
  static RouteBase ColorRouter = GoRoute(
      name: PagesURL.colorUrl.name,
      path: PagesURL.colorUrl.path,
      builder: (context, state) => const ColorPage());

  static RouteBase dateRouter = GoRoute(
      name: PagesURL.daterUrl.name,
      path: PagesURL.daterUrl.path,
      builder: (context, state) => const DatePage());
  static RouteBase cacheImageRouter = GoRoute(
      name: PagesURL.cacheImageUrl.name,
      path: PagesURL.cacheImageUrl.path,
      builder: (context, state) => const CacheImagePage());

  static RouteBase dbRouter = GoRoute(
      name: PagesURL.dbUrl.name,
      path: PagesURL.dbUrl.path,
      builder: (context, state) => const dbPage());

  static RouteBase NetworkServiceRouter = GoRoute(
      name: PagesURL.NetworkServiceURL.name,
      path: PagesURL.NetworkServiceURL.path,
      builder: (context, state) => const NetworkServicePage());

  static RouteBase EventBusRouter = GoRoute(
      name: PagesURL.EventBusURL.name,
      path: PagesURL.EventBusURL.path,
      builder: (context, state) => const EventBusPage());

  static RouteBase flutterCallNaviveRouter = GoRoute(
      name: PagesURL.flutterCallNaviveURL.name,
      path: PagesURL.flutterCallNaviveURL.path,
      builder: (context, state) => const FlutterCallNativePage());

  // '刷新'
  static RouteBase RefreshWidgetRouter = GoRoute(
      name: PagesURL.CustomRefreshWidgetURL.name,
      path: PagesURL.CustomRefreshWidgetURL.path,
      builder: (context, state) => const RefreshWidgetPage());

// '刷新'
  static RouteBase ToastUtilsRouter = GoRoute(
      name: PagesURL.ToastUtilURL.name,
      path: PagesURL.ToastUtilURL.path,
      builder: (context, state) => const ToastUtilsPage());

  // 测试路由
  static RouteBase testPageRouter = GoRoute(
      name: PagesURL.testRouterUrl.name,
      path: PagesURL.testRouterUrl.path,
      builder: (context, state) {
        return const kkTestRouterPage();
      });

  static RouteBase testPageRouterOne = GoRoute(
      name: PagesURL.testRouterUrl1.name,
      path: PagesURL.testRouterUrl1.path,
      builder: (context, state) {
        final Map<String, dynamic> queryParam = state.uri.queryParameters;
        return kkTest1RouterPage(queryParam: queryParam);
      });

  static RouteBase testPageRouterTwo = GoRoute(
      name: PagesURL.testRouterUrl2.name,
      path: PagesURL.testRouterUrl2.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> queryParam = state.uri.queryParameters;
        return CustomTransitionPage(
            child: kkTest2RouterPage(queryParam: queryParam),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1), // 从底部开始
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            });
      });
  static RouteBase testPageRouterFour = GoRoute(
      name: PagesURL.testRouterUrl4.name,
      path: PagesURL.testRouterUrl4.path,
      builder: (context, state) {
        return const Test4RouterPage();
      });

  /// 测试重定向
  static RouteBase testPageRouterThree = GoRoute(
      name: PagesURL.testRouterUrl_redirect.name,
      path: PagesURL.testRouterUrl_redirect.path,
      builder: (context, state) {
        return const Test3TouterPagePage();
      },
      redirect: RouteGuard.authGuard);

  /// 登录
  static RouteBase loginRouter = GoRoute(
      name: PagesURL.loginUrl.name,
      path: PagesURL.loginUrl.path,
      builder: (context, state) => const LoginPage());
}


GoRouter routerTest(String pageString) {
  Widget root = const RootPages();
  if (pageString == "TestRouterPage") {
    root = const kkTestRouterPage();
  }

  return GoRouter(
      initialLocation: '/',
      errorBuilder: (context, GoRouterState state) {
        return const UnknownPage();
      },
      debugLogDiagnostics: true,
      observers: [
        MyRouteObserver()
      ],
      routes: [
        GoRoute(
            path: "/",
            name: "home",
            builder: (_, state) => root,
            routes: routes)
      ]);
}

final router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, GoRouterState state) {
      return const UnknownPage();
    },
    debugLogDiagnostics: true,
    observers: [RouteObserver()],
    routes: routes);

final routes = [
  RouterPages.loginRouter,
  RouterPages.homeRouter,
  RouterPages.ColorRouter,
  RouterPages.dateRouter,
  RouterPages.dbRouter,
  RouterPages.cacheImageRouter,
  RouterPages.testPageRouter,
  RouterPages.testPageRouterOne,
  RouterPages.NetworkServiceRouter,
  RouterPages.testPageRouterTwo,
  RouterPages.EventBusRouter,
  RouterPages.testPageRouterThree,
  RouterPages.testPageRouterFour,
  RouterPages.flutterCallNaviveRouter,
  RouterPages.RefreshWidgetRouter,
  RouterPages.ToastUtilsRouter
];
