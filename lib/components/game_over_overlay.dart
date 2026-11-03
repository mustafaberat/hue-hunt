/// Game Over kartı: seviye, isteğe bağlı skorboard, tekrar / ana sayfa.
///
/// [ScoreboardSession.top] null ise tablo hiç çizilmez (çevrimdışı).
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';
import '../scoreboard/score.dart';
import '../scoreboard/scoreboard_session.dart';
import 'app_button.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({
    required this.level,
    required this.bestLevel,
    required this.previousBestLevel,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.bestStreak,
    required this.scoreboard,
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  final int level;
  final int bestLevel;
  final int previousBestLevel;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final int bestStreak;
  final ScoreboardSession scoreboard;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  final _name = TextEditingController();
  List<ScoreEntry>? _board;
  var _saved = false;
  var _saving = false;
  String? _saveError;
  int? _highlightLevel;
  var _isNewRecord = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: AppMotion.gameOverCardReveal,
    )..forward();
    final curve = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _scale = Tween(begin: 0.94, end: 1.0).animate(curve);
    _slide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _revealController.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(List<ScoreEntry> current) async {
    if (_saving) {
      return;
    }
    final name = ScoreRules.parseName(_name.text);
    if (name == null) {
      return;
    }
    setState(() {
      _saving = true;
      _saveError = null;
      _isNewRecord = current.isEmpty || widget.level > current.first.level;
    });
    final save = widget.scoreboard.save(
      board: current,
      name: name,
      level: widget.level,
    );
    List<ScoreEntry>? synced;
    try {
      synced = await save.synced;
    } catch (_) {
      synced = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      if (synced == null) {
        _saveError = AppStringKey.scoreboardUnavailable;
      } else {
        _board = synced;
        _saved = true;
        _highlightLevel = widget.level;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      namesRoute: true,
      label: AppScope.of(
        context,
      ).t(_isNewRecord ? AppStringKey.newRecord : AppStringKey.gameOver),
      child: ColoredBox(
        color: AppColors.overlay,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.overlayMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.overlayInset,
              ),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: ScaleTransition(
                    scale: _scale,
                    child: _Card(child: _body(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final t = AppScope.of(context).t;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ResultHeader(
          title: t(
            _isNewRecord ? AppStringKey.newRecord : AppStringKey.gameOver,
          ),
          isNewRecord: _isNewRecord,
        ),
        AnimatedSwitcher(
          duration: AppMotion.scoreRowHighlight,
          child:
              _highlightLevel == null
                  ? const SizedBox.shrink()
                  : Padding(
                    padding: const EdgeInsets.only(top: AppDimens.spaceXSmall),
                    child: Text(
                      t(AppStringKey.scoreSaved),
                      key: const ValueKey('score-saved'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.logoAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
        ),
        const SizedBox(height: AppDimens.spaceLarge),
        _ResultLevelCard(
          label: t(AppStringKey.reachedLevel),
          level: widget.level,
        ),
        const SizedBox(height: AppDimens.spaceXSmall),
        Text(
          t(AppStringKey.personalBest).replaceAll(
            '{level}',
            '${widget.bestLevel}',
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        if (widget.previousBestLevel > widget.level) ...[
          const SizedBox(height: AppDimens.spaceXXSmall),
          Text(
            t(AppStringKey.recordGap).replaceAll(
              '{count}',
              '${widget.previousBestLevel - widget.level}',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.logoAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: AppDimens.spaceMedium),
        _StatsSummary(
          correctCount: widget.correctCount,
          wrongCount: widget.wrongCount,
          accuracy: widget.accuracy,
          bestStreak: widget.bestStreak,
        ),
        const SizedBox(height: AppDimens.spaceLarge),
        ListenableBuilder(
          listenable: widget.scoreboard,
          builder:
              (context, _) => _ScoreboardGate(
                future: widget.scoreboard.top,
                board: _board,
                level: widget.level,
                saved: _saved,
                saving: _saving,
                saveError: _saveError,
                highlightLevel: _highlightLevel,
                name: _name,
                onSave: _save,
              ),
        ),
        const SizedBox(height: AppDimens.spaceLarge),
        AppButton(
          label: t(AppStringKey.playAgain),
          onPressed: widget.onPlayAgain,
        ),
        const SizedBox(height: AppDimens.spaceMedium),
        AppButton(
          label: t(AppStringKey.home),
          primary: false,
          onPressed: widget.onHome,
        ),
      ],
    );
  }
}

class _StatsSummary extends StatelessWidget {
  const _StatsSummary({
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.bestStreak,
  });

  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    final values = [
      t(AppStringKey.statsCorrect).replaceAll('{count}', '$correctCount'),
      t(AppStringKey.statsWrong).replaceAll('{count}', '$wrongCount'),
      t(AppStringKey.statsAccuracy).replaceAll(
        '{percent}',
        '${(accuracy * 100).round()}',
      ),
      t(AppStringKey.statsBestStreak).replaceAll('{count}', '$bestStreak'),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimens.spaceMedium,
      runSpacing: AppDimens.spaceXSmall,
      children: [
        for (final value in values)
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title, required this.isNewRecord});

  final String title;
  final bool isNewRecord;

  @override
  Widget build(BuildContext context) {
    final accent =
        isNewRecord ? const Color(0xFFFFBA20) : const Color(0xFFCABEFF);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 2,
              color: accent.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 10),
            Icon(
              isNewRecord
                  ? Icons.emoji_events_rounded
                  : Icons.auto_awesome_rounded,
              size: AppDimens.gameOverIcon,
              color: accent,
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 2,
              color: accent.withValues(alpha: 0.55),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spaceXSmall),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: AppType.gameOverTitle,
            fontWeight: FontWeight.w800,
            letterSpacing: AppType.overlayTracking,
          ),
        ),
      ],
    );
  }
}

class _ResultLevelCard extends StatelessWidget {
  const _ResultLevelCard({required this.label, required this.level});

  final String label;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF252A37), Color(0xFF1A1F2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66CABEFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44937DFF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0x33937DFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x99CABEFF)),
            ),
            child: Center(
              child: Text(
                '$level',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFCABEFF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.flag_rounded, color: Color(0xFF00DAF3)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.overlayInner,
          AppDimens.overlayInnerTop,
          AppDimens.overlayInner,
          AppDimens.overlayInner,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

/// [future] yoksa (offline) hiç yer kaplamaz. Hata = gizle.
class _ScoreboardGate extends StatelessWidget {
  const _ScoreboardGate({
    required this.future,
    required this.board,
    required this.level,
    required this.saved,
    required this.saving,
    required this.saveError,
    required this.highlightLevel,
    required this.name,
    required this.onSave,
  });

  final Future<List<ScoreEntry>>? future;
  final List<ScoreEntry>? board;
  final int level;
  final bool saved;
  final bool saving;
  final String? saveError;
  final int? highlightLevel;
  final TextEditingController name;
  final ValueChanged<List<ScoreEntry>> onSave;

  @override
  Widget build(BuildContext context) {
    if (future == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.spaceLarge),
      child: FutureBuilder<List<ScoreEntry>>(
        future: future,
        builder: (context, snapshot) {
          final scores = board ?? snapshot.data;
          if (scores == null) {
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }
            return const SizedBox(
              width: AppDimens.iconSection,
              height: AppDimens.iconSection,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.text,
              ),
            );
          }
          return _ScoreboardPanel(
            scores: scores,
            showTable: saved,
            showForm: !saved && ScoreRules.qualifies(scores, level),
            showRank: !saved && !ScoreRules.qualifies(scores, level),
            saving: saving,
            saveError: saveError,
            highlightLevel: highlightLevel,
            name: name,
            onSave: () => onSave(scores),
          );
        },
      ),
    );
  }
}

class _ScoreboardPanel extends StatelessWidget {
  const _ScoreboardPanel({
    required this.scores,
    required this.showTable,
    required this.showForm,
    required this.showRank,
    required this.saving,
    required this.saveError,
    required this.highlightLevel,
    required this.name,
    required this.onSave,
  });

  final List<ScoreEntry> scores;
  final bool showTable;
  final bool showForm;
  final bool showRank;
  final bool saving;
  final String? saveError;
  final int? highlightLevel;
  final TextEditingController name;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTable) ...[
          Row(
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                size: 18,
                color: Color(0xFFCABEFF),
              ),
              const SizedBox(width: AppDimens.spaceXSmall),
              Expanded(
                child: Text(
                  t(AppStringKey.scoreboard).toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Text(
                'TOP 5',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceMedium),
          if (scores.isEmpty)
            Text(
              t(AppStringKey.scoreboardEmpty),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          _AnimatedScoreRows(scores: scores, highlightLevel: highlightLevel),
        ],
        if (showRank) _RankMessage(text: t(AppStringKey.scoreboardNotEntered)),
        if (showForm) ...[
          const SizedBox(height: AppDimens.spaceRegular),
          TextField(
            controller: name,
            maxLength: GameConfig.scoreNameMax,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSave(),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              counterText: '',
              hintText: t(AppStringKey.yourName),
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceXSmall),
          if (saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spaceXSmall),
              child: Text(
                t(saveError!),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.heart),
              ),
            ),
          AppButton(
            label: t(AppStringKey.saveScore),
            onPressed: saving ? null : onSave,
            busy: saving,
          ),
        ],
      ],
    );
  }
}

class _RankMessage extends StatelessWidget {
  const _RankMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceRegular,
        vertical: AppDimens.spaceMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipIdle,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AnimatedScoreRows extends StatelessWidget {
  const _AnimatedScoreRows({required this.scores, this.highlightLevel});

  final List<ScoreEntry> scores;
  final int? highlightLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < scores.length; i++)
          TweenAnimationBuilder<double>(
            key: ValueKey('${scores[i].name}-${scores[i].level}-$i'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppMotion.scoreRowReveal,
            curve: Curves.easeOutCubic,
            builder:
                (context, value, child) => Transform.translate(
                  offset: Offset(0, (1 - value) * AppDimens.scoreRowOffset),
                  child: Opacity(opacity: value, child: child),
                ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i == scores.length - 1 ? 0 : AppDimens.spaceXSmall,
              ),
              child: _ScoreRow(
                rank: i + 1,
                entry: scores[i],
                highlighted: highlightLevel == scores[i].level,
              ),
            ),
          ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.rank,
    required this.entry,
    this.highlighted = false,
  });

  final int rank;
  final ScoreEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rankColor = switch (rank) {
      1 => const Color(0xFFFFBA20),
      2 => const Color(0xFFBDF4FF),
      3 => const Color(0xFFCABEFF),
      _ => AppColors.textMuted,
    };
    final initial = entry.name.trim().isEmpty
        ? '?'
        : entry.name.trim().characters.first.toUpperCase();
    return AnimatedContainer(
      duration: AppMotion.scoreRowHighlight,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x332E1D5C) : const Color(0x991A1F2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF937DFF)
              : AppColors.divider,
        ),
        boxShadow: highlighted
            ? const [
                BoxShadow(
                  color: Color(0x33937DFF),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: text.titleSmall?.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceXSmall),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: rankColor.withValues(alpha: 0.42)),
            ),
            child: Center(
              child: Text(
                initial,
                style: text.titleMedium?.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.chipIdle,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'LVL ${entry.level}',
                    style: text.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceXSmall),
          Text(
            '${entry.level}',
            style: text.titleMedium?.copyWith(
              color: rankColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
