import 'package:finalapp/helper/election_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/* class CandidatesPage extends StatelessWidget {
  final String category;
  final bool showVoteButton;
  final bool showResults;

  const CandidatesPage({
    required this.category, 
    required this.showVoteButton, 
    required this.showResults,
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Candidates'),
        centerTitle: true,
      ),
      body: Consumer<ElectionProvider>(
        builder: (context, electionProvider, child) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = electionProvider.candidates
              .where((candidate) => candidate['category'] == category)
              .toList();

          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(candidate['imageUrl']),
                ),
                title: Text(candidate['name']),
                subtitle: Text(candidate['quote']),
                trailing: (showVoteButton)
                    ? ElevatedButton(
                        onPressed: () async {
  // Check if the user has already voted
  final hasVoted = await Provider.of<ElectionProvider>(context, listen: false).hasVotedInCategory(category);
  
  if (hasVoted) {
    // Show a message indicating that the user has already voted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have already voted in this category')),
    );
  } else {
    // Call the voteForCandidate method if the user hasn't voted yet
    Provider.of<ElectionProvider>(context, listen: false).voteForCandidate(candidate['id'], category);
    
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voted successfully for ${candidate['name']}')),
    );
  }
}
,
                        child: const Text('Vote'),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
} */

/* class CandidatesPage extends StatelessWidget {
  final String category;
  final bool showVoteButton;
  final bool showResults;

  const CandidatesPage({
    required this.category, 
    required this.showVoteButton, 
    required this.showResults,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Candidates'),
        centerTitle: true,
      ),
      body: Consumer<ElectionProvider>(
        builder: (context, electionProvider, child) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = electionProvider.candidates
              .where((candidate) => candidate['category'] == category)
              .toList();

          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(candidate['imageUrl']),
                ),
                title: Text(candidate['name']),
                subtitle: Text(candidate['quote']),
                trailing:(showVoteButton || showResults)
    ? ElevatedButton(
        onPressed: () async {
          // Check if the user has already voted
          final hasVoted = await Provider.of<ElectionProvider>(context, listen: false).hasVotedInCategory(category);
          
          if (hasVoted) {
            // Show a message indicating that the user has already voted
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You have already voted in this category')),
            );
          } else {
            // Call the voteForCandidate method if the user hasn't voted yet
            Provider.of<ElectionProvider>(context, listen: false).voteForCandidate(candidate['id'], category);
            
            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voted successfully for ${candidate['name']}')),
            );
          }
        },
        child: const Text('Vote'),
      )
    : Container(
        width: 100, // Adjust the width as needed
        child: ListTile(
          subtitle: Text(electionProvider.resultsAvailable ? 'Results' : 'Results not available.'),
        ),
      ),

              );
            },
          );
        },
      ),
    );
  }
} */

class CandidatesPage extends StatelessWidget {
  final String category;
  final bool showVoteButton;
  final bool showResults;

  const CandidatesPage({
    required this.category,
    required this.showVoteButton,
    required this.showResults,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Candidates'),
        centerTitle: true,
      ),
      body: Consumer<ElectionProvider>(
        builder: (context, electionProvider, child) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = electionProvider.candidates
              .where((candidate) => candidate['category'] == category)
              .toList();

          final totalVotes =
              electionProvider.totalVotesPerCategory[category] ?? 0;

          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(candidate['imageUrl']),
                ),
                title: Text(candidate['name']),
                subtitle: Text(candidate['quote']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showResults)
                      if (electionProvider.resultsAvailable)
                        Text('Votes: ${candidate['votes']}/$totalVotes')
                      else
                        const Text(
                            "Results Pending"), // Empty space if condition is false
                    showVoteButton
                        ? ElevatedButton(
                            onPressed: () async {
                              // Check if the user has already voted
                              final hasVoted =
                                  await Provider.of<ElectionProvider>(context,
                                          listen: false)
                                      .hasVotedInCategory(category);

                              if (hasVoted) {
                                // Show a message indicating that the user has already voted
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'You have already voted in this category')),
                                );
                              } else {
                                // Call the voteForCandidate method if the user hasn't voted yet
                                final recordedVote =
                                    await Provider.of<ElectionProvider>(context,
                                            listen: false)
                                        .voteForCandidate(
                                            candidate['id'], category);
                                print(recordedVote);
                                // Show a success message
                                recordedVote
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Voted successfully for ${candidate['name']}')),
                                      )
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Voting time has elapsed')),
                                      );
                              }
                            },
                            child: const Text('Vote'),
                          )
                        : const SizedBox
                            .shrink(), // Empty space if condition is false
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
