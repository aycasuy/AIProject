import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/screens/learn_activity_screen.dart';
import 'package:mobile_app/services/api_service.dart';

import 'minimal_pairs_screen.dart';

class PracticeScreen extends StatefulWidget {
  final String username;
  final String targetLanguage;
  final String nativeLanguage;

  const PracticeScreen({
    super.key,
    required this.username,
    required this.targetLanguage,
    required this.nativeLanguage,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<dynamic> _mistakes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    final data = await ApiService.fetchMistakeDetails(
      widget.username,
      widget.targetLanguage,
      nativeLanguage: widget.nativeLanguage,
    );

    if (!mounted) return;

    setState(() {
      _mistakes = data;
      _isLoading = false;
    });
  }

  String _localizedPuzzleType(AppLocalizations loc, String puzzleType) {
    switch (puzzleType) {
      case 'blank_puzzle':
        return loc.practiceTypeBlank;

      case 'sentence_puzzle':
        return loc.practiceTypeSentence;

      case 'minimal_pair':
        return loc.practiceTypeMinimalPair;

      default:
        return loc.practiceTypeUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(loc.practiceScreenTitle),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            )
          : _mistakes.isEmpty
          ? _buildEmptyState(loc)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mistakes.length,
              itemBuilder: (context, index) {
                return _buildMistakeCard(_mistakes[index], loc);
              },
            ),
    );
  }

  Widget _buildMistakeCard(dynamic item, AppLocalizations loc) {
    final String puzzleType = item['puzzle_type']?.toString() ?? '';

    final String localizedType = _localizedPuzzleType(loc, puzzleType);

    final int mistakeCount = (item['mistake_count'] as num?)?.toInt() ?? 0;

    final String questionText = item['question_text']?.toString().trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
          ),
        ),
        title: Text(
          questionText.isNotEmpty ? questionText : loc.practiceUnknownQuestion,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            loc.practiceQuestionInfo(localizedType, mistakeCount),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _navigateToPuzzle(context, item, loc);
          },
          child: Text(
            loc.practiceSolve,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _navigateToPuzzle(
    BuildContext context,
    dynamic item,
    AppLocalizations loc,
  ) {
    final String puzzleType = item['puzzle_type']?.toString() ?? '';

    final int? puzzleId = (item['puzzle_id'] as num?)?.toInt();

    if (puzzleType.isEmpty || puzzleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.practiceInvalidQuestion)));
      return;
    }

    late final Widget targetScreen;

    switch (puzzleType) {
      case 'minimal_pair':
        targetScreen = MinimalPairsScreen(
          id: puzzleId,
          isPracticeMode: true,
          username: widget.username,
          targetLanguage: widget.targetLanguage,
          nativeLanguage: widget.nativeLanguage,
          themeColor: const Color(0xFFFF6B6B),
        );

        debugPrint('Minimal Pair ekranı açılacak: ID $puzzleId');
        break;

      case 'blank_puzzle':
        targetScreen = LearnActivityScreen(
          activityType: 'learn_blank',
          lessonTitle: loc.practiceBlankTitle,
          themeColor: const Color(0xFFFF6B6B),
          username: widget.username,
          minLevel: 'A1',
          targetLanguage: widget.targetLanguage,
          nativeLanguage: widget.nativeLanguage,
          lessonId: 0,
          sectionIndex: 0,
          isPracticeMode: true,
          practicePuzzleId: puzzleId,
        );
        break;

      case 'sentence_puzzle':
        targetScreen = LearnActivityScreen(
          activityType: 'learn_order',
          lessonTitle: loc.practiceSentenceTitle,
          themeColor: const Color(0xFFFF6B6B),
          username: widget.username,
          minLevel: 'A1',
          targetLanguage: widget.targetLanguage,
          nativeLanguage: widget.nativeLanguage,
          lessonId: 0,
          sectionIndex: 0,
          isPracticeMode: true,
          practicePuzzleId: puzzleId,
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.practiceUnknownPuzzleType(puzzleType))),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    ).then((_) {
      _loadMistakes();
    });
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            loc.practiceEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.practiceEmptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
