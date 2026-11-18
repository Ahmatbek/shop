import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/blocs/cart/cart_bloc.dart';
import 'package:shop_app/blocs/favorites/favorites_cubit.dart';
import 'package:shop_app/models/models.dart';

void main() {
  const product = Product(
    id: 7,
    name: 'Test',
    description: 'd',
    price: 50,
    imageUrl: '',
    category: 'Test',
  );

  test('favorites toggle on and off and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = FavoritesCubit(prefs);

    cubit.toggle(7);
    expect(cubit.state, {7});
    expect(FavoritesCubit(prefs).state, {7});

    cubit.toggle(7);
    expect(cubit.state, isEmpty);
    await cubit.close();
  });

  test('cart is restored from preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bloc = CartBloc(prefs);
    bloc.add(const CartItemAdded(product));
    bloc.add(const CartItemAdded(product));
    await Future<void>.delayed(Duration.zero);
    await bloc.close();

    final restored = CartBloc(prefs);
    expect(restored.state.count, 2);
    expect(restored.state.total, 100);
    await restored.close();
  });
}
