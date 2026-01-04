import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:zinus_connect/screens/home_pages/home/home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
  ],
);
