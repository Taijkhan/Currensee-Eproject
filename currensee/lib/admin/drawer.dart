import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/admin/admin_contact.dart';
import 'package:currensee/admin/currency_management.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:currensee/admin/rate_alert.dart';
import 'package:currensee/admin/setting.dart';
import 'package:currensee/admin/user_conversion_history.dart';
import 'package:currensee/admin/user_management.dart';
import 'package:currensee/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final Stream<DocumentSnapshot> stream = FirebaseFirestore.instance
      .collection("registration")
      .doc("admin@gmail.com")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No user data found",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }

          var user = snapshot.data!.data() as Map<String, dynamic>;

          Uint8List? filebyte;
          if (user["Filebyte"] != null) {
            try {
              filebyte = Uint8List.fromList(List<int>.from(user["Filebyte"]));
            } catch (e) {
              print("Image conversion error: $e");
            }
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: filebyte != null
                          ? MemoryImage(filebyte)
                          : (user["Filename"] != null &&
                                  user["Filename"].toString().isNotEmpty
                              ? NetworkImage(user["Filename"])
                              : const AssetImage(
                                  "assets/images/default_avatar.png",
                                ) as ImageProvider),
                      child: filebyte == null &&
                              (user["Filename"] == null ||
                                  user["Filename"].toString().isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // User Name
                    Text(
                      user["FullName"] ?? "No Name",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // User Email
                    Text(
                      user["Email"] ?? "No Email",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Dashboard
              _buildDrawerTile(
                context,
                icon: Icons.dashboard,
                label: "Dashboard",
                theme: theme,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHome(user: user),
                    ),
                  );
                },
              ),

              // User Management
              _buildDrawerTile(
                context,
                icon: Icons.people,
                label: "User Management",
                theme: theme,
                onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagement(user: user,),)
                  );
                },
              ),

              // Currency Management
              _buildDrawerTile(
                context,
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

              // Conversion History
              _buildDrawerTile(
                context,
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

              // Contacts
              _buildDrawerTile(
                context,
                icon: Icons.notifications,
                label: "Contacts",
                theme: theme,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHelpCenterPage(user: user,),
                    ),
                  );
                },
              ),

              const Divider(),

              // Settings
              _buildDrawerTile(
                context,
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

              // Logout
              _buildDrawerTile(
                context,
                icon: Icons.logout,
                label: "Logout",
                theme: theme,
                isLogout: true,
                onTap: () => _showLogoutConfirmation(theme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ThemeData theme,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isLogout
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      hoverColor: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutConfirmation(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.lato(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }
}
