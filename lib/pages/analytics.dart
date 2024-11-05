import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalapp/helper/election_provider.dart';

class Analytics extends StatelessWidget {

  final category;
  const Analytics ({required this.category,super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),

      body: Consumer<ElectionProvider>(
        builder: (context, electionProvider, child) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final totalVotes = electionProvider.totalVotesPerCategory[category] ?? 0;
          final candidates = electionProvider.candidates
              .where((candidate) => candidate['category'] == category)
              .toList();
          final candidateData = candidates.map((candidate){
            return{
              'name': candidate['name'],
              'votes': double.parse(candidate['votes'])
            };
          }).toList();

          print(candidateData);
          print(totalVotes);

          return Text("ANALYTICS");
         /*  Center(
            child: SizedBox(
              height: 500,
              child: BarChart(
                BarChartData(
                  maxY: totalVotes + 10,
                  minY: 0,
                  barGroups: candidateData.map((data){
                    return BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: double.parse(data['votes']))
                      ]
                      );

                  }).toList()
                )
              ),
            ),
          ); */
          },
    ));
  }
}