import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

void main() {
  // Let's print constructor parameters / fields of LiquidGlassSettings
  print("LiquidGlassSettings fields:");
  // Let's create an instance to see what parameters it has
  const settings = LiquidGlassSettings(
    glassColor: null,
    blur: 10,
  );
  print("glassColor: ${settings.glassColor}");
  print("blur: ${settings.blur}");
}
