import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/auth/login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? filename;
  Uint8List? filebyte;
  bool isPasswordVisible = false;
  bool isUploading = false;
  
  final TextEditingController fullnameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController contactC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  Future<void> AddImage() async {
  print("Opening file picker...");
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    withData: true,
  );

  if (result == null) {
    _showDialog(title: "Error", content: "No file selected");
    return;
  }

  print("Selected file: ${result.files.first.name}");
  setState(() {
    filename = result.files.first.name;
    filebyte = result.files.first.bytes;
  });
}


  void _showDialog({
    required String title,
    required String content,
    VoidCallback? onOkPressed,
  }) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: title == "Error" ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
          content: Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
          actions: <Widget> [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onOkPressed != null) {
                  onOkPressed();
                }
              }, 
              child: Text(
                "OK",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ]
        );
      },
    );
  }

  bool _validateFields() {
    if (fullnameC.text.isEmpty) {
      _showDialog(title: "Error", content: "Fullname cannot be empty.");
      return false;
    }
    if (emailC.text.isEmpty) {
      _showDialog(title: "Error", content: "Email cannot be empty.");
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(emailC.text)) {
      _showDialog(title: "Error", content: "Invalid email format.");
      return false;
    }
    if (passwordC.text.isEmpty) {
      _showDialog(title: "Error", content: "Password cannot be empty.");
      return false;
    }
    if (contactC.text.isEmpty ||
        !RegExp(r"^\d{1,11}$").hasMatch(contactC.text)) {
      _showDialog(title: "Error", content: "Contact Number must be a valid number with up to 11 digits.");
      return false;
    }
    if (filename == null || filebyte == null) {
      _showDialog(title: "Error", content: "Please select an image.");
      return false;
    }
    return true;
  }

  Future<void> AddUser(String fullname, String email, String contact, String password) async {
    CollectionReference userCollection = FirebaseFirestore.instance.collection("registration");

    try {
      final existingUser = await userCollection.doc(email).get();
      if (existingUser.exists) {
        _showDialog(
          title: "Registration Failed",
          content: "This email is already taken. Please use a different email.",
        );
        return;
      }

      await userCollection.doc(email).set({
        "FullName": fullname,
        "Email": email,
        "Password": password,
        "Contact": contact,
        "Userrole": 'User',
        "Filename": filename,
        "Filebyte": filebyte?.toList(),
      });
      _showDialog(
        title: "Registration Successful",
        content: "You have successfully registered.",
        onOkPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
      );
    } catch (error) {
      _showDialog(
        title: "Registration Failed",
        content: "There was an error registering your account. Please try again.",
      );
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background using theme colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Registration Form
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage('asset/register_screen.jpg'),
                        fit: BoxFit.cover,
                        ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create your new account",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", fullnameC, theme: theme),
                  const SizedBox(height: 16),
                  _buildTextField("Email", emailC, theme: theme),
                  const SizedBox(height: 16),
                  _buildTextField("Contact", contactC, theme: theme),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Password",
                    passwordC,
                    obscureText: !isPasswordVisible,
                    isPasswordField: true,
                    theme: theme,
                  ),
                  const SizedBox(height: 20),
                  filebyte != null
                      ? Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(filebyte!, fit: BoxFit.cover),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: AddImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              filename ?? "Select Profile Image",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                              if (_validateFields()) {
                                setState(() => isUploading = true);
                                await AddUser(
                                  fullnameC.text,
                                  emailC.text,
                                  contactC.text,
                                  passwordC.text,
                                );
                                setState(() => isUploading = false);
                              }
                            },
                      child: isUploading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              "Register",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool isPasswordField = false,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}