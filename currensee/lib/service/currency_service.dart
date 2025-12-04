import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<Map<String, double>> fetchRates(String base) async {
    final url = Uri.parse("https://open.er-api.com/v6/latest/$base");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = Map<String, double>.from(data['rates']);
      return rates;
    } else {
      throw Exception("Failed to load currency rates");
    }
  }
}
