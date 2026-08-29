/// Seviye geçişinde kutuların sönüp yeniden doğması.
///
/// [GameGrid] yalnızca kutuları çizer. Süre / eğri / hizalama [AppMotion]'da.
library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Bir hücrenin o karedeki konumu ve görünürlüğü.
class GridCellPose {
  const GridCellPose({
    required this.row,
    required this.col,
    required this.index,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.scale,
    required this.outgoing,
  });

  final int row;
  final int col;

  /// [outgoing] ise önceki grid index'i, değilse yeni.
  final int index;
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double scale;

  /// true: eski round renkleri. false: yeni round.
  final bool outgoing;
}

/// t ∈ [0,1] (eğri uygulanmış) için tüm hücre pozları.
abstract final class GridRebirthMath {
  static double cellSize(int n, double board, double gap) {
    return (board - gap * (n - 1)) / n;
  }

  static List<GridCellPose> poses({
    required double t,
    required int fromN,
    required int toN,
    required double board,
    required double gap,
  }) {
    if (t >= 1) {
      return _settled(toN, board, gap);
    }
    if (t <= 0) {
      return _outgoing(fromN, board, gap, 0);
    }

    final split = AppMotion.gridRebirthSplit;
    if (t < split) {
      return _outgoing(fromN, board, gap, t / split);
    }
    return _incoming(toN, board, gap, (t - split) / (1 - split));
  }

  static List<GridCellPose> _settled(int n, double board, double gap) {
    return _incoming(n, board, gap, 1);
  }

  static List<GridCellPose> _outgoing(
    int n,
    double board,
    double gap,
    double u,
  ) {
    final cell = cellSize(n, board, gap);
    final scale = 1 + (AppMotion.gridRebirthOutScale - 1) * u;
    final opacity = (1 - u).clamp(0.0, 1.0);
    final poses = <GridCellPose>[];

    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        poses.add(
          GridCellPose(
            row: row,
            col: col,
            index: row * n + col,
            x: col * (cell + gap),
            y: row * (cell + gap),
            size: cell,
            opacity: opacity,
            scale: scale,
            outgoing: true,
          ),
        );
      }
    }
    return poses;
  }

  static List<GridCellPose> _incoming(
    int n,
    double board,
    double gap,
    double u,
  ) {
    final cell = cellSize(n, board, gap);
    final mid = (n - 1) / 2;
    final stagger = AppMotion.gridRebirthStagger;
    final poses = <GridCellPose>[];

    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        // Köşeler biraz geç doğar; toplam süre aynı kalır.
        final delay = n <= 1 ? 0.0 : ((row + col) / (2 * (n - 1))) * stagger;
        final span = 1 - delay;
        final local = span <= 0 ? 1.0 : ((u - delay) / span).clamp(0.0, 1.0);
        final s = local * local * (3 - 2 * local);

        final targetX = col * (cell + gap);
        final targetY = row * (cell + gap);
        // Merkeze yakın doğup slotuna kayar = hizalanma.
        final drift = (1 - s) * cell * AppMotion.gridRebirthAlign;

        poses.add(
          GridCellPose(
            row: row,
            col: col,
            index: row * n + col,
            x: targetX + (mid - col) * drift,
            y: targetY + (mid - row) * drift,
            size: cell,
            opacity: s,
            scale:
                AppMotion.gridRebirthInScale +
                (1 - AppMotion.gridRebirthInScale) * s,
            outgoing: false,
          ),
        );
      }
    }
    return poses;
  }
}

/// [token] değişince rebirth oynatır. İlk karede animasyon yok.
class GridRebirthTick extends StatefulWidget {
  const GridRebirthTick({
    required this.token,
    required this.columns,
    required this.builder,
    super.key,
  });

  /// Round kimliği (renk + index + grid). Değişince oynar.
  final Object token;
  final int columns;
  final Widget Function(
    BuildContext context,
    double t,
    bool animating,
    int fromN,
  )
  builder;

  @override
  State<GridRebirthTick> createState() => _GridRebirthTickState();
}

class _GridRebirthTickState extends State<GridRebirthTick>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  late int _fromN;

  @override
  void initState() {
    super.initState();
    _fromN = widget.columns;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.gridRebirth,
      value: 1,
    );
    _t = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.gridRebirthCurve,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _fromN = widget.columns);
      }
    });
  }

  @override
  void didUpdateWidget(GridRebirthTick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _fromN = oldWidget.columns;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return widget.builder(
          context,
          _t.value,
          _controller.isAnimating,
          _fromN,
        );
      },
    );
  }
}
