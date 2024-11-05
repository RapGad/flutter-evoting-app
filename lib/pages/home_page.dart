import 'package:carousel_slider/carousel_slider.dart';
import 'package:finalapp/helper/candidate_card.dart';
import 'package:finalapp/helper/election_provider.dart';
import 'package:finalapp/pages/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          Consumer<ElectionProvider>(
            builder: (context, electionProvider, child) {
              return (Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("SignOut"),
                  ),
                  IconButton(
                      onPressed: () {
                        electionProvider.resetFetchedData();
                      },
                      icon: const Icon(Icons.refresh))
                ],
              ));
            },
          )
        ],
      ),
      body: Consumer<ElectionProvider>(
        builder: (context, electionProvider, child) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates = electionProvider.candidates;
          //candidates.isEmpty ? const Center(child"Error")):

          if (candidates.isEmpty) {
            return const Center(child: Text("Error"));
          }

          Map<String, List<Map<String, dynamic>>> categorizedCandidates = {};
          for (var candidate in candidates) {
            if (!categorizedCandidates.containsKey(candidate['category'])) {
              categorizedCandidates[candidate['category']] = [];
            }
            categorizedCandidates[candidate['category']]!.add(candidate);
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                for (var category in categorizedCandidates.keys) ...[
                  Text(
                    "$category Candidates",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider(
                    items: categorizedCandidates[category]!
                        .map((candidate) => CandidateCard(
                              name: candidate['name'],
                              imageUrl: candidate['imageUrl'],
                              quote: candidate['quote'],
                            ))
                        .toList(),
                    options: candidates.length > 1
                        ? CarouselOptions(
                            viewportFraction: 1,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            autoPlay: true,
                          )
                        : CarouselOptions(
                            viewportFraction: 1,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            autoPlay: false,
                            enableInfiniteScroll: false),
                  ),
                  const SizedBox(height: 30),
                ],
                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/categories',
                          arguments: {'showVoteButton': true},
                        );
                      },
                      child: const Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Center(child: Text("Vote")),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/categories',
                          arguments: {'showResults': true},
                        );
                      },
                      child: const Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Center(child: Text("Result")),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/categories',
                          //arguments: {'showVoteButton': false},
                        );
                      },
                      child: const Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Center(child: Text("Candidates")),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/categories',
                          arguments: {'analytics': true},
                        );
                      },
                      child: const Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Center(child: Text("Analytics")),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
