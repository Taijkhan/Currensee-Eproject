import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/user/drawer.dart';
import 'package:currensee/user/homepage.dart';
import 'package:currensee/user/user_edit_profile.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final Map<String, dynamic> user;
  final String email; // we’ll load user by email

  const UserProfile({super.key, required this.email, required this.user});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userData;
  Uint8List? filebyte;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("registration") // change to your collection name
          .where("Email", isEqualTo: widget.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        setState(() {
          userData = data;

          if (data["Filebyte"] != null) {
            try {
              filebyte =
                  Uint8List.fromList(List<int>.from(data["Filebyte"]));
            } catch (e) {
              print("Image conversion error: $e");
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

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
      body:
       isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("User not found"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserHome(user: widget.user),
                        ),
                      );
                    },
                    child: Text(
                      "Homepage",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

              const SizedBox(height: 20),
              
              // Title
              Center(
                child: Text(
                  "My Profile",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Avatar
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
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  backgroundImage: filebyte != null
                                      ? MemoryImage(filebyte!)
                                      : const AssetImage(
                                              "assets/images/default_avatar.png")
                                          as ImageProvider,
                                  child: filebyte == null
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                ),
                              ),
                      
                              const SizedBox(height: 20),
                      
                              // Full Name
                              Text(
                                userData!["FullName"] ?? "Unknown",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                      
                              _buildDetailItem(
                                theme: theme,
                                icon: Icons.email,
                                label: "Email",
                                value: userData!["Email"] ?? "Unknown",
                              ),
                              const SizedBox(height: 12),
                      
                              _buildDetailItem(
                                theme: theme,
                                icon: Icons.phone,
                                label: "Contact",
                                value: userData!["Contact"] ?? "Unknown",
                              ),
                              const SizedBox(height: 24),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserEdit(user: widget.user),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
