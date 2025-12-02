import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/country_provider.dart';
import '../widgets/country_card.dart';
import '../models/country.dart' as app_model; // Alias for our AppCountry model
import 'detail.dart';

class HomeScreen extends StatelessWidget {
  final bool enableSearch;
  final bool enableFavorites;
  final bool enableSort;
  final bool enableThemeSwitch;
  const HomeScreen({
    super.key,
    required this.enableSearch,
    required this.enableFavorites,
    required this.enableSort,
    required this.enableThemeSwitch,
  });

  int _adaptiveCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 500) return 2;
    if (width < 800) return 3;
    if (width < 1100) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Country Explorer', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          if (enableSearch)
            SizedBox(
              width: 220,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search name or capital',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                  onChanged: provider.setSearchQuery,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: 'Poppins'),
                ),
              ),
            ),
          if (enableFavorites)
            IconButton(
              tooltip: provider.onlyFavorites ? 'Show All' : 'Show Favorites',
              icon: Icon(provider.onlyFavorites ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: provider.toggleOnlyFavorites,
            ),
          if (enableSort)
            PopupMenuButton<SortOption>(
              tooltip: 'Sort',
              onSelected: provider.setSort,
              itemBuilder: (context) => const [
                PopupMenuItem(value: SortOption.nameAZ, child: Text('Name A-Z')),
                PopupMenuItem(value: SortOption.populationAsc, child: Text('Population ↑')),
                PopupMenuItem(value: SortOption.populationDesc, child: Text('Population ↓')),
                PopupMenuItem(value: SortOption.areaAsc, child: Text('Area ↑')),
                PopupMenuItem(value: SortOption.areaDesc, child: Text('Area ↓')),
              ],
              icon: const Icon(Icons.sort),
            ),
          if (enableThemeSwitch)
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(provider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: provider.toggleTheme,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchCountries,
        child: isLoading
            ? const _GridLoading()
            : (provider.errorMessage != null)
                ? _ErrorState(message: provider.errorMessage!)
                : _buildGrid(context, provider.visibleCountries),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<app_model.AppCountry> data) { // Use aliased AppCountry
    if (data.isEmpty) {
      return const _EmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _adaptiveCrossAxisCount(context),
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final c = data[index];
        return CountryCard(
          country: c,
          onTap: () => _navigateToDetail(context, c),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, app_model.AppCountry c) { // Use aliased AppCountry
    Navigator.of(context).push(_fadeSlideRoute(DetailScreen(country: c)));
  }

  PageRoute _fadeSlideRoute(Widget child) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (context, anim, secondary, child) {
        final offset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim);
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(anim);
        return SlideTransition(
          position: offset,
          child: FadeTransition(opacity: opacity, child: child),
        );
      },
    );
  }
}

class _GridLoading extends StatelessWidget {
  const _GridLoading();
  @override
  Widget build(BuildContext context) {
    final cross = const HomeScreen(
      enableSearch: true,
      enableFavorites: true,
      enableSort: true,
      enableThemeSwitch: true,
    )._adaptiveCrossAxisCount(context);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: const [
          Expanded(child: _ShimmerBox()),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerLine(widthFactor: 0.8),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerLine(widthFactor: 0.6),
          ),
          SizedBox(height: 12),
        ],
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
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => ShaderMask(
        shaderCallback: (rect) => LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade100, Colors.grey.shade300],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1 + _c.value * 2, -0.3),
          end: Alignment(1 + _c.value * 2, 0.3),
        ).createShader(rect),
        blendMode: BlendMode.srcATop,
        child: Container(color: Colors.grey.shade300),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double widthFactor;
  const _ShimmerLine({required this.widthFactor});
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(widthFactor: widthFactor, child: const _ShimmerBox());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public_off, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.read<CountryProvider>().fetchCountries(),
            icon: const Icon(Icons.refresh),
            label: Text('Retry', style: Theme.of(context).textTheme.labelLarge!.copyWith(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 64),
          const SizedBox(height: 8),
          Text('No countries match your filters', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
