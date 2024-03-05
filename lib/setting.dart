import 'package:flutter/material.dart';
import 'constant/style.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.transparent,
                  child: Container(
                    decoration: CustomCardDecoration.cardDecoration,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'john.doe@example.com',
                          style: TextStyle(fontSize: 18, color: Colors.grey[300]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.blue[500],
                  child: Container(
                    decoration: CustomCardDecoration.cardDecoration,
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(Icons.drive_file_rename_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Change username',
                            style: TextStyle(fontSize: 20 , color: Colors.white),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.blue[500],
                  child: Container(
                    decoration: CustomCardDecoration.cardDecoration,
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(Icons.image, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Change avatar',
                            style: TextStyle(fontSize: 20 , color: Colors.white),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.blue[500],
                  child: Container(
                    decoration: CustomCardDecoration.cardDecoration,
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Change password',
                            style: TextStyle(fontSize: 20 , color: Colors.white),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
