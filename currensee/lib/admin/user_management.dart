import 'dart:typed_data';
import 'package:currensee/admin/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/constants/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class UserManagement extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserManagement({Key? key, required this.user}) : super(key: key);

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
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
          // Shortcut to Admin Dashboard
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('registration')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                var userList = snapshot.data?.docs ?? [];
                if (userList.isEmpty) {
                  return Center(
                    child: Text(
                      "No Users Found",
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                // Separate users by role
                var admins = userList.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['Userrole'] == 'Admin';
                }).toList();

                var users = userList.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['Userrole'] == 'User';
                }).toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Admin Section
                        Text(
                          "Admins",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...admins.map((admin) {
                          var data = admin.data() as Map<String, dynamic>;
                          Uint8List? imageBytes;
                          if (data['Filebyte'] != null) {
                            try {
                              imageBytes = Uint8List.fromList(
                                List<int>.from(data['Filebyte']),
                              );
                            } catch (e) {
                              print("Error converting image: $e");
                            }
                          }
                          return _UserListTile(
                            data: data,
                            docId: admin.id,
                            theme: theme,
                            fileBytes: imageBytes,
                          );
                        }).toList(),
                        const SizedBox(height: 20),

                        // User Section
                        Text(
                          " Users",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...users.map((user) {
                          var data = user.data() as Map<String, dynamic>;
                          Uint8List? imageBytes;
                          if (data['Filebyte'] != null) {
                            try {
                              imageBytes = Uint8List.fromList(
                                List<int>.from(data['Filebyte']),
                              );
                            } catch (e) {
                              print("Error converting image: $e");
                            }
                          }
                          return _UserListTile(
                            data: data,
                            docId: user.id,
                            theme: theme,
                            fileBytes: imageBytes,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widget for User ListTile
class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final ThemeData theme;
  final Uint8List? fileBytes;

  const _UserListTile({
    Key? key,
    required this.data,
    required this.docId,
    required this.theme,
    this.fileBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          backgroundImage: fileBytes != null
              ? MemoryImage(fileBytes!)
              : const AssetImage("assets/images/default_avatar.png")
                    as ImageProvider,
          child: fileBytes == null
              ? Icon(Icons.person, size: 28, color: theme.colorScheme.primary)
              : null,
        ),
        title: Text(
          data['FullName'] ?? 'Unknown',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          data['Email'] ?? 'Unknown',
          style: GoogleFonts.lato(
            fontSize: 14,
            color: theme.colorScheme.secondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          _showUserDetailsDialog(context);
        },
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: fileBytes != null
                  ? MemoryImage(fileBytes!)
                  : const AssetImage("assets/images/default_avatar.png")
                        as ImageProvider,
              child: fileBytes == null
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.badge,
                data['FullName'] ?? 'Unknown',
                theme,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.email, data['Email'] ?? 'Unknown', theme),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.phone, data['Contact'] ?? 'Unknown', theme),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.security,
                data['Userrole'] ?? 'User',
                theme,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.delete),
                label: Text(
                  "Delete User",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  _showDeleteConfirmation(
                    context,
                    docId,
                    data['FullName'] ?? 'User',
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String docId,
    String userName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete $userName?",
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
              onPressed: () async {
                Navigator.pop(context); // Close the confirmation dialog
                Navigator.pop(context); // Close the user details dialog
                try {
                  await FirebaseFirestore.instance
                      .collection('registration')
                      .doc(docId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting user: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
