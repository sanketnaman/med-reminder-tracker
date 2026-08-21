// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mediaro';

  @override
  String get home => 'Home';

  @override
  String get medicines => 'Medicines';

  @override
  String get medicine => 'Medicine';

  @override
  String get inventory => 'Inventory';

  @override
  String get progress => 'Progress';

  @override
  String get vitals => 'Vitals';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good';

  @override
  String get goodAfternoon => 'Good';

  @override
  String get goodEvening => 'Good';

  @override
  String get goodNight => 'Good';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get addDependent => 'Add Dependent';

  @override
  String get notifications => 'Notifications';

  @override
  String get noMedicinesYet => 'No medicines added yet';

  @override
  String get addFirstMedicineSubtitle =>
      'Add your first medicine and we\'ll remind you.';

  @override
  String get addFirstMedicine => 'Add First Medicine';

  @override
  String get todaysMedicationProgress => 'Today\'s Medication Progress';

  @override
  String get totalDose => 'Total Dose';

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String get viewTodaysPlan => 'View Today\'s Plan';

  @override
  String get takenStatus => 'Taken ✓';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get snoozeDose => 'Snooze Dose';

  @override
  String get howLongSnooze =>
      'How long would you like to snooze this reminder?';

  @override
  String get min10 => '10 Min';

  @override
  String get min30 => '30 Min';

  @override
  String get hour1 => '1 Hour';

  @override
  String snoozedFor(Object minutes) {
    return 'Snoozed for $minutes minutes.';
  }

  @override
  String get allMedicinesCompleted => 'All medicines completed!';

  @override
  String get allCompletedSub =>
      'You\'ve completed all your scheduled medicines for today.';

  @override
  String get nextMedicine => 'NEXT MEDICINE';

  @override
  String get takeNow => 'Take Now';

  @override
  String get markAsTaken => 'Mark as Taken';

  @override
  String get snooze => 'Snooze';

  @override
  String get overdue => 'OVERDUE';

  @override
  String get alsoScheduled => 'ALSO SCHEDULED';

  @override
  String get more => 'more';

  @override
  String get take => 'Take';

  @override
  String get doctorAppointments => 'Doctor Appointments';

  @override
  String get pro => 'PRO';

  @override
  String get scheduleManage => 'Schedule and manage visits';

  @override
  String get upgradeToAccess => 'Upgrade to Premium to access';

  @override
  String get self => 'Self';

  @override
  String get close => 'Close';

  @override
  String get todaysPlan => 'Today\'s Plan';

  @override
  String get noMedicationScheduled => 'No medication scheduled for today.';

  @override
  String get addMedicinesWithTimes =>
      'Add medicines with scheduled times to see them here.';

  @override
  String get left => 'left';

  @override
  String freeLimit(Object limit) {
    return 'Free plan limited to $limit medicines. Upgrade to Premium.';
  }

  @override
  String get upgrade => 'Upgrade';

  @override
  String markedAsTaken(Object name) {
    return '$name marked as Taken!';
  }

  @override
  String get todaysVitals => 'Today\'s Vitals';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get bloodSugar => 'Blood Sugar';

  @override
  String get weight => 'Weight';

  @override
  String get spo2 => 'SPO2';

  @override
  String get spirometer => 'Spirometer';

  @override
  String get walkTest => 'Walk Test';

  @override
  String get logReading => 'Log Reading';

  @override
  String get history => 'History';

  @override
  String get noVitalsRecorded => 'No vitals recorded yet';

  @override
  String get tapLogReading => 'Tap \"Log Reading\" to record your first vital.';

  @override
  String get today => 'Today';

  @override
  String get logVitalReading => 'Log Vital Reading';

  @override
  String get vitalType => 'Vital Type';

  @override
  String get bp => 'BP';

  @override
  String get sugar => 'Sugar';

  @override
  String get beforeMeal => 'Before Meal';

  @override
  String get afterMeal => 'After Meal';

  @override
  String get systolic => 'Systolic (mmHg)';

  @override
  String get diastolic => 'Diastolic (mmHg)';

  @override
  String get when => 'When?';

  @override
  String get bloodSugarUnit => 'Blood Sugar (mg/dL)';

  @override
  String get weightUnit => 'Weight (kg)';

  @override
  String get spo2Unit => 'SPO2 (%)';

  @override
  String get spirometerUnit => 'Spirometer Reading (L)';

  @override
  String get walkTestUnit => 'Walk Test (steps)';

  @override
  String get saveReading => 'Save Reading';

  @override
  String get deleteReading => 'Delete Reading';

  @override
  String deleteReadingConfirm(Object type) {
    return 'Delete this $type reading?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String readingSaved(Object type) {
    return '$type reading saved!';
  }

  @override
  String get errorEnterBp => 'Please enter both Systolic and Diastolic values';

  @override
  String get errorEnterSugar => 'Please enter a Blood Sugar value';

  @override
  String get errorEnterWeight => 'Please enter a Weight value';

  @override
  String get errorEnterSpo2 => 'Please enter an SPO2 value';

  @override
  String get errorEnterSpirometer => 'Please enter a Spirometer value';

  @override
  String get errorEnterWalk => 'Please enter a Walk Test value';

  @override
  String get lastLabel => 'Last:';

  @override
  String get hintEg => 'e.g.';

  @override
  String get inventoryDetails => 'Inventory Details';

  @override
  String get refillReminderBanner =>
      'Set Reminder To Alert You When It\'s Time To Refill';

  @override
  String get emptyCabinet => 'Your medicine cabinet is empty';

  @override
  String get emptyCabinetSub =>
      'Add medicines from the Home dashboard to track stock.';

  @override
  String get outOfStock => 'Out Of Stock';

  @override
  String get critical => 'Critical';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get noStockRemaining => 'No stock remaining';

  @override
  String hoursLeft(Object hours) {
    return '~$hours hours left';
  }

  @override
  String get dayLeft => '~1 day left';

  @override
  String daysLeft(Object days) {
    return '~$days days left';
  }

  @override
  String get remaining => 'remaining';

  @override
  String get edit => 'Edit';

  @override
  String get refillNow => 'Refill Now';

  @override
  String refillMedicine(Object name) {
    return 'Refill $name';
  }

  @override
  String currentStock(Object qty, Object unit) {
    return 'Current stock: $qty $unit';
  }

  @override
  String get addQuantity => 'Add quantity';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get pleaseEnterQuantity => 'Please enter a quantity';

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get addStock => 'Add Stock';

  @override
  String addedStock(Object name, Object qty, Object unit) {
    return 'Added $qty $unit to $name';
  }

  @override
  String freeLimitMedicines(Object limit) {
    return 'Free plan limited to $limit medicines. Upgrade to Premium.';
  }

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get medicationPerformance => 'Medication Performance';

  @override
  String get progressEmpty => 'Your progress will appear here';

  @override
  String get progressEmptySub =>
      'Take your medicines regularly to start building history.';

  @override
  String get setTodaysMedications => 'Set Today\'s Medications';

  @override
  String get totalDoses => 'Total Doses';

  @override
  String get percentComplete => '% Complete';

  @override
  String get doses => 'Doses';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get emailGoogleLocked =>
      'Email is linked to your Google account and cannot be changed.';

  @override
  String get cardiacPostSurgery => 'Cardiac Post-Surgery Patient';

  @override
  String get enableSpirometer => 'Enable Spirometer & Walk Test vitals';

  @override
  String get forCardiac => 'For cardiac post-surgery patients';

  @override
  String get nameEmpty => 'Name cannot be empty';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get general => 'General';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordOpened => 'Change Password workflow opened.';

  @override
  String get languageLabel => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get medicationReminders => 'Medication Reminders';

  @override
  String get missedDoseAlerts => 'Missed Dose Alerts';

  @override
  String get refillReminders => 'Refill Reminders';

  @override
  String get checkPermissions => 'Check/Update Permissions';

  @override
  String get permissionsChecked => 'Permissions checked/updated';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi (हिन्दी)';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirm =>
      'Are you sure you want to log out? Your progress will be saved.';

  @override
  String get subscription => 'Subscription';

  @override
  String get mediaroPremium => 'Mediaro Premium';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get unlimitedMedicinesVitals => 'Unlimited medicines & vitals';

  @override
  String medicinesUsed(Object limit, Object used) {
    return '$used of $limit medicines used';
  }

  @override
  String get switchedToFree => 'Switched to Free plan';

  @override
  String get upgradeToPremium => 'Upgrade to Premium:';

  @override
  String get unlimitedMedicines => 'Unlimited medicines';

  @override
  String get dailyVitals => 'Daily vitals tracking';

  @override
  String get advancedAnalytics => 'Advanced analytics';

  @override
  String get healthReports => 'Health Reports';

  @override
  String get legalAndPolicies => 'Legal and Policies';

  @override
  String get legalPrivacyPolicy => 'Legal & Privacy Policy';

  @override
  String get legalText =>
      'This application is a local medication reminder assistant. It does not provide medical diagnostics, medical advice, or therapeutic decisions. All user records are stored strictly offline on your physical device. In case of doubts, consult a certified healthcare professional before making any dosage changes.';

  @override
  String get myDependents => 'My Dependents';

  @override
  String get noDependentsYet => 'No dependents added yet';

  @override
  String get doctorAppointmentsTitle => 'Doctor Appointments';

  @override
  String get upcomingAppointments => 'upcoming appointment';

  @override
  String get upcomingAppointmentsPlural => 'upcoming appointments';

  @override
  String get noAppointments => 'No appointments yet';

  @override
  String get noAppointmentsSub =>
      'Tap \"New Appointment\" to schedule your first doctor visit.';

  @override
  String get newAppointment => 'New Appointment';

  @override
  String get todayBadge => 'TODAY';

  @override
  String get deleteAppointment => 'Delete Appointment';

  @override
  String deleteAppointmentConfirm(Object name) {
    return 'Delete appointment with $name?';
  }

  @override
  String get doctorName => 'Doctor Name';

  @override
  String get doctorHint => 'e.g. Dr. Smith';

  @override
  String get specialization => 'Specialization';

  @override
  String get specializationHint => 'e.g. Cardiologist';

  @override
  String get appointmentDate => 'Appointment Date';

  @override
  String get appointmentTime => 'Appointment Time';

  @override
  String get location => 'Location';

  @override
  String get locationHint => 'e.g. City Hospital, Room 302';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get notesHint => 'Any additional notes...';

  @override
  String get saveAppointment => 'Save Appointment';

  @override
  String get errorDoctorName => 'Please enter doctor name';

  @override
  String get errorLocation => 'Please enter location';

  @override
  String get appointmentSaved => 'Appointment saved!';

  @override
  String get neverMissDose => 'Never miss a dose.';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get continueGuest => 'Continue as Guest';

  @override
  String get termsAgreement =>
      'By continuing, you agree to our Terms of Service\nand Privacy Policy.';

  @override
  String signInFailed(Object error) {
    return 'Sign in failed: $error';
  }

  @override
  String get welcome => 'Welcome';

  @override
  String get personalizeExperience =>
      'Let\'s personalize your Mediaro experience.';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get useGooglePhoto => 'Use Google photo';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get emailAddress => 'Email address';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get select => 'Select';

  @override
  String get profileFor => 'Who is this profile for?';

  @override
  String get language => 'Language';

  @override
  String get selectLanguageHint => 'Select language';

  @override
  String get timezone => 'Timezone';

  @override
  String get detecting => 'Detecting...';

  @override
  String get autoDetected => 'Auto-detected';

  @override
  String get reminders => 'Reminders';

  @override
  String get reminderSound => 'Reminder sound';

  @override
  String get advanceNotification => 'Advance notification';

  @override
  String get atTime => 'At time';

  @override
  String get minBefore => 'min before';

  @override
  String get snoozeDuration => 'Snooze duration';

  @override
  String profileComplete(Object percent) {
    return 'Profile $percent% complete';
  }

  @override
  String get continueToMediaro => 'Continue to Mediaro';

  @override
  String get errorName => 'Please enter your name';

  @override
  String get errorAge => 'Please enter your age';

  @override
  String get errorAgeInvalid => 'Please enter a valid age (0-120)';

  @override
  String get errorGender => 'Please select your gender';

  @override
  String errorSavingProfile(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get preferNotToSay => 'Prefer not to say';

  @override
  String get myself => 'Myself';

  @override
  String get myParent => 'My Parent';

  @override
  String get mySpouse => 'My Spouse';

  @override
  String get myChild => 'My Child';

  @override
  String get someoneElse => 'Someone else';

  @override
  String get premiumHeader => 'PREMIUM';

  @override
  String get heroTitle => 'Stay on top of\nevery dose.';

  @override
  String get heroSub =>
      'More control. More confidence.\nBetter medication management.';

  @override
  String get whyGoPremium => 'Why go Premium?';

  @override
  String get benefitUnlimitedMeds => 'Unlimited medicines';

  @override
  String get benefitUnlimitedMedsDesc =>
      'Manage all your medications without the Free plan limit.';

  @override
  String get benefitUnlimitedDep => 'Unlimited dependents';

  @override
  String get benefitUnlimitedDepDesc =>
      'Manage medication schedules for your entire family.';

  @override
  String get benefitDailyVitals => 'Daily vitals';

  @override
  String get benefitDailyVitalsDesc =>
      'Track BP, blood sugar, SpO2 and weight.';

  @override
  String get benefitAppointments => 'Doctor appointments';

  @override
  String get benefitAppointmentsDesc => 'Never forget an upcoming appointment.';

  @override
  String get benefitReports => 'Health reports';

  @override
  String get benefitReportsDesc =>
      'Generate doctor-ready PDF reports with vitals and adherence.';

  @override
  String get benefitInsights => 'Advanced insights';

  @override
  String get benefitInsightsDesc =>
      'Understand your medication adherence over time.';

  @override
  String get benefitAdfree => 'Ad-free experience';

  @override
  String get benefitAdfreeDesc => 'Use Mediaro without advertisements.';

  @override
  String get chooseYourPlan => 'Choose your plan';

  @override
  String get yearly => 'YEARLY';

  @override
  String get monthlyLabel => 'MONTHLY';

  @override
  String get perYear => '/ year';

  @override
  String get perMonth => '/ month';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get save => 'SAVE';

  @override
  String get cancelAnytime =>
      'Cancel anytime. Your subscription is managed securely through Google Play.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get renewalText =>
      'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.';

  @override
  String continueYearly(Object price) {
    return 'Continue with Yearly — ₹$price/year';
  }

  @override
  String continueMonthly(Object price) {
    return 'Continue with Monthly — ₹$price/month';
  }

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get noPrevious => 'No previous purchases found.';

  @override
  String get activeBanner => 'Mediaro Premium';

  @override
  String get activeSub => 'Active — All features unlocked';

  @override
  String get healthReportsTitle => 'Health Reports';

  @override
  String get healthReportsDesc =>
      'Generate doctor-ready reports from your medication and vitals history.';

  @override
  String get upgradeToPremiumBtn => 'Upgrade to Premium';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get noReportsSub =>
      'Generate your first health report to share with your doctor.';

  @override
  String couldNotOpen(Object error) {
    return 'Could not open report: $error';
  }

  @override
  String get generateHealthReport => 'Generate Health Report';

  @override
  String get profileLabel => 'Profile';

  @override
  String get dateRange => 'Date Range';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last14Days => 'Last 14 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get customRange => 'Custom Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get includeInReport => 'Include in Report';

  @override
  String get medicationSummary => 'Medication Summary';

  @override
  String get medicationAdherence => 'Medication Adherence';

  @override
  String get vitalSigns => 'Vital Signs';

  @override
  String get doctorAppointmentsLabel => 'Doctor Appointments';

  @override
  String get previewReport => 'Preview Report';

  @override
  String get healthReport => 'Health Report';

  @override
  String takenOfTotal(Object taken, Object total) {
    return '$taken of $total doses taken';
  }

  @override
  String get activeMedications => 'Active medications in period';

  @override
  String get vitalReadings => 'Vital Readings';

  @override
  String bpSugarSpo2Weight(
    Object bp,
    Object spo2,
    Object sugar,
    Object weight,
  ) {
    return '$bp BP · $sugar Sugar · $spo2 SpO2 · $weight Weight';
  }

  @override
  String get doctorVisits => 'Doctor visits in period';

  @override
  String get generating => 'Generating...';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get reportGenerated => 'Report Generated';

  @override
  String get reportGeneratedSub =>
      'Your health report has been generated successfully.';

  @override
  String get open => 'Open';

  @override
  String get share => 'Share';

  @override
  String errorGeneratingReport(Object error) {
    return 'Error generating report: $error';
  }

  @override
  String get addMedicineTitle => 'Add Medicine';

  @override
  String get editMedicineTitle => 'Edit Medicine';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get searchMedicine => 'Search medicine...';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get combo => 'Combo';

  @override
  String get typeOfMedicine => 'Type of Medicine';

  @override
  String get doseDaily => 'Dose (daily)';

  @override
  String get totalDoseLabel => 'Total Dose';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get selectDays => 'Select Days';

  @override
  String get time => 'Time';

  @override
  String get mealRelation => 'Meal Relation';

  @override
  String get duringMeal => 'During Meal';

  @override
  String get instructionsNotes => 'Instructions / Notes (Optional)';

  @override
  String get notesHintMed => 'e.g., Take with warm water';

  @override
  String get deleteMedicine => 'Delete Medicine';

  @override
  String deleteMedicineConfirm(Object name) {
    return 'Are you sure you want to delete $name? All scheduled reminders will be removed.';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveMedicine => 'Save Medicine';

  @override
  String get errorAlertTime => 'Please add at least one alert time';

  @override
  String get tablet => 'Tablet';

  @override
  String get capsule => 'Capsule';

  @override
  String get syrup => 'Syrup';

  @override
  String get injection => 'Injection';

  @override
  String get drops => 'Drops';

  @override
  String get cream => 'Cream';

  @override
  String get powder => 'Powder';

  @override
  String get otherType => 'Other';

  @override
  String get everyDay => 'Every day';

  @override
  String get specificDays => 'Specific days';

  @override
  String get unitMl => 'ml';

  @override
  String get unitDrop => 'Drop';

  @override
  String get unitSpoon => 'Spoon';

  @override
  String get addDependentTitle => 'Add Dependent';

  @override
  String get editDependentTitle => 'Edit Dependent';

  @override
  String get enterNameHint => 'Enter name';

  @override
  String get pleaseEnterDependentName => 'Please enter a name';

  @override
  String get relationship => 'Relationship';

  @override
  String get cardiacQuestion => 'Cardiac Post-Surgery Patient?';

  @override
  String get cardiacDesc => 'This enables Spirometer and Walk Test vitals';

  @override
  String get addDependentBtn => 'Add Dependent';

  @override
  String get father => 'Father';

  @override
  String get mother => 'Mother';

  @override
  String get spouse => 'Spouse';

  @override
  String get son => 'Son';

  @override
  String get daughter => 'Daughter';

  @override
  String get brother => 'Brother';

  @override
  String get sister => 'Sister';

  @override
  String get grandfather => 'Grandfather';

  @override
  String get grandmother => 'Grandmother';

  @override
  String get dependentOther => 'Other';

  @override
  String get timeToTake => 'Time to Take Your Medicine!';

  @override
  String get dontForget => 'Don\'t forget to take your medicine on time.';

  @override
  String get stayConsistent => 'Stay Consistent';

  @override
  String get iTakeIt => 'I Take It';

  @override
  String get alarmSkip => 'Skip';

  @override
  String get snooze10m => 'Snooze (10m)';

  @override
  String get skipDose => 'Skip Dose';

  @override
  String skipDoseConfirm(Object name) {
    return 'Are you sure you want to mark this dose of $name as skipped?';
  }

  @override
  String get medications => 'Medications';

  @override
  String get appointments => 'Appointments';

  @override
  String get deleteMedicineLabel => 'Delete Medicine';
}
