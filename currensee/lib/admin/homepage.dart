import 'package:currensee/admin/admin_contact.dart';
import 'package:currensee/admin/admin_profile.dart';
import 'package:currensee/admin/currency_management.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/rate_alert.dart';
import 'package:currensee/admin/setting.dart';
import 'package:currensee/admin/user_conversion_history.dart';
import 'package:currensee/admin/user_management.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHome extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminHome({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState(user: user);
}

class _AdminHomeState extends State<AdminHome> {
  final Map<String, dynamic> user;

  _AdminHomeState({required this.user});

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
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('asset/register_screen.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Admin Dashboard",
                style: GoogleFonts.robotoSlab(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${user['FullName'] ?? 'Admin'}!",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardContainer(
                    icon: Icons.account_circle,
                    label: "My Profile",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProfile(user: user),
                        ),
                      );
                    },
                  ),
                  _buildDashboardContainer(
                    icon: Icons.people,
                    label: "User's Profile",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserManagement(user: user),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardContainer(
                    icon: Icons.currency_exchange,
                    label: "Currency Management",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CurrencyManagement(user: user),
                        ),
                      );
                    },
                  ),
                  _buildDashboardContainer(
                    icon: Icons.history,
                    label: "Conversion History",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminConversionsScreen(user: user),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardContainer(
                    icon: Icons.notifications,
                    label: "Contacts",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  AdminHelpCenterPage(user: user),
                        ),
                      );
                    },
                  ),
                  _buildDashboardContainer(
                    icon: Icons.settings,
                    label: "Settings",
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminSettings(user: user),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContainer({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}