import 'package:flutter/material.dart';

class FinalResults extends StatelessWidget {
  const FinalResults({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [        
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/student_profile.jpeg"),
            radius: 35,
            
            
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jeffrey hayford", style: TextStyle(
                fontSize: 15
              ),),
              Text("59%",style: TextStyle(
                fontSize: 12
              ),),
              Text("789 of 1699",style: TextStyle(
                fontSize: 12
              ),),
            ],
          ),
        ],
        
      ),
    );
    
  }
}