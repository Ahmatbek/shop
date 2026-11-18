import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favorites/favorites_cubit.dart';
import '../blocs/products/products_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesCubit>().state;
    final products = context
        .watch<ProductsBloc>()
        .state
        .products
        .where((p) => favorites.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: products.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: 'Пока пусто',
              subtitle: 'Нажмите на сердечко у товара, чтобы сохранить его здесь',
              action: onBrowse == null
                  ? null
                  : FilledButton(onPressed: onBrowse, child: const Text('В каталог')),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.74,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => ProductCard(product: products[i]),
            ),
    );
  }
}
