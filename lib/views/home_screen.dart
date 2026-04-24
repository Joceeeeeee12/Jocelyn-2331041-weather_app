import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/location_model.dart';
import '../widgets/weather_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_display.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF2C3E50)),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider) {
    switch (provider.status) {
      case WeatherStatus.loading:
        return const ShimmerLoader();

      case WeatherStatus.success:
        return _buildSuccessContent(provider);

      case WeatherStatus.offline:
        if (provider.currentWeather != null) {
          return _buildOfflineContent(provider);
        }
        return ErrorDisplay(
          message: AppConstants.noInternetMessage,
          isOffline: true,
          onRetry: () => provider.loadInitialData(),
        );

      case WeatherStatus.error:
        return ErrorDisplay(
          message: provider.errorMessage,
          onRetry: () => provider.loadInitialData(),
        );

      case WeatherStatus.initial:
        return _buildInitialContent();
    }
  }

  Widget _buildSuccessContent(WeatherProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadInitialData();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main weather card
            if (provider.currentWeather != null)
              WeatherCard(weather: provider.currentWeather!),
            const SizedBox(height: 24),

            // Filter section
            _buildFilterSection(provider),
            const SizedBox(height: 16),

            // Saved weathers list
            _buildSavedWeathersList(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineContent(WeatherProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 183, 178),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 255, 35, 35)),
            ),
            child: Row(
              children: [
                const Text('📡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppConstants.offlineBannerMessage,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 239, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (provider.currentWeather != null)
            WeatherCard(weather: provider.currentWeather!),
        ],
      ),
    );
  }

  Widget _buildFilterSection(WeatherProvider provider) {
    final filters = ['All', 'Sunny', 'Cloudy', 'Rainy', 'Snowy', 'Stormy'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Condition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isActive = provider.activeFilter == filter;
              return GestureDetector(
                onTap: () => provider.setFilter(filter),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4A90D9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF2C3E50),
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedWeathersList(WeatherProvider provider) {
    final weathers = provider.filteredWeathers;

    if (weathers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No cities match this filter.\nSearch a city to add it here!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Cities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        ...weathers.map((weather) => GestureDetector(
              onTap: () {
                // Update current weather ke kota yang diklik
                final location = LocationModel(
                  name: weather.cityName,
                  country: weather.country,
                  latitude: weather.latitude,
                  longitude: weather.longitude,
                );
                provider.fetchWeatherForLocation(location);

                // Scroll ke atas supaya user lihat main card berubah
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: WeatherCard(
                weather: weather,
                isCompact: true,
              ),
            )),
      ],
    );
  }

  Widget _buildInitialContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌤️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'Welcome to WeatherNow!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Search for a city to get started.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}