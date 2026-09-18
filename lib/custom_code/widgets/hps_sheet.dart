import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens visuais copiados da tela de login.
class HpsUi {
  static const Color bg = Color(0xFF0B0F17);
  static const Color surface = Color(0xFF131B2E);
  static const Color inputFill = Color(0xFF0F172A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color accent = Color(0xFF3B82F6);
  static const Color buttonStart = Color(0xFF2563EB);
  static const Color buttonEnd = Color(0xFF1D4ED8);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color glowBlue = Color(0xFF2563EB);
  static const Color glowTeal = Color(0xFF0D9488);

  static const double radiusCard = 24;
  static const double radiusControl = 14;
  static const double radiusPill = 30;
  static const double radiusSheet = 20;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 36,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: glowBlue.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];
}

/// Fundo com glows + grade 48px, igual ao login.
class HpsGridBackground extends StatelessWidget {
  const HpsGridBackground({super.key, this.child, this.expand = true});

  final Widget? child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: expand ? StackFit.expand : StackFit.loose,
      children: [
        const Positioned.fill(child: ColoredBox(color: HpsUi.bg)),
        Positioned(
          top: -120,
          left: -100,
          child: IgnorePointer(
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HpsUi.glowBlue.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -100,
          child: IgnorePointer(
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HpsUi.glowTeal.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _HpsGridPainter()),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _HpsGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Botão X único do overlay (44×44, ícone 22).
class HpsCloseButton extends StatelessWidget {
  const HpsCloseButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 22,
            color: HpsUi.textSecondary,
          ),
        ),
      ),
    );
  }
}

Widget _hpsEscWrap(BuildContext ctx, Widget child) {
  return CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.of(ctx).maybePop(),
    },
    child: Focus(autofocus: true, child: child),
  );
}

/// Overlay unificado: dialog 920×840 (≥850px) ou sheet 0.92–0.95.
/// Com [compact], o dialog usa sizing intrínseco (max 480px) e o sheet abre em 0.55.
Future<T?> showHpsSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool showClose = true,
  bool compact = false,
  double initialChildSize = 0.92,
  double minChildSize = 0.25,
  double maxChildSize = 0.95,
}) {
  final wide = MediaQuery.sizeOf(context).width >= 850;
  if (wide) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (dialogCtx) {
        final chrome = _HpsSheetChrome(
          title: title,
          showClose: showClose,
          showHandle: false,
          compact: compact,
          onClose: () => Navigator.of(dialogCtx).maybePop(),
          child: child,
        );
        final dialogChild = compact
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: chrome,
              )
            : LayoutBuilder(
                builder: (ctx, constraints) {
                  final size = MediaQuery.sizeOf(ctx);
                  final maxW = (size.width - 64).clamp(280.0, 920.0);
                  final maxH = (size.height - 48).clamp(420.0, 840.0);
                  return SizedBox(
                    width: maxW,
                    height: maxH,
                    child: chrome,
                  );
                },
              );
        return _hpsEscWrap(
          dialogCtx,
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: dialogChild,
          ),
        );
      },
    );
  }

  final clampedMin = minChildSize < 0.25 ? 0.25 : minChildSize;
  final sheetInitial = compact && initialChildSize == 0.92
      ? 0.55
      : initialChildSize;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.70),
    builder: (sheetCtx) {
      return _hpsEscWrap(
        sheetCtx,
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (n) {
            if (n.extent <= (n.minExtent + 0.03)) {
              Navigator.of(sheetCtx).maybePop();
              return true;
            }
            return false;
          },
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: sheetInitial,
            minChildSize: clampedMin,
            maxChildSize: maxChildSize,
            shouldCloseOnMinExtent: true,
            builder: (context, scrollController) {
              return _HpsSheetChrome(
                title: title,
                showClose: showClose,
                showHandle: true,
                scrollController: scrollController,
                onClose: () => Navigator.of(sheetCtx).maybePop(),
                child: child,
              );
            },
          ),
        ),
      );
    },
  );
}

class _HpsSheetChrome extends StatelessWidget {
  const _HpsSheetChrome({
    required this.child,
    required this.showClose,
    required this.showHandle,
    this.title,
    this.onClose,
    this.scrollController,
    this.compact = false,
  });

  final Widget child;
  final String? title;
  final bool showClose;
  final bool showHandle;
  final VoidCallback? onClose;
  final ScrollController? scrollController;
  final bool compact;

  Widget _titleBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        showHandle ? 8 : 14,
        showClose ? 60 : 16,
        8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title!,
          style: GoogleFonts.interTight(
            color: HpsUi.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _legacyHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _fatHandle() {
    return SizedBox(
      height: 48,
      child: Center(
        child: Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = showHandle
        ? const BorderRadius.vertical(top: Radius.circular(HpsUi.radiusSheet))
        : BorderRadius.circular(HpsUi.radiusSheet);
    final closeTop = (showHandle ? 8.0 : 12.0) + (kIsWeb ? 8.0 : 0.0);

    // Compact dialog sizes to content; DSS / 920×840 keep Expanded.
    final shrinkWrap = compact && !showHandle;

    // DSS controller goes ONLY on the 48px handle ListView so inner
    // forms/ListViews keep their own scroll (no unbounded height).
    final Widget body = Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (showHandle && scrollController != null)
          SizedBox(
            height: 48,
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [_fatHandle()],
            ),
          )
        else if (showHandle)
          _legacyHandle(),
        if (title != null && title!.isNotEmpty) _titleBar(),
        if (shrinkWrap) child else Expanded(child: child),
      ],
    );

    return ClipRRect(
      borderRadius: radius,
      child: HpsGridBackground(
        expand: !shrinkWrap,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HpsUi.surface.withOpacity(0.85),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: SafeArea(
              top: true,
              bottom: true,
              child: Stack(
                children: [
                  if (shrinkWrap) body else Positioned.fill(child: body),
                  if (showClose)
                    Positioned(
                      top: closeTop,
                      right: 12,
                      child: HpsCloseButton(onPressed: onClose),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
