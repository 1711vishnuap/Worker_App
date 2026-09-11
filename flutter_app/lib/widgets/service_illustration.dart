import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Small, local vector illustrations: crisp on every device, with no downloads.
class ServiceIllustration extends StatelessWidget {
  final String category;
  final double size;
  final bool fullBody;

  const ServiceIllustration(
      {super.key,
      this.category = 'Repair',
      this.size = 72,
      this.fullBody = false});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
            width: size,
            height: size,
            child:
                CustomPaint(painter: _ProfessionalPainter(category, fullBody))),
      );
}

class _ProfessionalPainter extends CustomPainter {
  final String category;
  final bool fullBody;
  _ProfessionalPainter(this.category, this.fullBody);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 120);
    final key = category.toLowerCase();
    final cleaning = key.contains('clean') || key.contains('laundry');
    final carpenter = key.contains('carpent') || key.contains('paint');
    final electrical = key.contains('electric');
    final shirt = cleaning
        ? const Color(0xFF91BCE4)
        : carpenter
            ? const Color(0xFFE6AD7B)
            : const Color(0xFF679FF1);
    const navy = Color(0xFF203C67);
    const skin = Color(0xFFF1BE99);
    final paint = Paint()..isAntiAlias = true;
    void rect(double x, double y, double w, double h, Color color,
        [double radius = 0]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, w, h), Radius.circular(radius)),
          paint..color = color);
    }

    void oval(double x, double y, double w, double h, Color color) {
      canvas.drawOval(Rect.fromLTWH(x, y, w, h), paint..color = color);
    }

    void line(Offset a, Offset b, Color color, double width) {
      canvas.drawLine(
          a,
          b,
          paint
            ..color = color
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round);
    }

    if (fullBody) {
      oval(9, 108, 105, 8, const Color(0xFFCBDCF8));
      canvas.save();
      canvas.translate(10, 0);
      canvas.scale(.85, .85);
    } else {
      oval(
          8,
          12,
          104,
          104,
          cleaning
              ? const Color(0xFFE8F2FB)
              : carpenter
                  ? const Color(0xFFFFF1E6)
                  : AppColors.primaryLight);
    }
    // Silhouette, rolled sleeves, and the overalls.
    rect(34, 53, 49, fullBody ? 43 : 56, shirt, 15);
    line(const Offset(37, 65), const Offset(28, 86), shirt, 16);
    line(const Offset(80, 65), const Offset(91, 81), shirt, 16);
    line(const Offset(28, 86), const Offset(40, 94), skin, 10);
    line(const Offset(91, 81), const Offset(101, 61), skin, 10);
    rect(49, 43, 18, 17, skin, 6);
    rect(39, 16, 38, 35, navy, 12);
    oval(40, 23, 36, 34, skin);
    rect(39, 16, 38, 16, electrical ? const Color(0xFFFFCA68) : navy, 8);
    rect(36, 26, 44, 6, electrical ? const Color(0xFFF0AE38) : navy, 3);
    rect(50, 35, 2.5, 3, navy, 1);
    rect(66, 35, 2.5, 3, navy, 1);
    canvas.drawArc(
        const Rect.fromLTWH(53, 39, 11, 7),
        .1,
        2.9,
        false,
        paint
          ..color = navy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);
    paint.style = PaintingStyle.fill;
    rect(43, 57, 7, 25, navy, 2);
    rect(68, 57, 7, 25, navy, 2);
    rect(42, 72, 34, fullBody ? 23 : 36, navy, 4);
    rect(51, 79, 16, 12, shirt, 3);
    oval(45, 72, 3, 3, const Color(0xFFFFD780));
    oval(69, 72, 3, 3, const Color(0xFFFFD780));
    if (fullBody) {
      line(const Offset(50, 94), const Offset(47, 123), navy, 13);
      line(const Offset(69, 94), const Offset(76, 122), navy, 13);
      rect(36, 121, 19, 9, const Color(0xFF142947), 4);
      rect(69, 120, 21, 9, const Color(0xFF142947), 4);
      rect(20, 91, 13, 8, navy, 2);
      rect(12, 97, 31, 22, AppColors.primary, 4);
      rect(12, 101, 31, 4, const Color(0xFF8DB7FD));
      rect(25, 100, 5, 7, const Color(0xFFFFD780), 1);
    }
    // Tools make the service recognizable even at category-tile size.
    if (cleaning || key.contains('paint')) {
      line(const Offset(101, 40), const Offset(101, 85), navy, 4);
      rect(92, 33, 19, 17, cleaning ? const Color(0xFFF5C777) : shirt, 3);
      if (cleaning) {
        for (var i = 0; i < 4; i++) {
          rect(94 + i * 4, 43, 2, 9, const Color(0xFFE4AC59), 1);
        }
      }
    } else if (carpenter) {
      line(const Offset(101, 41), const Offset(101, 76),
          const Color(0xFFB77850), 5);
      rect(89, 35, 23, 10, const Color(0xFF7189AA), 2);
    } else if (key.startsWith('ac ') || key.startsWith('air ')) {
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate(100, 44);
        canvas.rotate(i * 1.0472);
        line(const Offset(0, -12), const Offset(0, 12), const Color(0xFF508ECD),
            3);
        canvas.restore();
      }
    } else {
      line(const Offset(101, 44), const Offset(101, 76),
          const Color(0xFF8198B7), 5);
      canvas.drawArc(
          const Rect.fromLTWH(92, 30, 18, 20),
          -.4,
          3.95,
          false,
          paint
            ..color = const Color(0xFF8198B7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5);
      paint.style = PaintingStyle.fill;
    }
    if (fullBody) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProfessionalPainter oldDelegate) =>
      category != oldDelegate.category || fullBody != oldDelegate.fullBody;
}
