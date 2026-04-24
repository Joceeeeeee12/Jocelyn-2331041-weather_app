import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isOffline;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon sesuai jenis error
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isOffline
                    ? Colors.orange.shade50
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline
                    ? Icons.wifi_off_rounded
                    : Icons.cloud_off_rounded,
                size: 52,
                color: isOffline
                    ? const Color.fromARGB(255, 248, 100, 100)
                    : Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),

            // Judul
            Text(
              isOffline ? 'You\'re Offline' : 'Oops!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

            // Pesan
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Tombol retry
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(isOffline ? 'Try Again' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOffline
                      ? Colors.orange.shade400
                      : const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}