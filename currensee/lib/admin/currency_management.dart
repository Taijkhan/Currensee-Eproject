import 'package:currensee/admin/admin_service.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_flags/flutter_country_flags.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyManagement extends StatefulWidget {
  final Map<String, dynamic> user;

  const CurrencyManagement({Key? key, required this.user}) : super(key: key);

  @override
  _CurrencyManagementState createState() => _CurrencyManagementState();
}

class _CurrencyManagementState extends State<CurrencyManagement> {
  final AdminService _adminService = AdminService();
  final formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();

  bool _isLoading = true;
  bool _isAdding = false;
  List<Map<String, dynamic>> _currencies = [];

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() => _isLoading = true);

    try {
      final currencies = await _adminService.getSupportedCurrencies();
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading currencies: $e');
    }
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
        return "EU"; // Germany for Euro
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
        return "DK"; // Denmark (Flag Added) // Denmark
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
      case "ZWD":
        return "ZD";
      case "BDT":
        return "BD"; // Bangladesh
      case "LKR":
        return "LK"; // Sri Lankan Rupee (Rs)
      case "MAD":
        return "MA"; // Moroccan Dirham (د.م.)
      case "TWD":
        return "TW"; // New Taiwan Dollar (NT$)
      case "CLP":
        return "CL"; // Chilean Peso ($)
      case "COP":
        return "CO"; // Colombian Peso ($)
      case "DZD":
        return "DZ"; // Algerian Dinar (دج)
      case "QAR":
        return "QA"; // Qatari Riyal (ر.ق)
      case "JOD":
        return "JO"; // Jordanian Dinar (د.ا)
      case "OMR":
        return "OM"; // Omani Rial (ر.ع.)
      case "BHD":
        return "BH"; // Bahraini Dinar (.د.ب)
      case "UYU":
        return "UY"; // Uruguayan Peso ($U)
      case "KHR":
        return "KH"; // Cambodian Riel (៛)
      case "MMK":
        return "MM"; // Myanmar Kyat (K)
      case "ETB":
        return "ET"; // Ethiopian Birr (Br)
      case "TZS":
        return "TZ"; // Tanzanian Shilling (TSh)
      case "KES":
        return "KE"; // Kenyan Shilling (KSh)
      case "NPR":
        return "NP"; // Nepalese Rupee (₨) - Nepal
      case "GHS":
        return "GH"; // Ghanaian Cedi (₵) - Ghana
      case "BBD":
        return "BB"; // Barbados Dollar (Bds$) - Barbados
      case "FJD":
        return "FJ"; // Fiji Dollar (FJ$) - Fiji
      case "GYD":
        return "GY"; // Guyanese Dollar (G$) - Guyana
      case "JMD":
        return "JM"; // Jamaican Dollar (J$) - Jamaica
      case "LSL":
        return "LS"; // Lesotho Loti (M) - Lesotho
      case "MUR":
        return "MU"; // Mauritian Rupee (₨) - Mauritius
      case "NAD":
        return "NA"; // Namibian Dollar (N$) - Namibia
      case "SCR":
        return "SC"; // Seychellois Rupee (₨) - Seychelles
      case "SYP":
        return "SY"; // Syrian Pound (LS) - Syria
      case "TTD":
        return "TT"; // Trinidad and Tobago Dollar (TT$) - Trinidad and Tobago
      case "UGX":
        return "UG"; // Ugandan Shilling (USh) - Uganda
      case "UZS":
        return "UZ"; // Uzbekistan Som (so'm) - Uzbekistan
      case "VUV":
        return "VU"; // Vanuatu Vatu (VT) - Vanuatu
      case "WST":
        return "WS"; // Samoan Tala (WS$) - Samoa
      case "XOF":
        return "SN"; // West African CFA franc (Fr) - Senegal (used by several countries)
      case "XAF":
        return "CM"; // Central African CFA franc (Fr) - Cameroon (used by several countries)
      case "ZMW":
        return "ZM"; // Zambian Kwacha (ZK) - Zambia
      case "HKD":
        return "HK"; // Hong Kong Dollar (HK$)
      case "ISK":
        return "IS"; // Icelandic Krona (kr)
      case "BAM":
        return "BA"; // Bosnia Convertible Mark (KM)
      case "MKD":
        return "MK"; // North Macedonian Denar (ден)
      case "RON":
        return "RO"; // Romanian Leu (lei)
      case "BGN":
        return "BG"; // Bulgarian Lev (лв)
      case "HRK":
        return "HR"; // Croatian Kuna (kn)
      case "KZT":
        return "KZ"; // Kazakhstani Tenge (₸)
      case "AZN":
        return "AZ"; // Azerbaijani Manat (₼)
      case "GEL":
        return "GE"; // Georgian Lari (₾)
      case "MNT":
        return "MN"; // Mongolian Tögrög (₮)
      case "LAK":
        return "LA"; // Lao Kip (₭)
      case "MOP":
        return "MO"; // Macanese Pataca (MOP$)
      case "BND":
        return "BN"; // Brunei Dollar (B$)
      case "PGK":
        return "PG"; // Papua New Guinean Kina (K)
      case "TOP":
        return "TO"; // Tongan Paʻanga (T$)
      case "SBD":
        return "SB"; // Solomon Islands Dollar (SI$)
      case "LBP":
        return "LB"; // Lebanese Pound (ل.ل / L£)
      case "SDG":
        return "SD"; // Sudanese Pound (ج.س)
      case "MRU":
        return "MR"; // Mauritanian Ouguiya (UM)
      case "AOA":
        return "AO"; // Angolan Kwanza (Kz)
      case "CDF":
        return "CD"; // Congolese Franc (FC)
      case "MGA":
        return "MG"; // Malagasy Ariary (Ar)
      case "RWF":
        return "RW"; // Rwandan Franc (FRw / RF)
      case "SOS":
        return "SO"; // Somali Shilling (Sh.So.)
      case "MWK":
        return "MW"; // Malawian Kwacha (MK)
      case "SLL":
        return "SL"; // Sierra Leonean Leone (Le)
      case "GNF":
        return "GN"; // Guinean Franc (FG)
      case "XPF":
        return "PF"; // CFP Franc (₣)
      case "ALL":
        return "AL"; // Albanian Lek (L)
      case "MDL":
        return "MD"; // Moldovan Leu (L)
      case "KGS":
        return "KG"; // Kyrgyzstani Som (⃀ / с)
      case "TJS":
        return "TJ"; // Tajikistani Somoni (ЅМ)
      case "AMD":
        return "AM"; // Armenian Dram (֏)
      case "SRD":
        return "SR"; // Surinamese Dollar (SR$)
      case "BZD":
        return "BZ"; // Belize Dollar (BZ$)
      case "HTG":
        return "HT"; // Haitian Gourde (G)
      case "CUP":
        return "CU"; // Cuban Peso (₱)
      case "CUC":
        return "CU"; // Cuban Convertible Peso (CUC$)
      case "PAB":
        return "PA"; // Panamanian Balboa (B/.)
      case "BWP":
        return "BW"; // Botswana Pula (P)
      case "SZL":
        return "SZ"; // Eswatini Lilangeni (E)
      case "ERN":
        return "ER"; // Eritrean Nakfa (Nfk)
      case "LYD":
        return "LY"; // Libyan Dinar (ل.د)
      case "TND":
        return "TN"; // Tunisian Dinar (د.ت)
      case "DJF":
        return "DJ"; // Djiboutian Franc (Fdj)
      case "KMF":
        return "KM"; // Comorian Franc (CF)
      case "MVR":
        return "MV"; // Maldivian Rufiyaa (ރ)
      case "BTN":
        return "BT"; // Bhutanese Ngultrum (Nu.)
      case "YER":
        return "YE"; // Yemeni Rial (﷼)
      case "IRR":
        return "IR"; // Iranian Rial (﷼)
      case "AWG":
      return "AW";
         
      case "KPW":
      return "KP"; // North Korean Won (₩)


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
          "CurrenSee",
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: AdminDrawer(),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: TextButton.icon(
                icon: Icon(Icons.dashboard, color: theme.colorScheme.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHome(user: widget.user),
                    ),
                  );
                },
                label: Text(
                  "Admin Dashboard",
                  style: GoogleFonts.lato(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Center(
            child: Text(
              "💱 Currency List",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Currency List
          Expanded(child: _buildCurrencyList(theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCurrencyDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrencyList(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_currencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.currency_exchange,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No currencies found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first currency',
              style: GoogleFonts.lato(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currencies.length,
      itemBuilder: (context, index) {
        final currency = _currencies[index];
        return _buildCurrencyCard(currency, theme);
      },
    );
  }

  Widget _buildCurrencyCard(Map<String, dynamic> currency, ThemeData theme) {
    final countryCode =
        currency['country'] ?? getCountryFromCurrency(currency['code'] ?? '');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: countryCode != null
            ? FlutterCountryFlags(
                country: countryCode,
                height: 32,
                width: 42,
                borderRadius: 8,
              )
            : CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  currency['code']?.substring(0, 2) ?? '??',
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        title: Text(
          currency['name'] ?? '',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code: ${currency['code']}',
                style: GoogleFonts.lato(fontSize: 13),
              ),
              Text(
                'Symbol: ${currency['symbol']}',
                style: GoogleFonts.lato(fontSize: 13),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: () => _showDeleteConfirmation(currency, theme),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> currency, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Currency',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${currency['name']} (${currency['code']})?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCurrency(currency['id']);
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCurrencyDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Currency',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      codeController,
                      "Currency Code*",
                      "e.g., USD, EUR, GBP",
                      Icons.code,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      nameController,
                      "Currency Name*",
                      "e.g., US Dollar, Euro",
                      Icons.money,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      symbolController,
                      "Currency Symbol*",
                      "e.g., \$, €, £, ₹",
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isAdding ? null : _addCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Add Currency',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value!.isEmpty ? 'Please enter ${label.toLowerCase()}' : null,
    );
  }

  void _addCurrency() async {
    if (formKey.currentState!.validate()) {
      setState(() => _isAdding = true);

      final countryCode = getCountryFromCurrency(codeController.text);

      final currencyData = {
        'code': codeController.text.toUpperCase(),
        'name': nameController.text,
        'symbol': symbolController.text,
        'country': countryCode,
      };

      try {
        await _adminService.addCurrency(currencyData);
        _resetForm();
        Navigator.pop(context);
        await _loadCurrencies();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency added successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add currency: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() => _isAdding = false);
      }
    }
  }

  void _resetForm() {
    codeController.clear();
    nameController.clear();
    symbolController.clear();
  }

  void _deleteCurrency(String currencyId) async {
    try {
      await _adminService.deleteCurrency(currencyId);
      await _loadCurrencies();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Currency deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete currency: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    symbolController.dispose();
    super.dispose();
  }
}
