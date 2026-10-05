import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showSupportMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_outlined,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find answers to common questions or contact support.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ==========================================================
          // FREQUENTLY ASKED QUESTIONS
          // ==========================================================

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ExpansionTile(
                  leading: const Icon(
                    Icons.confirmation_number_outlined,
                  ),
                  title: const Text(
                    'How do I book a train ticket?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'Open the Home screen and select Book Train Ticket. '
                            'Choose your source station, destination station, '
                            'ticket details and continue to payment.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.payment_outlined,
                  ),
                  title: const Text(
                    'How does payment work?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'After confirming your booking details, you will '
                            'be redirected to the available payment flow. '
                            'After successful payment, your ticket will be '
                            'created and displayed in My Tickets.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.qr_code_2_outlined,
                  ),
                  title: const Text(
                    'Where can I find my ticket QR code?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'Open Tickets from the bottom navigation bar '
                            'and select your ticket. The QR code can be '
                            'used for ticket verification during your journey.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.send_outlined,
                  ),
                  title: const Text(
                    'How do I send a ticket?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'Open your tickets and select the ticket you '
                            'want to transfer. Use the ticket transfer '
                            'option and follow the instructions shown on screen.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.download_outlined,
                  ),
                  title: const Text(
                    'How do I receive a transferred ticket?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'Open Receive Ticket from the Home screen. '
                            'Incoming ticket transfers can be accepted or '
                            'rejected from there.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                  ),
                  title: const Text(
                    'How does Live Trains work?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'The Live section provides live train information '
                            'for supported Mumbai local trains. Select the '
                            'required source and destination to view available '
                            'live train information.',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                ExpansionTile(
                  leading: const Icon(
                    Icons.dark_mode_outlined,
                  ),
                  title: const Text(
                    'How do I enable Dark Mode?',
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Text(
                        'Go to Profile → Settings and turn on the '
                            'Dark Mode switch.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // CONTACT SUPPORT
          // ==========================================================

          const Text(
            'Contact Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                  ),
                  title: const Text(
                    'Email Support',
                  ),
                  subtitle: const Text(
                    'Get help through email',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    _showSupportMessage(
                      context,
                      'Email support will be available soon.',
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.chat_outlined,
                  ),
                  title: const Text(
                    'Chat Support',
                  ),
                  subtitle: const Text(
                    'Chat with Local Rail support',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    _showSupportMessage(
                      context,
                      'Chat support will be available soon.',
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.report_problem_outlined,
                  ),
                  title: const Text(
                    'Report a Problem',
                  ),
                  subtitle: const Text(
                    'Tell us about an issue',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    _showSupportMessage(
                      context,
                      'Problem reporting will be available soon.',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // APP INFORMATION
          // ==========================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(
                    Icons.train_outlined,
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Local Rail',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mumbai suburban railway app',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}