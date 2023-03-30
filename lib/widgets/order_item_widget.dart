import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/orders.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class OrderItemWidget extends StatefulWidget {
  const OrderItemWidget({super.key, required this.order});

  final OrderItem order;

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _expand = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('${widget.order.amount} S.R.'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.orderTime)),
            trailing: IconButton(
              icon: Icon(_expand ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expand = !_expand;
                });
              },
            ),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              constraints: BoxConstraints(
                  minHeight: _expand ? 50 : 0,
                  maxHeight:
                      _expand ? 200 : 0), //widget.order.products.length * 20
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              height: min(widget.order.products.length * 20.0 + 40.0, 160),
              child: ListView(
                children: widget.order.products
                    .map(
                      (e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '${e.quantity} * ${e.price}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          )
                        ],
                      ),
                    )
                    .toList(),
              ))
        ],
      ),
    );
  }
}
