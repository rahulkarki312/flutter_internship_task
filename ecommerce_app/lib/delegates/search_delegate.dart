import 'package:ecommerce_app/providers/products.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../widgets/error.dart';
import '../widgets/loader.dart';

// This creates a search functionality in the home page

class searchProductsDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      children: [
        FutureBuilder(
          future:
              Provider.of<Products>(context, listen: false).getProductsFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Product> matchQueryProducts = [];
              for (var product in snapshot.data!) {
                if (product.title.toLowerCase().contains(query.toLowerCase())) {
                  matchQueryProducts.add(product);
                }
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: matchQueryProducts.length,
                itemBuilder: (context, index) {
                  var product = matchQueryProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl)),
                    title: Text(product.title),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: product.id,
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              // showSnackBar(context: context, content: snapshot.error.toString());
              return ErrorScreen(error: snapshot.error.toString());
            } else {
              return const Loader();
            }
          },
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [
        FutureBuilder(
          future:
              Provider.of<Products>(context, listen: false).getProductsFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Product> matchQueryProducts = [];
              for (var product in snapshot.data!) {
                if (product.title.toLowerCase().contains(query.toLowerCase())) {
                  matchQueryProducts.add(product);
                }
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: matchQueryProducts.length,
                itemBuilder: (context, index) {
                  var product = matchQueryProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl)),
                    title: Text(product.title),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: product.id,
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              // showSnackBar(context: context, content: snapshot.error.toString());
              return ErrorScreen(error: snapshot.error.toString());
            } else {
              return const Loader();
            }
          },
        )
      ],
    );
  }
}
