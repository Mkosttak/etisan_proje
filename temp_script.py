from pathlib import Path
path = Path(r"lib/screens/reservations/create_reservation_screen.dart")
text = path.read_text(encoding='utf-8')
old = "  Widget _buildDateSelector(MealProvider mealProvider) {\r\n    return SizedBox(\r\n      height: 80,\r\n      child: ListView.builder(\r\n        scrollDirection: Axis.horizontal,\r\n        padding: const EdgeInsets.symmetric(horizontal: 16),"
new = "  Widget _buildDateSelector(MealProvider mealProvider, {EdgeInsetsGeometry? padding}) {\r\n    final horizontalPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);\r\n    return SizedBox(\r\n      height: 80,\r\n      child: ListView.builder(\r\n        scrollDirection: Axis.horizontal,\r\n        padding: horizontalPadding,"
if old not in text:
    raise SystemExit('block not found')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
