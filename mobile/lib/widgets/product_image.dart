import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/shop_repository.dart' show apiBaseUrl;

/// Product picture. Relative urls (e.g. `/images/hoodie.svg`) are served by
/// our own backend; SVGs are drawn with flutter_svg, bitmaps are cached.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  String get _resolved => url.startsWith('/') ? '$apiBaseUrl$url' : url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(color: cs.surfaceContainerHighest);
    final error = ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined, color: cs.outline),
    );

    if (url.isEmpty) return error;

    if (_resolved.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        _resolved,
        fit: fit,
        placeholderBuilder: (_) => placeholder,
      );
    }

    return CachedNetworkImage(
      imageUrl: _resolved,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 350),
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => error,
    );
  }
}
