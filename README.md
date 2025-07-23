# FrankTheLocalLLM


This repository contains a minimal Flutter project configured with
[responsive_framework](https://pub.dev/packages/responsive_framework) to
provide adaptive layouts across devices. The project also includes the web
folder so it can be built and served as a web application.

## Getting Started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) on
   your machine.

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

You can modify `lib/main.dart` to adjust breakpoints or add additional widgets.


## Backend API

A simple FastAPI backend is located in the `backend/` directory. The configuration uses environment variables via `pydantic` and enables CORS.

### Setup

1. Install Python 3.11 or newer.
2. Install dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
3. Run the server:
   ```bash
   python -m backend.app.main
   ```

The server exposes a sample endpoint at `/api/hello` returning a welcome message.

