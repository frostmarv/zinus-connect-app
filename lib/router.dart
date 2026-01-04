import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:zinus_connect/screens/home_pages/home/home_page.dart';
import 'package:zinus_connect/screens/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
  ],
);
