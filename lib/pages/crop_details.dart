import 'package:flutter/material.dart';

class CropDetails extends StatelessWidget {
  final Map<String, dynamic> disease;

  const CropDetails({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disease['diseaseName']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scientific Name: ${disease['scientificName']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(
              disease['images'][0],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 200),
            ),
            const SizedBox(height: 20),
            Text(
              "Symptoms",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(disease['symptoms'] ?? 'No data available'),
            const SizedBox(height: 20),
            Text(
              "Causes",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(disease['causes'] ?? 'No data available'),
            const SizedBox(height: 20),
            Text(
              "Remedies",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...List<Widget>.from((disease['remedies'] ?? [])
                .map((remedy) => Text("• $remedy"))),
            const SizedBox(height: 20),
            Text(
              "Chemical Control",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(disease['chemicalControl'] ?? 'No data available'),
          ],
        ),
      ),
    );
  }
}
