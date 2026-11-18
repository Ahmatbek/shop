import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/orders/orders_bloc.dart';
import '../models/models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const OrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          switch (state.status) {
            case OrdersStatus.initial:
            case OrdersStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case OrdersStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error ?? 'Ошибка', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<OrdersBloc>().add(const OrdersRequested()),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            case OrdersStatus.loaded:
            case OrdersStatus.placing:
            case OrdersStatus.placed:
              if (state.orders.isEmpty) {
                return const Center(child: Text('Заказов пока нет'));
              }
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, i) => _OrderTile(order: state.orders[i]),
              );
          }
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text('Заказ №${order.id} · ${formatPrice(order.total)}'),
        subtitle: Text(formatDate(order.createdAt)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Адрес: ${order.address}'),
          const SizedBox(height: 8),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${item.productName} — ${item.quantity} × '
                  '${formatPrice(item.price)}'),
            ),
        ],
      ),
    );
  }
}
