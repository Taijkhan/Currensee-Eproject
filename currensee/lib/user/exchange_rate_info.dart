import 'package:currensee/user/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:currensee/user/drawer.dart';
import 'package:currensee/constants/app_color.dart';

class ExchangeRateInfo extends StatefulWidget {
  final Map<String, dynamic> user;

  const ExchangeRateInfo({Key? key, required this.user}) : super(key: key);

  @override
  _ExchangeRateInfoState createState() => _ExchangeRateInfoState();
}

class _ExchangeRateInfoState extends State<ExchangeRateInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> currencyList = [];
  String selectedCurrency = "PKR";
  String baseCurrency = "USD";
  Map<String, double> currentRates = {};
  List<RateData> historicalData = [];
  bool isLoading = true;
  String timeRange = "7days";
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadCurrencies();
    fetchCurrentRates();
    fetchHistoricalData();
  }

  Future<void> loadCurrencies() async {
    try {
      final snapshot = await _firestore.collection('currency').orderBy('name').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          currencyList = snapshot.docs
              .map((doc) => doc.data()['code']?.toString() ?? '')
              .where((code) => code.isNotEmpty)
              .toList();
          currencyList.sort();
        });
      } else {
        fetchCurrenciesFromAPI();
      }
    } catch (e) {
      fetchCurrenciesFromAPI();
    }
  }

  Future<void> fetchCurrenciesFromAPI() async {
    final response = await http.get(Uri.parse("https://open.er-api.com/v6/latest/USD"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currencyList = (data['rates'] as Map<String, dynamic>).keys.toList();
        currencyList.sort();
      });
    }
  }

  Future<void> fetchCurrentRates() async {
    try {
      final response = await http.get(Uri.parse("https://open.er-api.com/v6/latest/$baseCurrency"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentRates = Map<String, double>.from(data['rates']);
        });
      }
    } catch (e) {
      print("Error fetching current rates: $e");
    }
  }

  Future<void> fetchHistoricalData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
      historicalData = [];
    });

    try {
      final DateTime endDate = DateTime.now();
      DateTime startDate;
      
      switch (timeRange) {
        case "30days":
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case "90days":
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        case "1year":
          startDate = endDate.subtract(const Duration(days: 365));
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 7));
      }

      final String startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final String endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await http.get(Uri.parse(
          "https://api.frankfurter.app/$startDateStr..$endDateStr?from=$baseCurrency&to=$selectedCurrency"
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>?;
        
        if (rates != null && rates.isNotEmpty) {
          List<RateData> tempData = [];
          
          rates.forEach((date, currencyData) {
            if (currencyData is Map<String, dynamic>) {
              final rate = currencyData[selectedCurrency];
              if (rate != null) {
                tempData.add(RateData(
                  date: DateTime.parse(date),
                  rate: rate.toDouble(),
                ));
              }
            }
          });

          tempData.sort((a, b) => a.date.compareTo(b.date));

          setState(() {
            historicalData = tempData;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No historical data available for this period";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load historical data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: Please check your connection";
        isLoading = false;
      });
    }
  }

  void _showCurrencyDetails() {
    final theme = Theme.of(context);
    final currentRate = currentRates[selectedCurrency];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$baseCurrency/$selectedCurrency Details", 
            style: theme.textTheme.titleLarge),
        content: currentRate != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Rate: 1 $baseCurrency = ${currentRate.toStringAsFixed(4)} $selectedCurrency",
                      style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Text("24h Change: ${_calculate24hChange().toStringAsFixed(2)}%",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: _calculate24hChange() >= 0 ? AppColors.success : AppColors.error,
                      )),
                  const SizedBox(height: 8),
                  Text("Last Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}",
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ],
              )
            : Text("Rate information not available", style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  double _calculate24hChange() {
    if (historicalData.length < 2) return 0.0;
    
    final latestRate = historicalData.last.rate;
    final previousRate = historicalData[historicalData.length - 2].rate;
    
    return ((latestRate - previousRate) / previousRate) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange Rates"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      drawer: UserDrawer(user: widget.user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Exchange Rate Information",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "View historical trends and current rates",
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (errorMessage.isNotEmpty) const SizedBox(height: 16),

              // Currency Selection Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCurrencyRow(
                        context,
                        "Base Currency",
                        baseCurrency,
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildCurrencyRow(
                        context,
                        "Target Currency",
                        selectedCurrency,
                        false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Range Selector
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeRangeChip("7 Days", "7days", theme),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip("30 Days", "30days", theme),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip("90 Days", "90days", theme),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip("1 Year", "1year", theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Current Rate Card
              if (currentRates[selectedCurrency] != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: const Icon(Icons.currency_exchange, size: 30),
                    title: Text(
                      "Current Rate",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "1 $baseCurrency = ${currentRates[selectedCurrency]!.toStringAsFixed(4)} $selectedCurrency",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      color: theme.colorScheme.secondary,
                      onPressed: _showCurrencyDetails,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Chart Title
              Text(
                "Historical Trend",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Chart Container
              SizedBox(
                height: 300,
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                    : historicalData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timeline, size: 48, color: AppColors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  "No historical data available",
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SfCartesianChart(
                                primaryXAxis: DateTimeAxis(
                                  dateFormat: DateFormat('MMM dd'),
                                  title: AxisTitle(text: 'Date'),
                                  labelStyle: theme.textTheme.bodySmall,
                                ),
                                primaryYAxis: NumericAxis(
                                  title: AxisTitle(text: 'Exchange Rate'),
                                  numberFormat: NumberFormat.compact(),
                                  labelStyle: theme.textTheme.bodySmall,
                                ),
                                series: <CartesianSeries>[
                                  LineSeries<RateData, DateTime>(
                                    dataSource: historicalData,
                                    xValueMapper: (RateData rate, _) => rate.date,
                                    yValueMapper: (RateData rate, _) => rate.rate,
                                    color: theme.colorScheme.primary,
                                    width: 3,
                                    markerSettings: MarkerSettings(isVisible: true),
                                    name: '$baseCurrency/$selectedCurrency',
                                  ),
                                ],
                                tooltipBehavior: TooltipBehavior(enable: true),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeChip(String label, String value, ThemeData theme) {
    final isSelected = timeRange == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          timeRange = value;
          fetchHistoricalData();
        });
      },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : AppColors.grey,
        ),
      ),
    );
  }
  
  Widget _buildCurrencyRow(BuildContext context, String title, String currencyCode, bool isBase) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.bodyLarge),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currencyCode,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                items: currencyList.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(
                      currency,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      if (isBase) {
                        baseCurrency = newValue;
                        fetchCurrentRates();
                      } else {
                        selectedCurrency = newValue;
                      }
                      fetchHistoricalData();
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RateData {
  final DateTime date;
  final double rate;

  RateData({required this.date, required this.rate});
}