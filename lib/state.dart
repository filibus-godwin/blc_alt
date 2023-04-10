import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio(BaseOptions(baseUrl: 'http://192.168.43.75:5000'));

class Candidate {
  const Candidate({
    required this.candidateName,
    required this.partyId,
    required this.partyName,
    required this.candidateImageUrl,
  });

  final String candidateName;
  final String partyId;
  final String candidateImageUrl;
  final String partyName;

  factory Candidate.fromJson(Map<String, dynamic> data) {
    return Candidate(
      candidateName: data['candidateName'],
      partyId: data['partyId'],
      partyName: data['partyName'],
      candidateImageUrl: data['candidateImageUrl'],
    );
  }

  @override
  String toString() {
    return 'Candidate(candidateName: $candidateName, candidateImageUrl: $candidateImageUrl, partyId: $partyId, partyName: $partyName)';
  }
}

final candiatesProvider = FutureProvider<List<Candidate>?>((_) async {
  final List<Candidate> candidates = [];
  try {
    final result = await dio.get<Map<String, dynamic>>('/candidates');
    if (result.statusCode == 202) {
      for (final candidate in result.data!['candidates']) {
        final c = Candidate.fromJson(candidate);
        candidates.add(c);
      }
    }
    return candidates;
  } on DioError {
    rethrow;
  }
});

typedef InitResp = Map<String, dynamic>;

class InitRes {}

class Voted extends InitRes {}

class NotVoted extends InitRes {}

typedef I = Map<String, dynamic>;

Future<InitRes?> futureInit() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("id");
    if (id == null) {
      final resp = await dio.get<InitResp>('/id');
      prefs.setString("id", resp.data?['id']);
      return NotVoted();
    }
    final resp = await dio.get<I>("/voted/$id");
    if (resp.data?["voted"]) {
      return Voted();
    }
    return NotVoted();
  } catch (e) {
    rethrow;
  }
}

Future<void> vote(String partyId) async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString("id");
  try {
    final _ = await dio.get("/vote/$id/$partyId");
    return;
  } catch (e) {
    rethrow;
  }
}
