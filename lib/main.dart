import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  Stripe.publishableKey =
      'pk_test_51PJt7MSEyw5WOO4EltXHyV4rtGiiaqpWmJCjFmBRZOb25z2xK0KHsqgkqNk1VjpCIQfsKMvOU8y7H30cPa65eFvo00pOqaSCFA'; // Use your publishable key
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  Map<String, dynamic> paymentIntentData = {};

  void makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent();

      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Ikay',
        ),
      )
          .then((value) {
        print('Payment sheet initialized');
      }).catchError((e) {
        print('Error initializing payment sheet: $e');
      });

      displayPaymentSheet();
    } catch (e) {
      print('Error: $e');
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
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
              'Bearer sk_test_51PJt7MSEyw5WOO4EXYNeKpA21KO9noxB7a49IwgHwADsrln9Tgywe9tAGlWVtQnF0W1if38YSR84UphC4sfW8WBQ00G7eNaYUf',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      // print the url
      print(response.request!.url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
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
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
