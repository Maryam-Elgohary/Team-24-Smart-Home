import 'package:flutter/material.dart';

class WaitingApprovalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Color(0xFF5857AA)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Waiting for admin approval to log in',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232344),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Icon(
              Icons.hourglass_empty,
              size: 60,
              color: Colors.blue,
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Your account has been created\n successfully and is currently under\n review by the administration. You will\n receive a notification once it is\n approved!',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF232344),
                ),
                textAlign: TextAlign.left,
              ),

            ),
                        SizedBox(height: 150),

          ],
        ),
      ),
    );
  }
}