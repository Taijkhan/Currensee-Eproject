import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/admin/drawer.dart';
import 'package:currensee/admin/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHelpCenterPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHelpCenterPage({Key? key, required this.user}) : super(key: key);

  @override
  _AdminHelpCenterPageState createState() => _AdminHelpCenterPageState();
}

class _AdminHelpCenterPageState extends State<AdminHelpCenterPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, read, unread

  void _showMessageDetails(Map<String, dynamic> message) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Message Details",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // User Information
              _buildDetailRow("User Name", message['Name'] ?? 'Not provided'),
              _buildDetailRow("Email", message['Email'] ?? 'Not provided'),
              _buildDetailRow("Contact", message['Contact'] ?? 'Not provided'),
              
              const SizedBox(height: 16),
              Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
              const SizedBox(height: 16),
              
              // Message
              Text(
                "Message:",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  message['Message'] ?? 'No message',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Timestamp
              _buildDetailRow(
                "Received",
                message['Timestamp'] != null 
                    ? _formatTimestamp(message['Timestamp'])
                    : 'Unknown',
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _markAsRead(message['id']);
                        Navigator.pop(context);
                      },
                      child: Text(
                        message['read'] == true ? "Mark Unread" : "Mark Read",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _markAsRead(String messageId) async {
    try {
      final messageDoc = _firestore.collection('contact').doc(messageId);
      final message = await messageDoc.get();
      final currentReadStatus = message.data()?['read'] ?? false;
      
      await messageDoc.update({'read': !currentReadStatus});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentReadStatus 
                ? 'Message marked as unread' 
                : 'Message marked as read',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating message status'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Message",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this message? This action cannot be undone.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('contact').doc(messageId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message deleted successfully'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting message'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            child: Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
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
        elevation: 4,
      ),
      drawer: AdminDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
  // Header with Dashboard button and centered title
  Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16.0),
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
                    fontWeight: FontWeight.w600,
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
              "User's Contact List",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search messages...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterStatus,
                        onChanged: (value) => setState(() => _filterStatus = value!),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text("All")),
                          DropdownMenuItem(value: 'unread', child: Text("Unread")),
                          DropdownMenuItem(value: 'read', child: Text("Read")),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('contact')
                    .orderBy('Timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No messages yet",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter messages
                  var messages = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final messageText = (data['Message'] ?? '').toString().toLowerCase();
                    final matchesSearch = messageText.contains(_searchQuery.toLowerCase());
                    
                    if (_filterStatus == 'all') return matchesSearch;
                    if (_filterStatus == 'read') return matchesSearch && (data['read'] == true);
                    if (_filterStatus == 'unread') return matchesSearch && (data['read'] != true);
                    
                    return matchesSearch;
                  }).toList();

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        "No messages match your search",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final doc = messages[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isRead = data['read'] == true;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isRead 
                                ? theme.colorScheme.outline.withOpacity(0.3)
                                : theme.colorScheme.primary.withOpacity(0.5),
                            width: isRead ? 1 : 2,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isRead
                                ? theme.colorScheme.outline.withOpacity(0.3)
                                : theme.colorScheme.primary,
                            child: Icon(
                              Icons.person,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['Name'] ?? 'Unknown User',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "NEW",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['Email'] ?? 'No email',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (data['Message'] ?? 'No message').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(data['Timestamp']),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    const SizedBox(width: 8),
                                    Text("View Details"),
                                  ],
                                ),
                                onTap: () => _showMessageDetails({
                                  ...data,
                                  'id': doc.id,
                                }),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.mark_email_read),
                                    const SizedBox(width: 8),
                                    Text(isRead ? "Mark Unread" : "Mark Read"),
                                  ],
                                ),
                                onTap: () => _markAsRead(doc.id),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: theme.colorScheme.error),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Delete",
                                      style: TextStyle(color: theme.colorScheme.error),
                                    ),
                                  ],
                                ),
                                onTap: () => _deleteMessage(doc.id),
                              ),
                            ],
                          ),
                          onTap: () => _showMessageDetails({
                            ...data,
                            'id': doc.id,
                          }),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}