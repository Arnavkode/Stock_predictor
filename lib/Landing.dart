import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String symbol = "TCS.NS"; // Default stock symbol
  Map<String, dynamic>? predictionData; // To store API response
  bool isLoading = false; // To show a loading indicator

  // Function to fetch prediction data from Flask API
  Future<void> fetchPrediction() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Replace with your Flask server's IP address and port
      final url = Uri.parse('http://172.16.105.158:5000/predict?symbol=$symbol');
      print('Fetching data from: $url'); // Debugging log
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Response: ${response.body}'); // Debugging log
        setState(() {
          predictionData = json.decode(response.body); // Parse JSON response
        });
      } else {
        throw Exception('Failed to fetch prediction data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Debugging log
      setState(() {
        predictionData = null; // Clear data on error
      });
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPrediction(); // Call the function when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background container
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: const Color(0xFF493657),
          child: Column(
            children: [
              SizedBox(
                height: 0.2 * MediaQuery.of(context).size.height,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator() // Show loading indicator
                      : predictionData != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Symbol: ${predictionData!['symbol']}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Current Price: ₹${predictionData!['current_price']}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Predicted Price: ₹${predictionData!['predicted_price']}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          : const Text(
                              'No data available. Please try again.',
                              style: TextStyle(fontSize: 16),
                            ),
                ),
              ),
            ],
          ),
        ),
        // AppBar
        AppBar(
          title: const Text(
            "Stock Predictor",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}