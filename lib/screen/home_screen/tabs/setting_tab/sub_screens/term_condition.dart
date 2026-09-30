import 'dart:convert';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  _TermsConditionsScreenState createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  String _termsContent = '';
  String _lastUpdated = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    final response = await http.get(
      Uri.parse('${StringCons.baseApiUrl}/legal/terms'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _termsContent = data['content'];
        _lastUpdated = data['lastUpdated'];
        isLoading = false;
      });
    } else {
      // Handle the error if the API call fails
      setState(() {
        _termsContent = 'Failed to load terms and conditions.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading for Terms and Conditions
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 24, // Larger size for the heading
                      fontWeight: FontWeight.bold, // Bold styling
                      color: ClrCons.whiteColor,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ), // Adds space between the heading and content
                  // Terms Content
                  if (isLoading)
                    Center(
                      child: FastGifWidget(), // Custom loader widget
                    ),
                  if (_termsContent.isNotEmpty)
                    Text(
                      _termsContent,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: ClrCons.whiteColor,
                      ),
                    ),

                  // Last Updated date
                  if (_lastUpdated.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Last Updated: $_lastUpdated',
                        style: TextStyle(
                          fontSize: 12,
                          color: ClrCons.whiteColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
