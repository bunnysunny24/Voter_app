import 'package:flutter/material.dart';
import 'package:voter/models/vote.dart';
import 'package:voter/models/candidate.dart';
import 'package:voter/models/school_class.dart';
import 'package:voter/services/storage_service.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();

  List<SchoolClass> _classes = [];
  List<String> _positions = [];
  Map<String, List<Candidate>> _candidatesByPosition = {};
  Map<String, String?> _selectedCandidates = {};
  String? _selectedClass;
  bool _isLoading = true;
  bool _hasVoted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load classes
      _classes = _storageService.getAllClasses();

      // Load positions
      _positions = _storageService.getCandidatePositions();

      // Load candidates by position
      _candidatesByPosition = {};
      for (var position in _positions) {
        _candidatesByPosition[position] = 
            _storageService.getCandidatesByPosition(position);
      }

      // Initialize selected candidates map
      _selectedCandidates = {for (var position in _positions) position: null};

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  void _validateStudentVotes() {
    if (_selectedClass == null) {
      _showErrorSnackBar('Please select your class');
      return;
    }

    if (_studentIdController.text.isEmpty) {
      _showErrorSnackBar('Please enter your student ID');
      return;
    }

    // Check if student has already voted for any position
    for (var position in _positions) {
      if (_storageService.hasStudentVoted(_studentIdController.text, position)) {
        _showErrorSnackBar('You have already voted for $position');
        return;
      }
    }

    // Check if all positions have been voted for
    for (var position in _positions) {
      if (_selectedCandidates[position] == null) {
        _showErrorSnackBar('Please select a candidate for $position');
        return;
      }
    }

    // Submit votes
    _submitVotes();
  }

  Future<void> _submitVotes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Create and save votes for each position
      for (var position in _positions) {
        final vote = Vote(
          studentId: _studentIdController.text,
          className: _selectedClass!,
          position: position,
          candidateName: _selectedCandidates[position]!,
          timestamp: DateTime.now(),
        );
        
        await _storageService.addVote(vote);
      }

      setState(() {
        _hasVoted = true;
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit votes: $e';
      });
      _showErrorSnackBar('Failed to submit votes: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Votes Submitted Successfully!'),
        content: Text(
          'Thank you for participating in the school election. Your votes have been recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home screen
            },
            child: Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cast Your Vote'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _hasVoted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Your votes have been submitted!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Thank you for participating.',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Return to Home'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Student Information',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        controller: _studentIdController,
                                        decoration: InputDecoration(
                                          labelText: 'Student ID',
                                          hintText: 'Enter your student ID',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.person),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your student ID';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Class',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.class_),
                                        ),
                                        hint: Text('Select your class'),
                                        value: _selectedClass,
                                        items: _classes
                                            .map((c) => DropdownMenuItem(
                                                  value: c.name,
                                                  child: Text(c.name),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedClass = value;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select your class';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ..._positions.map((position) => _buildPositionCard(position)),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _validateStudentVotes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Submit Votes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildPositionCard(String position) {
    final candidates = _candidatesByPosition[position] ?? [];

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              position,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            ...candidates.map((candidate) => RadioListTile<String>(
                  title: Text(candidate.name),
                  subtitle: Text(
                    '${candidate.className} | ${candidate.description}',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: candidate.name,
                  groupValue: _selectedCandidates[position],
                  onChanged: (value) {
                    setState(() {
                      _selectedCandidates[position] = value;
                    });
                  },
                )),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No candidates available for this position',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }
}
