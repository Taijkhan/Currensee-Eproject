import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/setting.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminEdit extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminEdit({super.key, required this.user});

  @override
  State<AdminEdit> createState() => _AdminEditState();
}

class _AdminEditState extends State<AdminEdit> {
  Uint8List? filebyte;
  String? filename;
  bool isUploading = false;
  bool _hasUnsavedChanges = false;

  late TextEditingController nameController;
  late TextEditingController contactController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user["FullName"]);
    contactController = TextEditingController(text: widget.user["Contact"]);
    passwordController = TextEditingController(text: widget.user["Password"]);

    // Add listeners to detect changes
    nameController.addListener(_checkForChanges);
    contactController.addListener(_checkForChanges);
    passwordController.addListener(_checkForChanges);

    if (widget.user["Filebyte"] != null) {
      try {
        filebyte = Uint8List.fromList(List<int>.from(widget.user["Filebyte"]));
      } catch (e) {
        print("Image conversion error: $e");
      }
    }
  }

  void _checkForChanges() {
    final hasChanges =
        nameController.text != widget.user["FullName"] ||
        contactController.text != widget.user["Contact"] ||
        passwordController.text != widget.user["Password"] ||
        filebyte != null;

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        filebyte = result.files.single.bytes;
        filename = result.files.single.name;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> uploadImageAndSave() async {
    setState(() {
      isUploading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("registration")
          .doc(widget.user["Email"])
          .update({
        "FullName": nameController.text,
        "Contact": contactController.text,
        "Password": passwordController.text,
        "Filename": filename,
        "Filebyte": filebyte?.toList(),
      });

      setState(() {
        _hasUnsavedChanges = false;
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog("Something went wrong: $e");
    }

    setState(() {
      isUploading = false;
    });
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Success",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          "Profile updated successfully!",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Error",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSave() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure?", style: theme.textTheme.titleLarge),
        content: Text(
          "Do you really want to save these changes?",
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
              uploadImageAndSave();
            },
            child: Text(
              "Yes, Save",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;

    final theme = Theme.of(context);

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Discard Changes?", style: theme.textTheme.titleLarge),
            content: Text(
              "You have unsaved changes. Are you sure you want to leave without saving?",
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Yes, Discard",
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _navigateToSettings() async {
    final shouldNavigate = await _confirmDiscard();
    if (shouldNavigate) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminSettings(user: widget.user),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_checkForChanges);
    contactController.removeListener(_checkForChanges);
    passwordController.removeListener(_checkForChanges);
    nameController.dispose();
    contactController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold(
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
        drawer: AdminDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings Button with unsaved changes indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_hasUnsavedChanges)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.circle,
                        color: theme.colorScheme.error,
                        size: 12,
                      ),
                    ),
                  TextButton(
                    onPressed: _navigateToSettings,
                    child: Text(
                      "Settings",
                       style: GoogleFonts.lato(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Update Your Profile Heading
              Center(
                child: Text(
                  "Update Your Profile",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile Image
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: filebyte != null
                        ? Image.memory(filebyte!, fit: BoxFit.cover)
                        : (widget.user["Filebyte"] != null
                            ? Image.memory(
                                Uint8List.fromList(
                                    List<int>.from(widget.user["Filebyte"])),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 150,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Change Image Button
              Center(
                child: ElevatedButton(
                  onPressed: selectImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Change Image"),
                ),
              ),

              const SizedBox(height: 24),

              // Full Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
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
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Field
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
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
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
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
                      width: 2,
                    ),
                  ),
                ),
                obscureText: false,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUploading ? null : _confirmSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                          "Save Changes",
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
    );
  }
}
