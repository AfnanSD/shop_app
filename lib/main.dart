import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/product_details_screen.dart';

import 'package:provider/provider.dart';
import 'package:shop_app/screens/prouducts_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          //ChangeNotifierProvider(create: (context) => ProductsProvider()),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (context) => ProductsProvider('', [], ''),
            update: (context, auth, previousProducts) => ProductsProvider(
              auth.token!,
              previousProducts == null ? [] : previousProducts.items,
              auth.userId!,
            ),
          ),
          ChangeNotifierProvider(create: (context) => Cart()),
          //ChangeNotifierProvider(create: (context) => Orders()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders('', []),
            update: (context, auth, previousOrders) => Orders(auth.token!,
                previousOrders == null ? [] : previousOrders.orders),
          )
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Lato'),
            home: auth.isAuthintecated
                ? const ProductOverviewScreen()
                : const AuthScreen(),
            routes: {
              ProductDetailsScreen.routeName: (context) =>
                  const ProductDetailsScreen(),
              UserProductsScreen.routName: (context) =>
                  const UserProductsScreen(),
              EditProductScreen.routeName: (context) =>
                  const EditProductScreen(),
            },
          ),
        )
        // MaterialApp(
        //   theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Lato'),
        //   home: const AuthScreen(),
        //   routes: {
        //     ProductDetailsScreen.routeName: (context) =>
        //         const ProductDetailsScreen(),
        //     UserProductsScreen.routName: (context) => const UserProductsScreen(),
        //     EditProductScreen.routeName: (context) => const EditProductScreen(),
        //   },
        // ),
        );
  }
}
