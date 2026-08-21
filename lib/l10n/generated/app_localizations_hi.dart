// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Mediaro';

  @override
  String get home => 'होम';

  @override
  String get medicines => 'दवाइयाँ';

  @override
  String get medicine => 'दवाई';

  @override
  String get inventory => 'इन्वेंट्री';

  @override
  String get progress => 'प्रगति';

  @override
  String get vitals => 'वाइटल्स';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get goodMorning => 'शुभ';

  @override
  String get goodAfternoon => 'शुभ';

  @override
  String get goodEvening => 'शुभ';

  @override
  String get goodNight => 'शुभ';

  @override
  String get morning => 'सुबह';

  @override
  String get afternoon => 'दोपहर';

  @override
  String get evening => 'शाम';

  @override
  String get night => 'रात';

  @override
  String get switchProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get addDependent => 'आश्रित जोड़ें';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get noMedicinesYet => 'अभी तक कोई दवाई नहीं जोड़ी';

  @override
  String get addFirstMedicineSubtitle =>
      'अपनी पहली दवाई जोड़ें और हम आपको याद दिलाएँगे।';

  @override
  String get addFirstMedicine => 'पहली दवाई जोड़ें';

  @override
  String get todaysMedicationProgress => 'आज की दवाई प्रगति';

  @override
  String get totalDose => 'कुल खुराक';

  @override
  String get taken => 'ली गई';

  @override
  String get missed => 'छूटी';

  @override
  String get viewTodaysPlan => 'आज का प्लान देखें';

  @override
  String get takenStatus => 'ली गई ✓';

  @override
  String get upcoming => 'आने वाली';

  @override
  String get addMedicine => 'दवाई जोड़ें';

  @override
  String get snoozeDose => 'खुराक स्नूज़ करें';

  @override
  String get howLongSnooze =>
      'आप इस रिमाइंडर को कितनी देर के लिए स्नूज़ करना चाहेंगे?';

  @override
  String get min10 => '10 मिनट';

  @override
  String get min30 => '30 मिनट';

  @override
  String get hour1 => '1 घंटा';

  @override
  String snoozedFor(Object minutes) {
    return '$minutes मिनट के लिए स्नूज़ किया।';
  }

  @override
  String get allMedicinesCompleted => 'सभी दवाइयाँ पूरी हो गईं!';

  @override
  String get allCompletedSub =>
      'आज की सभी निर्धारित दवाइयाँ आपने पूरी कर ली हैं।';

  @override
  String get nextMedicine => 'अगली दवाई';

  @override
  String get takeNow => 'अभी लें';

  @override
  String get markAsTaken => 'ली गई चिन्हित करें';

  @override
  String get snooze => 'स्नूज़';

  @override
  String get overdue => 'बाकी';

  @override
  String get alsoScheduled => 'भी निर्धारित';

  @override
  String get more => 'और';

  @override
  String get take => 'लें';

  @override
  String get doctorAppointments => 'डॉक्टर अपॉइंटमेंट';

  @override
  String get pro => 'प्रो';

  @override
  String get scheduleManage => 'विज़िट शेड्यूल और प्रबंधित करें';

  @override
  String get upgradeToAccess => 'एक्सेस के लिए प्रीमियम में अपग्रेड करें';

  @override
  String get self => 'स्वयं';

  @override
  String get close => 'बंद करें';

  @override
  String get todaysPlan => 'आज का प्लान';

  @override
  String get noMedicationScheduled => 'आज के लिए कोई दवाई निर्धारित नहीं है।';

  @override
  String get addMedicinesWithTimes =>
      'उन्हें यहाँ देखने के लिए निर्धारित समय के साथ दवाइयाँ जोड़ें।';

  @override
  String get left => 'बाकी';

  @override
  String freeLimit(Object limit) {
    return 'फ्री प्लान में अधिकतम $limit दवाइयाँ। प्रीमियम में अपग्रेड करें।';
  }

  @override
  String get upgrade => 'अपग्रेड';

  @override
  String markedAsTaken(Object name) {
    return '$name को ली गई चिन्हित किया!';
  }

  @override
  String get todaysVitals => 'आज के वाइटल्स';

  @override
  String get bloodPressure => 'रक्तचाप';

  @override
  String get bloodSugar => 'रक्त शर्करा';

  @override
  String get weight => 'वज़न';

  @override
  String get spo2 => 'SPO2';

  @override
  String get spirometer => 'स्पायरोमीटर';

  @override
  String get walkTest => 'वॉक टेस्ट';

  @override
  String get logReading => 'रीडिंग दर्ज करें';

  @override
  String get history => 'इतिहास';

  @override
  String get noVitalsRecorded => 'अभी तक कोई वाइटल्स दर्ज नहीं';

  @override
  String get tapLogReading =>
      'अपना पहला वाइटल दर्ज करने के लिए रीडिंग दर्ज करें पर टैप करें।';

  @override
  String get today => 'आज';

  @override
  String get logVitalReading => 'वाइटल रीडिंग दर्ज करें';

  @override
  String get vitalType => 'वाइटल प्रकार';

  @override
  String get bp => 'BP';

  @override
  String get sugar => 'शर्करा';

  @override
  String get beforeMeal => 'भोजन से पहले';

  @override
  String get afterMeal => 'भोजन के बाद';

  @override
  String get systolic => 'सिस्टोलिक (mmHg)';

  @override
  String get diastolic => 'डायस्टोलिक (mmHg)';

  @override
  String get when => 'कब?';

  @override
  String get bloodSugarUnit => 'रक्त शर्करा (mg/dL)';

  @override
  String get weightUnit => 'वज़न (kg)';

  @override
  String get spo2Unit => 'SPO2 (%)';

  @override
  String get spirometerUnit => 'स्पायरोमीटर रीडिंग (L)';

  @override
  String get walkTestUnit => 'वॉक टेस्ट (कदम)';

  @override
  String get saveReading => 'रीडिंग सहेजें';

  @override
  String get deleteReading => 'रीडिंग हटाएँ';

  @override
  String deleteReadingConfirm(Object type) {
    return 'यह $type रीडिंग हटाएँ?';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String readingSaved(Object type) {
    return '$type रीडिंग सहेजी गई!';
  }

  @override
  String get errorEnterBp =>
      'कृपया सिस्टोलिक और डायस्टोलिक दोनों मान दर्ज करें';

  @override
  String get errorEnterSugar => 'कृपया रक्त शर्करा मान दर्ज करें';

  @override
  String get errorEnterWeight => 'कृपया वज़न मान दर्ज करें';

  @override
  String get errorEnterSpo2 => 'कृपया SPO2 मान दर्ज करें';

  @override
  String get errorEnterSpirometer => 'कृपया स्पायरोमीटर मान दर्ज करें';

  @override
  String get errorEnterWalk => 'कृपया वॉक टेस्ट मान दर्ज करें';

  @override
  String get lastLabel => 'अंतिम:';

  @override
  String get hintEg => 'जैसे';

  @override
  String get inventoryDetails => 'इन्वेंट्री विवरण';

  @override
  String get refillReminderBanner =>
      'रीफिल समय की चेतावनी के लिए रिमाइंडर सेट करें';

  @override
  String get emptyCabinet => 'आपकी दवाई कैबिनेट खाली है';

  @override
  String get emptyCabinetSub =>
      'स्टॉक ट्रैक करने के लिए होम डैशबोर्ड से दवाइयाँ जोड़ें।';

  @override
  String get outOfStock => 'स्टॉक में नहीं';

  @override
  String get critical => 'गंभीर';

  @override
  String get lowStock => 'कम स्टॉक';

  @override
  String get inStock => 'स्टॉक में';

  @override
  String get noStockRemaining => 'कोई स्टॉक शेष नहीं';

  @override
  String hoursLeft(Object hours) {
    return '~$hours घंटे बाकी';
  }

  @override
  String get dayLeft => '~1 दिन बाकी';

  @override
  String daysLeft(Object days) {
    return '~$days दिन बाकी';
  }

  @override
  String get remaining => 'शेष';

  @override
  String get edit => 'संपादित करें';

  @override
  String get refillNow => 'अभी रीफिल करें';

  @override
  String refillMedicine(Object name) {
    return '$name रीफिल करें';
  }

  @override
  String currentStock(Object qty, Object unit) {
    return 'वर्तमान स्टॉक: $qty $unit';
  }

  @override
  String get addQuantity => 'मात्रा जोड़ें';

  @override
  String get enterQuantity => 'मात्रा दर्ज करें';

  @override
  String get pleaseEnterQuantity => 'कृपया मात्रा दर्ज करें';

  @override
  String get pleaseEnterValidQuantity => 'कृपया वैध मात्रा दर्ज करें';

  @override
  String get addStock => 'स्टॉक जोड़ें';

  @override
  String addedStock(Object name, Object qty, Object unit) {
    return '$qty $unit $name में जोड़ा गया';
  }

  @override
  String freeLimitMedicines(Object limit) {
    return 'फ्री प्लान में अधिकतम $limit दवाइयाँ। प्रीमियम में अपग्रेड करें।';
  }

  @override
  String get yourProgress => 'आपकी प्रगति';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get medicationPerformance => 'दवाई प्रदर्शन';

  @override
  String get progressEmpty => 'आपकी प्रगति यहाँ दिखाई देगी';

  @override
  String get progressEmptySub =>
      'इतिहास बनाना शुरू करने के लिए नियमित रूप से अपनी दवाइयाँ लें।';

  @override
  String get setTodaysMedications => 'आज की दवाइयाँ सेट करें';

  @override
  String get totalDoses => 'कुल खुराकें';

  @override
  String get percentComplete => '% पूर्ण';

  @override
  String get doses => 'खुराकें';

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get name => 'नाम';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get email => 'ईमेल';

  @override
  String get enterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get emailGoogleLocked =>
      'ईमेल आपके Google खाते से जुड़ा है और इसे बदला नहीं जा सकता।';

  @override
  String get cardiacPostSurgery => 'कार्डियक पोस्ट-सर्जरी मरीज़';

  @override
  String get enableSpirometer => 'स्पायरोमीटर और वॉक टेस्ट वाइटल्स सक्षम करें';

  @override
  String get forCardiac => 'कार्डियक पोस्ट-सर्जरी मरीज़ों के लिए';

  @override
  String get nameEmpty => 'नाम खाली नहीं हो सकता';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई!';

  @override
  String get general => 'सामान्य';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get passwordOpened => 'पासवर्ड बदलने की प्रक्रिया खुल गई।';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get notificationSettings => 'सूचना सेटिंग्स';

  @override
  String get medicationReminders => 'दवाई रिमाइंडर';

  @override
  String get missedDoseAlerts => 'छूटी खुराक अलर्ट';

  @override
  String get refillReminders => 'रीफिल रिमाइंडर';

  @override
  String get checkPermissions => 'अनुमतियाँ जाँचें/अपडेट करें';

  @override
  String get permissionsChecked => 'अनुमतियाँ जाँच/अपडेट हो गईं';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi (हिन्दी)';

  @override
  String get logOut => 'लॉग आउट';

  @override
  String get logOutConfirm =>
      'क्या आप वाकई लॉग आउट करना चाहते हैं? आपकी प्रगति सेव रहेगी।';

  @override
  String get subscription => 'सदस्यता';

  @override
  String get mediaroPremium => 'Mediaro प्रीमियम';

  @override
  String get freePlan => 'फ्री प्लान';

  @override
  String get unlimitedMedicinesVitals => 'असीमित दवाइयाँ और वाइटल्स';

  @override
  String medicinesUsed(Object limit, Object used) {
    return '$limit में से $used दवाइयाँ उपयोग की गईं';
  }

  @override
  String get switchedToFree => 'फ्री प्लान में बदला गया';

  @override
  String get upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get unlimitedMedicines => 'असीमित दवाइयाँ';

  @override
  String get dailyVitals => 'दैनिक वाइटल्स';

  @override
  String get advancedAnalytics => 'उन्नत एनालिटिक्स';

  @override
  String get healthReports => 'हेल्थ रिपोर्ट';

  @override
  String get legalAndPolicies => 'कानूनी और नीतियाँ';

  @override
  String get legalPrivacyPolicy => 'कानूनी और गोपनीयता नीति';

  @override
  String get legalText =>
      'यह एप्लिकेशन एक स्थानीय दवाई रिमाइंडर सहायक है। यह चिकित्सा निदान, चिकित्सा सलाह या उपचार निर्णय प्रदान नहीं करता। सभी उपयोगकर्ता रिकॉर्ड पूरी तरह से आपके भौतिक डिवाइस पर ऑफलाइन संग्रहीत होते हैं। संदेह की स्थिति में, किसी भी खुराक परिवर्तन से पहले एक प्रमाणित स्वास्थ्य पेशेवर से परामर्श करें।';

  @override
  String get myDependents => 'मेरे आश्रित';

  @override
  String get noDependentsYet => 'अभी तक कोई आश्रित नहीं जोड़ा';

  @override
  String get doctorAppointmentsTitle => 'डॉक्टर अपॉइंटमेंट';

  @override
  String get upcomingAppointments => 'आगामी अपॉइंटमेंट';

  @override
  String get upcomingAppointmentsPlural => 'आगामी अपॉइंटमेंट';

  @override
  String get noAppointments => 'अभी तक कोई अपॉइंटमेंट नहीं';

  @override
  String get noAppointmentsSub =>
      'अपनी पहली डॉक्टर विज़िट शेड्यूल करने के लिए नया अपॉइंटमेंट पर टैप करें।';

  @override
  String get newAppointment => 'नया अपॉइंटमेंट';

  @override
  String get todayBadge => 'आज';

  @override
  String get deleteAppointment => 'अपॉइंटमेंट हटाएँ';

  @override
  String deleteAppointmentConfirm(Object name) {
    return '$name के साथ अपॉइंटमेंट हटाएँ?';
  }

  @override
  String get doctorName => 'डॉक्टर का नाम';

  @override
  String get doctorHint => 'जैसे डॉ. शर्मा';

  @override
  String get specialization => 'विशेषज्ञता';

  @override
  String get specializationHint => 'जैसे कार्डियोलॉजिस्ट';

  @override
  String get appointmentDate => 'अपॉइंटमेंट की तारीख';

  @override
  String get appointmentTime => 'अपॉइंटमेंट का समय';

  @override
  String get location => 'स्थान';

  @override
  String get locationHint => 'जैसे सिटी अस्पताल, कमरा 302';

  @override
  String get notesOptional => 'नोट्स (वैकल्पिक)';

  @override
  String get notesHint => 'कोई अतिरिक्त नोट्स...';

  @override
  String get saveAppointment => 'अपॉइंटमेंट सहेजें';

  @override
  String get errorDoctorName => 'कृपया डॉक्टर का नाम दर्ज करें';

  @override
  String get errorLocation => 'कृपया स्थान दर्ज करें';

  @override
  String get appointmentSaved => 'अपॉइंटमेंट सहेजा गया!';

  @override
  String get neverMissDose => 'कभी भी खुराक न छूटें।';

  @override
  String get continueGoogle => 'Google से जारी रखें';

  @override
  String get continueGuest => 'गेस्ट के रूप में जारी रखें';

  @override
  String get termsAgreement =>
      'जारी रखकर, आप हमारी सेवा की शर्तों और\nगोपनीयता नीति से सहमत होते हैं।';

  @override
  String signInFailed(Object error) {
    return 'साइन इन विफल: $error';
  }

  @override
  String get welcome => 'स्वागत है';

  @override
  String get personalizeExperience =>
      'आइए आपके Mediaro अनुभव को व्यक्तिगत बनाएँ।';

  @override
  String get profilePhoto => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get chooseGallery => 'गैलरी से चुनें';

  @override
  String get useGooglePhoto => 'Google फ़ोटो उपयोग करें';

  @override
  String get personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get enterFullName => 'अपना पूरा नाम दर्ज करें';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get age => 'आयु';

  @override
  String get gender => 'लिंग';

  @override
  String get select => 'चुनें';

  @override
  String get profileFor => 'यह प्रोफ़ाइल किसके लिए है?';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguageHint => 'भाषा चुनें';

  @override
  String get timezone => 'समय क्षेत्र';

  @override
  String get detecting => 'पता लगा रहे हैं...';

  @override
  String get autoDetected => 'स्वतः पता चला';

  @override
  String get reminders => 'रिमाइंडर';

  @override
  String get reminderSound => 'रिमाइंडर ध्वनि';

  @override
  String get advanceNotification => 'अग्रिम सूचना';

  @override
  String get atTime => 'समय पर';

  @override
  String get minBefore => 'मिनट पहले';

  @override
  String get snoozeDuration => 'स्नूज़ अवधि';

  @override
  String profileComplete(Object percent) {
    return 'प्रोफ़ाइल $percent% पूर्ण';
  }

  @override
  String get continueToMediaro => 'Mediaro में जारी रखें';

  @override
  String get errorName => 'कृपया अपना नाम दर्ज करें';

  @override
  String get errorAge => 'कृपया अपनी आयु दर्ज करें';

  @override
  String get errorAgeInvalid => 'कृपया वैध आयु दर्ज करें (0-120)';

  @override
  String get errorGender => 'कृपया अपना लिंग चुनें';

  @override
  String errorSavingProfile(Object error) {
    return 'प्रोफ़ाइल सहेजने में त्रुटि: $error';
  }

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get other => 'अन्य';

  @override
  String get preferNotToSay => 'बताना नहीं चाहते';

  @override
  String get myself => 'स्वयं';

  @override
  String get myParent => 'माता/पिता';

  @override
  String get mySpouse => 'जीवनसाथी';

  @override
  String get myChild => 'बच्चा';

  @override
  String get someoneElse => 'कोई और';

  @override
  String get premiumHeader => 'प्रीमियम';

  @override
  String get heroTitle => 'हर खुराक पर\nनज़र रखें।';

  @override
  String get heroSub => 'अधिक नियंत्रण। अधिक आत्मविश्वास।\nबेहतर दवाई प्रबंधन।';

  @override
  String get whyGoPremium => 'प्रीमियम क्यों लें?';

  @override
  String get benefitUnlimitedMeds => 'असीमित दवाइयाँ';

  @override
  String get benefitUnlimitedMedsDesc =>
      'फ्री प्लान की सीमा के बिना अपनी सभी दवाइयाँ प्रबंधित करें।';

  @override
  String get benefitUnlimitedDep => 'असीमित आश्रित';

  @override
  String get benefitUnlimitedDepDesc =>
      'अपने पूरे परिवार के लिए दवाई शेड्यूल प्रबंधित करें।';

  @override
  String get benefitDailyVitals => 'दैनिक वाइटल्स';

  @override
  String get benefitDailyVitalsDesc =>
      'BP, रक्त शर्करा, SpO2 और वज़न ट्रैक करें।';

  @override
  String get benefitAppointments => 'डॉक्टर अपॉइंटमेंट';

  @override
  String get benefitAppointmentsDesc => 'आगामी अपॉइंटमेंट कभी न भूलें।';

  @override
  String get benefitReports => 'हेल्थ रिपोर्ट';

  @override
  String get benefitReportsDesc =>
      'वाइटल्स और पालन के साथ डॉक्टर-रेडी PDF रिपोर्ट बनाएँ।';

  @override
  String get benefitInsights => 'उन्नत अंतर्दृष्टि';

  @override
  String get benefitInsightsDesc => 'समय के साथ अपनी दवाई पालन समझें।';

  @override
  String get benefitAdfree => 'विज्ञापन-मुक्त अनुभव';

  @override
  String get benefitAdfreeDesc => 'विज्ञापनों के बिना Mediaro का उपयोग करें।';

  @override
  String get chooseYourPlan => 'अपना प्लान चुनें';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get monthlyLabel => 'मासिक';

  @override
  String get perYear => '/ वर्ष';

  @override
  String get perMonth => '/ माह';

  @override
  String get bestValue => 'सर्वोत्तम मूल्य';

  @override
  String get save => 'सहेजें';

  @override
  String get cancelAnytime =>
      'कभी भी रद्द करें। आपकी सदस्यता Google Play के माध्यम से सुरक्षित रूप से प्रबंधित होती है।';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get renewalText =>
      'सदस्यता स्वचालित रूप से नवीनीकृत होती है जब तक वर्तमान अवधि के समाप्त होने से कम से कम 24 घंटे पहले ऑटो-रिन्यू बंद नहीं किया जाता।';

  @override
  String continueYearly(Object price) {
    return 'वार्षिक के साथ जारी रखें — ₹$price/वर्ष';
  }

  @override
  String continueMonthly(Object price) {
    return 'मासिक के साथ जारी रखें — ₹$price/माह';
  }

  @override
  String get restorePurchases => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get noPrevious => 'कोई पिछली खरीदारी नहीं मिली।';

  @override
  String get activeBanner => 'Mediaro प्रीमियम';

  @override
  String get activeSub => 'सक्रिय — सभी सुविधाएँ अनलॉक';

  @override
  String get healthReportsTitle => 'हेल्थ रिपोर्ट';

  @override
  String get healthReportsDesc =>
      'अपनी दवाई और वाइटल्स इतिहास से डॉक्टर-रेडी रिपोर्ट बनाएँ।';

  @override
  String get upgradeToPremiumBtn => 'प्रीमियम में अपग्रेड करें';

  @override
  String get generateReport => 'रिपोर्ट बनाएँ';

  @override
  String get noReportsYet => 'अभी तक कोई रिपोर्ट नहीं';

  @override
  String get noReportsSub =>
      'अपने डॉक्टर के साथ साझा करने के लिए अपनी पहली हेल्थ रिपोर्ट बनाएँ।';

  @override
  String couldNotOpen(Object error) {
    return 'रिपोर्ट नहीं खुल सकी: $error';
  }

  @override
  String get generateHealthReport => 'हेल्थ रिपोर्ट बनाएँ';

  @override
  String get profileLabel => 'प्रोफ़ाइल';

  @override
  String get dateRange => 'तारीख सीमा';

  @override
  String get last7Days => 'पिछले 7 दिन';

  @override
  String get last14Days => 'पिछले 14 दिन';

  @override
  String get last30Days => 'पिछले 30 दिन';

  @override
  String get customRange => 'कस्टम रेंज';

  @override
  String get from => 'से';

  @override
  String get to => 'तक';

  @override
  String get includeInReport => 'रिपोर्ट में शामिल करें';

  @override
  String get medicationSummary => 'दवाई सारांश';

  @override
  String get medicationAdherence => 'दवाई पालन';

  @override
  String get vitalSigns => 'वाइटल साइन्स';

  @override
  String get doctorAppointmentsLabel => 'डॉक्टर अपॉइंटमेंट';

  @override
  String get previewReport => 'रिपोर्ट पूर्वावलोकन';

  @override
  String get healthReport => 'हेल्थ रिपोर्ट';

  @override
  String takenOfTotal(Object taken, Object total) {
    return '$total में से $taken खुराकें ली गईं';
  }

  @override
  String get activeMedications => 'अवधि में सक्रिय दवाइयाँ';

  @override
  String get vitalReadings => 'वाइटल रीडिंग्स';

  @override
  String bpSugarSpo2Weight(
    Object bp,
    Object spo2,
    Object sugar,
    Object weight,
  ) {
    return '$bp BP · $sugar शर्करा · $spo2 SpO2 · $weight वज़न';
  }

  @override
  String get doctorVisits => 'अवधि में डॉक्टर विज़िट';

  @override
  String get generating => 'बना रहे हैं...';

  @override
  String get generatePdf => 'PDF बनाएँ';

  @override
  String get reportGenerated => 'रिपोर्ट बन गई';

  @override
  String get reportGeneratedSub => 'आपकी हेल्थ रिपोर्ट सफलतापूर्वक बन गई है।';

  @override
  String get open => 'खोलें';

  @override
  String get share => 'साझा करें';

  @override
  String errorGeneratingReport(Object error) {
    return 'रिपोर्ट बनाने में त्रुटि: $error';
  }

  @override
  String get addMedicineTitle => 'दवाई जोड़ें';

  @override
  String get editMedicineTitle => 'दवाई संपादित करें';

  @override
  String get medicineName => 'दवाई का नाम';

  @override
  String get searchMedicine => 'दवाई खोजें...';

  @override
  String get pleaseEnterName => 'कृपया नाम दर्ज करें';

  @override
  String get combo => 'कॉम्बो';

  @override
  String get typeOfMedicine => 'दवाई का प्रकार';

  @override
  String get doseDaily => 'खुराक (दैनिक)';

  @override
  String get totalDoseLabel => 'कुल खुराक';

  @override
  String get startDate => 'शुरू की तारीख';

  @override
  String get endDate => 'समाप्ति तिथि';

  @override
  String get ongoing => 'जारी';

  @override
  String get setReminder => 'रिमाइंडर सेट करें';

  @override
  String get selectDays => 'दिन चुनें';

  @override
  String get time => 'समय';

  @override
  String get mealRelation => 'भोजन संबंध';

  @override
  String get duringMeal => 'भोजन के दौरान';

  @override
  String get instructionsNotes => 'निर्देश / नोट्स (वैकल्पिक)';

  @override
  String get notesHintMed => 'जैसे, गर्म पानी के साथ लें';

  @override
  String get deleteMedicine => 'दवाई हटाएँ';

  @override
  String deleteMedicineConfirm(Object name) {
    return 'क्या आप वाकई $name को हटाना चाहते हैं? सभी निर्धारित रिमाइंडर हटा दिए जाएँगे।';
  }

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String get saveMedicine => 'दवाई सहेजें';

  @override
  String get errorAlertTime => 'कृपया कम से कम एक अलर्ट समय जोड़ें';

  @override
  String get tablet => 'टैबलेट';

  @override
  String get capsule => 'कैप्सूल';

  @override
  String get syrup => 'सिरप';

  @override
  String get injection => 'इंजेक्शन';

  @override
  String get drops => 'ड्रॉप्स';

  @override
  String get cream => 'क्रीम';

  @override
  String get powder => 'पाउडर';

  @override
  String get otherType => 'अन्य';

  @override
  String get everyDay => 'हर दिन';

  @override
  String get specificDays => 'विशिष्ट दिन';

  @override
  String get unitMl => 'ml';

  @override
  String get unitDrop => 'ड्रॉप';

  @override
  String get unitSpoon => 'चम्मच';

  @override
  String get addDependentTitle => 'आश्रित जोड़ें';

  @override
  String get editDependentTitle => 'आश्रित संपादित करें';

  @override
  String get enterNameHint => 'नाम दर्ज करें';

  @override
  String get pleaseEnterDependentName => 'कृपया नाम दर्ज करें';

  @override
  String get relationship => 'रिश्ता';

  @override
  String get cardiacQuestion => 'कार्डियक पोस्ट-सर्जरी मरीज़?';

  @override
  String get cardiacDesc => 'यह स्पायरोमीटर और वॉक टेस्ट वाइटल्स सक्षम करता है';

  @override
  String get addDependentBtn => 'आश्रित जोड़ें';

  @override
  String get father => 'पिता';

  @override
  String get mother => 'माता';

  @override
  String get spouse => 'जीवनसाथी';

  @override
  String get son => 'पुत्र';

  @override
  String get daughter => 'पुत्री';

  @override
  String get brother => 'भाई';

  @override
  String get sister => 'बहन';

  @override
  String get grandfather => 'दादा/नाना';

  @override
  String get grandmother => 'दादी/नानी';

  @override
  String get dependentOther => 'अन्य';

  @override
  String get timeToTake => 'दवाई लेने का समय है!';

  @override
  String get dontForget => 'समय पर अपनी दवाई लेना न भूलें।';

  @override
  String get stayConsistent => 'नियमित रहें';

  @override
  String get iTakeIt => 'मैं लेता/लेती हूँ';

  @override
  String get alarmSkip => 'छोड़ें';

  @override
  String get snooze10m => 'स्नूज़ (10 मिनट)';

  @override
  String get skipDose => 'खुराक छोड़ें';

  @override
  String skipDoseConfirm(Object name) {
    return 'क्या आप वाकई $name की इस खुराक को छोड़ना चाहते हैं?';
  }

  @override
  String get medications => 'दवाइयाँ';

  @override
  String get appointments => 'अपॉइंटमेंट';

  @override
  String get deleteMedicineLabel => 'दवाई हटाएँ';
}
