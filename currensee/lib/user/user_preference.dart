import 'dart:typed_data';

import 'package:currensee/admin/change_password.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/edit_profile.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:currensee/auth/login.dart';
import 'package:currensee/user/drawer.dart';
import 'package:currensee/user/help_center.dart';
import 'package:currensee/user/homepage.dart';
import 'package:currensee/user/user_edit_profile.dart';
import 'package:flutter/material.dart';

class UserPreference extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserPreference({Key? key, required this.user}) : super(key: key);

  @override
  _UserPreferenceState createState() => _UserPreferenceState(user: user);
}

class _UserPreferenceState extends State<UserPreference> {
  final Map<String, dynamic> user;

  _UserPreferenceState({required this.user});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Homepage Button with Icon
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserHome(user: user),
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

            // Profile Section
            Center(
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      backgroundImage: user["Filebyte"] != null
                          ? MemoryImage(
                              Uint8List.fromList(
                                List<int>.from(user["Filebyte"]),
                              ),
                            )
                          : const AssetImage("assets/images/default_avatar.png")
                                as ImageProvider,
                      child: user["Filebyte"] == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    user["FullName"] ?? "User",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Settings Options
            Expanded(
              child: ListView(
                children: [
                  // Edit Profile
                  _buildSettingsItem(
                    context,
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserEdit(user: user),
                        ),
                      );
                    },
                  ),

                  // Change Password
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Changepassword(user: user),
                        ),
                      );
                    },
                  ),

                  // Help Center
                  _buildSettingsItem(
                    context,
                    icon: Icons.help_outline,
                    title: "Help Center",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpCenterPage(user: user),
                        ),
                      );
                    },
                  ),

                  // Logout
                  _buildSettingsItem(
                    context,
                    icon: Icons.logout,
                    title: "Logout",
                    isLogout: true,
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isLogout
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
            fontWeight: isLogout ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);
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
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }
}
