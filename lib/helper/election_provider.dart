import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _candidates = [];
  bool _isLoading = true;
  bool _resultsAvailable = false;
  Map<String, int> _results =
      {}; // Store results as a map of category-candidate to votes
  Map<String, int> _totalVotesPerCategory =
      {}; // Store total votes per category

  List<Map<String, dynamic>> get candidates => _candidates;
  bool get isLoading => _isLoading;
  bool get resultsAvailable => _resultsAvailable;
  Map<String, int> get results => _results;
  Map<String, int> get totalVotesPerCategory => _totalVotesPerCategory;

  ElectionProvider() {
    fetchElectionData();
  }

  Future<void> resetFetchedData() async {
    fetchElectionData();
  }

  Future<void> fetchElectionData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final electionRef =
          _firestore.collection('elections').doc('election2024');
      DocumentSnapshot snapshot = await electionRef.get();
      print(snapshot.data());
      final categoriesSnapshot = await electionRef.collection('category').get();
      print(categoriesSnapshot.docs.isEmpty);

      List<Map<String, dynamic>> candidatesList = [];

      for (var categoryDoc in categoriesSnapshot.docs) {
        final candidatesSnapshot =
            await categoryDoc.reference.collection('candidates').get();
        for (var candidateDoc in candidatesSnapshot.docs) {
          candidatesList.add({
            'id': candidateDoc.id,
            'name': candidateDoc['name'],
            'imageUrl': candidateDoc['imageUrl'],
            'quote': candidateDoc['quote'],
            'category': categoryDoc.id,
            'votes': 0, // Initialize votes count for each candidate
          });
        }
      }

      _candidates = candidatesList;

      // Fetch results availability
      await fetchResultsAvailability();

      // If results are available, fetch and calculate the results
      if (_resultsAvailable) {
        await fetchResults();
        calculateCandidateVotes();
      }
    } catch (e) {
      print('Error fetching election data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchResultsAvailability() async {
    try {
      final electionRef =
          _firestore.collection('elections').doc('election2024');
      final electionData = await electionRef.get();
      _resultsAvailable = electionData['resultsAvailable'] ?? false;
    } catch (e) {
      print('Error fetching results availability: $e');
    }
  }

  Future<void> fetchResults() async {
    try {
      final electionRef =
          _firestore.collection('elections').doc('election2024');
      final resultsSnapshot = await electionRef.collection('votes').get();

      // Initialize an empty map to store the votes count and total votes per category
      Map<String, int> voteCounts = {};
      Map<String, int> categoryVoteCounts = {};

      // Sum the votes for each candidate in each category
      for (var voteDoc in resultsSnapshot.docs) {
        String candidateId = voteDoc['candidateId'];
        String categoryId = voteDoc['categoryId'];
        String key = '$categoryId-$candidateId';

        // Count votes for candidates
        if (voteCounts.containsKey(key)) {
          voteCounts[key] = voteCounts[key]! + 1;
        } else {
          voteCounts[key] = 1;
        }

        // Count total votes per category
        if (categoryVoteCounts.containsKey(categoryId)) {
          categoryVoteCounts[categoryId] = categoryVoteCounts[categoryId]! + 1;
        } else {
          categoryVoteCounts[categoryId] = 1;
        }
      }

      // Store the results
      _results = voteCounts;
      _totalVotesPerCategory = categoryVoteCounts;
    } catch (e) {
      print('Error fetching results: $e');
    }
  }

  void calculateCandidateVotes() {
    // Update the votes count for each candidate
    for (var candidate in _candidates) {
      String key = '${candidate['category']}-${candidate['id']}';
      if (_results.containsKey(key)) {
        candidate['votes'] = _results[key]!;
      } else {
        candidate['votes'] = 0;
      }
    }
  }

  Future<bool> voteForCandidate(String candidateId, String categoryId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final electionRef =
            _firestore.collection('elections').doc('election2024');
        final electionDoc = await electionRef.get();

        if (electionDoc.exists) {
          final data = electionDoc.data() as Map<String, dynamic>;
          final Timestamp startTime = data['startTime'];
          final Timestamp endTime = data['endTime'];
          final DateTime now = DateTime.now();

          if (now.isAfter(startTime.toDate()) &&
              now.isBefore(endTime.toDate())) {
            await electionRef.collection('votes').add({
              'userId': userId,
              'candidateId': candidateId,
              'categoryId': categoryId,
              'electionId': 'election2024',
              'timestamp': FieldValue.serverTimestamp(),
            });
            print('Vote added successfully!');

            return true;
          } else {
            print('Voting is not allowed at this time.');
            return false;
          }
        } else {
          print('Election document does not exist.');
          return false;
        }
      }
    } catch (e) {
      print('Error voting: $e');
    }

    return false;
  }

  Future<bool> hasVotedInCategory(String categoryId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;
        final electionRef =
            _firestore.collection('elections').doc('election2024');
        final querySnapshot = await electionRef
            .collection('votes')
            .where('userId', isEqualTo: userId)
            .where('electionId', isEqualTo: 'election2024')
            .where('categoryId', isEqualTo: categoryId)
            .get();
        return querySnapshot.docs.isNotEmpty;
      }
    } catch (e) {
      print('Error checking vote status: $e');
    }
    return false;
  }
}
