import 'package:flutter/material.dart';
import 'package:voter/screens/voting_screen.dart';
import 'package:voter/screens/results_screen.dart';
import 'package:voter/screens/admin_screen.dart';
import 'package:voter/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  bool _isVotingFinalized = false;

  @override
  void initState() {
    super.initState();
    _checkVotingStatus();
  }

  Future<void> _checkVotingStatus() async {
    setState(() {
      _isVotingFinalized = _storageService.isVotingFinalized();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // App logo or icon
              Icon(
                Icons.how_to_vote_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // App title
              Text(
                'School Voting App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // App subtitle
              Text(
                'Cast your vote for school leadership',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 50),
              // Main action buttons
              _buildActionButton(
                icon: Icons.ballot_rounded,
                label: 'Cast Vote',
                onPressed: _isVotingFinalized
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VotingScreen(),
                          ),
                        ).then((_) => _checkVotingStatus());
                      },
                isDisabled: _isVotingFinalized,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'View Results',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin Panel',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminScreen(),
                    ),
                  ).then((_) => _checkVotingStatus());
                },
              ),
              const SizedBox(height: 40),
              // Voting status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isVotingFinalized
                      ? Colors.red.withOpacity(0.8)
                      : Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isVotingFinalized
                      ? 'Voting has been finalized'
                      : 'Voting is open',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDisabled = false,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isDisabled) ...[
              const SizedBox(width: 8),
              Icon(Icons.lock, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
