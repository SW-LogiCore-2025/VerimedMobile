# VeriMed App

Una aplicación Flutter para escaneo de códigos QR y códigos de barras.

## Requisitos previos

- Flutter 3.29.2 o superior
- Dart 3.7.0 o superior
- Android Studio / Xcode (para desarrollo móvil)

## Configuración del proyecto

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio-url>
cd verimedapp
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configuración de Android
- Asegúrate de tener Android SDK 35 instalado
- Configura tu `local.properties` en `android/` con la ruta de tu Android SDK:
```
sdk.dir=C:\\Users\\TuUsuario\\AppData\\Local\\Android\\Sdk
```

### 4. Configuración de iOS (solo macOS)
```bash
cd ios
pod install
cd ..
```

### 5. Ejecutar la aplicación

#### Android
```bash
flutter run -d android
```

#### iOS (solo macOS)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

## Características

- Escaneo de códigos QR
- Escaneo de códigos de barras
- Soporte para flash
- Selección de imágenes de galería
- Interfaz moderna y responsive

## Permisos necesarios

### Android
- `CAMERA` - Para acceso a la cámara
- `FLASHLIGHT` - Para control del flash

### iOS
- `NSCameraUsageDescription` - Para acceso a la cámara
- `NSPhotoLibraryUsageDescription` - Para acceso a la galería

## Estructura del proyecto

```
lib/
├── main.dart              # Punto de entrada
├── screens/              # Pantallas de la aplicación
├── widgets/              # Widgets reutilizables
└── utilities/            # Utilidades y helpers
```

## Dependencias principales

- `mobile_scanner: ^7.0.1` - Escáner de códigos
- `image_picker: ^1.1.2` - Selector de imágenes

## Troubleshooting

### Error de compilación en Android
```bash
flutter clean
flutter pub get
flutter run
```

### Error de pods en iOS
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```
