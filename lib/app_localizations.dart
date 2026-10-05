import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  // ==========================================================
  // ACCESS
  // ==========================================================

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    ) ??
        const AppLocalizations(Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  String get languageCode {
    return locale.languageCode;
  }

  bool get isHindi {
    return locale.languageCode == 'hi';
  }

  bool get isMarathi {
    return locale.languageCode == 'mr';
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  String _text({
    required String en,
    required String hi,
    required String mr,
  }) {
    switch (locale.languageCode) {
      case 'hi':
        return hi;

      case 'mr':
        return mr;

      default:
        return en;
    }
  }

  // ==========================================================
  // GENERAL
  // ==========================================================

  String get appName => _text(
    en: 'Local Rail',
    hi: 'लोकल रेल',
    mr: 'लोकल रेल',
  );

  String get passenger => _text(
    en: 'Passenger',
    hi: 'यात्री',
    mr: 'प्रवासी',
  );

  String get save => _text(
    en: 'Save',
    hi: 'सहेजें',
    mr: 'जतन करा',
  );

  String get cancel => _text(
    en: 'Cancel',
    hi: 'रद्द करें',
    mr: 'रद्द करा',
  );

  String get done => _text(
    en: 'Done',
    hi: 'पूर्ण',
    mr: 'पूर्ण',
  );

  String get close => _text(
    en: 'Close',
    hi: 'बंद करें',
    mr: 'बंद करा',
  );

  String get confirm => _text(
    en: 'Confirm',
    hi: 'पुष्टि करें',
    mr: 'पुष्टी करा',
  );

  String get submit => _text(
    en: 'Submit',
    hi: 'जमा करें',
    mr: 'सबमिट करा',
  );

  String get retry => _text(
    en: 'Retry',
    hi: 'पुनः प्रयास करें',
    mr: 'पुन्हा प्रयत्न करा',
  );

  String get yes => _text(
    en: 'Yes',
    hi: 'हाँ',
    mr: 'होय',
  );

  String get no => _text(
    en: 'No',
    hi: 'नहीं',
    mr: 'नाही',
  );

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  String get home => _text(
    en: 'Home',
    hi: 'होम',
    mr: 'होम',
  );

  String get tickets => _text(
    en: 'Tickets',
    hi: 'टिकट',
    mr: 'तिकीट',
  );

  String get live => _text(
    en: 'Live',
    hi: 'लाइव',
    mr: 'लाइव्ह',
  );

  String get profile => _text(
    en: 'Profile',
    hi: 'प्रोफ़ाइल',
    mr: 'प्रोफाइल',
  );

  // ==========================================================
  // HOME
  // ==========================================================

  String hello(String name) => _text(
    en: 'Hello, $name! 👋',
    hi: 'नमस्ते, $name! 👋',
    mr: 'नमस्कार, $name! 👋',
  );

  String get travelSmarter => _text(
    en: 'Travel smarter with Mumbai local trains.',
    hi: 'मुंबई लोकल ट्रेनों के साथ स्मार्ट यात्रा करें।',
    mr: 'मुंबई लोकल ट्रेनने स्मार्ट प्रवास करा.',
  );

  String get bookTrainTicket => _text(
    en: 'Book Train Ticket',
    hi: 'ट्रेन टिकट बुक करें',
    mr: 'ट्रेन तिकीट बुक करा',
  );

  String get bookNewMumbaiTicket => _text(
    en: 'Book a new Mumbai local train ticket',
    hi: 'नई मुंबई लोकल ट्रेन टिकट बुक करें',
    mr: 'नवीन मुंबई लोकल ट्रेन तिकीट बुक करा',
  );

  String get myTickets => _text(
    en: 'My Tickets',
    hi: 'मेरे टिकट',
    mr: 'माझी तिकिटे',
  );

  String get viewManageTickets => _text(
    en: 'View and manage your tickets',
    hi: 'अपने टिकट देखें और प्रबंधित करें',
    mr: 'तुमची तिकिटे पहा आणि व्यवस्थापित करा',
  );

  String get sendTicket => _text(
    en: 'Send Ticket',
    hi: 'टिकट भेजें',
    mr: 'तिकीट पाठवा',
  );

  String get sendTicketSubtitle => _text(
    en: 'Send a ticket to another passenger',
    hi: 'दूसरे यात्री को टिकट भेजें',
    mr: 'दुसऱ्या प्रवाशाला तिकीट पाठवा',
  );

  String get receiveTicket => _text(
    en: 'Receive Ticket',
    hi: 'टिकट प्राप्त करें',
    mr: 'तिकीट प्राप्त करा',
  );

  String get receiveTicketSubtitle => _text(
    en: 'View tickets received from other passengers',
    hi: 'अन्य यात्रियों से प्राप्त टिकट देखें',
    mr: 'इतर प्रवाशांकडून मिळालेली तिकिटे पहा',
  );

  String get transferTicket => _text(
    en: 'Transfer Ticket',
    hi: 'टिकट ट्रांसफर करें',
    mr: 'तिकीट ट्रान्सफर करा',
  );

  String get transferTicketSubtitle => _text(
    en: 'Transfer an individual ticket',
    hi: 'एक टिकट दूसरे यात्री को ट्रांसफर करें',
    mr: 'एक तिकीट दुसऱ्या प्रवाशाला ट्रान्सफर करा',
  );

  String get transferHistory => _text(
    en: 'Transfer History',
    hi: 'ट्रांसफर इतिहास',
    mr: 'ट्रान्सफर इतिहास',
  );

  String get transferHistorySubtitle => _text(
    en: 'View your sent and received ticket transfers',
    hi: 'भेजे और प्राप्त किए गए टिकट ट्रांसफर देखें',
    mr: 'पाठवलेले आणि प्राप्त केलेले तिकीट ट्रान्सफर पहा',
  );

  String get liveTrains => _text(
    en: 'Live Trains',
    hi: 'लाइव ट्रेनें',
    mr: 'लाइव्ह ट्रेन',
  );

  String get liveTrainsSubtitle => _text(
    en: 'Track Mumbai local trains and view their status',
    hi: 'मुंबई लोकल ट्रेनों को ट्रैक करें और उनकी स्थिति देखें',
    mr: 'मुंबई लोकल ट्रेनचा मागोवा घ्या आणि त्यांची स्थिती पहा',
  );

  String get quickInformation => _text(
    en: 'Quick Information',
    hi: 'त्वरित जानकारी',
    mr: 'त्वरित माहिती',
  );

  String get trains => _text(
    en: 'Trains',
    hi: 'ट्रेनें',
    mr: 'ट्रेन',
  );

  String get secure => _text(
    en: 'Secure',
    hi: 'सुरक्षित',
    mr: 'सुरक्षित',
  );

  String get keepQrReady => _text(
    en: 'Keep your ticket QR code ready during your journey for verification.',
    hi: 'यात्रा के दौरान सत्यापन के लिए अपना टिकट QR कोड तैयार रखें।',
    mr: 'प्रवासादरम्यान पडताळणीसाठी तुमचा तिकीट QR कोड तयार ठेवा.',
  );

  // ==========================================================
  // PROFILE
  // ==========================================================

  String get personalInformation => _text(
    en: 'Personal Information',
    hi: 'व्यक्तिगत जानकारी',
    mr: 'वैयक्तिक माहिती',
  );

  String get personalInformationSubtitle => _text(
    en: 'Manage your name, email and mobile number',
    hi: 'अपना नाम, ईमेल और मोबाइल नंबर प्रबंधित करें',
    mr: 'तुमचे नाव, ईमेल आणि मोबाईल नंबर व्यवस्थापित करा',
  );

  String get settings => _text(
    en: 'Settings',
    hi: 'सेटिंग्स',
    mr: 'सेटिंग्ज',
  );

  String get settingsSubtitle => _text(
    en: 'Notifications, appearance and app settings',
    hi: 'सूचनाएं, दिखावट और ऐप सेटिंग्स',
    mr: 'सूचना, दिसणे आणि अॅप सेटिंग्ज',
  );

  String get helpSupport => _text(
    en: 'Help & Support',
    hi: 'सहायता और समर्थन',
    mr: 'मदत आणि समर्थन',
  );

  String get helpSupportSubtitle => _text(
    en: 'FAQs, support and report a problem',
    hi: 'अक्सर पूछे जाने वाले प्रश्न, सहायता और समस्या रिपोर्ट करें',
    mr: 'वारंवार विचारले जाणारे प्रश्न, मदत आणि समस्या नोंदवा',
  );

  String get logout => _text(
    en: 'Logout',
    hi: 'लॉग आउट',
    mr: 'लॉग आउट',
  );

  String get logoutConfirm => _text(
    en: 'Are you sure you want to logout?',
    hi: 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
    mr: 'तुम्हाला नक्की लॉग आउट करायचे आहे का?',
  );

  // ==========================================================
  // SETTINGS
  // ==========================================================

  String get general => _text(
    en: 'General',
    hi: 'सामान्य',
    mr: 'सामान्य',
  );

  String get notifications => _text(
    en: 'Notifications',
    hi: 'सूचनाएं',
    mr: 'सूचना',
  );

  String get notificationsSubtitle => _text(
    en: 'Receive booking and ticket updates',
    hi: 'बुकिंग और टिकट अपडेट प्राप्त करें',
    mr: 'बुकिंग आणि तिकीट अपडेट मिळवा',
  );

  String get darkMode => _text(
    en: 'Dark Mode',
    hi: 'डार्क मोड',
    mr: 'डार्क मोड',
  );

  String get darkModeSubtitle => _text(
    en: 'Use dark appearance for the app',
    hi: 'ऐप को डार्क थीम में इस्तेमाल करें',
    mr: 'अॅप डार्क थीममध्ये वापरा',
  );

  String get application => _text(
    en: 'Application',
    hi: 'एप्लिकेशन',
    mr: 'अॅप्लिकेशन',
  );

  String get language => _text(
    en: 'Language',
    hi: 'भाषा',
    mr: 'भाषा',
  );

  String get english => _text(
    en: 'English',
    hi: 'अंग्रेज़ी',
    mr: 'इंग्रजी',
  );

  String get hindi => _text(
    en: 'हिन्दी',
    hi: 'हिन्दी',
    mr: 'हिंदी',
  );

  String get marathi => _text(
    en: 'मराठी',
    hi: 'मराठी',
    mr: 'मराठी',
  );

  String get selectLanguage => _text(
    en: 'Select Language',
    hi: 'भाषा चुनें',
    mr: 'भाषा निवडा',
  );

  String get appVersion => _text(
    en: 'App Version',
    hi: 'ऐप संस्करण',
    mr: 'अॅप आवृत्ती',
  );

  String get localRailDescription => _text(
    en: 'Your local train travel companion',
    hi: 'स्थानीय ट्रेन यात्रा के लिए आपका साथी',
    mr: 'लोकल ट्रेन प्रवासासाठी तुमचा साथीदार',
  );

  // ==========================================================
  // PERSONAL INFORMATION
  // ==========================================================

  String get fullName => _text(
    en: 'Full Name',
    hi: 'पूरा नाम',
    mr: 'पूर्ण नाव',
  );

  String get email => _text(
    en: 'Email',
    hi: 'ईमेल',
    mr: 'ईमेल',
  );

  String get mobileNumber => _text(
    en: 'Mobile Number',
    hi: 'मोबाइल नंबर',
    mr: 'मोबाईल नंबर',
  );

  String get saveChanges => _text(
    en: 'Save Changes',
    hi: 'परिवर्तन सहेजें',
    mr: 'बदल जतन करा',
  );

  String get profileUpdated => _text(
    en: 'Profile updated successfully.',
    hi: 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई।',
    mr: 'प्रोफाइल यशस्वीरित्या अपडेट केली.',
  );

  // ==========================================================
  // LOGIN
  // ==========================================================

  String get login => _text(
    en: 'Login',
    hi: 'लॉगिन',
    mr: 'लॉगिन',
  );

  String get password => _text(
    en: 'Password',
    hi: 'पासवर्ड',
    mr: 'पासवर्ड',
  );

  String get rememberMe => _text(
    en: 'Remember Me',
    hi: 'मुझे याद रखें',
    mr: 'मला लक्षात ठेवा',
  );

  String get loginSuccessful => _text(
    en: 'Login successful!',
    hi: 'लॉगिन सफल हुआ!',
    mr: 'लॉगिन यशस्वी झाले!',
  );

  String get invalidEmailPassword => _text(
    en: 'Invalid email or password.',
    hi: 'अमान्य ईमेल या पासवर्ड।',
    mr: 'अवैध ईमेल किंवा पासवर्ड.',
  );

  String get validEmail => _text(
    en: 'Please enter a valid email address.',
    hi: 'कृपया वैध ईमेल पता दर्ज करें।',
    mr: 'कृपया वैध ईमेल पत्ता प्रविष्ट करा.',
  );

  String get accountDisabled => _text(
    en: 'This account has been disabled.',
    hi: 'यह खाता अक्षम कर दिया गया है।',
    mr: 'हे खाते अक्षम केले आहे.',
  );

  String get accountNotFound => _text(
    en: 'No account found with this email.',
    hi: 'इस ईमेल से कोई खाता नहीं मिला।',
    mr: 'या ईमेलसह कोणतेही खाते सापडले नाही.',
  );

  String get incorrectPassword => _text(
    en: 'Incorrect password.',
    hi: 'गलत पासवर्ड।',
    mr: 'चुकीचा पासवर्ड.',
  );

  String get networkError => _text(
    en: 'Network error. Please check your internet connection.',
    hi: 'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।',
    mr: 'नेटवर्क त्रुटी. कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
  );

  // ==========================================================
  // REGISTER
  // ==========================================================

  String get register => _text(
    en: 'Register',
    hi: 'रजिस्टर करें',
    mr: 'नोंदणी करा',
  );

  String get createAccount => _text(
    en: 'Create Account',
    hi: 'खाता बनाएं',
    mr: 'खाते तयार करा',
  );

  String get phoneNumber => _text(
    en: 'Phone Number',
    hi: 'फोन नंबर',
    mr: 'फोन नंबर',
  );

  // ==========================================================
  // TICKETS
  // ==========================================================

  String get noTickets => _text(
    en: 'No tickets found.',
    hi: 'कोई टिकट नहीं मिला।',
    mr: 'कोणतीही तिकिटे सापडली नाहीत.',
  );

  String get from => _text(
    en: 'From',
    hi: 'से',
    mr: 'पासून',
  );

  String get to => _text(
    en: 'To',
    hi: 'तक',
    mr: 'पर्यंत',
  );

  String get train => _text(
    en: 'Train',
    hi: 'ट्रेन',
    mr: 'ट्रेन',
  );

  String get fare => _text(
    en: 'Fare',
    hi: 'किराया',
    mr: 'भाडे',
  );

  String get journeyDate => _text(
    en: 'Journey Date',
    hi: 'यात्रा की तारीख',
    mr: 'प्रवासाची तारीख',
  );

  String get passengers => _text(
    en: 'Passengers',
    hi: 'यात्री',
    mr: 'प्रवासी',
  );

  String get ticketDetails => _text(
    en: 'Ticket Details',
    hi: 'टिकट विवरण',
    mr: 'तिकीट तपशील',
  );

  // ==========================================================
  // BOOKING
  // ==========================================================

  String get reviewTicket => _text(
    en: 'Review Ticket',
    hi: 'टिकट की समीक्षा करें',
    mr: 'तिकीट तपासा',
  );

  String get via => _text(
    en: 'Via',
    hi: 'मार्ग',
    mr: 'मार्ग',
  );

  String get direct => _text(
    en: 'Direct',
    hi: 'सीधा',
    mr: 'थेट',
  );

  String get journey => _text(
    en: 'Journey',
    hi: 'यात्रा',
    mr: 'प्रवास',
  );

  String get oneWay => _text(
    en: 'One Way',
    hi: 'एक तरफ़',
    mr: 'एकेरी',
  );

  String get returnJourney => _text(
    en: 'Return',
    hi: 'वापसी',
    mr: 'परती',
  );

  String get distance => _text(
    en: 'Distance',
    hi: 'दूरी',
    mr: 'अंतर',
  );

  String get route => _text(
    en: 'Route',
    hi: 'मार्ग',
    mr: 'मार्ग',
  );

  String get totalFare => _text(
    en: 'Total Fare',
    hi: 'कुल किराया',
    mr: 'एकूण भाडे',
  );

  String get payment => _text(
    en: 'Payment',
    hi: 'भुगतान',
    mr: 'पेमेंट',
  );

  String get processingPayment => _text(
    en: 'Processing Payment...',
    hi: 'भुगतान संसाधित किया जा रहा है...',
    mr: 'पेमेंट प्रक्रिया सुरू आहे...',
  );

  String payAmount(String amount) => _text(
    en: 'Pay ₹$amount',
    hi: '₹$amount भुगतान करें',
    mr: '₹$amount पेमेंट करा',
  );

  String get paymentSuccessful => _text(
    en: 'Payment Successful',
    hi: 'भुगतान सफल',
    mr: 'पेमेंट यशस्वी',
  );

  String get bookingSuccessful => _text(
    en: 'Your Mumbai Local train ticket has been booked successfully.',
    hi: 'आपका मुंबई लोकल ट्रेन टिकट सफलतापूर्वक बुक हो गया है।',
    mr: 'तुमचे मुंबई लोकल ट्रेन तिकीट यशस्वीरित्या बुक झाले आहे.',
  );

  String get bookingId => _text(
    en: 'Booking ID:',
    hi: 'बुकिंग आईडी:',
    mr: 'बुकिंग आयडी:',
  );

  String get paymentId => _text(
    en: 'Payment ID:',
    hi: 'भुगतान आईडी:',
    mr: 'पेमेंट आयडी:',
  );

  // ==========================================================
  // LIVE TRAINS
  // ==========================================================

  String get trackMumbaiTrains => _text(
    en: 'Track Mumbai local trains in real time.',
    hi: 'मुंबई लोकल ट्रेनों को वास्तविक समय में ट्रैक करें।',
    mr: 'मुंबई लोकल ट्रेनचा रिअल-टाइममध्ये मागोवा घ्या.',
  );

  String get currentStation => _text(
    en: 'Current Station',
    hi: 'वर्तमान स्टेशन',
    mr: 'सध्याचे स्टेशन',
  );

  String get nextStation => _text(
    en: 'Next Station',
    hi: 'अगला स्टेशन',
    mr: 'पुढील स्टेशन',
  );

  String get running => _text(
    en: 'Running',
    hi: 'चल रही है',
    mr: 'चालू',
  );

  String get delayed => _text(
    en: 'Delayed',
    hi: 'देरी से',
    mr: 'उशीर',
  );

  String get onTime => _text(
    en: 'On Time',
    hi: 'समय पर',
    mr: 'वेळेवर',
  );

  String get searchStation => _text(
    en: 'Search Station',
    hi: 'स्टेशन खोजें',
    mr: 'स्टेशन शोधा',
  );

  String get selectDestination => _text(
    en: 'Select Destination',
    hi: 'गंतव्य चुनें',
    mr: 'गंतव्य निवडा',
  );

  // ==========================================================
  // TRANSFERS
  // ==========================================================

  String get send => _text(
    en: 'Send',
    hi: 'भेजें',
    mr: 'पाठवा',
  );

  String get receive => _text(
    en: 'Receive',
    hi: 'प्राप्त करें',
    mr: 'प्राप्त करा',
  );

  String get transfer => _text(
    en: 'Transfer',
    hi: 'ट्रांसफर',
    mr: 'ट्रान्सफर',
  );

  String get transferSuccessful => _text(
    en: 'Ticket transferred successfully.',
    hi: 'टिकट सफलतापूर्वक ट्रांसफर किया गया।',
    mr: 'तिकीट यशस्वीरित्या ट्रान्सफर केले.',
  );

  // ==========================================================
  // HELP & SUPPORT
  // ==========================================================

  String get faqs => _text(
    en: 'FAQs',
    hi: 'अक्सर पूछे जाने वाले प्रश्न',
    mr: 'वारंवार विचारले जाणारे प्रश्न',
  );

  String get contactSupport => _text(
    en: 'Contact Support',
    hi: 'सहायता से संपर्क करें',
    mr: 'सपोर्टशी संपर्क करा',
  );

  String get reportProblem => _text(
    en: 'Report a Problem',
    hi: 'समस्या रिपोर्ट करें',
    mr: 'समस्या नोंदवा',
  );

  String get aboutLocalRail => _text(
    en: 'About Local Rail',
    hi: 'लोकल रेल के बारे में',
    mr: 'लोकल रेल बद्दल',
  );

  // ==========================================================
  // COMMON MESSAGES
  // ==========================================================

  String get notificationsComingSoon => _text(
    en: 'Notifications will be available soon.',
    hi: 'सूचनाएं जल्द उपलब्ध होंगी।',
    mr: 'सूचना लवकरच उपलब्ध होतील.',
  );

  String featureComingSoon(String feature) => _text(
    en: '$feature will be available soon.',
    hi: '$feature जल्द उपलब्ध होगा।',
    mr: '$feature लवकरच उपलब्ध होईल.',
  );

  String get unableToLogout => _text(
    en: 'Unable to logout.',
    hi: 'लॉग आउट नहीं हो सका।',
    mr: 'लॉग आउट करता आले नाही.',
  );

  String get somethingWentWrong => _text(
    en: 'Something went wrong.',
    hi: 'कुछ गलत हो गया।',
    mr: 'काहीतरी चुकीचे झाले.',
  );
}

// ============================================================
// LOCALIZATION DELEGATE
// ============================================================

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const [
      'en',
      'hi',
      'mr',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(
      Locale locale,
      ) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<AppLocalizations> old,
      ) {
    return false;
  }
}