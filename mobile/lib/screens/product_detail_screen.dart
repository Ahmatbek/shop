import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart/cart_bloc.dart';
import '../models/models.dart';
import '../widgets/favorite_button.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  bool _added = false;

  Future<void> _add() async {
    final bloc = context.read<CartBloc>();
    for (var i = 0; i < _qty; i++) {
      bloc.add(CartItemAdded(widget.product));
    }
    setState(() => _added = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FavoriteButton(productId: product.id, size: 24),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Hero(
              tag: 'product-image-${product.id}',
              child: ProductImage(url: product.imageUrl),
            ),
          ),
          _FadeSlide(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(product.category),
                    backgroundColor: cs.secondaryContainer,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 12),
                  Text(product.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(product.price),
                    style: theme.textTheme.titleLarge?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: theme.cardTheme.color,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                _QuantityStepper(
                  value: _qty,
                  onChanged: (v) => setState(() => _qty = v),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _add,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                      child: Icon(
                        _added ? Icons.check_circle : Icons.add_shopping_cart,
                        key: ValueKey(_added),
                      ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _added ? 'Добавлено' : 'В корзину · ${formatPrice(product.price * _qty)}',
                        key: ValueKey(_added),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 99 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
