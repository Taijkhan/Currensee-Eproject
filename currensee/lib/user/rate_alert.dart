import 'package:currensee/user/drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RateAlert extends StatefulWidget {
  final String email;
  final Map<String, dynamic> user;

  const RateAlert({super.key, required this.email, required this.user});

  @override
  State<RateAlert> createState() => _RateAlertState();
}

class _RateAlertState extends State<RateAlert> {
  String? selectedCurrency;
  final TextEditingController rateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveAlert(Map<String, dynamic> currencyData) async {
    if (selectedCurrency == null) {
      _showErrorDialog("Please select a currency");
      return;
    }

    if (rateController.text.isEmpty) {
      _showErrorDialog("Please enter a target rate");
      return;
    }

    double? targetRate = double.tryParse(rateController.text);
    if (targetRate == null || targetRate <= 0) {
      _showErrorDialog("Please enter a valid positive rate");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("rate_alerts").add({
        "Email": widget.email,
        "Currency": currencyData['code'],
        "CurrencyName": currencyData['name'],
        "TargetRate": targetRate,
        "Timestamp": FieldValue.serverTimestamp(),
        "Status": "active",
        "IsNotified": false,
      });

      _showSuccessDialog(currencyData['name']);
    } catch (e) {
      _showErrorDialog("Failed to save alert. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String currencyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Success"),
          ],
        ),
        content: Text("Rate alert for $currencyName has been set successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Rate Alert"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      drawer: UserDrawer(user: widget.user,),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Rate Alert",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Get notified when your target rate is reached",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Currency Dropdown from Firestore
              Text(
                "Select Currency",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("currency").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No currencies found. Please add currencies to the collection.");
                  }

                  final currencies = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCurrency,
                      hint: const Text("Select a currency"),
                      items: currencies.map((currency) {
                        final code = currency['code'] ?? '';
                        final name = currency['name'] ?? '';
                        return DropdownMenuItem<String>(
                          value: code,
                          child: Text("$code - $name"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCurrency = val;
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Target Rate Input
              Text(
                "Target Exchange Rate",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "Enter your target exchange rate",
                  prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || selectedCurrency == null
                      ? null
                      : () async {
                          final doc = await FirebaseFirestore.instance
                              .collection("currency")
                              .where("code", isEqualTo: selectedCurrency)
                              .get();
                          if (doc.docs.isNotEmpty) {
                            await _saveAlert(doc.docs.first.data() as Map<String, dynamic>);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications, color: theme.colorScheme.onPrimary),
                            const SizedBox(width: 8),
                            Text(
                              "Set Alert",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const Spacer(),

              // Info Section
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "How it works:",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Select a currency and set your target exchange rate\n"
                        "• We'll monitor exchange rates for you\n"
                        "• You'll receive a notification when the rate reaches your target",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    rateController.dispose();
    super.dispose();
  }
}
