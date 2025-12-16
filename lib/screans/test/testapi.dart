import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  dynamic result;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = Uri.parse(
          'https://wvp3ymemn7opeafpmelsgkgypaxpwej1.ui.nabu.casa/api/states');
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIyNGIyOTIyOTZlMGE0MWQ0YmJjMDgzZWZhMWQ1NGM3YyIsImlhdCI6MTc2NDUxMzI4MiwiZXhwIjoyMDc5ODczMjgyfQ.59ftcU9QvCq5_UjEecC4hf-mM2cNYkMTD-XSBgbzsfU',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          result = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch data. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test Screen'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : result is List
                  ? ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        var item = result[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(item['entity_id'] ?? 'No Entity ID'),
                            subtitle:
                                Text('State: ${item['state'] ?? 'Unknown'}'),
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Text(
                          result.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
    );
  }
}
