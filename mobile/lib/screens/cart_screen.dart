import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart/cart_bloc.dart';
import '../blocs/orders/orders_bloc.dart';
import '../models/models.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onBrowse});

  /// Called by the empty state button to jump back to the catalog tab.
  final VoidCallback? onBrowse;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _checkout(List<CartItem> items) {
    if (!_formKey.currentState!.validate()) return;
    context.read<OrdersBloc>().add(
          CheckoutSubmitted(items: items, address: _address.text.trim()),
        );
  }

  Future<void> _showSuccess() {
    return showDialog<void>(
      context: context,
      builder: (_) => const _SuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == OrdersStatus.placed) {
          context.read<CartBloc>().add(const CartCleared());
          _address.clear();
          _showSuccess();
        } else if (state.status == OrdersStatus.failure) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error ?? 'Ошибка')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Корзина', style: Theme.of(context).textTheme.headlineSmall),
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, cart) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: cart.isEmpty
                  ? EmptyState(
                      key: const ValueKey('empty'),
                      icon: Icons.shopping_bag_outlined,
                      title: 'Корзина пуста',
                      subtitle: 'Добавьте что-нибудь из каталога',
                      action: widget.onBrowse == null
                          ? null
                          : FilledButton(
                              onPressed: widget.onBrowse,
                              child: const Text('В каталог'),
                            ),
                    )
                  : Column(
                      key: const ValueKey('items'),
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => _CartRow(
                              key: ValueKey(cart.items[i].product.id),
                              item: cart.items[i],
                            ),
                          ),
                        ),
                        _CheckoutPanel(
                          formKey: _formKey,
                          addressController: _address,
                          total: cart.total,
                          onCheckout: () => _checkout(cart.items),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartBloc>();
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('dismiss-${item.product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => bloc.add(CartItemRemoved(item.product)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: ProductImage(url: item.product.imageUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(item.product.price),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _RoundButton(
                          icon: Icons.remove,
                          onPressed: () => bloc.add(CartItemDecremented(item.product)),
                        ),
                        SizedBox(
                          width: 36,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: Text(
                              '${item.quantity}',
                              key: ValueKey(item.quantity),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ),
                        _RoundButton(
                          icon: Icons.add,
                          onPressed: () => bloc.add(CartItemAdded(item.product)),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            formatPrice(item.total),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({
    required this.formKey,
    required this.addressController,
    required this.total,
    required this.onCheckout,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 12,
      color: theme.cardTheme.color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Адрес доставки',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введите адрес доставки' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Итого', style: theme.textTheme.bodySmall),
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: total),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            builder: (_, v, __) => Text(
                              formatPrice(v),
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<OrdersBloc, OrdersState>(
                      buildWhen: (a, b) => a.status != b.status,
                      builder: (context, state) {
                        final placing = state.status == OrdersStatus.placing;
                        return FilledButton(
                          onPressed: placing ? null : onCheckout,
                          child: placing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Оформить заказ'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog with a check mark that scales in.
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 56, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            Text('Заказ оформлен!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Статус можно посмотреть в профиле → Мои заказы',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отлично'),
            ),
          ],
        ),
      ),
    );
  }
}
