import 'package:currensee/auth/login.dart';
import 'package:currensee/user/conversion_history.dart';
import 'package:currensee/user/currency_converter.dart';
import 'package:currensee/user/currency_list.dart';
import 'package:currensee/user/exchange_rate_info.dart';
import 'package:currensee/user/homepage.dart';
import 'package:currensee/user/market_trends.dart';
import 'package:currensee/user/rate_alert.dart';
import 'package:currensee/user/user_preference.dart';
import 'package:flutter/material.dart';

class UserDrawer extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDrawer({super.key, required this.user});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.currency_exchange, color: Colors.white, size: 40),
                    const SizedBox(width: 10),
                    Text(
                      'CurrenSee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Exchange Made Easy 💱",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text("🇺🇸", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 10),
                    Text("🇪🇺", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 10),
                    Text("🇮🇳", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 10),
                    Text("🇵🇰", style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),

          // Homepage
          ListTile(
            leading: Icon(Icons.dashboard, color: theme.colorScheme.onSurface),
            title: Text("Homepage", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserHome(user: widget.user),
                ),
              );
            },
          ),

          // Currency Conversion
          ListTile(
            leading: Icon(Icons.currency_exchange, color: theme.colorScheme.onSurface),
            title: Text("Currency Conversion", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyConverter(user: widget.user,),
                ),
              );
            },
          ),

          // Currency List
          ListTile(
            leading: Icon(Icons.list, color: theme.colorScheme.onSurface),
            title: Text("Currency List", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => CurrencyList(user: widget.user,),
                  ),
                );
            },
          ),

          // Exchange Rate Info
          ListTile(
            leading: Icon(Icons.show_chart, color: theme.colorScheme.onSurface),
            title: Text("Exchange Rate Info", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ExchangeRateInfo(user: widget.user),
                  )
                );
            },
          ),

          // Conversion History
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
            title: Text("Conversion History", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ConversionHistory(email: widget.user["Email"], user: widget.user,),
                  )
                );
            },
          ),

          // Rate Alerts
          ListTile(
            leading: Icon(Icons.notifications, color: theme.colorScheme.onSurface),
            title: Text("Rate Alerts", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => RateAlert(email: widget.user["Email"], user: widget.user,),
                  )
                );
            },
          ),

          // Preferences
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text("User Preferences", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserPreference(user: widget.user),
                  )
                );
            },
          ),

          // Market Trends
          ListTile(
            leading: Icon(Icons.newspaper, color: theme.colorScheme.onSurface),
            title: Text("Market Trends", style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => CurrencyNewsPage(user: widget.user),
                  )
                );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              "Logout",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            onTap: () {
              _showLogoutConfirmation(theme);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: theme.textTheme.titleLarge),
        content: Text(
          "Are you sure you want to logout?",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }
}
