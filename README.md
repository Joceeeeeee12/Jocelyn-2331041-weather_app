Jocelyn - 2331041 - 6PSIB - Lab. Pengembangan Aplikasi

# WeatherNow

WeatherNow is a Flutter-based weather application that fetches real-time weather data from the **Open-Meteo API** — a free, open-source weather API that requires no API key. The app is built with a clean, modular architecture using **Provider** as the state management solution to satisfy both academic deliverables and practical production standards.

---

## Key Features

- Real-time weather data fetched from Open-Meteo API.
- Default display of 5 major Indonesian cities on launch — no search required to start.
- 7-day weather forecast with daily high/low temperatures.
- City search powered by Open-Meteo Geocoding API using `async/await` + `FutureBuilder`.
- Filter weather results by condition (Sunny, Cloudy, Rainy, Snowy, Stormy).
- Offline readiness with automatic cache fallback via `shared_preferences`.
- Dynamic UI — weather card gradient changes based on current weather condition.
- Creative shimmer loading state for smooth data fetch transitions.
- Friendly error and offline UI — no raw error codes or stack traces shown to user.
- Reusable widgets used consistently across all screens.

---

## Folder Structure

```
lib/
├── main.dart                    # App root, MultiProvider setup, route configuration
├── models/
│   ├── weather_model.dart       # WeatherModel & ForecastDay entity + JSON serialization
│   └── location_model.dart      # LocationModel entity + JSON serialization
├── services/
│   ├── weather_service.dart     # Open-Meteo API integration (weather + geocoding)
│   └── cache_service.dart       # Local cache read/write via shared_preferences
├── providers/
│   └── weather_provider.dart    # State orchestration (network + cache fallback + error handling)
├── views/
│   ├── home_screen.dart         # Main UI with weather card, filter chips, saved cities list
│   └── search_screen.dart       # City search UI with FutureBuilder async flow
├── widgets/
│   ├── weather_card.dart        # Reusable weather card (full mode & compact mode)
│   ├── shimmer_loader.dart      # Reusable shimmer loading skeleton
│   └── error_display.dart       # Reusable error/offline state UI
└── utils/
    └── constants.dart           # API base URLs, endpoints, cache keys, UI strings
```

---

## Why Provider?

Provider was chosen as the state management solution because:

- It cleanly separates business logic from UI — `WeatherProvider` handles all state transitions while views only observe and react.
- The data flow is explicit and traceable: `Service → Provider → UI`. Every state change goes through `notifyListeners()`, making it easy to understand and debug.
- `ChangeNotifier` + `Consumer` pattern keeps widget rebuilds scoped — only the affected widget subtree is rebuilt, not the entire screen.
- It is officially recommended by the Flutter team and has first-class integration with the widget tree.
- At this application's scale, Provider provides the right level of complexity — Bloc and Riverpod would introduce unnecessary boilerplate without meaningful benefit.

---

## Offline Readiness Strategy

1. On app launch, `WeatherProvider` checks whether a valid cache exists (less than 1 hour old) via `CacheService`.
2. If valid cache exists, it is loaded immediately while a background fetch refreshes the data.
3. If no valid cache exists, the app fetches fresh data from Open-Meteo API through `WeatherService`.
4. On successful fetch, the response is serialized and saved to local storage via `CacheService`.
5. If the fetch fails (network unavailable or API error), `WeatherProvider` falls back to the last cached data and sets status to `WeatherStatus.offline`.
6. If no cache exists and no internet is available, the app shows a friendly offline error screen with a retry button.

This approach ensures users always see the last successfully fetched data when the internet is disconnected.

---

## Error Handling Approach

- All API errors are caught in `WeatherService` using `try/catch` and re-thrown as meaningful exceptions.
- `WeatherProvider` interprets the error type — distinguishing between connection errors and server errors — and sets the appropriate status (`WeatherStatus.offline` or `WeatherStatus.error`).
- The UI layer never exposes raw stack traces or HTTP status codes to the user.
- `ErrorDisplay` widget is used for all error and offline states, showing a contextual icon, a user-friendly message, and a retry button.
- All user-facing messages are centralized in `constants.dart` — never hardcoded directly in UI files.

---

## Search & Filter (Asynchronous)

- City search is implemented using `async/await` in `WeatherProvider.searchCities()` which calls the Open-Meteo Geocoding API.
- The `SearchScreen` uses `FutureBuilder` to reactively render search results as the Future resolves — ensuring the UI remains responsive and never freezes during data processing.
- When a city is selected from search results, `WeatherProvider.fetchWeatherForLocation()` is called to fetch and display its weather data.
- Filter chips on the `HomeScreen` allow users to filter saved cities by weather condition:
  - All
  - Sunny
  - Cloudy
  - Rainy
  - Snowy
  - Stormy
- Filtering is applied client-side using the `filteredWeathers` getter in `WeatherProvider`, which filters `_savedWeathers` without re-fetching from the API.

---

## Reusable Widgets

### 1. `WeatherCard`
Renders weather data in two modes controlled by the `isCompact` boolean parameter:
- **Full mode** — Used on `HomeScreen` as the main featured card. Displays city name, timestamp, large emoji icon, temperature, H/L forecast, wind/humidity/feels-like details, and a 7-day forecast scroll.
- **Compact mode** — Used in the saved cities list on `HomeScreen`. Displays a condensed row with emoji, city name, condition, timestamp, temperature, and H/L values.

### 2. `ShimmerLoader`
Displays an animated shimmer skeleton in two modes controlled by the `isSearchMode` boolean parameter:
- **Home mode** — Mimics the layout of the full `WeatherCard` + filter chips + compact card list.
- **Search mode** — Mimics the layout of search result list items.

### 3. `ErrorDisplay`
Handles all error and offline states across the app with a contextual icon, message, and retry button. The `isOffline` boolean parameter switches between an offline style (orange, wifi-off icon) and a general error style (red, cloud-off icon).

---
