import 'package:flutter/material.dart';

import '../models/ticket_model.dart';
import '../services/ticket_transfer_service.dart';

class TicketTransferScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketTransferScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketTransferScreen> createState() =>
      _TicketTransferScreenState();
}

class _TicketTransferScreenState
    extends State<TicketTransferScreen> {
  final TextEditingController _recipientController =
  TextEditingController();

  final FocusNode _recipientFocusNode =
  FocusNode();

  final TicketTransferService _transferService =
  TicketTransferService();

  // Keep 'sms' internally because the transfer service
  // already uses this value for mobile-number transfers.
  String _deliveryMethod = 'sms';

  bool _isLoading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _recipientFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATE EMAIL
  // ============================================================

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return emailRegex.hasMatch(
      email.trim(),
    );
  }

  // ============================================================
  // VALIDATE PHONE
  // ============================================================

  bool _isValidPhone(String phone) {
    String value = phone.trim();

    value = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    if (value.startsWith('+91') &&
        value.length == 13) {
      value = value.substring(3);
    }

    if (value.startsWith('91') &&
        value.length == 12) {
      value = value.substring(2);
    }

    return RegExp(
      r'^[0-9]{10}$',
    ).hasMatch(value);
  }

  // ============================================================
  // CHANGE MOBILE NUMBER / EMAIL
  // ============================================================

  void _changeDeliveryMethod(String method) {
    if (_deliveryMethod == method) {
      return;
    }

    // Close the currently active keyboard.
    _recipientFocusNode.unfocus();

    setState(() {
      _deliveryMethod = method;
      _recipientController.clear();
    });

    // Wait for the old keyboard/input connection to close.
    // Then focus the newly-created field.
    Future.delayed(
      const Duration(milliseconds: 400),
          () {
        if (!mounted) {
          return;
        }

        _recipientFocusNode.requestFocus();
      },
    );
  }

  // ============================================================
  // CREATE TRANSFER
  // ============================================================

  Future<void> _createTransfer() async {
    FocusScope.of(context).unfocus();

    final String recipient =
    _recipientController.text.trim();

    if (recipient.isEmpty) {
      _showMessage(
        _deliveryMethod == 'email'
            ? 'Please enter the recipient email ID.'
            : 'Please enter the recipient mobile number.',
      );
      return;
    }

    // ----------------------------------------------------------
    // EMAIL VALIDATION
    // ----------------------------------------------------------

    if (_deliveryMethod == 'email') {
      if (!_isValidEmail(recipient)) {
        _showMessage(
          'Please enter a valid email ID.',
        );
        return;
      }
    }

    // ----------------------------------------------------------
    // MOBILE NUMBER VALIDATION
    // ----------------------------------------------------------

    if (_deliveryMethod == 'sms') {
      if (!_isValidPhone(recipient)) {
        _showMessage(
          'Please enter a valid 10-digit mobile number.',
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;

      // --------------------------------------------------------
      // EMAIL TRANSFER
      // --------------------------------------------------------

      if (_deliveryMethod == 'email') {
        result = await _transferService.createTransfer(
          ticket: widget.ticket,
          recipientEmail: recipient,
        );
      }

      // --------------------------------------------------------
      // MOBILE NUMBER TRANSFER
      // --------------------------------------------------------

      else {
        result = await _transferService.createTransfer(
          ticket: widget.ticket,
          recipientPhone: recipient,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      await _showTransferCreatedDialog(
        result,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ============================================================
  // TRANSFER CREATED DIALOG
  // ============================================================

  Future<void> _showTransferCreatedDialog(
      Map<String, dynamic> result,
      ) async {
    final String transferId =
        result['transferId']?.toString() ?? '';

    final String recipientName =
        result['recipientName']?.toString() ??
            'Passenger';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Transfer Created',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer request created for '
                    '$recipientName.',
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                  Colors.orange.shade50,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Text(
                  'The ticket has NOT been transferred yet. '
                      'The recipient must accept the transfer '
                      'before ownership changes.',
                  style: TextStyle(
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Transfer ID',
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              SelectableText(
                transferId,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Done',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TICKET CARD
  // ============================================================

  Widget _buildTicketCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
        side: BorderSide(
          color:
          Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.indigo,
                ),
                SizedBox(width: 10),
                Text(
                  'Selected Ticket',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _ticketInfo(
                    'From',
                    widget.ticket.source,
                  ),
                ),

                const Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey,
                  ),
                ),

                Expanded(
                  child: _ticketInfo(
                    'To',
                    widget.ticket.destination,
                  ),
                ),
              ],
            ),

            if (widget.ticket.via != null &&
                widget.ticket.via!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 16),

              _ticketInfo(
                'Via',
                widget.ticket.via!,
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _ticketInfo(
                    'Journey',
                    widget.ticket.journeyType,
                  ),
                ),

                Expanded(
                  child: _ticketInfo(
                    'Fare',
                    '₹${widget.ticket.fare.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketInfo(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color:
            Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE NUMBER / EMAIL SELECTOR
  // ============================================================

  Widget _buildDeliveryMethod() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer Method',
          style: TextStyle(
            fontSize: 17,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _deliveryOption(
                value: 'sms',
                icon:
                Icons.phone_outlined,
                title: 'Mobile Number',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _deliveryOption(
                value: 'email',
                icon:
                Icons.email_outlined,
                title: 'Email',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _deliveryOption({
    required String value,
    required IconData icon,
    required String title,
  }) {
    final bool selected =
        _deliveryMethod == value;

    return InkWell(
      borderRadius:
      BorderRadius.circular(14),
      onTap: () {
        _changeDeliveryMethod(
          value,
        );
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.indigo.shade50
              : Colors.white,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Colors.indigo
                : Colors.grey.shade300,
            width:
            selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.indigo
                  : Colors.grey.shade700,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.indigo,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECIPIENT FIELD
  // ============================================================

  Widget _buildRecipientField() {
    final bool isEmail =
        _deliveryMethod == 'email';

    return TextFormField(
      // Forces Flutter to create a completely
      // new field when Mobile Number / Email changes.
      key: ValueKey(
        _deliveryMethod,
      ),

      controller:
      _recipientController,

      focusNode:
      _recipientFocusNode,

      // EMAIL -> EMAIL KEYBOARD
      // MOBILE NUMBER -> PHONE KEYPAD
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : TextInputType.phone,

      textInputAction:
      TextInputAction.done,

      autocorrect: false,

      enableSuggestions:
      !isEmail,

      autofillHints: isEmail
          ? const [
        AutofillHints.email,
      ]
          : const [
        AutofillHints.telephoneNumber,
      ],

      decoration:
      InputDecoration(
        labelText: isEmail
            ? 'Recipient Email ID'
            : 'Recipient Mobile Number',

        hintText: isEmail
            ? 'example@gmail.com'
            : '9876543210',

        prefixIcon: Icon(
          isEmail
              ? Icons.email_outlined
              : Icons.phone_outlined,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide:
          const BorderSide(
            color: Colors.indigo,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isEmail =
        _deliveryMethod == 'email';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer Ticket',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets.all(18),

                decoration:
                BoxDecoration(
                  color:
                  Colors.indigo.shade50,

                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.send_outlined,
                      size: 36,
                      color: Colors.indigo,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Transfer Your Ticket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Colors.indigo,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Transfer this individual ticket '
                                'to another registered user.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // SELECTED TICKET
              // ==================================================

              _buildTicketCard(),

              const SizedBox(
                height: 26,
              ),

              // ==================================================
              // MOBILE NUMBER / EMAIL
              // ==================================================

              _buildDeliveryMethod(),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // RECIPIENT TITLE
              // ==================================================

              Text(
                isEmail
                    ? 'Recipient Email'
                    : 'Recipient Mobile Number',

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // RECIPIENT FIELD
              // ==================================================

              _buildRecipientField(),

              const SizedBox(
                height: 8,
              ),

              Text(
                isEmail
                    ? 'Enter the email ID registered with Smart Local Train.'
                    : 'Enter the mobile number registered with Smart Local Train.',

                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              // ==================================================
              // WARNING
              // ==================================================

              Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets.all(14),

                decoration:
                BoxDecoration(
                  color:
                  Colors.orange.shade50,

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),

                  border: Border.all(
                    color:
                    Colors.orange.shade200,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                      Colors.orange.shade800,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'The ticket will remain yours until '
                            'the recipient accepts the transfer. '
                            'Only this selected ticket will be transferred.',

                        style: TextStyle(
                          color:
                          Colors.orange.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // TRANSFER BUTTON
              // ==================================================

              SizedBox(
                width:
                double.infinity,

                height: 54,

                child:
                FilledButton.icon(
                  onPressed:
                  _isLoading
                      ? null
                      : _createTransfer,

                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.send_outlined,
                  ),

                  label: Text(
                    _isLoading
                        ? 'Creating Transfer...'
                        : 'Transfer Ticket',
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              Center(
                child: Text(
                  'Transfer is secure and one-time.',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}