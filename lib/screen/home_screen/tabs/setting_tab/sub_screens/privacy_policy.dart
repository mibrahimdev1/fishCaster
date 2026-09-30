import 'dart:convert';
import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/widgets/Theme/themedBackground.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _privacyPolicyContent = '';
  String _lastUpdated = '';
  bool isLoading = true; // Start with true to show loader initially

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    final response = await http.get(
      Uri.parse('${StringCons.baseApiUrl}/legal/privacy'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _privacyPolicyContent = data['content'];
        _lastUpdated = data['lastUpdated'];
        isLoading = false; // Set isLoading to false when data is loaded
      });
    } else {
      setState(() {
        _privacyPolicyContent = 'Failed to load privacy policy.';
        isLoading = false; // Set isLoading to false even if there's an error
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
                  // Heading for Privacy Policy
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24, // Larger size for the heading
                      fontWeight: FontWeight.bold, // Bold styling
                      color: ClrCons.whiteColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  // If loading, show the loader centered
                  if (isLoading)
                    Center(
                      child: FastGifWidget(), // Custom loader widget
                    ),
                  // Privacy Policy Content
                  if (_privacyPolicyContent.isNotEmpty && !isLoading)
                    Text(
                      _privacyPolicyContent,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: ClrCons.whiteColor,
                      ),
                    ),
                  // Last Updated date
                  if (_lastUpdated.isNotEmpty && !isLoading)
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
