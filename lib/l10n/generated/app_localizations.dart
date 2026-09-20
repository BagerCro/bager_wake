import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In hr, this message translates to:
  /// **'BagerWake'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In hr, this message translates to:
  /// **'Pregled'**
  String get navDashboard;

  /// No description provided for @navTest.
  ///
  /// In hr, this message translates to:
  /// **'Test'**
  String get navTest;

  /// No description provided for @navFixGuide.
  ///
  /// In hr, this message translates to:
  /// **'Vodič'**
  String get navFixGuide;

  /// No description provided for @navHistory.
  ///
  /// In hr, this message translates to:
  /// **'Povijest'**
  String get navHistory;

  /// No description provided for @navAbout.
  ///
  /// In hr, this message translates to:
  /// **'O aplikaciji'**
  String get navAbout;

  /// No description provided for @navBulkFix.
  ///
  /// In hr, this message translates to:
  /// **'Popravi sve'**
  String get navBulkFix;

  /// No description provided for @commonRetry.
  ///
  /// In hr, this message translates to:
  /// **'Pokušaj ponovno'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In hr, this message translates to:
  /// **'Odustani'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In hr, this message translates to:
  /// **'Zatvori'**
  String get commonClose;

  /// No description provided for @commonOpenSettings.
  ///
  /// In hr, this message translates to:
  /// **'Otvori postavke'**
  String get commonOpenSettings;

  /// No description provided for @commonLoading.
  ///
  /// In hr, this message translates to:
  /// **'Učitavanje…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In hr, this message translates to:
  /// **'Nešto je pošlo po zlu.'**
  String get commonError;

  /// No description provided for @commonUnknown.
  ///
  /// In hr, this message translates to:
  /// **'Nepoznato'**
  String get commonUnknown;

  /// No description provided for @statusOk.
  ///
  /// In hr, this message translates to:
  /// **'U redu'**
  String get statusOk;

  /// No description provided for @statusWarning.
  ///
  /// In hr, this message translates to:
  /// **'Upozorenje'**
  String get statusWarning;

  /// No description provided for @statusProblem.
  ///
  /// In hr, this message translates to:
  /// **'Problem'**
  String get statusProblem;

  /// No description provided for @statusUnavailable.
  ///
  /// In hr, this message translates to:
  /// **'Ne može se provjeriti'**
  String get statusUnavailable;

  /// No description provided for @unavailableReasonLabel.
  ///
  /// In hr, this message translates to:
  /// **'Razlog'**
  String get unavailableReasonLabel;

  /// No description provided for @unavailableReasonFallback.
  ///
  /// In hr, this message translates to:
  /// **'Aplikacija nije dobila razlog od sustava.'**
  String get unavailableReasonFallback;

  /// No description provided for @dashboardTitle.
  ///
  /// In hr, this message translates to:
  /// **'Pregled'**
  String get dashboardTitle;

  /// No description provided for @dashboardDeviceSubtitle.
  ///
  /// In hr, this message translates to:
  /// **'Android {release} · API {sdk}'**
  String dashboardDeviceSubtitle(String release, int sdk);

  /// No description provided for @dashboardLoadError.
  ///
  /// In hr, this message translates to:
  /// **'Nisam uspio pročitati stanje uređaja. Provjeri je li aplikaciji dano dopuštenje i pokušaj ponovno.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardUnknownDevice.
  ///
  /// In hr, this message translates to:
  /// **'Nepoznat uređaj'**
  String get dashboardUnknownDevice;

  /// No description provided for @dashboardNotifPermButton.
  ///
  /// In hr, this message translates to:
  /// **'Zatraži dopuštenje'**
  String get dashboardNotifPermButton;

  /// No description provided for @diagBatteryOptimizationTitle.
  ///
  /// In hr, this message translates to:
  /// **'Optimizacija baterije'**
  String get diagBatteryOptimizationTitle;

  /// No description provided for @diagBatteryOptimizationDesc.
  ///
  /// In hr, this message translates to:
  /// **'Ako je aplikacija pod \'optimizacijom baterije\', sustav joj gasi pozadinski rad kad je ne koristiš – notifikacije i alarmi mogu kasniti ili uopće ne stići.'**
  String get diagBatteryOptimizationDesc;

  /// No description provided for @diagNotificationsEnabledTitle.
  ///
  /// In hr, this message translates to:
  /// **'Dopuštenje za notifikacije'**
  String get diagNotificationsEnabledTitle;

  /// No description provided for @diagNotificationsEnabledDesc.
  ///
  /// In hr, this message translates to:
  /// **'Bez ovog dopuštenja sustav uopće ne prikazuje notifikacije aplikacije, bez obzira na sva ostala podešavanja.'**
  String get diagNotificationsEnabledDesc;

  /// No description provided for @diagExactAlarmPermissionTitle.
  ///
  /// In hr, this message translates to:
  /// **'Dopuštenje za točne alarme'**
  String get diagExactAlarmPermissionTitle;

  /// No description provided for @diagExactAlarmPermissionDesc.
  ///
  /// In hr, this message translates to:
  /// **'Bez ovog dopuštenja Android smije alarm pomaknuti kasnije umjesto da zazvoni točno kad je zakazan.'**
  String get diagExactAlarmPermissionDesc;

  /// No description provided for @diagBackgroundRestrictedTitle.
  ///
  /// In hr, this message translates to:
  /// **'Ograničen rad u pozadini'**
  String get diagBackgroundRestrictedTitle;

  /// No description provided for @diagBackgroundRestrictedDesc.
  ///
  /// In hr, this message translates to:
  /// **'Kad je ovo uključeno, sustav gotovo potpuno blokira rad aplikacije dok je ne gledaš na ekranu – notifikacije obično uopće ne stignu.'**
  String get diagBackgroundRestrictedDesc;

  /// No description provided for @diagStandbyBucketTitle.
  ///
  /// In hr, this message translates to:
  /// **'Skupina aktivnosti (App Standby)'**
  String get diagStandbyBucketTitle;

  /// No description provided for @diagStandbyBucketDesc.
  ///
  /// In hr, this message translates to:
  /// **'Android svrstava aplikacije u skupine prema tome koliko ih koristiš. U lošijoj skupini dobivaš manje prilika za pozadinski rad, pa notifikacije kasne.'**
  String get diagStandbyBucketDesc;

  /// No description provided for @diagDataSaverTitle.
  ///
  /// In hr, this message translates to:
  /// **'Štednja podataka'**
  String get diagDataSaverTitle;

  /// No description provided for @diagDataSaverDesc.
  ///
  /// In hr, this message translates to:
  /// **'Kad je uključena, aplikacije u pozadini ne smiju koristiti mobilni internet – poruke i sinkronizacija čekaju dok ručno ne otvoriš aplikaciju.'**
  String get diagDataSaverDesc;

  /// No description provided for @diagPowerSaveModeTitle.
  ///
  /// In hr, this message translates to:
  /// **'Način uštede baterije'**
  String get diagPowerSaveModeTitle;

  /// No description provided for @diagPowerSaveModeDesc.
  ///
  /// In hr, this message translates to:
  /// **'Ovaj način dodatno guši pozadinski rad i odgađa alarme i notifikacije dok je uključen, kako bi se produžilo trajanje baterije.'**
  String get diagPowerSaveModeDesc;

  /// No description provided for @diagDozeStateTitle.
  ///
  /// In hr, this message translates to:
  /// **'Doze (stanje mirovanja)'**
  String get diagDozeStateTitle;

  /// No description provided for @diagDozeStateDesc.
  ///
  /// In hr, this message translates to:
  /// **'Kad telefon duže vrijeme miruje bez dodira, Android periodično \'uspavljuje\' sve aplikacije – notifikacije se grupiraju i stižu u paketima umjesto odmah.'**
  String get diagDozeStateDesc;

  /// No description provided for @testTitle.
  ///
  /// In hr, this message translates to:
  /// **'Test dostave'**
  String get testTitle;

  /// No description provided for @testWindowLabel.
  ///
  /// In hr, this message translates to:
  /// **'Trajanje testa'**
  String get testWindowLabel;

  /// No description provided for @testWindow15.
  ///
  /// In hr, this message translates to:
  /// **'15 min'**
  String get testWindow15;

  /// No description provided for @testWindow30.
  ///
  /// In hr, this message translates to:
  /// **'30 min'**
  String get testWindow30;

  /// No description provided for @testWindow60.
  ///
  /// In hr, this message translates to:
  /// **'60 min'**
  String get testWindow60;

  /// No description provided for @testPreflightTitle.
  ///
  /// In hr, this message translates to:
  /// **'Prije nego počneš'**
  String get testPreflightTitle;

  /// No description provided for @testPreflightBody.
  ///
  /// In hr, this message translates to:
  /// **'Zaključaj ekran, ne otvaraj ovu aplikaciju i ostavi telefon na miru dok test traje. Android mora povjerovati da telefon miruje da bi uopće primijenio ograničenja koja testiramo – ako diraš telefon, rezultat neće biti pouzdano očitanje. Tri provjere su namjerno razmaknute kroz test, a ne sve na kraju: najjača provjera budi telefon i time bi spasila slabije, pa bi rezultat ispao bolji nego što stvarno jest. Zato će notifikacije stizati jedna po jedna.'**
  String get testPreflightBody;

  /// No description provided for @testStartButton.
  ///
  /// In hr, this message translates to:
  /// **'Pokreni test'**
  String get testStartButton;

  /// No description provided for @testNeedPermissions.
  ///
  /// In hr, this message translates to:
  /// **'Nedostaju dopuštenja potrebna za test.'**
  String get testNeedPermissions;

  /// No description provided for @testGoToDashboard.
  ///
  /// In hr, this message translates to:
  /// **'Idi na Pregled'**
  String get testGoToDashboard;

  /// No description provided for @testRunningTitle.
  ///
  /// In hr, this message translates to:
  /// **'Test u tijeku'**
  String get testRunningTitle;

  /// No description provided for @testTimeRemaining.
  ///
  /// In hr, this message translates to:
  /// **'Preostalo vrijeme: {time}'**
  String testTimeRemaining(String time);

  /// No description provided for @testCancelButton.
  ///
  /// In hr, this message translates to:
  /// **'Prekini test'**
  String get testCancelButton;

  /// No description provided for @testResultsTitle.
  ///
  /// In hr, this message translates to:
  /// **'Rezultati testa'**
  String get testResultsTitle;

  /// No description provided for @testDirtyResultBanner.
  ///
  /// In hr, this message translates to:
  /// **'Ovo NIJE čisto očitanje.'**
  String get testDirtyResultBanner;

  /// No description provided for @testScreenUnlocked.
  ///
  /// In hr, this message translates to:
  /// **'Ekran je bio otključan tijekom testa.'**
  String get testScreenUnlocked;

  /// No description provided for @testScreenUnlockedUnknown.
  ///
  /// In hr, this message translates to:
  /// **'Ne može se provjeriti je li ekran bio otključan tijekom testa (nedostaje dopuštenje za pristup korištenju) – rezultat vjerojatno stoji, ali to ne možemo potvrditi.'**
  String get testScreenUnlockedUnknown;

  /// No description provided for @testRebooted.
  ///
  /// In hr, this message translates to:
  /// **'Telefon se restartao tijekom testa.'**
  String get testRebooted;

  /// No description provided for @testNewTest.
  ///
  /// In hr, this message translates to:
  /// **'Novi test'**
  String get testNewTest;

  /// No description provided for @testRunInProgress.
  ///
  /// In hr, this message translates to:
  /// **'Test je već u tijeku – nastavljamo pratiti postojeći.'**
  String get testRunInProgress;

  /// No description provided for @testNoResultsYet.
  ///
  /// In hr, this message translates to:
  /// **'Rezultati još nisu spremni.'**
  String get testNoResultsYet;

  /// No description provided for @laneAlarmClockTitle.
  ///
  /// In hr, this message translates to:
  /// **'Alarm (najjači)'**
  String get laneAlarmClockTitle;

  /// No description provided for @laneAlarmClockDesc.
  ///
  /// In hr, this message translates to:
  /// **'Najjača vrsta alarma koju Android nudi – tako rade budilice.'**
  String get laneAlarmClockDesc;

  /// No description provided for @laneExactIdleTitle.
  ///
  /// In hr, this message translates to:
  /// **'Točan podsjetnik'**
  String get laneExactIdleTitle;

  /// No description provided for @laneExactIdleDesc.
  ///
  /// In hr, this message translates to:
  /// **'Ovo koriste aplikacije za podsjetnike.'**
  String get laneExactIdleDesc;

  /// No description provided for @laneWorkManagerTitle.
  ///
  /// In hr, this message translates to:
  /// **'Pozadinska sinkronizacija'**
  String get laneWorkManagerTitle;

  /// No description provided for @laneWorkManagerDesc.
  ///
  /// In hr, this message translates to:
  /// **'Ovo koriste chat i sinkronizacijske aplikacije – prvo što proizvođači ugase.'**
  String get laneWorkManagerDesc;

  /// No description provided for @outcomePending.
  ///
  /// In hr, this message translates to:
  /// **'Čeka se…'**
  String get outcomePending;

  /// No description provided for @outcomeFiredOnTime.
  ///
  /// In hr, this message translates to:
  /// **'Stiglo na vrijeme'**
  String get outcomeFiredOnTime;

  /// No description provided for @outcomeFiredLate.
  ///
  /// In hr, this message translates to:
  /// **'Kasnilo'**
  String get outcomeFiredLate;

  /// No description provided for @outcomeNeverFired.
  ///
  /// In hr, this message translates to:
  /// **'Nikad nije stiglo'**
  String get outcomeNeverFired;

  /// No description provided for @outcomeCancelled.
  ///
  /// In hr, this message translates to:
  /// **'Otkazano'**
  String get outcomeCancelled;

  /// No description provided for @outcomeDelay.
  ///
  /// In hr, this message translates to:
  /// **'Kašnjenje: {delay}'**
  String outcomeDelay(String delay);

  /// No description provided for @fixGuideTitle.
  ///
  /// In hr, this message translates to:
  /// **'Vodič za popravak'**
  String get fixGuideTitle;

  /// No description provided for @fixGuideAggressiveness.
  ///
  /// In hr, this message translates to:
  /// **'Razina agresivnosti: {rank}/5'**
  String fixGuideAggressiveness(int rank);

  /// No description provided for @fixGuideUnverified.
  ///
  /// In hr, this message translates to:
  /// **'Koraci za marku {brand} još nisu fizički provjereni na pravom uređaju te marke – izbornici se mogu razlikovati.'**
  String fixGuideUnverified(String brand);

  /// No description provided for @fixGuideConfirmCheckbox.
  ///
  /// In hr, this message translates to:
  /// **'Potvrđujem da sam ovo napravio/la'**
  String get fixGuideConfirmCheckbox;

  /// No description provided for @fixGuideOpenFailed.
  ///
  /// In hr, this message translates to:
  /// **'Nisam uspio automatski otvoriti postavke. Idi ručno: Postavke → Baterija / Aplikacije.'**
  String get fixGuideOpenFailed;

  /// No description provided for @fixGuideOpenSucceeded.
  ///
  /// In hr, this message translates to:
  /// **'Otvorene su postavke – provjeri jesi li promijenio/la traženu opciju.'**
  String get fixGuideOpenSucceeded;

  /// No description provided for @fixGuideNoSteps.
  ///
  /// In hr, this message translates to:
  /// **'Za ovu marku trenutno nema definiranih koraka.'**
  String get fixGuideNoSteps;

  /// No description provided for @fixGuideLoadError.
  ///
  /// In hr, this message translates to:
  /// **'Nisam uspio učitati vodič za ovu marku uređaja.'**
  String get fixGuideLoadError;

  /// No description provided for @historyTitle.
  ///
  /// In hr, this message translates to:
  /// **'Povijest testova'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In hr, this message translates to:
  /// **'Još nema testova. Pokreni prvi na kartici Test.'**
  String get historyEmpty;

  /// No description provided for @historyDirtyTag.
  ///
  /// In hr, this message translates to:
  /// **'Nepouzdano'**
  String get historyDirtyTag;

  /// No description provided for @historyUnknownTag.
  ///
  /// In hr, this message translates to:
  /// **'Djelomično nepoznato'**
  String get historyUnknownTag;

  /// No description provided for @historyWindowLabel.
  ///
  /// In hr, this message translates to:
  /// **'Prozor: {minutes} min'**
  String historyWindowLabel(int minutes);

  /// No description provided for @aboutTitle.
  ///
  /// In hr, this message translates to:
  /// **'O aplikaciji'**
  String get aboutTitle;

  /// No description provided for @aboutWhatItKnows.
  ///
  /// In hr, this message translates to:
  /// **'Što aplikacija stvarno zna'**
  String get aboutWhatItKnows;

  /// No description provided for @aboutWhatItKnowsBody.
  ///
  /// In hr, this message translates to:
  /// **'Aplikacija čita samo ono što Android javno dopušta pročitati – stanje baterijskih ograničenja, dopuštenja i rezultate vlastitog testa dostave koji sama provede.'**
  String get aboutWhatItKnowsBody;

  /// No description provided for @aboutWhatItCannotKnow.
  ///
  /// In hr, this message translates to:
  /// **'Što aplikacija ne može znati'**
  String get aboutWhatItCannotKnow;

  /// No description provided for @aboutWhatItCannotKnowBody.
  ///
  /// In hr, this message translates to:
  /// **'Android ne nudi javni način da se pročita jesu li proizvođačevi prekidači za \'autostart\' uključeni. Zato te aplikacija traži da to potvrdiš ručno, umjesto da tvrdi da zna nešto što nije provjerila.'**
  String get aboutWhatItCannotKnowBody;

  /// No description provided for @aboutNoDataCollection.
  ///
  /// In hr, this message translates to:
  /// **'Aplikacija ne prikuplja, ne šalje i ne pohranjuje nikakve tvoje podatke izvan tvog telefona.'**
  String get aboutNoDataCollection;

  /// No description provided for @aboutNoBatteryClaim.
  ///
  /// In hr, this message translates to:
  /// **'Aplikacija ne tvrdi da će produžiti trajanje baterije – njena jedina svrha je pokazati istinu o tome zašto notifikacije ne stižu.'**
  String get aboutNoBatteryClaim;

  /// No description provided for @aboutTipTitle.
  ///
  /// In hr, this message translates to:
  /// **'Napojnica'**
  String get aboutTipTitle;

  /// No description provided for @aboutTipBody.
  ///
  /// In hr, this message translates to:
  /// **'Ovdje će jednog dana biti opcionalna napojnica za razvoj aplikacije. Trenutno kupnja nije dostupna u aplikaciji.'**
  String get aboutTipBody;

  /// No description provided for @aboutTipComingSoon.
  ///
  /// In hr, this message translates to:
  /// **'Uskoro'**
  String get aboutTipComingSoon;

  /// No description provided for @aboutVersion.
  ///
  /// In hr, this message translates to:
  /// **'Verzija {version}'**
  String aboutVersion(Object version);

  /// No description provided for @bulkFixTitle.
  ///
  /// In hr, this message translates to:
  /// **'Popravi sve'**
  String get bulkFixTitle;

  /// No description provided for @bulkFixIntro.
  ///
  /// In hr, this message translates to:
  /// **'Aplikacija ne može sama isključiti optimizaciju baterije za druge aplikacije – to Android jednostavno ne dopušta. Umjesto toga, evo popisa: klikni aplikaciju, otvorit će se njene postavke, promijeni tamo ručno, a kad se vratiš ovdje ćemo automatski ponovno provjeriti stanje.'**
  String get bulkFixIntro;

  /// No description provided for @bulkFixSectionImportant.
  ///
  /// In hr, this message translates to:
  /// **'Važne aplikacije'**
  String get bulkFixSectionImportant;

  /// No description provided for @bulkFixSectionOthers.
  ///
  /// In hr, this message translates to:
  /// **'Svi ostali appovi'**
  String get bulkFixSectionOthers;

  /// No description provided for @bulkFixSectionAutostart.
  ///
  /// In hr, this message translates to:
  /// **'Autostart (ručna provjera)'**
  String get bulkFixSectionAutostart;

  /// No description provided for @bulkFixAutostartExplainer.
  ///
  /// In hr, this message translates to:
  /// **'Android ne nudi nikakav način da bilo koja aplikacija automatski provjeri je li \'autostart\' uključen za drugu aplikaciju. Ovo mora ostati ručna provjera – potvrdi svaki korak sam/a.'**
  String get bulkFixAutostartExplainer;

  /// No description provided for @bulkFixCategoryMessaging.
  ///
  /// In hr, this message translates to:
  /// **'Poruke'**
  String get bulkFixCategoryMessaging;

  /// No description provided for @bulkFixCategoryBanking.
  ///
  /// In hr, this message translates to:
  /// **'Bankarstvo'**
  String get bulkFixCategoryBanking;

  /// No description provided for @bulkFixCategoryCalendar.
  ///
  /// In hr, this message translates to:
  /// **'Kalendar'**
  String get bulkFixCategoryCalendar;

  /// No description provided for @bulkFixCategoryOther.
  ///
  /// In hr, this message translates to:
  /// **'Ostalo'**
  String get bulkFixCategoryOther;

  /// No description provided for @bulkFixStatusExempt.
  ///
  /// In hr, this message translates to:
  /// **'Izuzeto'**
  String get bulkFixStatusExempt;

  /// No description provided for @bulkFixStatusNotExempt.
  ///
  /// In hr, this message translates to:
  /// **'Nije izuzeto'**
  String get bulkFixStatusNotExempt;

  /// No description provided for @bulkFixStatusUnknown.
  ///
  /// In hr, this message translates to:
  /// **'Ne može se provjeriti'**
  String get bulkFixStatusUnknown;

  /// No description provided for @bulkFixCheckButton.
  ///
  /// In hr, this message translates to:
  /// **'Provjeri postavke'**
  String get bulkFixCheckButton;

  /// No description provided for @bulkFixRefresh.
  ///
  /// In hr, this message translates to:
  /// **'Osvježi'**
  String get bulkFixRefresh;

  /// No description provided for @bulkFixLoadError.
  ///
  /// In hr, this message translates to:
  /// **'Nisam uspio učitati popis instaliranih aplikacija.'**
  String get bulkFixLoadError;

  /// No description provided for @bulkFixEmptyOthers.
  ///
  /// In hr, this message translates to:
  /// **'Nema drugih instaliranih aplikacija za prikaz.'**
  String get bulkFixEmptyOthers;

  /// No description provided for @bulkFixNoImportantInstalled.
  ///
  /// In hr, this message translates to:
  /// **'Nijedna od poznatih važnih aplikacija nije pronađena na ovom telefonu.'**
  String get bulkFixNoImportantInstalled;
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
      <String>['en', 'hr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hr':
      return AppLocalizationsHr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
