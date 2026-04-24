import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final bool isSearchMode;

  const ShimmerLoader({
    super.key,
    this.isSearchMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return isSearchMode ? _buildSearchShimmer() : _buildHomeShimmer();
  }

  // Shimmer untuk HomeScreen — mirip WeatherCard besar
  Widget _buildHomeShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer WeatherCard besar
            Container(
              width: double.infinity,
              height: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            const SizedBox(height: 24),

            // Shimmer filter chips
            Row(
              children: List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 70,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Shimmer label "Saved Cities"
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),

            // Shimmer compact cards
            ...List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Shimmer untuk SearchScreen — mirip list item hasil search
  Widget _buildSearchShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(8, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ),
    );
  }
}