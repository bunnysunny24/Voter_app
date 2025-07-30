import 'package:hive_flutter/hive_flutter.dart';
import 'package:voter/models/vote.dart';
import 'package:voter/models/candidate.dart';
import 'package:voter/models/school_class.dart';

class StorageService {
  static const String votesBoxName = 'votes';
  static const String candidatesBoxName = 'candidates';
  static const String classesBoxName = 'classes';
  static const String settingsBoxName = 'settings';

  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Box references
  late Box<Vote> _votesBox;
  late Box<Candidate> _candidatesBox;
  late Box<SchoolClass> _classesBox;
  late Box<dynamic> _settingsBox;

  // Initialize Hive and open boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(VoteAdapter());
    Hive.registerAdapter(CandidateAdapter());
    Hive.registerAdapter(SchoolClassAdapter());
    
    // Open boxes
    _votesBox = await Hive.openBox<Vote>(votesBoxName);
    _candidatesBox = await Hive.openBox<Candidate>(candidatesBoxName);
    _classesBox = await Hive.openBox<SchoolClass>(classesBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    
    // Initialize default data if needed
    await _initializeDefaultData();
  }

  // Initialize default data if boxes are empty
  Future<void> _initializeDefaultData() async {
    // Initialize classes if empty
    if (_classesBox.isEmpty) {
      final defaultClasses = [
        SchoolClass(name: 'LKG', totalStudents: 30),
        SchoolClass(name: 'UKG', totalStudents: 30),
      ];
      
      // Add classes 1-12
      for (int i = 1; i <= 12; i++) {
        defaultClasses.add(SchoolClass(name: 'Class $i', totalStudents: 30));
      }
      
      // Add all classes to box
      for (var schoolClass in defaultClasses) {
        await _classesBox.add(schoolClass);
      }
    }
    
    // Initialize candidates if empty
    if (_candidatesBox.isEmpty) {
      // Add Head Girl candidates
      await _candidatesBox.add(Candidate(
        name: 'Hethvika',
        position: 'Head Girl',
        className: '',
        description: 'Head Girl candidate',
      ));
      await _candidatesBox.add(Candidate(
        name: 'Saivarsha',
        position: 'Head Girl',
        className: '',
        description: 'Head Girl candidate',
      ));
      await _candidatesBox.add(Candidate(
        name: 'Deeksha',
        position: 'Head Girl',
        className: '',
        description: 'Head Girl candidate',
      ));
      // Add Head Boy candidates
      await _candidatesBox.add(Candidate(
        name: 'Reuben',
        position: 'Head Boy',
        className: '',
        description: 'Head Boy candidate',
      ));
      await _candidatesBox.add(Candidate(
        name: 'Pranay Kumar',
        position: 'Head Boy',
        className: '',
        description: 'Head Boy candidate',
      ));
    }
    
    // Initialize settings if empty
    if (!_settingsBox.containsKey('votingFinalized')) {
      await _settingsBox.put('votingFinalized', false);
    }
  }

  // Vote management methods
  Future<void> addVote(Vote vote) async {
    await _votesBox.add(vote);
  }

  List<Vote> getAllVotes() {
    return _votesBox.values.toList();
  }

  List<Vote> getVotesByClass(String className) {
    return _votesBox.values.where((vote) => vote.className == className).toList();
  }

  List<Vote> getVotesByPosition(String position) {
    return _votesBox.values.where((vote) => vote.position == position).toList();
  }

  bool hasStudentVoted(String studentId, String position) {
    return _votesBox.values.any((vote) => 
        vote.studentId == studentId && vote.position == position);
  }

  // Candidate management methods
  Future<void> addCandidate(Candidate candidate) async {
    await _candidatesBox.add(candidate);
  }

  List<Candidate> getAllCandidates() {
    return _candidatesBox.values.toList();
  }

  List<Candidate> getCandidatesByPosition(String position) {
    return _candidatesBox.values.where((candidate) => 
        candidate.position == position).toList();
  }

  // Class management methods
  List<SchoolClass> getAllClasses() {
    return _classesBox.values.toList();
  }

  // Settings management methods
  bool isVotingFinalized() {
    return _settingsBox.get('votingFinalized', defaultValue: false);
  }

  Future<void> finalizeVoting() async {
    await _settingsBox.put('votingFinalized', true);
  }

  Future<void> resetAllData() async {
    await _votesBox.clear();
    await _candidatesBox.clear();
    await _settingsBox.put('votingFinalized', false);
    await _initializeDefaultData();
  }

  // Results calculation methods
  Map<String, Map<String, int>> getVoteCountsByPosition() {
    final results = <String, Map<String, int>>{};
    final positions = getCandidatePositions();
    
    for (var position in positions) {
      final positionVotes = getVotesByPosition(position);
      final candidateVotes = <String, int>{};
      
      for (var vote in positionVotes) {
        candidateVotes[vote.candidateName] = 
            (candidateVotes[vote.candidateName] ?? 0) + 1;
      }
      
      results[position] = candidateVotes;
    }
    
    return results;
  }

  List<String> getCandidatePositions() {
    final positions = _candidatesBox.values
        .map((candidate) => candidate.position)
        .toSet()
        .toList();
    return positions;
  }

  Map<String, String> getWinnersByPosition() {
    final winners = <String, String>{};
    final voteCounts = getVoteCountsByPosition();
    
    for (var position in voteCounts.keys) {
      final candidateVotes = voteCounts[position]!;
      if (candidateVotes.isNotEmpty) {
        final maxVotes = candidateVotes.values.reduce((a, b) => a > b ? a : b);
        final winningCandidates = candidateVotes.entries
            .where((entry) => entry.value == maxVotes)
            .map((entry) => entry.key)
            .toList();
        
        winners[position] = winningCandidates.length == 1 
            ? winningCandidates.first 
            : '${winningCandidates.join(', ')} (Tie)';
      } else {
        winners[position] = 'No votes';
      }
    }
    
    return winners;
  }
}
