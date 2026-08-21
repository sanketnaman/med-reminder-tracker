import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mediaro'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @vitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get vitals;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodNight;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get switchProfile;

  /// No description provided for @addDependent.
  ///
  /// In en, this message translates to:
  /// **'Add Dependent'**
  String get addDependent;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noMedicinesYet.
  ///
  /// In en, this message translates to:
  /// **'No medicines added yet'**
  String get noMedicinesYet;

  /// No description provided for @addFirstMedicineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first medicine and we\'ll remind you.'**
  String get addFirstMedicineSubtitle;

  /// No description provided for @addFirstMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add First Medicine'**
  String get addFirstMedicine;

  /// No description provided for @todaysMedicationProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medication Progress'**
  String get todaysMedicationProgress;

  /// No description provided for @totalDose.
  ///
  /// In en, this message translates to:
  /// **'Total Dose'**
  String get totalDose;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @viewTodaysPlan.
  ///
  /// In en, this message translates to:
  /// **'View Today\'s Plan'**
  String get viewTodaysPlan;

  /// No description provided for @takenStatus.
  ///
  /// In en, this message translates to:
  /// **'Taken ✓'**
  String get takenStatus;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @snoozeDose.
  ///
  /// In en, this message translates to:
  /// **'Snooze Dose'**
  String get snoozeDose;

  /// No description provided for @howLongSnooze.
  ///
  /// In en, this message translates to:
  /// **'How long would you like to snooze this reminder?'**
  String get howLongSnooze;

  /// No description provided for @min10.
  ///
  /// In en, this message translates to:
  /// **'10 Min'**
  String get min10;

  /// No description provided for @min30.
  ///
  /// In en, this message translates to:
  /// **'30 Min'**
  String get min30;

  /// No description provided for @hour1.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get hour1;

  /// Shown after snoozing a dose. {minutes} is the snooze duration.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for {minutes} minutes.'**
  String snoozedFor(Object minutes);

  /// No description provided for @allMedicinesCompleted.
  ///
  /// In en, this message translates to:
  /// **'All medicines completed!'**
  String get allMedicinesCompleted;

  /// No description provided for @allCompletedSub.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed all your scheduled medicines for today.'**
  String get allCompletedSub;

  /// No description provided for @nextMedicine.
  ///
  /// In en, this message translates to:
  /// **'NEXT MEDICINE'**
  String get nextMedicine;

  /// No description provided for @takeNow.
  ///
  /// In en, this message translates to:
  /// **'Take Now'**
  String get takeNow;

  /// No description provided for @markAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get markAsTaken;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get overdue;

  /// No description provided for @alsoScheduled.
  ///
  /// In en, this message translates to:
  /// **'ALSO SCHEDULED'**
  String get alsoScheduled;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @take.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get take;

  /// No description provided for @doctorAppointments.
  ///
  /// In en, this message translates to:
  /// **'Doctor Appointments'**
  String get doctorAppointments;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @scheduleManage.
  ///
  /// In en, this message translates to:
  /// **'Schedule and manage visits'**
  String get scheduleManage;

  /// No description provided for @upgradeToAccess.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to access'**
  String get upgradeToAccess;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @todaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Plan'**
  String get todaysPlan;

  /// No description provided for @noMedicationScheduled.
  ///
  /// In en, this message translates to:
  /// **'No medication scheduled for today.'**
  String get noMedicationScheduled;

  /// No description provided for @addMedicinesWithTimes.
  ///
  /// In en, this message translates to:
  /// **'Add medicines with scheduled times to see them here.'**
  String get addMedicinesWithTimes;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// {limit} is the maximum number of medicines allowed on the free plan.
  ///
  /// In en, this message translates to:
  /// **'Free plan limited to {limit} medicines. Upgrade to Premium.'**
  String freeLimit(Object limit);

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// {name} is the medicine name.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as Taken!'**
  String markedAsTaken(Object name);

  /// No description provided for @todaysVitals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Vitals'**
  String get todaysVitals;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @bloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get bloodSugar;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'SPO2'**
  String get spo2;

  /// No description provided for @spirometer.
  ///
  /// In en, this message translates to:
  /// **'Spirometer'**
  String get spirometer;

  /// No description provided for @walkTest.
  ///
  /// In en, this message translates to:
  /// **'Walk Test'**
  String get walkTest;

  /// No description provided for @logReading.
  ///
  /// In en, this message translates to:
  /// **'Log Reading'**
  String get logReading;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noVitalsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No vitals recorded yet'**
  String get noVitalsRecorded;

  /// No description provided for @tapLogReading.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Log Reading\" to record your first vital.'**
  String get tapLogReading;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @logVitalReading.
  ///
  /// In en, this message translates to:
  /// **'Log Vital Reading'**
  String get logVitalReading;

  /// No description provided for @vitalType.
  ///
  /// In en, this message translates to:
  /// **'Vital Type'**
  String get vitalType;

  /// No description provided for @bp.
  ///
  /// In en, this message translates to:
  /// **'BP'**
  String get bp;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @beforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before Meal'**
  String get beforeMeal;

  /// No description provided for @afterMeal.
  ///
  /// In en, this message translates to:
  /// **'After Meal'**
  String get afterMeal;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic (mmHg)'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (mmHg)'**
  String get diastolic;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get when;

  /// No description provided for @bloodSugarUnit.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar (mg/dL)'**
  String get bloodSugarUnit;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightUnit;

  /// No description provided for @spo2Unit.
  ///
  /// In en, this message translates to:
  /// **'SPO2 (%)'**
  String get spo2Unit;

  /// No description provided for @spirometerUnit.
  ///
  /// In en, this message translates to:
  /// **'Spirometer Reading (L)'**
  String get spirometerUnit;

  /// No description provided for @walkTestUnit.
  ///
  /// In en, this message translates to:
  /// **'Walk Test (steps)'**
  String get walkTestUnit;

  /// No description provided for @saveReading.
  ///
  /// In en, this message translates to:
  /// **'Save Reading'**
  String get saveReading;

  /// No description provided for @deleteReading.
  ///
  /// In en, this message translates to:
  /// **'Delete Reading'**
  String get deleteReading;

  /// {type} is the vital type (e.g. Blood Pressure, Blood Sugar).
  ///
  /// In en, this message translates to:
  /// **'Delete this {type} reading?'**
  String deleteReadingConfirm(Object type);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// {type} is the vital type.
  ///
  /// In en, this message translates to:
  /// **'{type} reading saved!'**
  String readingSaved(Object type);

  /// No description provided for @errorEnterBp.
  ///
  /// In en, this message translates to:
  /// **'Please enter both Systolic and Diastolic values'**
  String get errorEnterBp;

  /// No description provided for @errorEnterSugar.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Blood Sugar value'**
  String get errorEnterSugar;

  /// No description provided for @errorEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Weight value'**
  String get errorEnterWeight;

  /// No description provided for @errorEnterSpo2.
  ///
  /// In en, this message translates to:
  /// **'Please enter an SPO2 value'**
  String get errorEnterSpo2;

  /// No description provided for @errorEnterSpirometer.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Spirometer value'**
  String get errorEnterSpirometer;

  /// No description provided for @errorEnterWalk.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Walk Test value'**
  String get errorEnterWalk;

  /// No description provided for @lastLabel.
  ///
  /// In en, this message translates to:
  /// **'Last:'**
  String get lastLabel;

  /// No description provided for @hintEg.
  ///
  /// In en, this message translates to:
  /// **'e.g.'**
  String get hintEg;

  /// No description provided for @inventoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Inventory Details'**
  String get inventoryDetails;

  /// No description provided for @refillReminderBanner.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder To Alert You When It\'s Time To Refill'**
  String get refillReminderBanner;

  /// No description provided for @emptyCabinet.
  ///
  /// In en, this message translates to:
  /// **'Your medicine cabinet is empty'**
  String get emptyCabinet;

  /// No description provided for @emptyCabinetSub.
  ///
  /// In en, this message translates to:
  /// **'Add medicines from the Home dashboard to track stock.'**
  String get emptyCabinetSub;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out Of Stock'**
  String get outOfStock;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @noStockRemaining.
  ///
  /// In en, this message translates to:
  /// **'No stock remaining'**
  String get noStockRemaining;

  /// {hours} is the approximate number of hours of stock remaining.
  ///
  /// In en, this message translates to:
  /// **'~{hours} hours left'**
  String hoursLeft(Object hours);

  /// No description provided for @dayLeft.
  ///
  /// In en, this message translates to:
  /// **'~1 day left'**
  String get dayLeft;

  /// {days} is the approximate number of days of stock remaining.
  ///
  /// In en, this message translates to:
  /// **'~{days} days left'**
  String daysLeft(Object days);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @refillNow.
  ///
  /// In en, this message translates to:
  /// **'Refill Now'**
  String get refillNow;

  /// {name} is the medicine name.
  ///
  /// In en, this message translates to:
  /// **'Refill {name}'**
  String refillMedicine(Object name);

  /// {qty} is the stock quantity, {unit} is the unit (e.g. tablets).
  ///
  /// In en, this message translates to:
  /// **'Current stock: {qty} {unit}'**
  String currentStock(Object qty, Object unit);

  /// No description provided for @addQuantity.
  ///
  /// In en, this message translates to:
  /// **'Add quantity'**
  String get addQuantity;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// {qty} is quantity, {unit} is the unit, {name} is the medicine name.
  ///
  /// In en, this message translates to:
  /// **'Added {qty} {unit} to {name}'**
  String addedStock(Object name, Object qty, Object unit);

  /// {limit} is the maximum number of medicines on the free plan.
  ///
  /// In en, this message translates to:
  /// **'Free plan limited to {limit} medicines. Upgrade to Premium.'**
  String freeLimitMedicines(Object limit);

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @medicationPerformance.
  ///
  /// In en, this message translates to:
  /// **'Medication Performance'**
  String get medicationPerformance;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your progress will appear here'**
  String get progressEmpty;

  /// No description provided for @progressEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Take your medicines regularly to start building history.'**
  String get progressEmptySub;

  /// No description provided for @setTodaysMedications.
  ///
  /// In en, this message translates to:
  /// **'Set Today\'s Medications'**
  String get setTodaysMedications;

  /// No description provided for @totalDoses.
  ///
  /// In en, this message translates to:
  /// **'Total Doses'**
  String get totalDoses;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'% Complete'**
  String get percentComplete;

  /// No description provided for @doses.
  ///
  /// In en, this message translates to:
  /// **'Doses'**
  String get doses;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @emailGoogleLocked.
  ///
  /// In en, this message translates to:
  /// **'Email is linked to your Google account and cannot be changed.'**
  String get emailGoogleLocked;

  /// No description provided for @cardiacPostSurgery.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Post-Surgery Patient'**
  String get cardiacPostSurgery;

  /// No description provided for @enableSpirometer.
  ///
  /// In en, this message translates to:
  /// **'Enable Spirometer & Walk Test vitals'**
  String get enableSpirometer;

  /// No description provided for @forCardiac.
  ///
  /// In en, this message translates to:
  /// **'For cardiac post-surgery patients'**
  String get forCardiac;

  /// No description provided for @nameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameEmpty;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordOpened.
  ///
  /// In en, this message translates to:
  /// **'Change Password workflow opened.'**
  String get passwordOpened;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get medicationReminders;

  /// No description provided for @missedDoseAlerts.
  ///
  /// In en, this message translates to:
  /// **'Missed Dose Alerts'**
  String get missedDoseAlerts;

  /// No description provided for @refillReminders.
  ///
  /// In en, this message translates to:
  /// **'Refill Reminders'**
  String get refillReminders;

  /// No description provided for @checkPermissions.
  ///
  /// In en, this message translates to:
  /// **'Check/Update Permissions'**
  String get checkPermissions;

  /// No description provided for @permissionsChecked.
  ///
  /// In en, this message translates to:
  /// **'Permissions checked/updated'**
  String get permissionsChecked;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिन्दी)'**
  String get hindi;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? Your progress will be saved.'**
  String get logOutConfirm;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @mediaroPremium.
  ///
  /// In en, this message translates to:
  /// **'Mediaro Premium'**
  String get mediaroPremium;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @unlimitedMedicinesVitals.
  ///
  /// In en, this message translates to:
  /// **'Unlimited medicines & vitals'**
  String get unlimitedMedicinesVitals;

  /// {used} is the number of medicines currently in use, {limit} is the free plan limit.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} medicines used'**
  String medicinesUsed(Object limit, Object used);

  /// No description provided for @switchedToFree.
  ///
  /// In en, this message translates to:
  /// **'Switched to Free plan'**
  String get switchedToFree;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium:'**
  String get upgradeToPremium;

  /// No description provided for @unlimitedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Unlimited medicines'**
  String get unlimitedMedicines;

  /// No description provided for @dailyVitals.
  ///
  /// In en, this message translates to:
  /// **'Daily vitals tracking'**
  String get dailyVitals;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get advancedAnalytics;

  /// No description provided for @healthReports.
  ///
  /// In en, this message translates to:
  /// **'Health Reports'**
  String get healthReports;

  /// No description provided for @legalAndPolicies.
  ///
  /// In en, this message translates to:
  /// **'Legal and Policies'**
  String get legalAndPolicies;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalText.
  ///
  /// In en, this message translates to:
  /// **'This application is a local medication reminder assistant. It does not provide medical diagnostics, medical advice, or therapeutic decisions. All user records are stored strictly offline on your physical device. In case of doubts, consult a certified healthcare professional before making any dosage changes.'**
  String get legalText;

  /// No description provided for @myDependents.
  ///
  /// In en, this message translates to:
  /// **'My Dependents'**
  String get myDependents;

  /// No description provided for @noDependentsYet.
  ///
  /// In en, this message translates to:
  /// **'No dependents added yet'**
  String get noDependentsYet;

  /// No description provided for @doctorAppointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor Appointments'**
  String get doctorAppointmentsTitle;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'upcoming appointment'**
  String get upcomingAppointments;

  /// No description provided for @upcomingAppointmentsPlural.
  ///
  /// In en, this message translates to:
  /// **'upcoming appointments'**
  String get upcomingAppointmentsPlural;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointments;

  /// No description provided for @noAppointmentsSub.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New Appointment\" to schedule your first doctor visit.'**
  String get noAppointmentsSub;

  /// No description provided for @newAppointment.
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get newAppointment;

  /// No description provided for @todayBadge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayBadge;

  /// No description provided for @deleteAppointment.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get deleteAppointment;

  /// {name} is the doctor's name.
  ///
  /// In en, this message translates to:
  /// **'Delete appointment with {name}?'**
  String deleteAppointmentConfirm(Object name);

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name'**
  String get doctorName;

  /// No description provided for @doctorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Smith'**
  String get doctorHint;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @specializationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cardiologist'**
  String get specializationHint;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment Date'**
  String get appointmentDate;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment Time'**
  String get appointmentTime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. City Hospital, Room 302'**
  String get locationHint;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional notes...'**
  String get notesHint;

  /// No description provided for @saveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get saveAppointment;

  /// No description provided for @errorDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter doctor name'**
  String get errorDoctorName;

  /// No description provided for @errorLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter location'**
  String get errorLocation;

  /// No description provided for @appointmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Appointment saved!'**
  String get appointmentSaved;

  /// No description provided for @neverMissDose.
  ///
  /// In en, this message translates to:
  /// **'Never miss a dose.'**
  String get neverMissDose;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @continueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueGuest;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service\nand Privacy Policy.'**
  String get termsAgreement;

  /// {error} is the error message from the sign-in failure.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {error}'**
  String signInFailed(Object error);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize your Mediaro experience.'**
  String get personalizeExperience;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGallery;

  /// No description provided for @useGooglePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Google photo'**
  String get useGooglePhoto;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @profileFor.
  ///
  /// In en, this message translates to:
  /// **'Who is this profile for?'**
  String get profileFor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageHint;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @detecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting...'**
  String get detecting;

  /// No description provided for @autoDetected.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected'**
  String get autoDetected;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reminderSound.
  ///
  /// In en, this message translates to:
  /// **'Reminder sound'**
  String get reminderSound;

  /// No description provided for @advanceNotification.
  ///
  /// In en, this message translates to:
  /// **'Advance notification'**
  String get advanceNotification;

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'At time'**
  String get atTime;

  /// No description provided for @minBefore.
  ///
  /// In en, this message translates to:
  /// **'min before'**
  String get minBefore;

  /// No description provided for @snoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Snooze duration'**
  String get snoozeDuration;

  /// {percent} is the profile completion percentage (0-100).
  ///
  /// In en, this message translates to:
  /// **'Profile {percent}% complete'**
  String profileComplete(Object percent);

  /// No description provided for @continueToMediaro.
  ///
  /// In en, this message translates to:
  /// **'Continue to Mediaro'**
  String get continueToMediaro;

  /// No description provided for @errorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get errorName;

  /// No description provided for @errorAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get errorAge;

  /// No description provided for @errorAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age (0-120)'**
  String get errorAgeInvalid;

  /// No description provided for @errorGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get errorGender;

  /// {error} is the error message from the profile save failure.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(Object error);

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @myself.
  ///
  /// In en, this message translates to:
  /// **'Myself'**
  String get myself;

  /// No description provided for @myParent.
  ///
  /// In en, this message translates to:
  /// **'My Parent'**
  String get myParent;

  /// No description provided for @mySpouse.
  ///
  /// In en, this message translates to:
  /// **'My Spouse'**
  String get mySpouse;

  /// No description provided for @myChild.
  ///
  /// In en, this message translates to:
  /// **'My Child'**
  String get myChild;

  /// No description provided for @someoneElse.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get someoneElse;

  /// No description provided for @premiumHeader.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premiumHeader;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of\nevery dose.'**
  String get heroTitle;

  /// No description provided for @heroSub.
  ///
  /// In en, this message translates to:
  /// **'More control. More confidence.\nBetter medication management.'**
  String get heroSub;

  /// No description provided for @whyGoPremium.
  ///
  /// In en, this message translates to:
  /// **'Why go Premium?'**
  String get whyGoPremium;

  /// No description provided for @benefitUnlimitedMeds.
  ///
  /// In en, this message translates to:
  /// **'Unlimited medicines'**
  String get benefitUnlimitedMeds;

  /// No description provided for @benefitUnlimitedMedsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage all your medications without the Free plan limit.'**
  String get benefitUnlimitedMedsDesc;

  /// No description provided for @benefitUnlimitedDep.
  ///
  /// In en, this message translates to:
  /// **'Unlimited dependents'**
  String get benefitUnlimitedDep;

  /// No description provided for @benefitUnlimitedDepDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage medication schedules for your entire family.'**
  String get benefitUnlimitedDepDesc;

  /// No description provided for @benefitDailyVitals.
  ///
  /// In en, this message translates to:
  /// **'Daily vitals'**
  String get benefitDailyVitals;

  /// No description provided for @benefitDailyVitalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track BP, blood sugar, SpO2 and weight.'**
  String get benefitDailyVitalsDesc;

  /// No description provided for @benefitAppointments.
  ///
  /// In en, this message translates to:
  /// **'Doctor appointments'**
  String get benefitAppointments;

  /// No description provided for @benefitAppointmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Never forget an upcoming appointment.'**
  String get benefitAppointmentsDesc;

  /// No description provided for @benefitReports.
  ///
  /// In en, this message translates to:
  /// **'Health reports'**
  String get benefitReports;

  /// No description provided for @benefitReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate doctor-ready PDF reports with vitals and adherence.'**
  String get benefitReportsDesc;

  /// No description provided for @benefitInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced insights'**
  String get benefitInsights;

  /// No description provided for @benefitInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand your medication adherence over time.'**
  String get benefitInsightsDesc;

  /// No description provided for @benefitAdfree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get benefitAdfree;

  /// No description provided for @benefitAdfreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Mediaro without advertisements.'**
  String get benefitAdfreeDesc;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get chooseYourPlan;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY'**
  String get yearly;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get monthlyLabel;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. Your subscription is managed securely through Google Play.'**
  String get cancelAnytime;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @renewalText.
  ///
  /// In en, this message translates to:
  /// **'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.'**
  String get renewalText;

  /// {price} is the yearly subscription price.
  ///
  /// In en, this message translates to:
  /// **'Continue with Yearly — ₹{price}/year'**
  String continueYearly(Object price);

  /// {price} is the monthly subscription price.
  ///
  /// In en, this message translates to:
  /// **'Continue with Monthly — ₹{price}/month'**
  String continueMonthly(Object price);

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @noPrevious.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get noPrevious;

  /// No description provided for @activeBanner.
  ///
  /// In en, this message translates to:
  /// **'Mediaro Premium'**
  String get activeBanner;

  /// No description provided for @activeSub.
  ///
  /// In en, this message translates to:
  /// **'Active — All features unlocked'**
  String get activeSub;

  /// No description provided for @healthReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Reports'**
  String get healthReportsTitle;

  /// No description provided for @healthReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate doctor-ready reports from your medication and vitals history.'**
  String get healthReportsDesc;

  /// No description provided for @upgradeToPremiumBtn.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumBtn;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @noReportsSub.
  ///
  /// In en, this message translates to:
  /// **'Generate your first health report to share with your doctor.'**
  String get noReportsSub;

  /// {error} is the error message.
  ///
  /// In en, this message translates to:
  /// **'Could not open report: {error}'**
  String couldNotOpen(Object error);

  /// No description provided for @generateHealthReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Health Report'**
  String get generateHealthReport;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last14Days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 Days'**
  String get last14Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @includeInReport.
  ///
  /// In en, this message translates to:
  /// **'Include in Report'**
  String get includeInReport;

  /// No description provided for @medicationSummary.
  ///
  /// In en, this message translates to:
  /// **'Medication Summary'**
  String get medicationSummary;

  /// No description provided for @medicationAdherence.
  ///
  /// In en, this message translates to:
  /// **'Medication Adherence'**
  String get medicationAdherence;

  /// No description provided for @vitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSigns;

  /// No description provided for @doctorAppointmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor Appointments'**
  String get doctorAppointmentsLabel;

  /// No description provided for @previewReport.
  ///
  /// In en, this message translates to:
  /// **'Preview Report'**
  String get previewReport;

  /// No description provided for @healthReport.
  ///
  /// In en, this message translates to:
  /// **'Health Report'**
  String get healthReport;

  /// {taken} is the number of doses taken, {total} is the total scheduled doses.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} doses taken'**
  String takenOfTotal(Object taken, Object total);

  /// No description provided for @activeMedications.
  ///
  /// In en, this message translates to:
  /// **'Active medications in period'**
  String get activeMedications;

  /// No description provided for @vitalReadings.
  ///
  /// In en, this message translates to:
  /// **'Vital Readings'**
  String get vitalReadings;

  /// {bp}, {sugar}, {spo2}, {weight} are counts of each vital type recorded.
  ///
  /// In en, this message translates to:
  /// **'{bp} BP · {sugar} Sugar · {spo2} SpO2 · {weight} Weight'**
  String bpSugarSpo2Weight(Object bp, Object spo2, Object sugar, Object weight);

  /// No description provided for @doctorVisits.
  ///
  /// In en, this message translates to:
  /// **'Doctor visits in period'**
  String get doctorVisits;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report Generated'**
  String get reportGenerated;

  /// No description provided for @reportGeneratedSub.
  ///
  /// In en, this message translates to:
  /// **'Your health report has been generated successfully.'**
  String get reportGeneratedSub;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// {error} is the error message.
  ///
  /// In en, this message translates to:
  /// **'Error generating report: {error}'**
  String errorGeneratingReport(Object error);

  /// No description provided for @addMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicineTitle;

  /// No description provided for @editMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicineTitle;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search medicine...'**
  String get searchMedicine;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @combo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get combo;

  /// No description provided for @typeOfMedicine.
  ///
  /// In en, this message translates to:
  /// **'Type of Medicine'**
  String get typeOfMedicine;

  /// No description provided for @doseDaily.
  ///
  /// In en, this message translates to:
  /// **'Dose (daily)'**
  String get doseDaily;

  /// No description provided for @totalDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Dose'**
  String get totalDoseLabel;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select Days'**
  String get selectDays;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @mealRelation.
  ///
  /// In en, this message translates to:
  /// **'Meal Relation'**
  String get mealRelation;

  /// No description provided for @duringMeal.
  ///
  /// In en, this message translates to:
  /// **'During Meal'**
  String get duringMeal;

  /// No description provided for @instructionsNotes.
  ///
  /// In en, this message translates to:
  /// **'Instructions / Notes (Optional)'**
  String get instructionsNotes;

  /// No description provided for @notesHintMed.
  ///
  /// In en, this message translates to:
  /// **'e.g., Take with warm water'**
  String get notesHintMed;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicine;

  /// {name} is the medicine name.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? All scheduled reminders will be removed.'**
  String deleteMedicineConfirm(Object name);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveMedicine.
  ///
  /// In en, this message translates to:
  /// **'Save Medicine'**
  String get saveMedicine;

  /// No description provided for @errorAlertTime.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one alert time'**
  String get errorAlertTime;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get syrup;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injection;

  /// No description provided for @drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @cream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get cream;

  /// No description provided for @powder.
  ///
  /// In en, this message translates to:
  /// **'Powder'**
  String get powder;

  /// No description provided for @otherType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherType;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @specificDays.
  ///
  /// In en, this message translates to:
  /// **'Specific days'**
  String get specificDays;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get unitDrop;

  /// No description provided for @unitSpoon.
  ///
  /// In en, this message translates to:
  /// **'Spoon'**
  String get unitSpoon;

  /// No description provided for @addDependentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Dependent'**
  String get addDependentTitle;

  /// No description provided for @editDependentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Dependent'**
  String get editDependentTitle;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterNameHint;

  /// No description provided for @pleaseEnterDependentName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterDependentName;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @cardiacQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Post-Surgery Patient?'**
  String get cardiacQuestion;

  /// No description provided for @cardiacDesc.
  ///
  /// In en, this message translates to:
  /// **'This enables Spirometer and Walk Test vitals'**
  String get cardiacDesc;

  /// No description provided for @addDependentBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Dependent'**
  String get addDependentBtn;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse;

  /// No description provided for @son.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get son;

  /// No description provided for @daughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get daughter;

  /// No description provided for @brother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get brother;

  /// No description provided for @sister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get sister;

  /// No description provided for @grandfather.
  ///
  /// In en, this message translates to:
  /// **'Grandfather'**
  String get grandfather;

  /// No description provided for @grandmother.
  ///
  /// In en, this message translates to:
  /// **'Grandmother'**
  String get grandmother;

  /// No description provided for @dependentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dependentOther;

  /// No description provided for @timeToTake.
  ///
  /// In en, this message translates to:
  /// **'Time to Take Your Medicine!'**
  String get timeToTake;

  /// No description provided for @dontForget.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to take your medicine on time.'**
  String get dontForget;

  /// No description provided for @stayConsistent.
  ///
  /// In en, this message translates to:
  /// **'Stay Consistent'**
  String get stayConsistent;

  /// No description provided for @iTakeIt.
  ///
  /// In en, this message translates to:
  /// **'I Take It'**
  String get iTakeIt;

  /// No description provided for @alarmSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get alarmSkip;

  /// No description provided for @snooze10m.
  ///
  /// In en, this message translates to:
  /// **'Snooze (10m)'**
  String get snooze10m;

  /// No description provided for @skipDose.
  ///
  /// In en, this message translates to:
  /// **'Skip Dose'**
  String get skipDose;

  /// {name} is the medicine name.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this dose of {name} as skipped?'**
  String skipDoseConfirm(Object name);

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @deleteMedicineLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicineLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
