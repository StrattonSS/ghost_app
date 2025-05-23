import 'package:flutter/material.dart';
import 'submit_location_page.dart';
import '../widgets/ghost_coin_counter.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Haunted Locations"),
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 12), child: GhostCoinCounter())
        ],
      ),
      body: const Center(
        child: Text(
          "Haunted locations will be listed here soon.",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitLocationPage()),
          );
        },
        label: const Text('Submit a Location'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }
}