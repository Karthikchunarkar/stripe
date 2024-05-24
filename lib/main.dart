import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  Stripe.publishableKey =
      'mfbultan4ij4t44kjsp8ii3ghohe4j5qo4bgnpljlkq5se37v40a';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> paymentIntnet = {};

  void makePayment() async {
    try {
      paymentIntnet = await createPaymentIntent();

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntnet['client_secret'],
                  merchantDisplayName: 'Ikay'))
          .then((value) {});

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Done');
    } catch (e) {
      print('Failed');
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        'amount': '2000',
        'currency': 'USD',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('&'),
        headers: {
          'Authorization':
              'Bearer sk_test_51OZwpmSCZL8FwXYbkpy5hsA3zgQHJOGU33A7OLiJfYKIWInKycxddWHnS46toCUs3PzwZsTMjrjHk10eNtaqCTnz00K6KqEIjX',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: ${e.toString()}');
    }
  }

  Future<void> testNetwork() async {
    try {
      var response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        print('Network is working');
      } else {
        print('Failed to connect to the internet');
      }
    } catch (e) {
      print('Network test error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                makePayment();
              },
              child: const Text('Pay Now'))),
    );
  }
}
