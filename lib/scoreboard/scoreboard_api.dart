/// Skorboard HTTP. İş kuralı yok; JSON alanları [ScoreJson].
///
/// Çağıran çevrimdışı kontrolünü kendisi yapar — bu katman her zaman ister.
library;

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'score.dart';

abstract final class ScoreboardApi {
  static Uri get _uri => Uri.parse(AppIdentity.scoresUrl);

  static Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.hasConnectivity;
  }

  static Future<List<ScoreEntry>> fetchTop() async {
    final body = await _read(http.get(_uri));
    return _scoresOf(body);
  }

  static Future<ScoreSubmitResult> submit(ScoreEntry entry) async {
    final body = await _read(
      http.post(
        _uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(entry.toJson()),
      ),
    );
    return ScoreSubmitResult(
      scores: _scoresOf(body),
      accepted: body[ScoreJson.accepted] == true,
    );
  }

  static Future<Map<String, dynamic>> _read(
    Future<http.Response> request,
  ) async {
    final response = await request.timeout(AppMotion.scoresFetchTimeout);
    if (response.statusCode != 200) {
      throw Exception('scores ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static List<ScoreEntry> _scoresOf(Map<String, dynamic> body) {
    final raw = body[ScoreJson.scores] as List<dynamic>? ?? const [];
    return [
      for (final row in raw) ScoreEntry.fromJson(row as Map<String, dynamic>),
    ];
  }
}
