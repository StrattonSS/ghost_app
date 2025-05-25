import 'package:flutter/material.dart';
import 'submit_location_page.dart';
import '../widgets/ghost_coin_counter.dart';
import 'terminal_theme.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      appBar: AppBar(
        backgroundColor: TerminalColors.background,
        title: const Text(
          ">> EXPLORE_LOC.TXT",
          style: TerminalTextStyles.heading,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GhostCoinCounter(),
          )
        ],
      ),
      body: const Center(
        child: Text(
          ">> Haunted locations will be listed here soon.",
          style: TerminalTextStyles.body,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TerminalColors.green,
        foregroundColor: TerminalColors.background,
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
