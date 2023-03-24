import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.id});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, EditProductScreen.routeName,
                          arguments: id);
                    },
                    icon: const Icon(Icons.edit, color: Colors.grey)),
                IconButton(
                    onPressed: () async {
                      try {
                        await Provider.of<ProductsProvider>(context,
                                listen: false)
                            .deleteProduct(id);
                      } catch (e) {
                        scaffold.showSnackBar(const SnackBar(
                            content: Text('Could not delete product')));
                      }
                    },
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).errorColor)),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
