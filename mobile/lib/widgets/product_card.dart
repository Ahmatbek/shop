import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart/cart_bloc.dart';
import '../models/models.dart';
import '../screens/product_detail_screen.dart';
import 'favorite_button.dart';
import 'product_image.dart';

/// Shows a floating "added to cart" snackbar and adds the product.
void addToCart(BuildContext context, Product product) {
  context.read<CartBloc>().add(CartItemAdded(product));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('«${product.name}» добавлен в корзину'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
}

/// Grid card: hero image, favorite heart, name, price and quick add.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 420),
            reverseTransitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (_, __, ___) => ProductDetailScreen(product: product),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: ProductImage(url: product.imageUrl),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FavoriteButton(productId: product.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatPrice(product.price),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'В корзину',
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => addToCart(context, product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
