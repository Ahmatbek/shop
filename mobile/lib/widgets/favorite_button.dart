import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favorites/favorites_cubit.dart';

/// Heart that pops when toggled.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 22});

  final int productId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocSelector<FavoritesCubit, Set<int>, bool>(
      selector: (favs) => favs.contains(productId),
      builder: (context, isFav) {
        return Material(
          color: cs.surface.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.read<FavoritesCubit>().toggle(productId),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(isFav),
                tween: Tween(begin: isFav ? 0.6 : 1.0, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: size,
                  color: isFav ? Colors.redAccent : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
