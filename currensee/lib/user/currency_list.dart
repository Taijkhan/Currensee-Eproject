import 'package:currensee/admin/homepage.dart';
import 'package:currensee/user/currency_converter.dart';
import 'package:currensee/user/drawer.dart';
import 'package:currensee/user/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_flags/flutter_country_flags.dart';
import 'package:currensee/admin/admin_service.dart';

class CurrencyList extends StatefulWidget {
  final Map<String, dynamic> user;

  const CurrencyList({Key? key, required this.user}) : super(key: key);

  @override
  _CurrencyListState createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _currencies = [];
  List<Map<String, dynamic>> _filteredCurrencies = [];

  String _sortBy = "Name"; // Default sort option

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadCurrencies() async {
    setState(() => _isLoading = true);
    try {
      final currencies = await _adminService.getSupportedCurrencies();
      setState(() {
        _currencies = currencies;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading currencies: $e");
    }
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> temp = _currencies.where((currency) {
      String code = currency['code']?.toString().toLowerCase() ?? '';
      String name = currency['name']?.toString().toLowerCase() ?? '';
      return code.contains(query) || name.contains(query);
    }).toList();

    // Sorting
    if (_sortBy == "Name") {
      temp.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    } else if (_sortBy == "Code") {
      temp.sort((a, b) => (a['code'] ?? '').compareTo(b['code'] ?? ''));
    } else if (_sortBy == "Symbol") {
      temp.sort((a, b) => (a['symbol'] ?? '').compareTo(b['symbol'] ?? ''));
    }

    setState(() {
      _filteredCurrencies = temp;
    });
  }

  String? getCountryFromCurrency(String code) {
    switch (code.toUpperCase()) {
      case "AFN":
        return "AF";
      case "USD":
        return "US";
      case "PKR":
        return "PK";
      case "GBP":
        return "GB";
      case "EUR":
        return "EU"; // European union representative
      case "CAD":
        return "CA";
      case "AUD":
        return "AU";
      case "INR":
        return "IN";
      case "AED":
        return "AE";
      case "CNY":
        return "CN";
      case "JPY":
        return "JP";
      case "BRL":
        return "BR"; // Brazil
      case "ZAR":
        return "ZA"; // South Africa
      case "MXN":
        return "MX"; // Mexico
      case "RUB":
        return "RU"; // Russia
      case "SGD":
        return "SG"; // Singapore
      case "CHF":
        return "CH"; // Switzerland
      case "MYR":
        return "MY"; // Malaysia
      case "TRY":
        return "TR"; // Turkey
      case "KRW":
        return "KR"; // South Korea
      case "SEK":
        return "SE"; // Sweden
      case "NOK":
        return "NO"; // Norway
      case "DKK":
        return "DK"; // Denmark
      case "SAR":
        return "SA"; // Saudi Arabia
      case "THB":
        return "TH"; // Thailand
      case "IDR":
        return "ID"; // Indonesia
      case "PLN":
        return "PL"; // Poland
      case "PHP":
        return "PH"; // Philippines
      case "EGP":
        return "EG"; // Egypt
      case "VND":
        return "VN"; // Vietnam
      case "NZD":
        return "NZ"; // New Zealand
      case "HUF":
        return "HU"; // Hungary
      case "CZK":
        return "CZ"; // Czech Republic
      case "KWD":
        return "KW"; // Kuwait
      case "ARS":
        return "AR"; // Argentina
      case "NGN":
        return "NG";
      case "ZWL":
        return "ZW";
      case "BDT":
        return "BD"; // Bangladesh
      case "LKR":
        return "LK"; // Sri Lanka
      case "MAD":
        return "MA"; // Morocco
      case "TWD":
        return "TW"; // Taiwan
      case "CLP":
        return "CL"; // Chile
      case "COP":
        return "CO"; // Colombia
      case "DZD":
        return "DZ"; // Algeria
      case "QAR":
        return "QA"; // Qatar
      case "JOD":
        return "JO"; // Jordan
      case "OMR":
        return "OM"; // Oman
      case "BHD":
        return "BH"; // Bahrain
      case "UYU":
        return "UY"; // Uruguay
      case "KHR":
        return "KH"; // Cambodia
      case "MMK":
        return "MM"; // Myanmar
      case "ETB":
        return "ET"; // Ethiopia
      case "TZS":
        return "TZ"; // Tanzania
      case "KES":
        return "KE"; // Kenya
      case "NPR":
        return "NP"; // Nepal
      case "GHS":
        return "GH"; // Ghana
      case "BBD":
        return "BB"; // Barbados
      case "FJD":
        return "FJ"; // Fiji
      case "GYD":
        return "GY"; // Guyana
      case "JMD":
        return "JM"; // Jamaica
      case "LSL":
        return "LS"; // Lesotho
      case "MUR":
        return "MU"; // Mauritius
      case "NAD":
        return "NA"; // Namibia
      case "SCR":
        return "SC"; // Seychelles
      case "SYP":
        return "SY"; // Syria
      case "TTD":
        return "TT"; // Trinidad & Tobago
      case "UGX":
        return "UG"; // Uganda
      case "UZS":
        return "UZ"; // Uzbekistan
      case "VUV":
        return "VU"; // Vanuatu
      case "WST":
        return "WS"; // Samoa
      case "XOF":
        return "SN"; // Representative for West African CFA
      case "XAF":
        return "CM"; // Representative for Central African CFA
      case "ZMW":
        return "ZM"; // Zambia
      case "HKD":
        return "HK"; // Hong Kong
      case "ISK":
        return "IS"; // Iceland
      case "BAM":
        return "BA"; // Bosnia & Herzegovina
      case "MKD":
        return "MK"; // North Macedonia
      case "RON":
        return "RO"; // Romania
      case "BGN":
        return "BG"; // Bulgaria
      case "HRK":
        return "HR"; // Croatia
      case "KZT":
        return "KZ"; // Kazakhstan
      case "AZN":
        return "AZ"; // Azerbaijan
      case "GEL":
        return "GE"; // Georgia
      case "MNT":
        return "MN"; // Mongolia
      case "LAK":
        return "LA"; // Laos
      case "MOP":
        return "MO"; // Macau
      case "BND":
        return "BN"; // Brunei
      case "PGK":
        return "PG"; // Papua New Guinea
      case "TOP":
        return "TO"; // Tonga
      case "SBD":
        return "SB"; // Solomon Islands
      case "LBP":
        return "LB"; // Lebanon
      case "SDG":
        return "SD"; // Sudan
      case "MRU":
        return "MR"; // Mauritania
      case "AOA":
        return "AO"; // Angola
      case "CDF":
        return "CD"; // DR Congo
      case "MGA":
        return "MG"; // Madagascar
      case "RWF":
        return "RW"; // Rwanda
      case "SOS":
        return "SO"; // Somalia
      case "MWK":
        return "MW"; // Malawi
      case "SLL":
        return "SL"; // Sierra Leone
      case "GNF":
        return "GN"; // Guinea
      case "XPF":
        return "PF"; // French Polynesia (CFP)
      case "ALL":
        return "AL"; // Albania
      case "MDL":
        return "MD"; // Moldova
      case "KGS":
        return "KG"; // Kyrgyzstan
      case "TJS":
        return "TJ"; // Tajikistan
      case "AMD":
        return "AM"; // Armenia
      case "SRD":
        return "SR"; // Suriname
      case "BZD":
        return "BZ"; // Belize
      case "HTG":
        return "HT"; // Haiti
      case "CUP":
        return "CU"; // Cuba
      case "PAB":
        return "PA"; // Panama
      case "BWP":
        return "BW"; // Botswana
      case "SZL":
        return "SZ"; // Eswatini
      case "ERN":
        return "ER"; // Eritrea
      case "LYD":
        return "LY"; // Libya
      case "TND":
        return "TN"; // Tunisia
      case "DJF":
        return "DJ"; // Djibouti
      case "KMF":
        return "KM"; // Comoros
      case "MVR":
        return "MV"; // Maldives
      case "BTN":
        return "BT"; // Bhutan
      case "YER":
        return "YE"; // Yemen
      case "IRR":
        return "IR"; // Iran
      case "KPW":
        return "KP"; // North Korea
      case "AWG":
        return "AW"; // Aruba
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Currency List",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: UserDrawer(user: widget.user),
      body: Column(
        children: [
          // Homepage Button (restored to original position)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserHome(user: widget.user),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text("Homepage"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ), // Rounded corners for a modern look
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search and Sort Section (Improved UI)
          _buildSearchBarAndSort(theme),

          Expanded(child: _buildCurrencyList(theme)),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndSort(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                hintText: "Search by name or code...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              underline: SizedBox(),
              icon: Icon(Icons.sort, color: theme.colorScheme.primary),
              items: ["Name", "Code", "Symbol"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }
    if (_filteredCurrencies.isEmpty) {
      return Center(
        child: Text(
          "No currencies found",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _filteredCurrencies.length,
      itemBuilder: (context, index) {
        final currency = _filteredCurrencies[index];
        final countryCode =
            currency['country'] ??
            getCountryFromCurrency(currency['code'] ?? '');

        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: countryCode != null
                ? FlutterCountryFlags(
                    country: countryCode,
                    height: 40,
                    width: 50,
                    borderRadius: 8,
                  )
                : CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    radius: 20,
                    child: Text(
                      currency['code']?.substring(0, 2) ?? "??",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
            title: Text(
              currency['name'] ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${currency['code']} • ${currency['symbol']}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to converter and pre-select this currency as TARGET
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CurrencyConverter(
                      user: widget.user,
                      initialTarget: currency['code']?.toString(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Convert",
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
