import 'package:flutter/material.dart';

// ---------- Palette (warm cream, deep green, soft card colors) ----------
const Color paperColor = Color(0xFFF4F1EA);
const Color inkColor = Color(0xFF1F2A24);
const Color primaryGreen = Color(0xFF245C44);
const Color mutedTextColor = Color(0xFF8A857B);
const Color borderColor = Color(0xFFE8E3D8);
const Color chipColor = Color(0xFFF1EEE7);
const Color successColor = primaryGreen;
const Color errorColor = Color(0xFFB3261E);

// Serif font used for titles (built into Android, no package needed).
const String headingFont = 'serif';

// Every post gets a color and icon based on its id: green, purple, orange.
const List<Color> postColors = [
  Color(0xFF2B5B45),
  Color(0xFF7A5C9E),
  Color(0xFFC8672A),
];
const List<IconData> postIcons = [
  Icons.eco_outlined,
  Icons.cloud_outlined,
  Icons.wb_sunny_outlined,
];

Color postColorFor(int postId) => postColors[postId % postColors.length];
IconData postIconFor(int postId) => postIcons[postId % postIcons.length];

const List<BoxShadow> softShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6)),
];

// ---------- Theme ----------
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: primaryGreen,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: inkColor,
    error: errorColor,
  ),
  scaffoldBackgroundColor: paperColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: paperColor,
    foregroundColor: inkColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: 76,
    titleSpacing: 20,
    titleTextStyle: TextStyle(
      fontFamily: headingFont,
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: inkColor,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: CircleBorder(),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryGreen),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: primaryGreen, width: 2),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryGreen),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: inkColor,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);

// ---------- Shared UI pieces (used by every screen) ----------

// White rounded card with a soft shadow.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;

  const SoftCard({
    super.key,
    required this.child,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(color: Colors.white, child: child),
      ),
    );
  }
}

// Colored side strip with an icon and a dot, shown on the left of each card.
class AccentStrip extends StatelessWidget {
  final int postId;

  const AccentStrip({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      color: postColorFor(postId),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(postIconFor(postId), color: Colors.white, size: 26),
          const SizedBox(height: 10),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// Small rounded label. Give it an icon (neutral) or a dotColor (tinted).
class InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;

  const InfoChip({super.key, required this.label, this.icon, this.dotColor});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = dotColor == null
        ? chipColor
        : Color.alphaBlend(dotColor!.withAlpha(36), Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: mutedTextColor),
            const SizedBox(width: 4),
          ],
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: inkColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Round green button used in the AppBar.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: primaryGreen,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

// Row with a serif section title on the left and a small count on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final String trailingText;

  const SectionHeader({
    super.key,
    required this.title,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: headingFont,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            trailingText,
            style: const TextStyle(color: mutedTextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}