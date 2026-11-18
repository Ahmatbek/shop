import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/shop_repository.dart';
import '../../models/models.dart';

// ---------- events ----------

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class ProductsRequested extends ProductsEvent {
  const ProductsRequested();
}

class ProductsSearchChanged extends ProductsEvent {
  const ProductsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ProductsCategorySelected extends ProductsEvent {
  const ProductsCategorySelected(this.category);

  /// null means "all categories"
  final String? category;

  @override
  List<Object?> get props => [category];
}

class ProductsSortChanged extends ProductsEvent {
  const ProductsSortChanged(this.sort);

  final ProductSort sort;

  @override
  List<Object?> get props => [sort];
}

// ---------- state ----------

enum ProductsStatus { initial, loading, success, failure }

enum ProductSort {
  popular('Популярные'),
  priceAsc('Сначала дешёвые'),
  priceDesc('Сначала дорогие'),
  name('По названию');

  const ProductSort(this.label);
  final String label;
}

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.query = '',
    this.category,
    this.error,
    this.sort = ProductSort.popular,
  });

  final ProductsStatus status;
  final List<Product> products;
  final String query;
  final String? category;
  final String? error;
  final ProductSort sort;

  List<String> get categories =>
      products.map((p) => p.category).toSet().toList()..sort();

  List<Product> get visible {
    final q = query.trim().toLowerCase();
    final list = products.where((p) {
      final matchesCategory = category == null || p.category == category;
      final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
    switch (sort) {
      case ProductSort.popular:
        break;
      case ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    String? query,
    String? error,
    bool clearError = false,
    String? category,
    bool clearCategory = false,
    ProductSort? sort,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      error: clearError ? null : (error ?? this.error),
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [status, products, query, category, error, sort];
}

// ---------- bloc ----------

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._repository) : super(const ProductsState()) {
    on<ProductsRequested>(_onRequested);
    on<ProductsSearchChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<ProductsSortChanged>((e, emit) => emit(state.copyWith(sort: e.sort)));
    on<ProductsCategorySelected>((e, emit) {
      emit(e.category == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(category: e.category));
    });
  }

  final ShopRepository _repository;

  Future<void> _onRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(status: ProductsStatus.loading, clearError: true));
    try {
      final products = await _repository.fetchProducts();
      emit(state.copyWith(status: ProductsStatus.success, products: products));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, error: e.message));
    }
  }
}
