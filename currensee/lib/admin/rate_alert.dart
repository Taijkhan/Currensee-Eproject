import 'package:currensee/service/currency_service.dart';
import 'package:flutter/material.dart';

class RateAlertScreen extends StatefulWidget {
  const RateAlertScreen({Key? key}) : super(key: key);

  @override
  State<RateAlertScreen> createState() => _RateAlertScreenState();
}

class _RateAlertScreenState extends State<RateAlertScreen> {
  Map<String, double> _rates = {};
  Map<String, double> _oldRates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    // auto refresh every 30 sec
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      await _fetchRates();
      return true;
    });
  }

  Future<void> _fetchRates() async {
    try {
      final rates = await CurrencyService.fetchRates("USD");
      setState(() {
        _oldRates = _rates;
        _rates = rates;
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("💹 Currency Rate Alerts"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRates,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _rates.length,
                itemBuilder: (context, index) {
                  final code = _rates.keys.elementAt(
                    index,
                  ); // e.g. PKR, INR, EUR
                  final rate = _rates[code]!;
                  final oldRate = _oldRates[code];
                  String trend = "No Change";
                  Color trendColor = Colors.grey;
                  IconData trendIcon = Icons.horizontal_rule;

                  if (oldRate != null) {
                    if (rate > oldRate) {
                      trend = "Increased";
                      trendColor = Colors.green;
                      trendIcon = Icons.arrow_upward;
                    } else if (rate < oldRate) {
                      trend = "Decreased";
                      trendColor = Colors.red;
                      trendIcon = Icons.arrow_downward;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.85),
                          theme.colorScheme.secondary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      title: Text(
                        "1 USD = ${rate.toStringAsFixed(2)} $code",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "Base Currency: USD",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(trendIcon, color: trendColor, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            trend,
                            style: TextStyle(
                              color: trendColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
