import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/shop_repository.dart';
import '../../models/models.dart';

// ---------- events ----------

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersRequested extends OrdersEvent {
  const OrdersRequested();
}

/// Forget everything (used on logout so the next user does not see old orders).
class OrdersCleared extends OrdersEvent {
  const OrdersCleared();
}

class CheckoutSubmitted extends OrdersEvent {
  const CheckoutSubmitted({required this.items, required this.address});

  final List<CartItem> items;
  final String address;

  @override
  List<Object?> get props => [items, address];
}

// ---------- state ----------

enum OrdersStatus { initial, loading, loaded, placing, placed, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.error,
  });

  final OrdersStatus status;
  final List<Order> orders;
  final String? error;

  OrdersState copyWith({OrdersStatus? status, List<Order>? orders, String? error}) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, orders, error];
}

// ---------- bloc ----------

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._repository) : super(const OrdersState()) {
    on<OrdersRequested>(_onRequested);
    on<CheckoutSubmitted>(_onCheckout);
    on<OrdersCleared>((event, emit) => emit(const OrdersState()));
  }

  final ShopRepository _repository;

  Future<void> _onRequested(OrdersRequested event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repository.fetchOrders();
      emit(state.copyWith(status: OrdersStatus.loaded, orders: orders));
    } on ApiException catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, error: e.message));
    }
  }

  Future<void> _onCheckout(CheckoutSubmitted event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: OrdersStatus.placing));
    try {
      final order = await _repository.checkout(event.items, event.address);
      emit(state.copyWith(
        status: OrdersStatus.placed,
        orders: [order, ...state.orders],
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, error: e.message));
    }
  }
}
