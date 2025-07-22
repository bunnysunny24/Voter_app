import 'package:flutter/material.dart';
import 'package:voter/models/candidate.dart';
import 'package:voter/services/storage_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<String> _positions = [];
  List<String> _classes = [];
  List<Candidate> _candidates = [];
  String? _selectedPosition;
  String? _selectedClass;
  bool _isVotingFinalized = false;
  bool _isLoading = true;
  bool _isAddingCandidate = false;
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
      // Check if voting is finalized
      _isVotingFinalized = _storageService.isVotingFinalized();
      
      // Load positions
      _positions = _storageService.getCandidatePositions();
      
      // Load classes
      _classes = _storageService.getAllClasses().map((c) => c.name).toList();
      
      // Load candidates
      _candidates = _storageService.getAllCandidates();
      
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
  
  Future<void> _finalizeVoting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finalize Voting'),
        content: Text(
          'Are you sure you want to finalize voting? '
          'This action cannot be undone and will prevent further votes from being cast.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Finalize'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        await _storageService.finalizeVoting();
        
        setState(() {
          _isVotingFinalized = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voting has been finalized successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to finalize voting: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finalize voting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset All Data'),
        content: Text(
          'WARNING: This will delete all votes and reset the voting status. '
          'This action cannot be undone. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reset Everything'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        await _storageService.resetAllData();
        
        setState(() {
          _isVotingFinalized = false;
          _isLoading = false;
        });
        
        // Reload data
        _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All data has been reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to reset data: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _addCandidate() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      final candidate = Candidate(
        name: _nameController.text.trim(),
        position: _selectedPosition!,
        className: _selectedClass!,
        description: _descriptionController.text.trim(),
      );
      
      await _storageService.addCandidate(candidate);
      
      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedPosition = null;
        _selectedClass = null;
        _isAddingCandidate = false;
      });
      
      // Reload candidates
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidate added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to add candidate: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add candidate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusCard(),
                      SizedBox(height: 20),
                      _buildActionButtons(),
                      SizedBox(height: 20),
                      if (_isAddingCandidate) _buildAddCandidateForm(),
                      SizedBox(height: 20),
                      _buildCandidatesList(),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      color: _isVotingFinalized ? Colors.red.shade100 : Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isVotingFinalized ? Icons.lock : Icons.lock_open,
                  color: _isVotingFinalized ? Colors.red : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  'Voting Status:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              _isVotingFinalized
                  ? 'Voting has been finalized. No more votes can be cast.'
                  : 'Voting is open. Students can cast their votes.',
              style: TextStyle(
                fontSize: 16,
                color: _isVotingFinalized ? Colors.red.shade900 : Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isVotingFinalized)
          ElevatedButton.icon(
            onPressed: _finalizeVoting,
            icon: Icon(Icons.lock_outline),
            label: Text('Finalize Voting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _resetAllData,
          icon: Icon(Icons.restore),
          label: Text('Reset All Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        SizedBox(height: 10),
        if (!_isVotingFinalized && !_isAddingCandidate)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAddingCandidate = true;
              });
            },
            icon: Icon(Icons.person_add),
            label: Text('Add New Candidate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAddCandidateForm() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Candidate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Candidate Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter candidate name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select position'),
                value: _selectedPosition,
                items: _positions
                    .map((pos) => DropdownMenuItem(
                          value: pos,
                          child: Text(pos),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a position';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select class'),
                value: _selectedClass,
                items: _classes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a class';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingCandidate = false;
                        _nameController.clear();
                        _descriptionController.clear();
                        _selectedPosition = null;
                        _selectedClass = null;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addCandidate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Add Candidate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCandidatesList() {
    if (_candidates.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No candidates added yet',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    
    // Group candidates by position
    final candidatesByPosition = <String, List<Candidate>>{};
    for (var position in _positions) {
      candidatesByPosition[position] = [];
    }
    
    for (var candidate in _candidates) {
      candidatesByPosition[candidate.position]?.add(candidate);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Candidates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ...candidatesByPosition.entries.map((entry) {
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade100,
                  padding: EdgeInsets.all(12),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (entry.value.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No candidates for this position',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: entry.value.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final candidate = entry.value[index];
                      return ListTile(
                        title: Text(candidate.name),
                        subtitle: Text(
                          '${candidate.className} | ${candidate.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.person),
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
