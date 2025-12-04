import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminConversionsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminConversionsScreen({Key? key, required this.user})
      : super(key: key);

  @override
  State<AdminConversionsScreen> createState() =>
      _AdminConversionsScreenState();
}

class _AdminConversionsScreenState extends State<AdminConversionsScreen> {
  String searchQuery = "";

  Future<void> _deleteConversion(String docId) async {
    await FirebaseFirestore.instance.collection('history').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Record deleted successfully")),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Recently converted";
    try {
      DateTime dt = (timestamp as Timestamp).toDate();
      return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
    } catch (_) {
      return timestamp.toString();
    }
  }

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
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: TextButton.icon(
                icon: Icon(Icons.home, color: theme.colorScheme.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminHome(user: widget.user),
                    ),
                  );
                },
                label: Text(
                  "Homepage",
                  style: GoogleFonts.lato(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🔥 Title
          Center(
            child: Text(
              "User's Conversion History",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔎 Modern Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Username...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 Conversion List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('history')
                  .orderBy('Timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: theme.colorScheme.primary),
                  );
                }

                final docs = snapshot.data!.docs;

                // 🔎 Filter docs based on search
                final filteredDocs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String userName =
                      (data['Username'] ?? "").toString().toLowerCase();
                  return userName.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          "No conversions found",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String userName = data['Username'] ?? "Unknown User";
                    String userEmail = data['Email'] ?? "No Email";
                    String fromCurrency = data['From'] ?? "";
                    String toCurrency = data['To'] ?? "";
                    String amount = data['Amount']?.toString() ?? "";
                    String result = (data['Converted'] ?? "").toString();
                    String timestamp = _formatTimestamp(data['Timestamp']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.9),
                            theme.colorScheme.secondary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(3, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(18),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              color: theme.colorScheme.primary, size: 30),
                        ),
                        title: Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userEmail,
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$amount $fromCurrency → $result $toCurrency",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "📅 $timestamp",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                title: Text("Confirm Delete",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold)),
                                content: Text(
                                  "Do you really want to delete this conversion?",
                                  style: GoogleFonts.lato(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(),
                                    child: Text("Cancel",
                                        style: GoogleFonts.poppins(
                                            color: theme.colorScheme.primary)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await _deleteConversion(doc.id);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("Delete",
                                        style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
