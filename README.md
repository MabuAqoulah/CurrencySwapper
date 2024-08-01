# CurrencySwapper

A new Flutter project.

## Getting Started

Configuration
API Keys: The app uses the Free Currency API. Ensure you have a valid API key and replace the existing key in the fetchApiUrl in the CurrencyBloc class.

Database Initialization: The app uses SQLite to store currency data. Ensure you have the necessary permissions and storage configurations for SQLite.

Architecture
Design Pattern
Bloc Pattern

Justification:
The Bloc (Business Logic Component) pattern is used to separate business logic from UI code. This makes the codebase more maintainable and testable. It provides a clear structure by separating state management (Bloc) from UI components (Widgets). This pattern helps in managing complex state transitions and business logic, especially in an app with asynchronous operations and data fetching.
Image Loader
Image Loading Library
Image.asset

Justification:
For this app, Image.asset is used to load currency flags from local assets. Given that the number of images is fixed and relatively small, using local assets avoids the overhead of network requests and provides a faster, more reliable loading experience. For scalability or handling a larger number of images, you might consider using network image loaders like CachedNetworkImage, but for this use case, Image.asset is efficient and straightforward.
Database
Database Usage
SQLite (sqflite package)

Justification:
SQLite is used to locally store currency data. This allows the app to work offline and reduces the need to re-fetch data from the API each time the app starts. SQLite is lightweight, fast, and well-supported in Flutter, making it a suitable choice for storing structured data like currency information.
Project Dependencies
Flutter: UI framework
sqflite: SQLite plugin for Flutter
dio: HTTP client for Flutter
flutter_bloc: State management library
License
This project is licensed under the MIT License - see the LICENSE file for details.

Feel free to customize this README further based on any additional features or details specific to your project!
