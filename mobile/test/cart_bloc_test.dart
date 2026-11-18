import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/blocs/cart/cart_bloc.dart';
import 'package:shop_app/models/models.dart';

void main() {
  const product = Product(
    id: 1,
    name: 'Test',
    description: '',
    price: 100,
    imageUrl: '',
    category: 'Test',
  );

  test('adding the same product twice increases quantity and total', () async {
    final bloc = CartBloc();
    bloc.add(const CartItemAdded(product));
    bloc.add(const CartItemAdded(product));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items.length, 1);
    expect(bloc.state.count, 2);
    expect(bloc.state.total, 200);
    await bloc.close();
  });

  test('decrementing to zero removes the line', () async {
    final bloc = CartBloc();
    bloc.add(const CartItemAdded(product));
    bloc.add(const CartItemDecremented(product));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isEmpty, true);
    await bloc.close();
  });

  test('cart can be cleared', () async {
    final bloc = CartBloc();
    bloc.add(const CartItemAdded(product));
    bloc.add(const CartCleared());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.count, 0);
    await bloc.close();
  });
}
