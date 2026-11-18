import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart/cart_bloc.dart';
import '../blocs/favorites/favorites_cubit.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Bottom navigation shell that keeps every tab alive.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          FavoritesScreen(onBrowse: () => _go(0)),
          CartScreen(onBrowse: () => _go(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Каталог',
          ),
          NavigationDestination(
            icon: BlocBuilder<FavoritesCubit, Set<int>>(
              builder: (_, favs) => Badge(
                isLabelVisible: favs.isNotEmpty,
                label: Text('${favs.length}'),
                child: const Icon(Icons.favorite_border),
              ),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Избранное',
          ),
          const NavigationDestination(
            icon: _CartIcon(selected: false),
            selectedIcon: _CartIcon(selected: true),
            label: 'Корзина',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

/// Cart icon whose badge bounces whenever the item count changes.
class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (a, b) => a.count != b.count,
      builder: (context, state) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(state.count),
          tween: Tween(begin: 1.4, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
          child: Badge(
            isLabelVisible: state.count > 0,
            label: Text('${state.count}'),
            child: Icon(selected ? Icons.shopping_bag : Icons.shopping_bag_outlined),
          ),
        );
      },
    );
  }
}
