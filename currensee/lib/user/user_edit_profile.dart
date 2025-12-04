import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/user/drawer.dart';
import 'package:currensee/user/user_preference.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

class UserEdit extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserEdit({super.key, required this.user});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
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

  /// Improved selectImage which handles:
  /// - web (bytes available via FilePicker)
  /// - mobile (sometimes bytes null, but path provided => read via File)
  Future<void> selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true, // try to get bytes directly (works on web)
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      );

      if (result == null) {
        // user canceled the picker
        return;
      }

      final picked = result.files.single;
      Uint8List? bytes = picked.bytes;

      // On some mobile platforms FilePicker returns a path but bytes==null.
      // If path exists and we are not on web, read file from path.
      if (bytes == null && picked.path != null && !kIsWeb) {
        try {
          bytes = await File(picked.path!).readAsBytes();
        } catch (e) {
          // Could not read file from path
          print("Failed to read file from path: $e");
        }
      }

      if (bytes != null) {
        setState(() {
          filebyte = bytes;
          filename = picked.name;
          _hasUnsavedChanges = true;
        });
      } else {
        _showErrorDialog(
          "Could not read the selected image. Try another image.",
        );
      }
    } catch (e) {
      print("selectImage error: $e");
      _showErrorDialog("Failed to pick image: $e");
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
          builder: (context) => UserPreference(user: widget.user),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
            onPressed: () async {
              if (await _confirmDiscard()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _navigateToSettings,
                icon: _hasUnsavedChanges
                    ? Icon(
                        Icons.circle,
                        color: theme.colorScheme.onPrimary,
                        size: 10,
                      )
                    : const SizedBox.shrink(),
                label: Text(
                  "Account Settings",
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: UserDrawer(user: widget.user),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.3,
                      ),
                      backgroundImage: filebyte != null
                          ? MemoryImage(filebyte!)
                          : (widget.user["Filename"] != null &&
                                        widget.user["Filename"]
                                            .toString()
                                            .isNotEmpty
                                    ? NetworkImage(widget.user["Filename"])
                                    : null)
                                as ImageProvider?,
                      child:
                          filebyte == null &&
                              (widget.user["Filename"] == null ||
                                  widget.user["Filename"].toString().isEmpty)
                          ? Icon(
                              Icons.account_circle,
                              size: 150,
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: selectImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  prefixIcon: Icon(
                    Icons.phone,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: theme.colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: isUploading ? null : _confirmSave,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                          fontSize: 16,
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
