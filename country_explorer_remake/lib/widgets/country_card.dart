import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Re-added flutter_svg
import '../models/country.dart' as app_model; // Alias for our AppCountry model
import '../providers/country_provider.dart';
import 'package:provider/provider.dart';
import '../utils/color_extensions.dart'; // Import the new extension
// Removed: import 'package:world_countries/world_countries.dart' as wc; // Removed world_countries import

class CountryCard extends StatefulWidget {
  final app_model.AppCountry country; // Use aliased AppCountry
  final VoidCallback onTap;
  const CountryCard({super.key, required this.country, required this.onTap});

  @override
  State<CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<CountryCard> {
  bool _hovered = false;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();
    final isFav = provider.isFavorite(widget.country);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_tiltY)
      ..rotateY(_tiltX);

    return MouseRegion(
      onEnter: (_) => setState(() {
        _hovered = true;
        _scale = 1.02;
      }),
      onHover: (event) {
        final size = context.size ?? const Size(200, 200);
        final dx = (event.localPosition.dx / size.width) - 0.5;
        final dy = (event.localPosition.dy / size.height) - 0.5;
        setState(() {
          _tiltX = dx * 0.10;
          _tiltY = -dy * 0.10;
        });
      },
      onExit: (_) => setState(() {
        _hovered = false;
        _tiltX = 0;
        _tiltY = 0;
        _scale = 1.0;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapCancel: () => setState(() => _scale = _hovered ? 1.02 : 1.0),
        onTapUp: (_) => setState(() => _scale = _hovered ? 1.02 : 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: Card(
              elevation: _hovered ? 6 : 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'flag:${widget.country.flagUrl}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: _FlagImage(url: widget.country.flagUrl), // Using custom _FlagImage
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            tooltip: isFav ? 'Unfavorite' : 'Favorite',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withAlphaFactor(0.2),
                            ),
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              provider.toggleFavorite(widget.country);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.country.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capital: ${widget.country.capital}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagImage extends StatelessWidget {
  final String url;
  const _FlagImage({required this.url});

  bool get _isSvg => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    Widget placeholder = const _ShimmerBox();
    if (url.isEmpty) {
      return placeholder;
    }
    if (_isSvg) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => placeholder,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return placeholder;
      },
      errorBuilder: (ctx, err, stack) {
        return const _ErrorIllustration(message: 'Flag unavailable');
      },
    );
  }
}

class _ErrorIllustration extends StatelessWidget {
  final String message;
  const _ErrorIllustration({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 + _controller.value * 2, -0.3),
              end: Alignment(1.0 + _controller.value * 2, 0.3),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Container(color: Colors.grey.shade300),
        );
      },
    );
  }
}
