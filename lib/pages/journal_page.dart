import 'package:flutter/material.dart';
import '../services/journal_service.dart';
import '../widgets/ghost_coin_counter.dart';
import 'package:ghost_app/services/journal_service.dart';


class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  Widget build(BuildContext context) {
    final entries = JournalService.instance.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghost Hunt Journal"),
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 12), child: GhostCoinCounter())
        ],
      ),
      body: entries.isEmpty
          ? const Center(
        child: Text("No evidence collected yet.",
            style: TextStyle(fontSize: 18, color: Colors.white70)),
      )
          : ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("${entry.tool.toUpperCase()} - ${entry.evidenceType}",
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "${entry.locationName} • ${entry.timestamp
                    .toLocal()
                    .toString()
                    .split('.')[0]}",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: entry.coinsClaimed
                  ? const Icon(Icons.check, color: Colors.greenAccent)
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    JournalService.instance.claimCoins(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ghost coins collected!")),
                  );
                },
                child: const Text("Collect Coins"),
              ),
            ),
          );
        },
      ),
    );
  }
}