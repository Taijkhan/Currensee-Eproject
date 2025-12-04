import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:currensee/user/drawer.dart';
import 'package:currensee/user/homepage.dart';
 // fix: ensure correct path (you had AppColors import)

class CurrencyConverter extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? initialBase;
  final String? initialTarget;

  const CurrencyConverter({
    Key? key,
    required this.user,
    this.initialBase,
    this.initialTarget,
  }) : super(key: key);

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> currencyList = [];
  String baseCurrency = "USD";
  String targetCurrency = "PKR";
  String result = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If initial values were provided, set temporary defaults; real assignment happens after currencies are loaded
    if (widget.initialBase != null) baseCurrency = widget.initialBase!;
    if (widget.initialTarget != null) targetCurrency = widget.initialTarget!;
    loadCurrenciesFromFirebase();
  }

  Future<void> loadCurrenciesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('currency').orderBy('name').get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) {
              final data = doc.data();
              return data['code']?.toString() ?? '';
            })
            .where((code) => code.isNotEmpty)
            .toList();

        list.sort();

        setState(() {
          currencyList = list;
        });

        // After we have the list, ensure initialBase/initialTarget are valid and set them
        setState(() {
          if (widget.initialBase != null && currencyList.contains(widget.initialBase)) {
            baseCurrency = widget.initialBase!;
          } else if (!currencyList.contains(baseCurrency) && currencyList.isNotEmpty) {
            baseCurrency = currencyList.first;
          }

          if (widget.initialTarget != null && currencyList.contains(widget.initialTarget)) {
            targetCurrency = widget.initialTarget!;
          } else if (!currencyList.contains(targetCurrency) && currencyList.isNotEmpty) {
            // If the preset target isn't available, try to keep a sensible default (first different from base)
            targetCurrency = currencyList.firstWhere((c) => c != baseCurrency, orElse: () => currencyList.first);
          }
        });
      } else {
        await loadCurrenciesFromAPI();
      }
    } catch (e) {
      print("Error loading currencies from Firebase: $e");
      await loadCurrenciesFromAPI();
    }
  }

  Future<void> loadCurrenciesFromAPI() async {
    try {
      final url = "https://open.er-api.com/v6/latest/USD";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = (data['rates'] as Map<String, dynamic>).keys.map((k) => k.toString()).toList();
        list.sort();

        setState(() {
          currencyList = list;
        });

        // apply initial selections if available
        setState(() {
          if (widget.initialBase != null && currencyList.contains(widget.initialBase)) {
            baseCurrency = widget.initialBase!;
          } else if (!currencyList.contains(baseCurrency) && currencyList.isNotEmpty) {
            baseCurrency = currencyList.first;
          }

          if (widget.initialTarget != null && currencyList.contains(widget.initialTarget)) {
            targetCurrency = widget.initialTarget!;
          } else if (!currencyList.contains(targetCurrency) && currencyList.isNotEmpty) {
            targetCurrency = currencyList.firstWhere((c) => c != baseCurrency, orElse: () => currencyList.first);
          }
        });
      } else {
        print("API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading currencies from API: $e");
    }
  }

  Future<void> convertCurrency() async {
    final amountText = _amountController.text;

    if (amountText.isEmpty) {
      _showAlertDialog("Input Required", "Please enter an amount to convert.");
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showAlertDialog("Invalid Input", "Please enter a valid number.");
      return;
    }

    setState(() {
      isLoading = true;
      result = "";
    });

    try {
      final url = "https://open.er-api.com/v6/latest/$baseCurrency";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][targetCurrency];

        if (rate != null) {
          final converted = amount * (rate as num);

          setState(() {
            result = "${converted.toStringAsFixed(2)} $targetCurrency";
          });

          _showSuccessDialog(amount, baseCurrency, converted, targetCurrency);

          if (widget.user["Userrole"] != "Admin") {
            await _firestore.collection("history").add({
              "Email": widget.user["Email"],
              "Username": widget.user['FullName'],
              "Amount": amount,
              "From": baseCurrency,
              "To": targetCurrency,
              "Converted": converted,
              "Rate": rate,
              "Timestamp": FieldValue.serverTimestamp(),
            });
          }
        } else {
          _showAlertDialog(
            "Rate Unavailable",
            "Exchange rate not available for $targetCurrency",
          );
        }
      } else {
        _showAlertDialog(
          "API Error",
          "Failed to fetch exchange rates. Please try again.",
        );
      }
    } catch (e) {
      _showAlertDialog(
        "Network Error",
        "Please check your internet connection and try again.",
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showAlertDialog(String title, String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showSuccessDialog(
    double amount,
    String fromCurrency,
    double converted,
    String toCurrency,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
            SizedBox(width: 8),
            Text(
              "Conversion Successful",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$amount $fromCurrency =", style: theme.textTheme.bodyMedium),
            Text(
              "${converted.toStringAsFixed(2)} $toCurrency",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Rate: 1 $fromCurrency = ${(converted / amount).toStringAsFixed(4)} $toCurrency",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CurrenSee",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: UserDrawer(user: widget.user),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Homepage button with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserHome(user: widget.user),
                        ),
                      );
                    },
                    icon: Icon(Icons.home, color: theme.colorScheme.primary),
                    label: Text(
                      "Homepage",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title with icon
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Convert Currency",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Converter Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white, // keep card white or AppColors.surface
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Amount Input with bold label & icon
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: "Enter Amount",
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: theme.colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
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
                      const SizedBox(height: 20),

                      // From Currency Dropdown with label & icon
                      DropdownButtonFormField<String>(
                        value: baseCurrency,
                        decoration: InputDecoration(
                          labelText: "From Currency",
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.arrow_downward,
                            color: theme.colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: currencyList.isEmpty
                            ? [
                                DropdownMenuItem(
                                  value: "USD",
                                  child: Text(
                                    "USD",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ]
                            : currencyList.map((currencyCode) {
                                return DropdownMenuItem(
                                  value: currencyCode,
                                  child: Text(
                                    currencyCode,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            baseCurrency = newValue!;
                            // If base and target become same, try to pick a different target
                            if (baseCurrency == targetCurrency && currencyList.isNotEmpty) {
                              targetCurrency = currencyList.firstWhere((c) => c != baseCurrency, orElse: () => baseCurrency);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // To Currency Dropdown with label & icon
                      DropdownButtonFormField<String>(
                        value: targetCurrency,
                        decoration: InputDecoration(
                          labelText: "To Currency",
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.arrow_upward,
                            color: theme.colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: currencyList.isEmpty
                            ? [
                                DropdownMenuItem(
                                  value: "PKR",
                                  child: Text(
                                    "PKR",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ]
                            : currencyList.map((currencyCode) {
                                return DropdownMenuItem(
                                  value: currencyCode,
                                  child: Text(
                                    currencyCode,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            targetCurrency = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Convert Button with icon and bold text
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : convertCurrency,
                          icon: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.swap_horiz,
                                  color: theme.colorScheme.onPrimary,
                                ),
                          label: Text(
                            isLoading ? "Converting..." : "Convert",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Loading indicator for initial currency load
              if (currencyList.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
