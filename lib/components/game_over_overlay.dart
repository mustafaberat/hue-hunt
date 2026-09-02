/// Game Over kartı: seviye, isteğe bağlı skorboard, tekrar / ana sayfa.
///
/// [ScoreboardSession.top] null ise tablo hiç çizilmez (çevrimdışı).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';
import '../scoreboard/score.dart';
import '../scoreboard/scoreboard_session.dart';
import 'app_button.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({
    required this.level,
    required this.scoreboard,
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  final int level;
  final ScoreboardSession scoreboard;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  final _name = TextEditingController();
  List<ScoreEntry>? _board;
  var _saved = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save(List<ScoreEntry> current) {
    final name = ScoreRules.parseName(_name.text);
    if (name == null) {
      return;
    }
    final save = widget.scoreboard.save(
      board: current,
      name: name,
      level: widget.level,
    );
    setState(() {
      _board = save.board;
      _saved = true;
    });
    unawaited(
      save.synced.then((synced) {
        if (!mounted || synced == null) {
          return;
        }
        setState(() => _board = synced);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
            child: _Card(child: _body(context)),
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
        Text(
          t(AppStringKey.gameOver).toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: AppType.overlayTracking,
          ),
        ),
        const SizedBox(height: AppDimens.spaceMedium),
        Text(
          '${t(AppStringKey.reachedLevel)} ${widget.level}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        ListenableBuilder(
          listenable: widget.scoreboard,
          builder:
              (context, _) => _ScoreboardGate(
                future: widget.scoreboard.top,
                board: _board,
                level: widget.level,
                saved: _saved,
                name: _name,
                onSave: _save,
              ),
        ),
        const SizedBox(height: AppDimens.spaceXLarge),
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
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
    required this.name,
    required this.onSave,
  });

  final Future<List<ScoreEntry>>? future;
  final List<ScoreEntry>? board;
  final int level;
  final bool saved;
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
            showForm: !saved && ScoreRules.qualifies(scores, level),
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
    required this.showForm,
    required this.name,
    required this.onSave,
  });

  final List<ScoreEntry> scores;
  final bool showForm;
  final TextEditingController name;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t(AppStringKey.scoreboard),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppDimens.spaceXSmall),
        if (scores.isEmpty)
          Text(
            t(AppStringKey.scoreboardEmpty),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        for (var i = 0; i < scores.length; i++)
          _ScoreRow(rank: i + 1, entry: scores[i]),
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
          AppButton(label: t(AppStringKey.saveScore), onPressed: onSave),
        ],
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.rank, required this.entry});

  final int rank;
  final ScoreEntry entry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceTiny),
      child: Row(
        children: [
          Text('$rank', style: text.bodyMedium),
          const SizedBox(width: AppDimens.spaceSmall),
          Expanded(
            child: Text(
              entry.name,
              style: text.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${entry.level}', style: text.bodyLarge),
        ],
      ),
    );
  }
}
