import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/payment_service.dart';
import 'state/cart_model.dart';
import 'state/catalog_model.dart';
import 'theme/app_theme.dart';

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key, this.paymentService});

  final PaymentService? paymentService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogModel()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        Provider<PaymentService>.value(value: paymentService ?? PaymentService()),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
