import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:currensee/admin/setting.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Changepassword extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? documentId;

  const Changepassword({Key? key, required this.user, this.documentId})
    : super(key: key);

  @override
  _ChangepasswordState createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController previousPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPreviousPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    previousPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Settings Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminSettings(user: widget.user),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: Text(
                      "Settings",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header and Image
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('asset/update_password.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(
                                0.15,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Change Password",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Update your password to secure your account.",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Previous Password Field
                _buildPasswordField(
                  controller: previousPasswordController,
                  labelText: "Previous Password",
                  theme: theme,
                  isVisible: _isPreviousPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPreviousPasswordVisible = !_isPreviousPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // New Password Field
                _buildPasswordField(
                  controller: newPasswordController,
                  labelText: "New Password",
                  theme: theme,
                  isVisible: _isNewPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField(
                  controller: confirmPasswordController,
                  labelText: "Confirm New Password",
                  theme: theme,
                  isVisible: _isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  isConfirmation: true,
                ),
                const SizedBox(height: 40),

                // Change Password Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      changePassword(
                        previousPasswordController.text,
                        newPasswordController.text,
                        confirmPasswordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Change Password",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required ThemeData theme,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    bool isConfirmation = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: theme.colorScheme.primary.withOpacity(0.8),
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Hide the default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        if (isConfirmation && value != newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  void changePassword(
    String previousPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("registration")
          .where(
            "Email",
            isEqualTo: widget.user["Email"]?.toString().toLowerCase() ?? "",
          )
          .get();

      if (snapshot.docs.isEmpty) {
        _showErrorDialog("User not found.");
        return;
      }

      var userData = snapshot.docs.first;
      String storedPassword = userData.data()["Password"] ?? "";

      if (storedPassword != previousPassword) {
        _showErrorDialog("Incorrect previous password.");
        return;
      }

      await FirebaseFirestore.instance
          .collection("registration")
          .doc(userData.id)
          .update({"Password": newPassword});

      // Dismiss the loading indicator
      Navigator.pop(context);
      _showSuccessDialog("Password changed successfully.");
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.pop(context);
      print("Error changing password: $e");
      _showErrorDialog("An error occurred. Please try again later.");
    }
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text("Error", style: theme.textTheme.titleLarge),
            ],
          ),
          content: Text(message, style: theme.textTheme.bodyLarge),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 10),
              Text("Success", style: theme.textTheme.titleLarge),
            ],
          ),
          content: Text(message, style: theme.textTheme.bodyLarge),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminHome(user: widget.user),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
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
