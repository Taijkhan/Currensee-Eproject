import 'dart:typed_data';

import 'package:currensee/admin/change_password.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/edit_profile.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:currensee/auth/login.dart';
import 'package:flutter/material.dart';

class AdminSettings extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminSettings({Key? key, required this.user}) : super(key: key);

  @override
  _AdminSettingsState createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CurrenSee",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: AdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminHome(user: user),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.dashboard,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    "Admin Dashboard",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Profile Section
              Center(
                child: Column(
                  children: [
                    _buildProfileAvatar(user, theme),
                    const SizedBox(height: 16),
                    Text(
                      user["FullName"] ?? "Admin User",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user["email"] ?? "admin@currensee.com",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Settings Options
              _buildSettingsCard(
                icon: Icons.edit_note_rounded,
                title: "Edit Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminEdit(user: user),
                    ),
                  );
                },
                theme: theme,
              ),
              const SizedBox(height: 15),
              _buildSettingsCard(
                icon: Icons.lock_open_rounded,
                title: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Changepassword(user: user),
                    ),
                  );
                },
                theme: theme,
              ),
              const SizedBox(height: 15),
              _buildSettingsCard(
                icon: Icons.logout_rounded,
                title: "Logout",
                onTap: () {
                  _showLogoutConfirmation(theme);
                },
                theme: theme,
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Map<String, dynamic> user, ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 58,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: user["Filebyte"] != null
            ? MemoryImage(Uint8List.fromList(List<int>.from(user["Filebyte"])))
            : null,
        child: user["Filebyte"] == null
            ? Icon(
                Icons.person,
                size: 60,
                color: theme.colorScheme.onPrimaryContainer,
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isLogout = false,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isLogout
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: isLogout
                    ? theme.colorScheme.error.withOpacity(0.7)
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            Text("Logout", style: theme.textTheme.titleLarge),
          ],
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: theme.textTheme.bodyLarge,
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Logout",
              style: TextStyle(
                color: theme.colorScheme.onError,
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
