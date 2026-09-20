// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'BagerWake';

  @override
  String get navDashboard => 'Pregled';

  @override
  String get navTest => 'Test';

  @override
  String get navFixGuide => 'Vodič';

  @override
  String get navHistory => 'Povijest';

  @override
  String get navAbout => 'O aplikaciji';

  @override
  String get commonRetry => 'Pokušaj ponovno';

  @override
  String get commonCancel => 'Odustani';

  @override
  String get commonClose => 'Zatvori';

  @override
  String get commonOpenSettings => 'Otvori postavke';

  @override
  String get commonLoading => 'Učitavanje…';

  @override
  String get commonError => 'Nešto je pošlo po zlu.';

  @override
  String get commonUnknown => 'Nepoznato';

  @override
  String get statusOk => 'U redu';

  @override
  String get statusWarning => 'Upozorenje';

  @override
  String get statusProblem => 'Problem';

  @override
  String get statusUnavailable => 'Ne može se provjeriti';

  @override
  String get unavailableReasonLabel => 'Razlog';

  @override
  String get unavailableReasonFallback =>
      'Aplikacija nije dobila razlog od sustava.';

  @override
  String get dashboardTitle => 'Pregled';

  @override
  String dashboardDeviceSubtitle(String release, int sdk) {
    return 'Android $release · API $sdk';
  }

  @override
  String get dashboardLoadError =>
      'Nisam uspio pročitati stanje uređaja. Provjeri je li aplikaciji dano dopuštenje i pokušaj ponovno.';

  @override
  String get dashboardUnknownDevice => 'Nepoznat uređaj';

  @override
  String get dashboardNotifPermButton => 'Zatraži dopuštenje';

  @override
  String get diagBatteryOptimizationTitle => 'Optimizacija baterije';

  @override
  String get diagBatteryOptimizationDesc =>
      'Ako je aplikacija pod \'optimizacijom baterije\', sustav joj gasi pozadinski rad kad je ne koristiš – notifikacije i alarmi mogu kasniti ili uopće ne stići.';

  @override
  String get diagNotificationsEnabledTitle => 'Dopuštenje za notifikacije';

  @override
  String get diagNotificationsEnabledDesc =>
      'Bez ovog dopuštenja sustav uopće ne prikazuje notifikacije aplikacije, bez obzira na sva ostala podešavanja.';

  @override
  String get diagExactAlarmPermissionTitle => 'Dopuštenje za točne alarme';

  @override
  String get diagExactAlarmPermissionDesc =>
      'Bez ovog dopuštenja Android smije alarm pomaknuti kasnije umjesto da zazvoni točno kad je zakazan.';

  @override
  String get diagBackgroundRestrictedTitle => 'Ograničen rad u pozadini';

  @override
  String get diagBackgroundRestrictedDesc =>
      'Kad je ovo uključeno, sustav gotovo potpuno blokira rad aplikacije dok je ne gledaš na ekranu – notifikacije obično uopće ne stignu.';

  @override
  String get diagStandbyBucketTitle => 'Skupina aktivnosti (App Standby)';

  @override
  String get diagStandbyBucketDesc =>
      'Android svrstava aplikacije u skupine prema tome koliko ih koristiš. U lošijoj skupini dobivaš manje prilika za pozadinski rad, pa notifikacije kasne.';

  @override
  String get diagDataSaverTitle => 'Štednja podataka';

  @override
  String get diagDataSaverDesc =>
      'Kad je uključena, aplikacije u pozadini ne smiju koristiti mobilni internet – poruke i sinkronizacija čekaju dok ručno ne otvoriš aplikaciju.';

  @override
  String get diagPowerSaveModeTitle => 'Način uštede baterije';

  @override
  String get diagPowerSaveModeDesc =>
      'Ovaj način dodatno guši pozadinski rad i odgađa alarme i notifikacije dok je uključen, kako bi se produžilo trajanje baterije.';

  @override
  String get diagDozeStateTitle => 'Doze (stanje mirovanja)';

  @override
  String get diagDozeStateDesc =>
      'Kad telefon duže vrijeme miruje bez dodira, Android periodično \'uspavljuje\' sve aplikacije – notifikacije se grupiraju i stižu u paketima umjesto odmah.';

  @override
  String get testTitle => 'Test dostave';

  @override
  String get testWindowLabel => 'Trajanje testa';

  @override
  String get testWindow15 => '15 min';

  @override
  String get testWindow30 => '30 min';

  @override
  String get testWindow60 => '60 min';

  @override
  String get testPreflightTitle => 'Prije nego počneš';

  @override
  String get testPreflightBody =>
      'Zaključaj ekran, ne otvaraj ovu aplikaciju i ostavi telefon na miru dok test traje. Android mora povjerovati da telefon miruje da bi uopće primijenio ograničenja koja testiramo – ako diraš telefon, rezultat neće biti pouzdano očitanje. Tri provjere su namjerno razmaknute kroz test, a ne sve na kraju: najjača provjera budi telefon i time bi spasila slabije, pa bi rezultat ispao bolji nego što stvarno jest. Zato će notifikacije stizati jedna po jedna.';

  @override
  String get testStartButton => 'Pokreni test';

  @override
  String get testNeedPermissions => 'Nedostaju dopuštenja potrebna za test.';

  @override
  String get testGoToDashboard => 'Idi na Pregled';

  @override
  String get testRunningTitle => 'Test u tijeku';

  @override
  String testTimeRemaining(String time) {
    return 'Preostalo vrijeme: $time';
  }

  @override
  String get testCancelButton => 'Prekini test';

  @override
  String get testResultsTitle => 'Rezultati testa';

  @override
  String get testDirtyResultBanner => 'Ovo NIJE čisto očitanje.';

  @override
  String get testScreenUnlocked => 'Ekran je bio otključan tijekom testa.';

  @override
  String get testScreenUnlockedUnknown =>
      'Ne može se provjeriti je li ekran bio otključan tijekom testa (nedostaje dopuštenje za pristup korištenju) – rezultat vjerojatno stoji, ali to ne možemo potvrditi.';

  @override
  String get testRebooted => 'Telefon se restartao tijekom testa.';

  @override
  String get testNewTest => 'Novi test';

  @override
  String get testRunInProgress =>
      'Test je već u tijeku – nastavljamo pratiti postojeći.';

  @override
  String get testNoResultsYet => 'Rezultati još nisu spremni.';

  @override
  String get laneAlarmClockTitle => 'Alarm (najjači)';

  @override
  String get laneAlarmClockDesc =>
      'Najjača vrsta alarma koju Android nudi – tako rade budilice.';

  @override
  String get laneExactIdleTitle => 'Točan podsjetnik';

  @override
  String get laneExactIdleDesc => 'Ovo koriste aplikacije za podsjetnike.';

  @override
  String get laneWorkManagerTitle => 'Pozadinska sinkronizacija';

  @override
  String get laneWorkManagerDesc =>
      'Ovo koriste chat i sinkronizacijske aplikacije – prvo što proizvođači ugase.';

  @override
  String get outcomePending => 'Čeka se…';

  @override
  String get outcomeFiredOnTime => 'Stiglo na vrijeme';

  @override
  String get outcomeFiredLate => 'Kasnilo';

  @override
  String get outcomeNeverFired => 'Nikad nije stiglo';

  @override
  String get outcomeCancelled => 'Otkazano';

  @override
  String outcomeDelay(String delay) {
    return 'Kašnjenje: $delay';
  }

  @override
  String get fixGuideTitle => 'Vodič za popravak';

  @override
  String fixGuideAggressiveness(int rank) {
    return 'Razina agresivnosti: $rank/5';
  }

  @override
  String fixGuideUnverified(String brand) {
    return 'Koraci za marku $brand još nisu fizički provjereni na pravom uređaju te marke – izbornici se mogu razlikovati.';
  }

  @override
  String get fixGuideConfirmCheckbox => 'Potvrđujem da sam ovo napravio/la';

  @override
  String get fixGuideOpenFailed =>
      'Nisam uspio automatski otvoriti postavke. Idi ručno: Postavke → Baterija / Aplikacije.';

  @override
  String get fixGuideOpenSucceeded =>
      'Otvorene su postavke – provjeri jesi li promijenio/la traženu opciju.';

  @override
  String get fixGuideNoSteps =>
      'Za ovu marku trenutno nema definiranih koraka.';

  @override
  String get fixGuideLoadError =>
      'Nisam uspio učitati vodič za ovu marku uređaja.';

  @override
  String get historyTitle => 'Povijest testova';

  @override
  String get historyEmpty => 'Još nema testova. Pokreni prvi na kartici Test.';

  @override
  String get historyDirtyTag => 'Nepouzdano';

  @override
  String get historyUnknownTag => 'Djelomično nepoznato';

  @override
  String historyWindowLabel(int minutes) {
    return 'Prozor: $minutes min';
  }

  @override
  String get aboutTitle => 'O aplikaciji';

  @override
  String get aboutWhatItKnows => 'Što aplikacija stvarno zna';

  @override
  String get aboutWhatItKnowsBody =>
      'Aplikacija čita samo ono što Android javno dopušta pročitati – stanje baterijskih ograničenja, dopuštenja i rezultate vlastitog testa dostave koji sama provede.';

  @override
  String get aboutWhatItCannotKnow => 'Što aplikacija ne može znati';

  @override
  String get aboutWhatItCannotKnowBody =>
      'Android ne nudi javni način da se pročita jesu li proizvođačevi prekidači za \'autostart\' uključeni. Zato te aplikacija traži da to potvrdiš ručno, umjesto da tvrdi da zna nešto što nije provjerila.';

  @override
  String get aboutNoDataCollection =>
      'Aplikacija ne prikuplja, ne šalje i ne pohranjuje nikakve tvoje podatke izvan tvog telefona.';

  @override
  String get aboutNoBatteryClaim =>
      'Aplikacija ne tvrdi da će produžiti trajanje baterije – njena jedina svrha je pokazati istinu o tome zašto notifikacije ne stižu.';

  @override
  String get aboutTipTitle => 'Napojnica';

  @override
  String get aboutTipBody =>
      'Ovdje će jednog dana biti opcionalna napojnica za razvoj aplikacije. Trenutno kupnja nije dostupna u aplikaciji.';

  @override
  String get aboutTipComingSoon => 'Uskoro';

  @override
  String aboutVersion(Object version) {
    return 'Verzija $version';
  }
}
