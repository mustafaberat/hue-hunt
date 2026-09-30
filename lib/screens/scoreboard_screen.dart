/// Çevrimiçi top-5 skorlarını Figma'daki yarışma görünümüyle sunar.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/app_bottom_nav.dart';
import '../config/app_config.dart';
import '../scoreboard/score.dart';
import '../scoreboard/scoreboard_session.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late final ScoreboardSession _scoreboard;

  @override
  void initState() {
    super.initState();
    _scoreboard = ScoreboardSession()..prefetch();
  }

  @override
  void dispose() {
    _scoreboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF151923), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _ScoreboardHeader(
                title: t(AppStringKey.scoreboard),
                backLabel: t(AppStringKey.home),
                topFiveLabel: t(AppStringKey.scoreboardTopFive),
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _scoreboard,
                  builder:
                      (context, _) =>
                          _ScoreboardContent(future: _scoreboard.top),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}

class _ScoreboardHeader extends StatelessWidget {
  const _ScoreboardHeader({
    required this.title,
    required this.backLabel,
    required this.topFiveLabel,
    required this.onBack,
  });

  final String title;
  final String backLabel;
  final String topFiveLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.settingsHeaderStart,
        AppDimens.settingsHeaderTop,
        AppDimens.pagePadding,
        AppDimens.settingsHeaderEndGap,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.text,
            tooltip: backLabel,
          ),
          const SizedBox(width: AppDimens.spaceXXSmall),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          _HeaderMark(label: topFiveLabel),
        ],
      ),
    );
  }
}

class _HeaderMark extends StatelessWidget {
  const _HeaderMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFFFFBA20),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ScoreboardContent extends StatelessWidget {
  const _ScoreboardContent({required this.future});

  final Future<List<ScoreEntry>>? future;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    if (future == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.text),
      );
    }

    return FutureBuilder<List<ScoreEntry>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.text),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Text(
                t(AppStringKey.scoreboardUnavailable),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final scores = snapshot.data!;
        if (scores.isEmpty) {
          return Center(child: Text(t(AppStringKey.scoreboardEmpty)));
        }

        final podium = scores.take(3).toList();
        final remaining = scores.skip(3).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ScoreboardIntro(count: scores.length),
            const SizedBox(height: 16),
            _Podium(scores: podium),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                t(AppStringKey.scoreboardGlobalStandings),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < remaining.length; i++)
                _StandingRow(rank: i + podium.length + 1, entry: remaining[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ScoreboardIntro extends StatelessWidget {
  const _ScoreboardIntro({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        gradient: const LinearGradient(
          colors: [Color(0xFF242832), Color(0xFF181A1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x33FFBA20),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFBA20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppScope.of(context).t(AppStringKey.scoreboardChampions),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppScope.of(context)
                      .t(AppStringKey.scoreboardConnectedScores)
                      .replaceAll('{count}', '$count'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFBDF4FF)),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.scores});

  final List<ScoreEntry> scores;

  @override
  Widget build(BuildContext context) {
    final first = scores.isNotEmpty ? scores[0] : null;
    final second = scores.length > 1 ? scores[1] : null;
    final third = scores.length > 2 ? scores[2] : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumCard(
            entry: second,
            rank: 2,
            color: const Color(0xFFBDF4FF),
            height: 148,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumCard(
            entry: first,
            rank: 1,
            color: const Color(0xFFFFBA20),
            height: 184,
            featured: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PodiumCard(
            entry: third,
            rank: 3,
            color: const Color(0xFFCABEFF),
            height: 136,
          ),
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.entry,
    required this.rank,
    required this.color,
    required this.height,
    this.featured = false,
  });

  final ScoreEntry? entry;
  final int rank;
  final Color color;
  final double height;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final enabled = entry != null;
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color:
            enabled
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: color.withValues(alpha: enabled ? 0.55 : 0.15),
        ),
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.16),
                    blurRadius: 18,
                  ),
                ]
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: featured ? 62 : 52,
            height: featured ? 62 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: enabled ? 0.20 : 0.06),
              border: Border.all(
                color: color.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: enabled ? color : AppColors.textMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entry?.name ?? '---',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled ? AppColors.text : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry == null ? '-' : 'LV ${entry!.level}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.rank, required this.entry});

  final int rank;
  final ScoreEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF252A37),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  'Level ${entry.level}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '${entry.level}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBDF4FF),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
