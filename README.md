# Summit Clean (Garmin Connect IQ watch face)

A clean, battery-friendly watch face for the Garmin Fenix 7 series: big white time, a step-goal arc around the bezel, date and native weather in an accent color, and two configurable bottom fields.

Targets: fenix 7 (47mm, 260x260) and fenix 7 Pro.
Status: builds and runs in the simulator and on a real Fenix 7. Store submission is in progress.

## Features
- Time in large white digits, 12 or 24 hour following the watch setting.
- Step-goal arc that fills clockwise from 12 o'clock.
- Date and temperature from Garmin's built-in weather. No account, API key, or location permission.
- Two bottom fields, each set to steps, battery, heart rate, or calories.
- Accent color: orange, cyan, green, or white.
- Redraws once a minute only. No per-second updates, animation, or background services.

## Build and run
1. Open this folder in VS Code (Monkey C extension installed, Connect IQ SDK 9.2.0 or later, Java 17).
2. Cmd/Ctrl+Shift+P -> "Monkey C: Build Current Project", pick fenix7.
3. "Monkey C: Run" starts the simulator with the face.
4. Sideload: build for the device, then copy the built `.prg` from `bin/` to `<watch>/GARMIN/APPS/` over USB. The Fenix 7 uses MTP, so on macOS use a tool such as OpenMTP.
5. Store: "Monkey C: Export Project" -> `.iq` file -> upload at apps-developer.garmin.com.

You need your own Connect IQ developer key to build. Generate one with the SDK or `openssl`, keep it outside the repository, and never commit it.

If the compiler rejects a product id or minApiLevel, use the SDK Manager device list to confirm the exact ids (for example fenix7, fenix7pro) and adjust `manifest.xml`.

Settings changed in the Connect IQ phone app only appear for store-published apps. Side-loaded builds use the defaults in `resources/properties/properties.xml`.

## License
MIT. See [LICENSE](LICENSE).
