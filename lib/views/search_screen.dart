import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/location_model.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_display.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<void>? _searchFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherProvider provider) {
    setState(() {
      if (query.isEmpty) {
        _searchFuture = null;
        provider.clearSearch();
      } else {
        _searchFuture = provider.searchCities(query);
      }
    });
  }

  Future<void> _onCitySelected(
      LocationModel location, WeatherProvider provider) async {
    await provider.fetchWeatherForLocation(location);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Search City',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search input field
                _buildSearchField(provider),
                const SizedBox(height: 16),

                // Search results menggunakan FutureBuilder
                Expanded(
                  child: _searchFuture == null
                      ? _buildEmptyState()
                      : FutureBuilder<void>(
                          future: _searchFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerLoader(isSearchMode: true);
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⚠️',
                                        style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Failed to search cities.\nPlease try again.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (provider.searchError.isNotEmpty) {
                              return ErrorDisplay(
                                message: provider.searchError,
                                isOffline: provider.searchError.contains('internet'),
                              );
                            }

                            if (provider.searchResults.isEmpty) {
                              return _buildNoResultState();
                            }

                            return _buildSearchResults(
                                provider.searchResults, provider);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(WeatherProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search city name...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFF4A90D9)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('', provider);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (query) => _onSearchChanged(query, provider),
      ),
    );
  }

  Widget _buildSearchResults(
      List<LocationModel> results, WeatherProvider provider) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final location = results[index];
        return GestureDetector(
          onTap: () => _onCitySelected(location, provider),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('📍', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        location.country,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Type a city name to search',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No cities found.\nTry a different keyword.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}