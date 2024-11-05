import 'package:finalapp/helper/election_provider.dart';
import 'package:finalapp/pages/analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatelessWidget {
  final bool showVoteButton;
  final bool showResults;
  final bool analytics;

  const CategoriesPage(
      {required this.showVoteButton,
      required this.showResults,
      super.key,
      required this.analytics});

  @override
  Widget build(BuildContext context) {
    final electionProvider = Provider.of<ElectionProvider>(context);
    final categories = electionProvider.candidates
        .map((candidate) => candidate['category'])
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category),
            onTap: () {
              analytics
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Analytics(category: category)))
                  : Navigator.pushNamed(
                      context,
                      '/candidates',
                      arguments: {
                        'category': category,
                        'showVoteButton': showVoteButton,
                        'showResults': showResults,
                      },
                    );
            },
          );
        },
      ),
    );
  }
}
