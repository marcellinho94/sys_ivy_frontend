import 'package:flutter/material.dart';
import 'package:sys_ivy_frontend/screens/dashboard.dart';
import 'package:sys_ivy_frontend/screens/home.dart';
import 'package:sys_ivy_frontend/screens/login.dart';
import 'package:sys_ivy_frontend/screens/operator.dart';
import 'package:sys_ivy_frontend/screens/operator_add_edit.dart';

class Routes {
  // ADD NEW ROUTES HERE
  static const String INITAL_ROUTE = "/";
  static const String LOGIN_ROUTE = "/login";
  static const String HOME_ROUTE = "/home";
  static const String DASHBOARD_ROUTE = "/dashboard";
  static const String PURCHASES_ROUTE = "/purchases";
  static const String SALES_ROUTE = "/sales";
  static const String CATEGORIES_ROUTE = "/categories";
  static const String PRODUCTS_ROUTE = "/products";
  static const String STOCK_ROUTE = "/stock";
  static const String OPERATOR_ROUTE = "/operator";
  static const String OPERATOR_ADD_EDIT_ROUTE = "/operator/add_edit";
  static const String LOGOUT_ROUTE = "/logout";

  // NAVIGATION
  static Route<dynamic> createRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case INITAL_ROUTE:
        return MaterialPageRoute(builder: (_) => const Login());
      case LOGIN_ROUTE:
        return MaterialPageRoute(builder: (_) => const Login());
      case HOME_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case DASHBOARD_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(DashBoard()));
      case PURCHASES_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case SALES_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case CATEGORIES_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case PRODUCTS_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case STOCK_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(null));
      case OPERATOR_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(Operator()));
      case OPERATOR_ADD_EDIT_ROUTE:
        return MaterialPageRoute(builder: (_) => const Home(OperatorAddEdit()));
    }

    return _errorNotFoundRoute();
  }

  static Route<dynamic> _errorNotFoundRoute() {
    return MaterialPageRoute(builder: (_) => const Login());
  }
}
