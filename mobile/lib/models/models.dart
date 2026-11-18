import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
      };

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, category];
}

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class OrderItem extends Equatable {
  const OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
  });

  final String productName;
  final double price;
  final int quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productName: json['productName'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
      );

  @override
  List<Object?> get props => [productName, price, quantity];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.address,
    required this.items,
  });

  final int id;
  final DateTime createdAt;
  final double total;
  final String address;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: (json['id'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        total: (json['total'] as num).toDouble(),
        address: json['address'] as String? ?? '',
        items: ((json['items'] as List<dynamic>?) ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, createdAt, total, address, items];
}

class UserSession extends Equatable {
  const UserSession({
    required this.token,
    required this.name,
    required this.email,
  });

  final String token;
  final String name;
  final String email;

  @override
  List<Object?> get props => [token, name, email];
}

String formatPrice(double value) => '${value.toStringAsFixed(0)} сом';

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}
