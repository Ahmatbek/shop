import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/products/products_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_grid.dart';

/// Catalog tab: greeting, search, category chips, sort and an animated grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) context.read<ProductsBloc>().add(ProductsSearchChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthBloc>().state;
    final name = auth is Authenticated ? auth.session.name : '';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            final loading = state.status == ProductsStatus.loading ||
                state.status == ProductsStatus.initial;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Добро пожаловать' : 'Привет, $name 👋',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text('Найдите то, что нравится', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: _onSearch,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Поиск товаров',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<ProductSort>(
                        tooltip: 'Сортировка',
                        initialValue: state.sort,
                        icon: const Icon(Icons.tune),
                        onSelected: (s) =>
                            context.read<ProductsBloc>().add(ProductsSortChanged(s)),
                        itemBuilder: (_) => [
                          for (final s in ProductSort.values)
                            PopupMenuItem(value: s, child: Text(s.label)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _CategoryChip(
                        label: 'Все',
                        selected: state.category == null,
                        onTap: () => context
                            .read<ProductsBloc>()
                            .add(const ProductsCategorySelected(null)),
                      ),
                      for (final c in state.categories)
                        _CategoryChip(
                          label: c,
                          selected: state.category == c,
                          onTap: () => context
                              .read<ProductsBloc>()
                              .add(ProductsCategorySelected(c)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _body(context, state, loading),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ProductsState state, bool loading) {
    if (loading) return const SkeletonGrid(key: ValueKey('skeleton'));

    if (state.status == ProductsStatus.failure) {
      return EmptyState(
        key: const ValueKey('error'),
        icon: Icons.cloud_off,
        title: 'Не удалось загрузить',
        subtitle: state.error ?? 'Ошибка',
        action: FilledButton(
          onPressed: () => context.read<ProductsBloc>().add(const ProductsRequested()),
          child: const Text('Повторить'),
        ),
      );
    }

    final products = state.visible;
    if (products.isEmpty) {
      return const EmptyState(
        key: ValueKey('empty'),
        icon: Icons.search_off,
        title: 'Ничего не найдено',
        subtitle: 'Попробуйте изменить запрос или категорию',
      );
    }

    return RefreshIndicator(
      key: ValueKey('grid-${state.category}-${state.sort}-${state.query}'),
      onRefresh: () async =>
          context.read<ProductsBloc>().add(const ProductsRequested()),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.74,
        ),
        itemCount: products.length,
        itemBuilder: (context, i) => _StaggeredEntry(
          index: i,
          child: ProductCard(product: products[i]),
        ),
      ),
    );
  }
}

/// Fades and slides an item in, delayed by its index.
class _StaggeredEntry extends StatelessWidget {
  const _StaggeredEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: Interval(delay / (400 + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 30 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
