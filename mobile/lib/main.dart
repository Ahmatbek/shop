import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/favorites/favorites_cubit.dart';
import 'blocs/orders/orders_bloc.dart';
import 'blocs/products/products_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'data/shop_repository.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(repository: ShopRepository(prefs: prefs), prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository, required this.prefs});

  final ShopRepository repository;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(repository)..add(const AuthStarted())),
          BlocProvider(create: (_) => ProductsBloc(repository)..add(const ProductsRequested())),
          BlocProvider(create: (_) => CartBloc(prefs)),
          BlocProvider(create: (_) => OrdersBloc(repository)),
          BlocProvider(create: (_) => FavoritesCubit(prefs)),
          BlocProvider(create: (_) => ThemeCubit(prefs)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: 'Shop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}

/// Chooses the screen from the auth state and wipes user data on logout.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is Unauthenticated,
      listener: (context, state) {
        context.read<CartBloc>().add(const CartCleared());
        context.read<OrdersBloc>().add(const OrdersCleared());
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() => const Scaffold(body: Center(child: CircularProgressIndicator())),
            Authenticated() => const ShellScreen(),
            AuthLoading() || Unauthenticated() => const LoginScreen(),
          };
        },
      ),
    );
  }
}
