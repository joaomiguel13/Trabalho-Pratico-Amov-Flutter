import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/data_structs.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar(
      {super.key,
      required this.orderOptions,
      required this.onOrderSelected,
      required this.onSearchTextChanged});

  final List<OrderBy> orderOptions;
  final Function(OrderBy) onOrderSelected;
  final Function(String) onSearchTextChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: orderOptions
              .map(
                (order) => ElevatedButton(
                  onPressed: () {
                    onOrderSelected(order);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(0, 50)),
                  ),
                  child: Text(getOrderText(order)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: 200.0,
          child: TextField(
            onChanged: onSearchTextChanged,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  String getOrderText(OrderBy order) {
    switch (order) {
      case OrderBy.name:
        return "Order by Name";
      case OrderBy.distance:
        return "Order by Distance";
      case OrderBy.category:
        return "Order by Category";
    }
  }
}
