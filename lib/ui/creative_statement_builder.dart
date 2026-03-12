import 'package:as_promised_weather/ui/models.dart';

/// Builds creative weather statements with phrase banks and line-splitting.
/// Uses a character-based fit heuristic (no Flutter/TextPainter).
class CreativeStatementBuilder {
  CreativeStatementBuilder({this.maxTitleWidth = 320});

  final double maxTitleWidth;

  /// Approximate max characters per line for "fits" check (conservative for bold 64px).
  int get _maxCharsPerLine => (maxTitleWidth / 18).floor().clamp(8, 100);

  WeatherStatement build({
    required int code,
    required bool isNight,
    required int tempF,
    required int humidity,
    required int windMph,
    required num visibilityMi,
    required int offsetSec,
    required WeatherStatement fallback,
  }) {
    String key = 'pleasant';
    String sub = '';

    if ([95, 96, 99].contains(code)) {
      key = 'rain';
      sub = 'thunderstorm';
    } else if ([71, 73, 75, 77, 85, 86].contains(code)) {
      key = 'snow';
      sub = ([75, 77, 86].contains(code)) ? 'heavy' : 'light';
    } else if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      key = 'rain';
      sub = ([65, 67, 82].contains(code)) ? 'heavy' : 'light';
    } else if ([51, 53, 55, 56, 57].contains(code)) {
      key = 'rain';
      sub = 'light';
    } else if ([45, 48].contains(code) || visibilityMi < 0.5) {
      key = 'atmosphere';
      sub = 'fog';
    } else if (windMph > 25) {
      key = 'atmosphere';
      sub = 'windy';
    } else if (humidity >= 85 && tempF >= 75) {
      key = 'atmosphere';
      sub = 'humid';
    } else if (code == 3) {
      key = 'overcast';
    } else if (code == 1 || code == 2) {
      key = 'partly_cloudy';
    } else if (code == 0) {
      if (tempF >= 92) {
        key = 'hot';
      } else if (tempF <= 32) {
        key = 'cold';
        sub = 'freezing';
      } else {
        key = 'clear';
      }
    } else {
      if (tempF >= 64 &&
          tempF <= 82 &&
          humidity >= 30 &&
          humidity <= 70 &&
          windMph <= 15) {
        key = 'pleasant';
      } else {
        key = 'overcast';
      }
    }

    final bank = _phraseBank;
    List<String> candidates = const [];
    final now = _nowInLocation(offsetSec);
    final seed = now.hour + tempF + humidity + windMph + code;

    if (key == 'rain' && sub == 'thunderstorm') {
      candidates = (bank['rain'] as Map)['thunderstorm'] as List<String>;
    } else if (key == 'rain') {
      candidates =
          (bank['rain'] as Map)[sub.isEmpty ? 'light' : sub] as List<String>;
    } else if (key == 'snow') {
      candidates =
          (bank['snow'] as Map)[sub.isEmpty ? 'light' : sub] as List<String>;
    } else if (key == 'cold') {
      candidates = (bank['cold'] as Map)['freezing'] as List<String>;
    } else if (key == 'atmosphere') {
      candidates = (bank['atmosphere'] as Map)[sub] as List<String>;
    } else if (key == 'clear' ||
        key == 'pleasant' ||
        key == 'partly_cloudy' ||
        key == 'overcast' ||
        key == 'hot') {
      candidates =
          (bank[key] as Map)[isNight ? 'night' : 'day'] as List<String>;
    }

    String phrase = '';
    for (int i = 0; i < (candidates.isEmpty ? 0 : candidates.length * 2); i++) {
      final candidate = candidates[(seed + i) % candidates.length];
      final linesTry = _splitPhraseSmart(candidate);
      if (_linesFit(linesTry)) {
        phrase = candidate;
        break;
      }
    }
    if (phrase.isEmpty && candidates.isNotEmpty) {
      candidates.sort((a, b) => a.length.compareTo(b.length));
      final shortest = candidates.first;
      final linesTry = _splitPhraseSmart(shortest);
      if (_linesFit(linesTry)) phrase = shortest;
    }
    if (phrase.isEmpty) return fallback;

    final lines = _splitPhraseSmart(phrase);
    final String l1 = lines.isNotEmpty ? lines[0] : '';
    final String l2 = lines.length > 1 ? lines[1] : '';
    final String l3 = lines.length > 2 ? lines[2] : '';
    final String? l4 = lines.length > 3 ? lines[3] : null;

    String? s1, s2, s3;
    final scored = [
      (l1, _maxWordLen(l1)),
      (l2, _maxWordLen(l2)),
      (l3, _maxWordLen(l3)),
      (l4 ?? '', _maxWordLen(l4 ?? '')),
    ];
    int idxMax = 0;
    int maxLen = -1;
    for (int i = 0; i < scored.length; i++) {
      if (scored[i].$2 > maxLen) {
        maxLen = scored[i].$2;
        idxMax = i;
      }
    }
    if (idxMax == 0) s1 = 'outline';
    if (idxMax == 1) s2 = 'outline';
    if (idxMax == 2) s3 = 'outline';
    if ((l1 + l2 + l3 + (l4 ?? '')).length >= 24) {
      final second = (idxMax + 2) % 4;
      if (second == 0) s1 = s1 ?? 'outline';
      if (second == 1) s2 = s2 ?? 'outline';
      if (second == 2) s3 = s3 ?? 'outline';
    }

    return WeatherStatement(
      line1: l1,
      line1Style: s1,
      line2: l2,
      line2Style: s2,
      line3: l3,
      line3Style: s3,
      line4: (l4 != null && l4.trim().isNotEmpty) ? l4 : null,
    );
  }

  bool _linesFit(List<String> lines) {
    if (lines.isEmpty) return true;
    for (final line in lines) {
      if (line.length > _maxCharsPerLine) return false;
      for (final token in line.split(' ')) {
        final t = token.trim();
        if (t.isNotEmpty && t.length > _maxCharsPerLine) return false;
      }
    }
    return true;
  }

  static DateTime _nowInLocation(int offsetSeconds) =>
      DateTime.now().toUtc().add(Duration(seconds: offsetSeconds));

  static int _maxWordLen(String s) =>
      s.split(' ').fold<int>(0, (m, w) => w.length > m ? w.length : m);

  List<String> _splitPhraseSmart(String phrase, {int maxLines = 4}) {
    final tokens = phrase
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    if (tokens.isEmpty) return [''];

    int linesWanted = tokens.length <= 2
        ? 2
        : tokens.length <= 5
            ? 3
            : 4;
    linesWanted = linesWanted.clamp(2, maxLines);

    const glue = {
      'a',
      'an',
      'the',
      'and',
      'or',
      'but',
      'for',
      'nor',
      'so',
      'yet',
      'to',
      'of',
      'in',
      'on',
      'at',
      'by',
      'is',
      'am',
      'are',
      'was',
      'were',
      'be',
      'been',
      'do',
      'did',
      'does',
    };

    final targetLen =
        (phrase.replaceAll(' ', '').length / linesWanted).ceil() + 1;
    final List<String> lines = [];
    String current = '';
    for (int i = 0; i < tokens.length; i++) {
      final String t = tokens[i];
      final bool lastToken = (i == tokens.length - 1);

      if (current.isEmpty) {
        current = t;
      } else {
        final int projected = current.length + 1 + t.length;
        final int remaining = tokens.length - i - 1;
        final int slotsLeft = linesWanted - lines.length - 1;
        final bool mustLeaveForLater =
            remaining > 0 && slotsLeft > 0 && remaining < slotsLeft;

        if (projected <= targetLen && !mustLeaveForLater) {
          current = '$current $t';
        } else {
          final lastWord = current.split(' ').last.toLowerCase();
          if (!lastToken && glue.contains(lastWord)) {
            current = '$current $t';
          } else {
            lines.add(current);
            current = t;
          }
        }
      }
    }
    if (current.isNotEmpty) lines.add(current);

    if (lines.length > linesWanted) {
      final head = lines.sublist(0, linesWanted - 1);
      final tail = lines.sublist(linesWanted - 1).join(' ');
      return [...head, tail];
    }

    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    return lines;
  }

  static final Map<String, dynamic> _phraseBank = {
    'clear': {
      'day': [
        'Actually behaving itself.',
        'Not a single cloud.',
        'Peak performance weather.',
        'Okay, sky is flexing.',
      ],
      'night': [
        'The moon is flexing.',
        'Space looks crisp.',
        'Checking for aliens.',
        'Top tier night vibes.',
      ],
    },
    'hot': {
      'day': [
        "I'm literally melting.",
        "Satan's front porch.",
        'Directly into the oven.',
        'The sun is shouting.',
      ],
      'night': [
        'Even the moon is sweaty.',
        'Midnight oven mode.',
        'The air is thick.',
        'Why is it hot?',
      ],
    },
    'pleasant': {
      'day': [
        'Nature is actually chill.',
        "Don't ruin this.",
        'Sky is being decent.',
        'Actually pleasant today.',
      ],
      'night': [
        'Nature finally calmed down.',
        'The air is behaving.',
        'Worth staying up.',
      ],
    },
    'partly_cloudy': {
      'day': [
        "Sun's playing hide and seek.",
        "Sky can't decide.",
        'Low effort sunshine.',
        'The sun is teasing.',
      ],
      'night': [
        'Peek‑a‑boo moon.',
        'The moon is shy.',
        'Sky is half‑loading.',
        'Spotty coverage tonight.',
      ],
    },
    'overcast': {
      'day': [
        'Fifty shades of gray.',
        'The sun retired.',
        'Mood: maximum gray.',
        'Total color failure.',
      ],
      'night': [
        'Who deleted the moon?',
        'Total blackout above.',
        "Sky's just a wall.",
        'Zero stars. One star.',
      ],
    },
    'rain': {
      'light': [
        'Basically a spray bottle.',
        'Just enough to annoy.',
        'The sky is spitting.',
        'Wet, but barely.',
      ],
      'heavy': [
        'Absolute liquid chaos.',
        'The sky is broken.',
        'Hope you can swim.',
        'Nature needs a mop.',
      ],
      'thunderstorm': [
        'Zeus is throwing tantrums.',
        'Loud, wet, and angry.',
        "Sky's growling at us.",
      ],
    },
    'snow': {
      'light': [
        "Nature's annoying glitter.",
        'The sky has dandruff.',
        'Cold, but aesthetic.',
        'A dusting of regret.',
      ],
      'heavy': [
        'Pure white chaos.',
        'Welcome to Hoth.',
        'Everything is canceled.',
      ],
    },
    'cold': {
      'freezing': [
        'Toes have left chat.',
        'Everything is a trap.',
        'Absolute vampire weather.',
      ],
    },
    'atmosphere': {
      'fog': [
        'World failed to load.',
        'Visibility is a myth.',
        'Welcome to Silent Hill.',
      ],
      'windy': [
        'Air is being aggressive.',
        "Nature's blow dryer.",
        'Free hair disaster.',
      ],
      'humid': [
        "I'm breathing soup.",
        'Walking through pudding.',
        'The air is moist.',
      ],
    },
  };
}

