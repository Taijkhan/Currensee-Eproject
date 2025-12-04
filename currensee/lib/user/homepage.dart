import 'dart:convert';
import 'package:currensee/constants/app_color.dart';
import 'package:currensee/user/conversion_history.dart';
import 'package:currensee/user/user_notification.dart';
import 'package:currensee/user/user_profile.dart';
import 'package:currensee/user/rate_alert.dart'; // new screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:currensee/user/drawer.dart';

class UserHome extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserHome({Key? key, required this.user}) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  String? fromCurrency;
  String? toCurrency;
  final TextEditingController amountController = TextEditingController();
  double? convertedResult;
  bool isLoading = false;

  List<Map<String, dynamic>> currencies = [];
  int notificationCount = 0; // counter for bell icon

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _listenNotifications();
  }

  Future<void> _loadCurrencies() async {
  final snapshot = await FirebaseFirestore.instance
      .collection("currency")
      .get();

  setState(() {
    currencies = snapshot.docs.map((doc) {
      return {"code": doc['code'], "name": doc['name']};
    }).toList();

    if (currencies.isNotEmpty) {
      final hasPKR = currencies.any((c) => c['code'] == "PKR");
      fromCurrency = hasPKR ? "PKR" : currencies.first['code'];

      final hasSAR = currencies.any((c) => c['code'] == "SAR");
      toCurrency = hasSAR
          ? "SAR"
          : (currencies.length > 1 ? currencies[1]['code'] : currencies.first['code']);
    }
  });
}

  void _listenNotifications() {
    FirebaseFirestore.instance
        .collection("notifications")
        .where("Email", isEqualTo: widget.user['Email'])
        .snapshots()
        .listen((snapshot) {
          setState(() {
            notificationCount = snapshot.docs.length;
          });
        });
  }

  Future<void> convertCurrency() async {
    String input = amountController.text.trim();
    double? amount = double.tryParse(input);

    if (amount == null || amount <= 0) {
      _showDialog("Invalid Input", "Please enter numbers only.");
      return;
    }

    if (fromCurrency == null || toCurrency == null) {
      _showDialog("Missing Selection", "Please select both currencies.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = "https://open.er-api.com/v6/latest/$fromCurrency";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["result"] == "success") {
          double rate = (data["rates"][toCurrency] ?? 0).toDouble();
          double result = amount * rate;

          setState(() {
            convertedResult = result;
          });

          await FirebaseFirestore.instance.collection("history").add({
            "Username": widget.user['FullName'] ?? "User",
            "Email": widget.user['Email'],
            "From": fromCurrency,
            "To": toCurrency,
            "Amount": amount,
            "Converted": result,
            "Rate": rate.toStringAsFixed(2),
            "Timestamp": DateTime.now().toString(),
          });

          /// Check if user has an alert for this currency
          final alertSnapshot = await FirebaseFirestore.instance
              .collection("rate_alerts")
              .where("Email", isEqualTo: widget.user['Email'])
              .where("Currency", isEqualTo: toCurrency)
              .get();

          for (var alert in alertSnapshot.docs) {
            final alertData = alert.data();
            double targetRate = (alertData["TargetRate"] as num).toDouble();

            if (rate >= targetRate) {
              // Add notification
              await FirebaseFirestore.instance.collection("notifications").add({
                "Email": widget.user['Email'],
                "Message":
                    "Your alert for $toCurrency has been hit! Current Rate: $rate",
                "Timestamp": DateTime.now().toString(),
              });
            }
          }
        } else {
          _showDialog("Error", "Failed to fetch conversion rates.");
        }
      } else {
        _showDialog("Error", "API request failed.");
      }
    } catch (e) {
      _showDialog("Error", "Something went wrong: $e");
    }

    setState(() => isLoading = false);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserProfile(email: widget.user['Email'], user: widget.user),
        ),
      );
    }
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
        actions: [
  Stack(
    children: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          // Navigate to notifications page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsPage(user: widget.user),
            ),
          );
        },
      ),
      if (notificationCount > 0)
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              notificationCount > 9 ? '9+' : '$notificationCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  ),
],
      ),
      drawer: UserDrawer(user: widget.user),
      body: currencies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Welcome, ${widget.user['FullName'] ?? "User"} 👋",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppColors.surface,
                    elevation: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "Want to Convert Money",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Enter Amount",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: fromCurrency,
                                  items: currencies
                                      .map<DropdownMenuItem<String>>((
                                        currency,
                                      ) {
                                        final code = currency['code'] as String;
                                        final name = currency['name'] as String;
                                        return DropdownMenuItem<String>(
                                          value: code,
                                          child: Text("$code - $name"),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => fromCurrency = val),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.swap_horiz, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: toCurrency,
                                  items: currencies
                                      .map<DropdownMenuItem<String>>((
                                        currency,
                                      ) {
                                        final code = currency['code'] as String;
                                        final name = currency['name'] as String;
                                        return DropdownMenuItem<String>(
                                          value: code,
                                          child: Text("$code - $name"),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => toCurrency = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading ? null : convertCurrency,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Convert",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 15),
                          if (convertedResult != null)
                            Text(
                              "${amountController.text} $fromCurrency = ${convertedResult!.toStringAsFixed(2)} $toCurrency",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 Quick Actions Section
                  Text(
                    "Quick Actions",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Rate Alerts
                      Expanded(
                        child: Card(
                          color: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RateAlert(
                                    email: widget.user['Email'],
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.notifications_active,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Rate Alerts",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // History
                      Expanded(
                        child: Card(
                          color: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversionHistory(
                                    email: widget.user['Email'],
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "History",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Recent Conversions",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("history")
                        .where("Email", isEqualTo: widget.user['Email'])
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text("No conversions yet.");
                      }
                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // smaller rounded corners
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.8),
                                  theme.colorScheme.secondary.withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 20, // smaller size
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  Icons.currency_exchange,
                                  color: theme.colorScheme.primary,
                                  size: 22, // smaller icon
                                ),
                              ),
                              title: Text(
                                "${data['Amount']} ${data['From']} → "
                                "${(data['Converted'] as num).toStringAsFixed(2)} ${data['To']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14, // smaller text
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    "Rate: 1 ${data['From']} = ${data['Rate']} ${data['To']}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    data.containsKey("Timestamp")
                                        ? "On: ${data['Timestamp']}"
                                        : "Recently converted",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "My Profile",
          ),
        ],
      ),
    );
  }
}
