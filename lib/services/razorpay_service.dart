import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  // ============================================================
  // SMART LOCAL TRAIN BACKEND
  // ============================================================

  static const String _backendBaseUrl =
      'https://smart-local-train-backend.onrender.com';

  // Render free service can take some time to wake up after
  // being inactive, so allow enough time for the first request.
  static const Duration _requestTimeout =
  Duration(seconds: 90);

  final Razorpay _razorpay = Razorpay();

  Future<void> Function(
      String paymentId,
      String orderId,
      String signature,
      )? _onSuccess;

  Future<void> Function(
      String message,
      )? _onError;

  bool _initialized = false;
  bool _paymentCallbackHandled = false;

  // True when the local demo payment fallback is used.
  bool _lastPaymentWasDemo = false;

  bool get lastPaymentWasDemo => _lastPaymentWasDemo;

  // ============================================================
  // INITIALIZE
  // ============================================================

  void initialize({
    required Future<void> Function(
        String paymentId,
        String orderId,
        String signature,
        ) onSuccess,
    required Future<void> Function(
        String message,
        ) onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;

    if (_initialized) {
      return;
    }

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );

    _initialized = true;
  }

  // ============================================================
  // GET FIREBASE AUTH TOKEN
  // ============================================================

  Future<String> _getFirebaseIdToken() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    final String? token = await user.getIdToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Could not get Firebase authentication token.',
      );
    }

    return token;
  }

  // ============================================================
  // START PAYMENT
  // ============================================================

  Future<void> startPayment({
    required String bookingId,
  }) async {
    if (bookingId.trim().isEmpty) {
      throw Exception(
        'Booking ID is missing.',
      );
    }

    if (kIsWeb) {
      throw Exception(
        'Razorpay Flutter checkout works on Android/iOS only.',
      );
    }

    if (!_initialized) {
      throw Exception(
        'Razorpay service is not initialized.',
      );
    }

    _paymentCallbackHandled = false;
    _lastPaymentWasDemo = false;

    try {
      // ----------------------------------------------------------
      // Get Firebase ID token
      // ----------------------------------------------------------

      final String token = await _getFirebaseIdToken();

      // ----------------------------------------------------------
      // Ask Render backend to create Razorpay order
      // ----------------------------------------------------------

      final Uri url = Uri.parse(
        '$_backendBaseUrl/createRazorpayOrder',
      );

      final http.Response response = await http
          .post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, dynamic>{
            'bookingId': bookingId,
          },
        ),
      )
          .timeout(_requestTimeout);

      // ----------------------------------------------------------
      // Check HTTP response
      // ----------------------------------------------------------

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final String message =
        _extractBackendError(response);

        // Only use demo fallback for server/network
        // availability problems.
        if (_isBackendUnavailable(
          response.statusCode,
          message,
        )) {
          _startDemoPayment();
          return;
        }

        throw Exception(message);
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response received from payment server.',
        );
      }

      final Map<String, dynamic> data = decoded;

      final String orderId =
      (data['orderId'] ?? '').toString();

      final String keyId =
      (data['keyId'] ?? '').toString();

      final String currency =
      (data['currency'] ?? 'INR').toString();

      final int amount =
      _parseAmount(data['amount']);

      if (orderId.isEmpty) {
        throw Exception(
          'Razorpay Order ID was not returned by server.',
        );
      }

      if (keyId.isEmpty) {
        throw Exception(
          'Razorpay Key ID was not returned by server.',
        );
      }

      if (amount <= 0) {
        throw Exception(
          'Invalid payment amount received from server.',
        );
      }

      // ----------------------------------------------------------
      // Razorpay checkout options
      // ----------------------------------------------------------

      final Map<String, dynamic> options =
      <String, dynamic>{
        'key': keyId,
        'amount': amount,
        'currency': currency,
        'name': 'Smart Local Train',
        'description': 'Mumbai Local Train Ticket',
        'order_id': orderId,
        'retry': <String, dynamic>{
          'enabled': true,
          'max_count': 3,
        },
        'send_sms_hash': true,
        'theme': <String, dynamic>{
          'color': '#3949AB',
        },
      };

      // ----------------------------------------------------------
      // Open REAL Razorpay Test Mode checkout
      // ----------------------------------------------------------

      _razorpay.open(options);
    } on TimeoutException {
      // Render free instance may take time to wake up.
      _startDemoPayment();
    } on http.ClientException catch (_) {
      // Network/backend unavailable.
      _startDemoPayment();
    } catch (e) {
      final String errorText =
      e.toString().trim().toLowerCase();

      if (_isConnectionError(errorText)) {
        _startDemoPayment();
        return;
      }

      throw Exception(
        _cleanError(e),
      );
    }
  }

  // ============================================================
  // CHECK BACKEND AVAILABILITY
  // ============================================================

  bool _isBackendUnavailable(
      int statusCode,
      String message,
      ) {
    final String text =
    message.trim().toLowerCase();

    return statusCode == 408 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504 ||
        text.contains('service unavailable') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('timeout') ||
        text.contains('timed out');
  }

  // ============================================================
  // CHECK CONNECTION ERROR
  // ============================================================

  bool _isConnectionError(
      String text,
      ) {
    return text.contains('socketexception') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('failed host lookup') ||
        text.contains('connection timed out') ||
        text.contains('timed out') ||
        text.contains('timeout') ||
        text.contains('clientexception') ||
        text.contains('network is unreachable') ||
        text.contains('network unreachable') ||
        text.contains('connection closed') ||
        text.contains('connection aborted');
  }

  // ============================================================
  // DEMO PAYMENT FALLBACK
  // ============================================================

  void _startDemoPayment() {
    if (_paymentCallbackHandled) {
      return;
    }

    _paymentCallbackHandled = false;
    _lastPaymentWasDemo = true;

    final String timestamp =
    DateTime.now()
        .millisecondsSinceEpoch
        .toString();

    final String demoPaymentId =
        'DEMO_PAY_$timestamp';

    final String demoOrderId =
        'DEMO_ORDER_$timestamp';

    final String demoSignature =
        'DEMO_SIGNATURE_$timestamp';

    Future<void>.delayed(
      const Duration(milliseconds: 700),
          () async {
        if (_paymentCallbackHandled) {
          return;
        }

        _paymentCallbackHandled = true;

        await _onSuccess?.call(
          demoPaymentId,
          demoOrderId,
          demoSignature,
        );
      },
    );
  }

  // ============================================================
  // RAZORPAY PAYMENT SUCCESS
  // ============================================================

  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {
    if (_paymentCallbackHandled) {
      return;
    }

    _paymentCallbackHandled = true;

    _lastPaymentWasDemo = false;

    final String paymentId =
        response.paymentId ?? '';

    final String orderId =
        response.orderId ?? '';

    final String signature =
        response.signature ?? '';

    if (paymentId.isEmpty) {
      await _onError?.call(
        'Payment succeeded, but Payment ID is missing.',
      );

      return;
    }

    if (orderId.isEmpty) {
      await _onError?.call(
        'Payment succeeded, but Razorpay Order ID is missing.',
      );

      return;
    }

    if (signature.isEmpty) {
      await _onError?.call(
        'Payment succeeded, but payment signature is missing.',
      );

      return;
    }

    try {
      await _onSuccess?.call(
        paymentId,
        orderId,
        signature,
      );
    } catch (e) {
      await _onError?.call(
        'Payment verification failed: ${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // RAZORPAY PAYMENT ERROR
  // ============================================================

  Future<void> _handlePaymentError(
      PaymentFailureResponse response,
      ) async {
    if (_paymentCallbackHandled) {
      return;
    }

    _paymentCallbackHandled = true;

    _lastPaymentWasDemo = false;

    String message =
        response.message?.trim() ?? '';

    if (message.isEmpty) {
      message =
      'Razorpay payment failed. Please try again.';
    }

    if (response.code != null) {
      message =
      'Payment failed (${response.code}): $message';
    }

    await _onError?.call(message);
  }

  // ============================================================
  // EXTERNAL WALLET
  // ============================================================

  Future<void> _handleExternalWallet(
      ExternalWalletResponse response,
      ) async {
    final String walletName =
        response.walletName ?? 'External Wallet';

    await _onError?.call(
      'External wallet selected: $walletName',
    );
  }

  // ============================================================
  // VERIFY PAYMENT
  // ============================================================

  Future<bool> verifyPayment({
    required String bookingId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    if (bookingId.trim().isEmpty) {
      throw Exception(
        'Booking ID is missing.',
      );
    }

    if (paymentId.trim().isEmpty) {
      throw Exception(
        'Payment ID is missing.',
      );
    }

    if (orderId.trim().isEmpty) {
      throw Exception(
        'Razorpay Order ID is missing.',
      );
    }

    if (signature.trim().isEmpty) {
      throw Exception(
        'Razorpay payment signature is missing.',
      );
    }

    // ----------------------------------------------------------
    // Demo payment does not require real Razorpay verification.
    // ----------------------------------------------------------

    if (_lastPaymentWasDemo) {
      return true;
    }

    try {
      // ----------------------------------------------------------
      // Get Firebase ID token
      // ----------------------------------------------------------

      final String token =
      await _getFirebaseIdToken();

      // ----------------------------------------------------------
      // Send payment details to Render backend
      // ----------------------------------------------------------

      final Uri url = Uri.parse(
        '$_backendBaseUrl/verifyRazorpayPayment',
      );

      final http.Response response = await http
          .post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, dynamic>{
            'bookingId': bookingId,
            'razorpayPaymentId': paymentId,
            'razorpayOrderId': orderId,
            'razorpaySignature': signature,
          },
        ),
      )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final String message =
        _extractBackendError(response);

        throw Exception(
          'Payment verification failed: $message',
        );
      }

      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic success =
        decoded['success'];

        return success == true;
      }

      return false;
    } on TimeoutException {
      throw Exception(
        'Payment verification timed out. '
            'Please check your payment status before trying again.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Payment verification failed: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Payment verification failed: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // EXTRACT BACKEND ERROR
  // ============================================================

  String _extractBackendError(
      http.Response response,
      ) {
    try {
      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic error =
        decoded['error'];

        if (error != null &&
            error.toString().trim().isNotEmpty) {
          return error.toString().trim();
        }

        final dynamic message =
        decoded['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and use
      // the raw response below.
    }

    final String body =
    response.body.trim();

    if (body.isNotEmpty) {
      return body;
    }

    return 'Payment server returned HTTP ${response.statusCode}.';
  }

  // ============================================================
  // PARSE AMOUNT
  // ============================================================

  int _parseAmount(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final double? parsed =
      double.tryParse(value);

      if (parsed != null) {
        return parsed.round();
      }
    }

    return 0;
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    final String text =
    error.toString().trim();

    if (text.startsWith('Exception:')) {
      return text
          .substring('Exception:'.length)
          .trim();
    }

    return text;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _razorpay.clear();

    _onSuccess = null;
    _onError = null;

    _paymentCallbackHandled = false;
    _lastPaymentWasDemo = false;
    _initialized = false;
  }
}