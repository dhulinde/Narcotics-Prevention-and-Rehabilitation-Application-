### Installation Steps

1. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

2. **Configure API endpoints**

   Open `lib/config/api_config.dart` and update the `baseUrl` to point to your server:

   ```dart
   // For Android emulator (pointing to host machine)
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   
   // For iOS simulator
   // static const String baseUrl = 'http://localhost:8000/api';
   
   // For physical devices, use your computer's IP address
   // static const String baseUrl = 'http://192.168.x.x:8000/api';
   ```

   Note:
    - `10.0.2.2` is the special IP that Android emulators use to connect to the host machine's localhost
    - For iOS simulators, you can use `localhost` instead
    - For physical devices, use your computer's actual IP address on the network

3. **Run the application**

   ```bash
   flutter run
   ```

   This will launch the app on your connected device or simulator.

### Building for Production

To build a release version of the app:

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```
