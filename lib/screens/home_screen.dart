import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'book_ticket_screen.dart';
import 'incoming_transfers_screen.dart';
import 'live_trains_screen.dart';
import 'login_screen.dart';
import 'my_tickets_screen.dart';
import 'outgoing_transfers_screen.dart';
import 'personal_information_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;
  bool _isLoadingName = true;
  String _userName = 'Passenger';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ==========================================================
  // LOAD USER NAME
  // ==========================================================

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingName = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final name =
      (doc.data()?['name'] as String?)?.trim();

      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) {
            _userName = name;
          } else if (user.displayName != null &&
              user.displayName!.trim().isNotEmpty) {
            _userName = user.displayName!.trim();
          }

          _isLoadingName = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Unable to load user name: $e',
      );

      if (mounted) {
        setState(() {
          _isLoadingName = false;
        });
      }
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    // Start Firebase logout immediately.
    // Do not make the user wait for the Firebase Future.
    FirebaseAuth.instance.signOut().catchError((error) {
      debugPrint(
        'Logout error: $error',
      );
    });

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },
              child: const Text(
                'LOGOUT',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ==========================================================
  // BOOK TICKET
  // ==========================================================

  void _openBookTicketScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookTicketScreen(),
      ),
    );
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  // ==========================================================
  // MAIN BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // LiveTrainsScreen has its own AppBar.
      appBar: _selectedIndex == 2
          ? null
          : AppBar(
        title: const Text(
          'Local Rail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openNotifications,
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
        ],
      ),

      body: _buildBody(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
        _onNavigationTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.confirmation_number_outlined,
            ),
            selectedIcon: Icon(
              Icons.confirmation_number,
            ),
            label: 'Tickets',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.location_on_outlined,
            ),
            selectedIcon: Icon(
              Icons.location_on,
            ),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildTicketsPage();

      case 2:
        return const LiveTrainsScreen();

      case 3:
        return _buildProfilePage();

      default:
        return _buildHomePage();
    }
  }

  // ==========================================================
  // HOME PAGE
  // ==========================================================

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            _isLoadingName
                ? 'Hello! 👋'
                : 'Hello, $_userName! 👋',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Travel smarter with Mumbai local trains.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // BOOK TRAIN TICKET
          // ==================================================

          _buildActionCard(
            icon: Icons.confirmation_number_outlined,
            title: 'Book Train Ticket',
            subtitle:
            'Book a new Mumbai local train ticket',
            onTap: _openBookTicketScreen,
          ),

          const SizedBox(height: 14),

          // ==================================================
          // SEND TICKET
          // ==================================================

          _buildActionCard(
            icon: Icons.send_outlined,
            title: 'Send Ticket',
            subtitle:
            'Transfer an individual ticket',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const MyTicketsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // ==================================================
          // RECEIVE TICKET
          // ==================================================

          _buildActionCard(
            icon: Icons.download_outlined,
            title: 'Receive Ticket',
            subtitle:
            'Accept or reject incoming transfers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const IncomingTransfersScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // ==================================================
          // TRANSFER HISTORY
          // ==================================================

          _buildActionCard(
            icon: Icons.swap_horiz_outlined,
            title: 'Transfer History',
            subtitle:
            'View sent tickets and revert transfers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const OutgoingTransfersScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ==================================================
          // QR INFORMATION
          // ==================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.indigo,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Keep your ticket QR code ready during your journey for verification.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
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

  // ==========================================================
  // TICKETS PAGE
  // ==========================================================

  Widget _buildTicketsPage() {
    return const MyTicketsScreen();
  }

  // ==========================================================
  // PROFILE PAGE
  // ==========================================================

  Widget _buildProfilePage() {
    final user =
        FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // ==================================================
          // PROFILE ICON
          // ==================================================

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // USER NAME
          // ==================================================

          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // ==================================================
          // EMAIL
          // ==================================================

          Text(
            user?.email ?? 'No email available',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          // ==================================================
          // PROFILE OPTIONS
          // ==================================================

          Card(
            child: Column(
              children: [
                // ------------------------------------------------
                // PERSONAL INFORMATION
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                  ),
                  title: const Text(
                    'Personal Information',
                  ),
                  subtitle: const Text(
                    'Manage your personal details',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () async {
                    final changed =
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const PersonalInformationScreen(),
                      ),
                    );

                    if (changed == true) {
                      _loadUserName();
                    }
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ------------------------------------------------
                // SETTINGS
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                  ),
                  title: const Text(
                    'Settings',
                  ),
                  subtitle: const Text(
                    'Notifications and Dark Mode',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const SettingsScreen(),
                      ),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ------------------------------------------------
                // HELP & SUPPORT
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                  ),
                  title: const Text(
                    'Help & Support',
                  ),
                  subtitle: const Text(
                    'FAQs, support and app assistance',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const HelpSupportScreen(),
                      ),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ------------------------------------------------
                // LOGOUT
                // ------------------------------------------------

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: _isLoggingOut
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.chevron_right,
                    color: Colors.red,
                  ),
                  onTap: _isLoggingOut
                      ? null
                      : _showLogoutConfirmation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACTION CARD
  // ==========================================================

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.indigo,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}