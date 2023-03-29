import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_details_screen.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({super.key});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black12,
          leading: IconButton(
              onPressed: () {
                setState(() {
                  product.toggleFavorite(auth.token!, auth.userId!);
                });
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border)),
          trailing: IconButton(
              onPressed: () {
                cart.addItem(product.title, product.price, product.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Item Added!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "UNDO",
                      textColor: Colors.red,
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ));
              },
              icon: const Icon(Icons.shopping_cart)),
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailsScreen.routeName,
            arguments: product.id,
          ),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/shop-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
