import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

// ---------- events ----------

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  const CartItemAdded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

/// Decreases the quantity by one (removes the line when it reaches zero).
class CartItemDecremented extends CartEvent {
  const CartItemDecremented(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

// ---------- state ----------

class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItem> items;

  int get count => items.fold(0, (sum, i) => sum + i.quantity);

  double get total => items.fold<double>(0, (sum, i) => sum + i.total);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}

// ---------- bloc ----------

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc([this._prefs]) : super(_restore(_prefs)) {
    on<CartItemAdded>(_onAdded);
    on<CartItemDecremented>(_onDecremented);
    on<CartItemRemoved>(_onRemoved);
    on<CartCleared>((event, emit) => emit(const CartState()));
  }

  static const _key = 'cart_items';
  final SharedPreferences? _prefs;

  static CartState _restore(SharedPreferences? prefs) {
    final raw = prefs?.getString(_key);
    if (raw == null) return const CartState();
    try {
      final list = (jsonDecode(raw) as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return CartItem(
          product: Product.fromJson(m['product'] as Map<String, dynamic>),
          quantity: (m['quantity'] as num).toInt(),
        );
      }).toList();
      return CartState(items: list);
    } catch (_) {
      return const CartState();
    }
  }

  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    _prefs?.setString(
      _key,
      jsonEncode([
        for (final i in change.nextState.items)
          {'product': i.product.toJson(), 'quantity': i.quantity},
      ]),
    );
  }

  void _onAdded(CartItemAdded event, Emitter<CartState> emit) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == event.product.id);
    if (index == -1) {
      items.add(CartItem(product: event.product, quantity: 1));
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    }
    emit(CartState(items: items));
  }

  void _onDecremented(CartItemDecremented event, Emitter<CartState> emit) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == event.product.id);
    if (index == -1) return;
    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    }
    emit(CartState(items: items));
  }

  void _onRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    emit(CartState(
      items: state.items.where((i) => i.product.id != event.product.id).toList(),
    ));
  }
}
