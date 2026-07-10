import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('uk')];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'Пласт'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get login;

  /// No description provided for @register.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструватися'**
  String get register;

  /// No description provided for @email.
  ///
  /// In uk, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In uk, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In uk, this message translates to:
  /// **'Ім\'я'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In uk, this message translates to:
  /// **'Прізвище'**
  String get lastName;

  /// No description provided for @loginButton.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструватися'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In uk, this message translates to:
  /// **'Немає акаунту? Зареєструйтесь'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In uk, this message translates to:
  /// **'Вже є акаунт? Увійдіть'**
  String get haveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In uk, this message translates to:
  /// **'Забули пароль?'**
  String get forgotPassword;

  /// No description provided for @profile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settings;

  /// No description provided for @calendar.
  ///
  /// In uk, this message translates to:
  /// **'Календар'**
  String get calendar;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In uk, this message translates to:
  /// **'Додати'**
  String get add;

  /// No description provided for @editProfile.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати профіль'**
  String get editProfile;

  /// No description provided for @profileSaved.
  ///
  /// In uk, this message translates to:
  /// **'Профіль збережено!'**
  String get profileSaved;

  /// No description provided for @fillRequiredFields.
  ///
  /// In uk, this message translates to:
  /// **'Заповніть всі обов\'язкові поля'**
  String get fillRequiredFields;

  /// No description provided for @required.
  ///
  /// In uk, this message translates to:
  /// **'Обов\'язково'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In uk, this message translates to:
  /// **'Необов\'язково'**
  String get optional;

  /// No description provided for @mainInfo.
  ///
  /// In uk, this message translates to:
  /// **'Основна інформація'**
  String get mainInfo;

  /// No description provided for @plastInfo.
  ///
  /// In uk, this message translates to:
  /// **'Пластова інформація'**
  String get plastInfo;

  /// No description provided for @contacts.
  ///
  /// In uk, this message translates to:
  /// **'Контакти'**
  String get contacts;

  /// No description provided for @nickname.
  ///
  /// In uk, this message translates to:
  /// **'Нікнейм'**
  String get nickname;

  /// No description provided for @phone.
  ///
  /// In uk, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In uk, this message translates to:
  /// **'Станиця'**
  String get location;

  /// No description provided for @dateOfBirth.
  ///
  /// In uk, this message translates to:
  /// **'Дата народження'**
  String get dateOfBirth;

  /// No description provided for @dateOfNaming.
  ///
  /// In uk, this message translates to:
  /// **'Дата іменування'**
  String get dateOfNaming;

  /// No description provided for @whoNamed.
  ///
  /// In uk, this message translates to:
  /// **'Хто іменував/ула'**
  String get whoNamed;

  /// No description provided for @dateJoinedPlast.
  ///
  /// In uk, this message translates to:
  /// **'Дата вступу до Пласту'**
  String get dateJoinedPlast;

  /// No description provided for @dateOath.
  ///
  /// In uk, this message translates to:
  /// **'Дата складання Пластової присяги'**
  String get dateOath;

  /// No description provided for @heardAboutPlast.
  ///
  /// In uk, this message translates to:
  /// **'Де і коли вперше почув/ла про Пласт'**
  String get heardAboutPlast;

  /// No description provided for @stanychny.
  ///
  /// In uk, this message translates to:
  /// **'Станичний'**
  String get stanychny;

  /// No description provided for @zamistnykStanychnogo.
  ///
  /// In uk, this message translates to:
  /// **'Заступник станичного'**
  String get zamistnykStanychnogo;

  /// No description provided for @referentUspUps.
  ///
  /// In uk, this message translates to:
  /// **'Референт/ка УСП/УПС'**
  String get referentUspUps;

  /// No description provided for @referentUppUpnUpu.
  ///
  /// In uk, this message translates to:
  /// **'Референт/ка УПП/УПН/УПЮ'**
  String get referentUppUpnUpu;

  /// No description provided for @skarbnyk.
  ///
  /// In uk, this message translates to:
  /// **'Скарбник/ча'**
  String get skarbnyk;

  /// No description provided for @notSet.
  ///
  /// In uk, this message translates to:
  /// **'Не встановлено'**
  String get notSet;

  /// No description provided for @addEvent.
  ///
  /// In uk, this message translates to:
  /// **'Додати подію'**
  String get addEvent;

  /// No description provided for @eventTitle.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get eventTitle;

  /// No description provided for @eventDescription.
  ///
  /// In uk, this message translates to:
  /// **'Опис'**
  String get eventDescription;

  /// No description provided for @eventType.
  ///
  /// In uk, this message translates to:
  /// **'Тип події'**
  String get eventType;

  /// No description provided for @startDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата початку'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата завершення'**
  String get endDate;

  /// No description provided for @training.
  ///
  /// In uk, this message translates to:
  /// **'Вишкіл'**
  String get training;

  /// No description provided for @camp.
  ///
  /// In uk, this message translates to:
  /// **'Табір'**
  String get camp;

  /// No description provided for @event.
  ///
  /// In uk, this message translates to:
  /// **'Подія'**
  String get event;

  /// No description provided for @goal.
  ///
  /// In uk, this message translates to:
  /// **'Ціль'**
  String get goal;

  /// No description provided for @trainings.
  ///
  /// In uk, this message translates to:
  /// **'Вишколи'**
  String get trainings;

  /// No description provided for @camps.
  ///
  /// In uk, this message translates to:
  /// **'Табори'**
  String get camps;

  /// No description provided for @events.
  ///
  /// In uk, this message translates to:
  /// **'Події'**
  String get events;

  /// No description provided for @goals.
  ///
  /// In uk, this message translates to:
  /// **'Цілі'**
  String get goals;

  /// No description provided for @history.
  ///
  /// In uk, this message translates to:
  /// **'Історія'**
  String get history;

  /// No description provided for @upcoming.
  ///
  /// In uk, this message translates to:
  /// **'Майбутні'**
  String get upcoming;

  /// No description provided for @noData.
  ///
  /// In uk, this message translates to:
  /// **'Немає даних'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In uk, this message translates to:
  /// **'Помилка'**
  String get error;

  /// No description provided for @uploadError.
  ///
  /// In uk, this message translates to:
  /// **'Помилка завантаження'**
  String get uploadError;

  /// No description provided for @phoneInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Телефон має бути у форматі +380XXXXXXXXX'**
  String get phoneInvalid;

  /// No description provided for @language.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In uk, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In uk, this message translates to:
  /// **'Темна'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In uk, this message translates to:
  /// **'Світла'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In uk, this message translates to:
  /// **'Системна'**
  String get systemTheme;

  /// No description provided for @ukrainian.
  ///
  /// In uk, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// No description provided for @english.
  ///
  /// In uk, this message translates to:
  /// **'Англійська'**
  String get english;

  /// No description provided for @logout.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In uk, this message translates to:
  /// **'Ви впевнені, що хочете вийти?'**
  String get confirmLogout;

  /// No description provided for @confirmDelete.
  ///
  /// In uk, this message translates to:
  /// **'Ви впевнені, що хочете видалити?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In uk, this message translates to:
  /// **'Так'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In uk, this message translates to:
  /// **'Ні'**
  String get no;

  /// No description provided for @resetPassword.
  ///
  /// In uk, this message translates to:
  /// **'Відновити пароль'**
  String get resetPassword;

  /// No description provided for @resetPasswordSent.
  ///
  /// In uk, this message translates to:
  /// **'Лист для відновлення пароля відправлено'**
  String get resetPasswordSent;

  /// No description provided for @checkEmail.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте свою пошту'**
  String get checkEmail;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In uk, this message translates to:
  /// **'Введіть новий пароль для вашого акаунту. Після збереження старий пароль більше не діятиме.'**
  String get resetPasswordInstructions;

  /// No description provided for @newPassword.
  ///
  /// In uk, this message translates to:
  /// **'Новий пароль'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити пароль'**
  String get confirmPassword;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In uk, this message translates to:
  /// **'Паролі не співпадають'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @errorRecoverySessionExpired.
  ///
  /// In uk, this message translates to:
  /// **'Посилання для відновлення пароля застаріло або вже використане. Запросіть нове.'**
  String get errorRecoverySessionExpired;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In uk, this message translates to:
  /// **'Пароль відновлено'**
  String get passwordResetSuccessTitle;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In uk, this message translates to:
  /// **'Ваш пароль успішно оновлено. Тепер ви можете увійти з новим паролем.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @continueToApp.
  ///
  /// In uk, this message translates to:
  /// **'Перейти до додатку'**
  String get continueToApp;

  /// No description provided for @passwordResetEmailSentTitle.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте пошту'**
  String get passwordResetEmailSentTitle;

  /// No description provided for @passwordResetEmailSentMessage.
  ///
  /// In uk, this message translates to:
  /// **'Ми надіслали інструкції для відновлення пароля на {email}. Перейдіть за посиланням у листі, щоб встановити новий пароль.'**
  String passwordResetEmailSentMessage(String email);

  /// No description provided for @backToLogin.
  ///
  /// In uk, this message translates to:
  /// **'Повернутися до входу'**
  String get backToLogin;

  /// No description provided for @back.
  ///
  /// In uk, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @today.
  ///
  /// In uk, this message translates to:
  /// **'Сьогодні'**
  String get today;

  /// No description provided for @noNickname.
  ///
  /// In uk, this message translates to:
  /// **'немає'**
  String get noNickname;

  /// No description provided for @profileId.
  ///
  /// In uk, this message translates to:
  /// **'ID'**
  String get profileId;

  /// No description provided for @errorEmailRequired.
  ///
  /// In uk, this message translates to:
  /// **'Email обов\'язковий'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Невірний формат email'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In uk, this message translates to:
  /// **'Пароль обов\'язковий'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In uk, this message translates to:
  /// **'Пароль занадто короткий (мін. 6 символів)'**
  String get errorPasswordTooShort;

  /// No description provided for @errorNameRequired.
  ///
  /// In uk, this message translates to:
  /// **'Ім\'я обов\'язкове'**
  String get errorNameRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In uk, this message translates to:
  /// **'Невірний email або пароль'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In uk, this message translates to:
  /// **'Email не підтверджено'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorUserAlreadyRegistered.
  ///
  /// In uk, this message translates to:
  /// **'Користувач з таким email вже існує'**
  String get errorUserAlreadyRegistered;

  /// No description provided for @errorNetwork.
  ///
  /// In uk, this message translates to:
  /// **'Помилка мережі. Перевірте з\'єднання'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Сталася непередбачена помилка'**
  String get errorUnknown;

  /// No description provided for @errorUserNotFound.
  ///
  /// In uk, this message translates to:
  /// **'Користувача з таким email не знайдено'**
  String get errorUserNotFound;

  /// No description provided for @stepsGoal.
  ///
  /// In uk, this message translates to:
  /// **'Кроки до виконання'**
  String get stepsGoal;

  /// No description provided for @trainingInfo.
  ///
  /// In uk, this message translates to:
  /// **'Інформація про вишкіл'**
  String get trainingInfo;

  /// No description provided for @kvdchNumber.
  ///
  /// In uk, this message translates to:
  /// **'Число'**
  String get kvdchNumber;

  /// No description provided for @completionDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата проходження'**
  String get completionDate;

  /// No description provided for @commandant.
  ///
  /// In uk, this message translates to:
  /// **'Комендант'**
  String get commandant;

  /// No description provided for @comments.
  ///
  /// In uk, this message translates to:
  /// **'Коментарі'**
  String get comments;

  /// No description provided for @trainingTypes.
  ///
  /// In uk, this message translates to:
  /// **'Типи вишколів'**
  String get trainingTypes;

  /// No description provided for @categoryUPP.
  ///
  /// In uk, this message translates to:
  /// **'УПП'**
  String get categoryUPP;

  /// No description provided for @categoryUPPDesc.
  ///
  /// In uk, this message translates to:
  /// **'Улад пластових пташат'**
  String get categoryUPPDesc;

  /// No description provided for @categoryUPN.
  ///
  /// In uk, this message translates to:
  /// **'УПН'**
  String get categoryUPN;

  /// No description provided for @categoryUPNDesc.
  ///
  /// In uk, this message translates to:
  /// **'Улад пластунів новаків'**
  String get categoryUPNDesc;

  /// No description provided for @categoryUPY.
  ///
  /// In uk, this message translates to:
  /// **'УПЮ'**
  String get categoryUPY;

  /// No description provided for @categoryUPYDesc.
  ///
  /// In uk, this message translates to:
  /// **'Улад пластунів юнаків'**
  String get categoryUPYDesc;

  /// No description provided for @toolUPP.
  ///
  /// In uk, this message translates to:
  /// **'улад пластових пташат'**
  String get toolUPP;

  /// No description provided for @toolUPN.
  ///
  /// In uk, this message translates to:
  /// **'улад пластунів новаків'**
  String get toolUPN;

  /// No description provided for @toolROV.
  ///
  /// In uk, this message translates to:
  /// **'рада орлиного вогню'**
  String get toolROV;

  /// No description provided for @toolUPY.
  ///
  /// In uk, this message translates to:
  /// **'улад пластунів юнаків'**
  String get toolUPY;

  /// No description provided for @toolKVV.
  ///
  /// In uk, this message translates to:
  /// **'крайовий вишкіл виховників'**
  String get toolKVV;

  /// No description provided for @toolVVP.
  ///
  /// In uk, this message translates to:
  /// **'вишкіл виховників пташат'**
  String get toolVVP;

  /// No description provided for @toolVPPT.
  ///
  /// In uk, this message translates to:
  /// **'вишкіл провідників пташачих таборів'**
  String get toolVPPT;

  /// No description provided for @toolKVZ.
  ///
  /// In uk, this message translates to:
  /// **'крайовий вишкіл зв\'язкових'**
  String get toolKVZ;

  /// No description provided for @toolKVPT.
  ///
  /// In uk, this message translates to:
  /// **'крайовий вишкіл провідників таборів'**
  String get toolKVPT;

  /// No description provided for @toolKVPV.
  ///
  /// In uk, this message translates to:
  /// **'крайовий вишкіл провідників вишколів'**
  String get toolKVPV;

  /// No description provided for @toolLSH.
  ///
  /// In uk, this message translates to:
  /// **'лісова школа'**
  String get toolLSH;

  /// No description provided for @toolSHB.
  ///
  /// In uk, this message translates to:
  /// **'школа булавних'**
  String get toolSHB;

  /// No description provided for @toolKVDCH.
  ///
  /// In uk, this message translates to:
  /// **'кваліфікаційний вишкіл дійсного членства'**
  String get toolKVDCH;

  /// No description provided for @toolROVMace.
  ///
  /// In uk, this message translates to:
  /// **'РОВ булавних'**
  String get toolROVMace;

  /// No description provided for @toolROVNesting.
  ///
  /// In uk, this message translates to:
  /// **'РОВ гніздових'**
  String get toolROVNesting;

  /// No description provided for @toolROVConductors.
  ///
  /// In uk, this message translates to:
  /// **'РОВ провідників таборів'**
  String get toolROVConductors;

  /// No description provided for @goalTitle.
  ///
  /// In uk, this message translates to:
  /// **'Назва цілі'**
  String get goalTitle;

  /// No description provided for @goalTargetDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата до якої ставиться ціль'**
  String get goalTargetDate;

  /// No description provided for @goalSteps.
  ///
  /// In uk, this message translates to:
  /// **'Кроки'**
  String get goalSteps;

  /// No description provided for @goalStepHint.
  ///
  /// In uk, this message translates to:
  /// **'Новий крок'**
  String get goalStepHint;

  /// No description provided for @goalStepsRequired.
  ///
  /// In uk, this message translates to:
  /// **'Додайте хоча б один крок'**
  String get goalStepsRequired;

  /// No description provided for @addGoal.
  ///
  /// In uk, this message translates to:
  /// **'Додати ціль'**
  String get addGoal;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердження email'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In uk, this message translates to:
  /// **'Лист з посиланням для підтвердження було відправлено на {email}. Будь ласка, перевірте пошту та натисніть на посилання для підтвердження.'**
  String emailVerificationMessage(String email);

  /// No description provided for @emailConfirmedTitle.
  ///
  /// In uk, this message translates to:
  /// **'Email підтверджено'**
  String get emailConfirmedTitle;

  /// No description provided for @emailConfirmedMessage.
  ///
  /// In uk, this message translates to:
  /// **'Дякуємо! Вашу електронну адресу підтверджено. Тепер ви можете увійти в додаток.'**
  String get emailConfirmedMessage;

  /// No description provided for @emailConfirmedCta.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get emailConfirmedCta;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Введіть email'**
  String get emailCannotBeEmpty;

  /// No description provided for @emailChangeConfirmationSent.
  ///
  /// In uk, this message translates to:
  /// **'На {email} надіслано лист підтвердження. Поки лист не підтверджено, у профілі використовується попередній email.'**
  String emailChangeConfirmationSent(String email);

  /// No description provided for @resendVerificationEmail.
  ///
  /// In uk, this message translates to:
  /// **'Відправити повторно'**
  String get resendVerificationEmail;

  /// No description provided for @verificationEmailResent.
  ///
  /// In uk, this message translates to:
  /// **'Лист відправлено повторно'**
  String get verificationEmailResent;

  /// No description provided for @signOut.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get signOut;

  /// No description provided for @startTime.
  ///
  /// In uk, this message translates to:
  /// **'Час початку'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In uk, this message translates to:
  /// **'Час завершення'**
  String get endTime;

  /// No description provided for @reminder.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування'**
  String get reminder;

  /// No description provided for @noReminder.
  ///
  /// In uk, this message translates to:
  /// **'Без нагадування'**
  String get noReminder;

  /// No description provided for @reminderAtStart.
  ///
  /// In uk, this message translates to:
  /// **'В час початку'**
  String get reminderAtStart;

  /// No description provided for @reminder5min.
  ///
  /// In uk, this message translates to:
  /// **'За 5 хвилин'**
  String get reminder5min;

  /// No description provided for @reminder15min.
  ///
  /// In uk, this message translates to:
  /// **'За 15 хвилин'**
  String get reminder15min;

  /// No description provided for @reminder30min.
  ///
  /// In uk, this message translates to:
  /// **'За 30 хвилин'**
  String get reminder30min;

  /// No description provided for @reminder1hour.
  ///
  /// In uk, this message translates to:
  /// **'За 1 годину'**
  String get reminder1hour;

  /// No description provided for @reminder2hours.
  ///
  /// In uk, this message translates to:
  /// **'За 2 години'**
  String get reminder2hours;

  /// No description provided for @reminder1day.
  ///
  /// In uk, this message translates to:
  /// **'За 1 день'**
  String get reminder1day;

  /// No description provided for @reminder2days.
  ///
  /// In uk, this message translates to:
  /// **'За 2 дні'**
  String get reminder2days;

  /// No description provided for @reminder1week.
  ///
  /// In uk, this message translates to:
  /// **'За 1 тиждень'**
  String get reminder1week;

  /// No description provided for @adminActivities.
  ///
  /// In uk, this message translates to:
  /// **'Адміністративна діяльність'**
  String get adminActivities;

  /// No description provided for @addAdminActivity.
  ///
  /// In uk, this message translates to:
  /// **'Додати адміністративну діяльність'**
  String get addAdminActivity;

  /// No description provided for @editAdminActivity.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати адміністративну діяльність'**
  String get editAdminActivity;

  /// No description provided for @position.
  ///
  /// In uk, this message translates to:
  /// **'Посада'**
  String get position;

  /// No description provided for @plastActivities.
  ///
  /// In uk, this message translates to:
  /// **'Пластова діяльність'**
  String get plastActivities;

  /// No description provided for @addPlastActivity.
  ///
  /// In uk, this message translates to:
  /// **'Додати пластову діяльність'**
  String get addPlastActivity;

  /// No description provided for @editPlastActivity.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати пластову діяльність'**
  String get editPlastActivity;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In uk, this message translates to:
  /// **'Забагато запитів. Спробуйте пізніше.'**
  String get errorTooManyRequests;

  /// No description provided for @errorGeneric.
  ///
  /// In uk, this message translates to:
  /// **'Сталася помилка. Спробуйте пізніше.'**
  String get errorGeneric;

  /// No description provided for @projectName.
  ///
  /// In uk, this message translates to:
  /// **'Назва проекту'**
  String get projectName;

  /// No description provided for @area.
  ///
  /// In uk, this message translates to:
  /// **'Ділянка'**
  String get area;

  /// No description provided for @date.
  ///
  /// In uk, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @firstUnit.
  ///
  /// In uk, this message translates to:
  /// **'Перший гурток/рій/гніздечко'**
  String get firstUnit;

  /// No description provided for @addFirstUnit.
  ///
  /// In uk, this message translates to:
  /// **'Додати перший гурток'**
  String get addFirstUnit;

  /// No description provided for @editFirstUnit.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати перший гурток'**
  String get editFirstUnit;

  /// No description provided for @firstStepsDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата перших сходин'**
  String get firstStepsDate;

  /// No description provided for @scarfTyingDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата пов\'язання хустки'**
  String get scarfTyingDate;

  /// No description provided for @aboutFirstSteps.
  ///
  /// In uk, this message translates to:
  /// **'Про перші сходини'**
  String get aboutFirstSteps;

  /// No description provided for @aboutFirstImpressions.
  ///
  /// In uk, this message translates to:
  /// **'Про перші враження'**
  String get aboutFirstImpressions;

  /// No description provided for @name.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get name;

  /// No description provided for @linkCourier.
  ///
  /// In uk, this message translates to:
  /// **'Зв\'язковий/а гніздовий/а куреня або гнізда'**
  String get linkCourier;

  /// No description provided for @addLinkCourier.
  ///
  /// In uk, this message translates to:
  /// **'Додати зв\'язкового/у'**
  String get addLinkCourier;

  /// No description provided for @editLinkCourier.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати зв\'язкового/у'**
  String get editLinkCourier;

  /// No description provided for @howToBeLink.
  ///
  /// In uk, this message translates to:
  /// **'Як тобі бути зв\'язковим/ою гніздовим/ою'**
  String get howToBeLink;

  /// No description provided for @yourKurin.
  ///
  /// In uk, this message translates to:
  /// **'Твій курінь'**
  String get yourKurin;

  /// No description provided for @addYourKurin.
  ///
  /// In uk, this message translates to:
  /// **'Додати курінь'**
  String get addYourKurin;

  /// No description provided for @editYourKurin.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати курінь'**
  String get editYourKurin;

  /// No description provided for @firstMeetingDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата першої здибанки'**
  String get firstMeetingDate;

  /// No description provided for @supporterDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата менування прихильником куреня'**
  String get supporterDate;

  /// No description provided for @dcKurinDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата набуття \"дч\" куреня'**
  String get dcKurinDate;

  /// No description provided for @whyThisKurin.
  ///
  /// In uk, this message translates to:
  /// **'Чому саме цей курінь'**
  String get whyThisKurin;

  /// No description provided for @aboutYourThoughts.
  ///
  /// In uk, this message translates to:
  /// **'Про твої думки'**
  String get aboutYourThoughts;

  /// No description provided for @campInfo.
  ///
  /// In uk, this message translates to:
  /// **'Інформація про табори'**
  String get campInfo;

  /// No description provided for @campTypeStandard.
  ///
  /// In uk, this message translates to:
  /// **'Табір'**
  String get campTypeStandard;

  /// No description provided for @campTypeSpartan.
  ///
  /// In uk, this message translates to:
  /// **'Спартанський табір'**
  String get campTypeSpartan;

  /// No description provided for @campTypeUPY.
  ///
  /// In uk, this message translates to:
  /// **'УПЮ табір'**
  String get campTypeUPY;

  /// No description provided for @campTypeInternational.
  ///
  /// In uk, this message translates to:
  /// **'Міжнародний табір'**
  String get campTypeInternational;

  /// No description provided for @campTypeWinter.
  ///
  /// In uk, this message translates to:
  /// **'Зимовий табір'**
  String get campTypeWinter;

  /// No description provided for @members.
  ///
  /// In uk, this message translates to:
  /// **'Учасники'**
  String get members;

  /// No description provided for @addMember.
  ///
  /// In uk, this message translates to:
  /// **'Додати учасника'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати учасника'**
  String get editMember;

  /// No description provided for @memberFirstName.
  ///
  /// In uk, this message translates to:
  /// **'Ім\'я'**
  String get memberFirstName;

  /// No description provided for @memberLastName.
  ///
  /// In uk, this message translates to:
  /// **'Прізвище'**
  String get memberLastName;

  /// No description provided for @memberDateOfBirth.
  ///
  /// In uk, this message translates to:
  /// **'Дата народження'**
  String get memberDateOfBirth;

  /// No description provided for @memberAddress.
  ///
  /// In uk, this message translates to:
  /// **'Адреса'**
  String get memberAddress;

  /// No description provided for @memberPhone.
  ///
  /// In uk, this message translates to:
  /// **'Номер телефону'**
  String get memberPhone;

  /// No description provided for @memberType.
  ///
  /// In uk, this message translates to:
  /// **'Тип учасника'**
  String get memberType;

  /// No description provided for @memberTypeNovak.
  ///
  /// In uk, this message translates to:
  /// **'Новак'**
  String get memberTypeNovak;

  /// No description provided for @memberTypePtasha.
  ///
  /// In uk, this message translates to:
  /// **'Пташа'**
  String get memberTypePtasha;

  /// No description provided for @memberTypeYunak.
  ///
  /// In uk, this message translates to:
  /// **'Юнак'**
  String get memberTypeYunak;

  /// No description provided for @memberTypePidvykhovnyk.
  ///
  /// In uk, this message translates to:
  /// **'Підвиховник'**
  String get memberTypePidvykhovnyk;

  /// No description provided for @memberTypeVykhovnyk.
  ///
  /// In uk, this message translates to:
  /// **'Виховник'**
  String get memberTypeVykhovnyk;

  /// No description provided for @rules.
  ///
  /// In uk, this message translates to:
  /// **'Правила'**
  String get rules;

  /// No description provided for @addRule.
  ///
  /// In uk, this message translates to:
  /// **'Додати правило'**
  String get addRule;

  /// No description provided for @editRule.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати правило'**
  String get editRule;

  /// No description provided for @ruleTitle.
  ///
  /// In uk, this message translates to:
  /// **'Назва правила'**
  String get ruleTitle;

  /// No description provided for @ruleDescription.
  ///
  /// In uk, this message translates to:
  /// **'Опис правила'**
  String get ruleDescription;

  /// No description provided for @birthdayReminder.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування про день народження'**
  String get birthdayReminder;

  /// No description provided for @birthdayReminderMessage.
  ///
  /// In uk, this message translates to:
  /// **'Завтра день народження у {name}!'**
  String birthdayReminderMessage(String name);

  /// No description provided for @usefulInfo.
  ///
  /// In uk, this message translates to:
  /// **'Корисна інформація'**
  String get usefulInfo;

  /// No description provided for @january.
  ///
  /// In uk, this message translates to:
  /// **'Січень'**
  String get january;

  /// No description provided for @february.
  ///
  /// In uk, this message translates to:
  /// **'Лютий'**
  String get february;

  /// No description provided for @march.
  ///
  /// In uk, this message translates to:
  /// **'Березень'**
  String get march;

  /// No description provided for @april.
  ///
  /// In uk, this message translates to:
  /// **'Квітень'**
  String get april;

  /// No description provided for @may.
  ///
  /// In uk, this message translates to:
  /// **'Травень'**
  String get may;

  /// No description provided for @june.
  ///
  /// In uk, this message translates to:
  /// **'Червень'**
  String get june;

  /// No description provided for @july.
  ///
  /// In uk, this message translates to:
  /// **'Липень'**
  String get july;

  /// No description provided for @august.
  ///
  /// In uk, this message translates to:
  /// **'Серпень'**
  String get august;

  /// No description provided for @september.
  ///
  /// In uk, this message translates to:
  /// **'Вересень'**
  String get september;

  /// No description provided for @october.
  ///
  /// In uk, this message translates to:
  /// **'Жовтень'**
  String get october;

  /// No description provided for @november.
  ///
  /// In uk, this message translates to:
  /// **'Листопад'**
  String get november;

  /// No description provided for @december.
  ///
  /// In uk, this message translates to:
  /// **'Грудень'**
  String get december;

  /// No description provided for @monday.
  ///
  /// In uk, this message translates to:
  /// **'Понеділок'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In uk, this message translates to:
  /// **'Вівторок'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In uk, this message translates to:
  /// **'Середа'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In uk, this message translates to:
  /// **'Четвер'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In uk, this message translates to:
  /// **'П\'ятниця'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In uk, this message translates to:
  /// **'Субота'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In uk, this message translates to:
  /// **'Неділя'**
  String get sunday;

  /// No description provided for @mon.
  ///
  /// In uk, this message translates to:
  /// **'Пн'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In uk, this message translates to:
  /// **'Вт'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In uk, this message translates to:
  /// **'Ср'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In uk, this message translates to:
  /// **'Чт'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In uk, this message translates to:
  /// **'Пт'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In uk, this message translates to:
  /// **'Сб'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In uk, this message translates to:
  /// **'Нд'**
  String get sun;

  /// No description provided for @site_plast_title.
  ///
  /// In uk, this message translates to:
  /// **'Сайт Пласту'**
  String get site_plast_title;

  /// No description provided for @site_plast.
  ///
  /// In uk, this message translates to:
  /// **'plast.org.ua'**
  String get site_plast;

  /// No description provided for @pravilnik_vporiadu.
  ///
  /// In uk, this message translates to:
  /// **'Правильник впорядку'**
  String get pravilnik_vporiadu;

  /// No description provided for @pravilnuk_odnostrii_part_one.
  ///
  /// In uk, this message translates to:
  /// **'Правильник однострою (частина 1)'**
  String get pravilnuk_odnostrii_part_one;

  /// No description provided for @pravilnuk_odnostrii_part_two.
  ///
  /// In uk, this message translates to:
  /// **'Правильник однострою (частина 2)'**
  String get pravilnuk_odnostrii_part_two;

  /// No description provided for @osnovni_zahodu.
  ///
  /// In uk, this message translates to:
  /// **'Основні заходи'**
  String get osnovni_zahodu;

  /// No description provided for @autumn.
  ///
  /// In uk, this message translates to:
  /// **'Осінь'**
  String get autumn;

  /// No description provided for @winter.
  ///
  /// In uk, this message translates to:
  /// **'Зима'**
  String get winter;

  /// No description provided for @summer.
  ///
  /// In uk, this message translates to:
  /// **'Літо'**
  String get summer;

  /// No description provided for @spring.
  ///
  /// In uk, this message translates to:
  /// **'Весна'**
  String get spring;

  /// No description provided for @open_plast_year.
  ///
  /// In uk, this message translates to:
  /// **'ВПР - ВІДКРИТТЯ ПЛАСТОВОГО РОКУ'**
  String get open_plast_year;

  /// No description provided for @autumn_raid.
  ///
  /// In uk, this message translates to:
  /// **'Осіній рейд'**
  String get autumn_raid;

  /// No description provided for @pov_vatra.
  ///
  /// In uk, this message translates to:
  /// **'Повстанська ватра'**
  String get pov_vatra;

  /// No description provided for @november_chun.
  ///
  /// In uk, this message translates to:
  /// **'Листопадовий чин'**
  String get november_chun;

  /// No description provided for @vertepu.
  ///
  /// In uk, this message translates to:
  /// **'Вертепи'**
  String get vertepu;

  /// No description provided for @vvm.
  ///
  /// In uk, this message translates to:
  /// **'ВВ - Вифлиємський вогонь миру'**
  String get vvm;

  /// No description provided for @andr_vechornici.
  ///
  /// In uk, this message translates to:
  /// **'Андріївські вечорниці'**
  String get andr_vechornici;

  /// No description provided for @bi_pi.
  ///
  /// In uk, this message translates to:
  /// **'День Бі-Пі - день засновника СКАУТИНГУ'**
  String get bi_pi;

  /// No description provided for @shevchenkiada.
  ///
  /// In uk, this message translates to:
  /// **'Шевченкіада'**
  String get shevchenkiada;

  /// No description provided for @dppp.
  ///
  /// In uk, this message translates to:
  /// **'ДППП - день першої пластової присяги'**
  String get dppp;

  /// No description provided for @spring_raid.
  ///
  /// In uk, this message translates to:
  /// **'Весняний рейд'**
  String get spring_raid;

  /// No description provided for @stegkamu_hero.
  ///
  /// In uk, this message translates to:
  /// **'Стежками героїв'**
  String get stegkamu_hero;

  /// No description provided for @gaivku.
  ///
  /// In uk, this message translates to:
  /// **'Гаївки'**
  String get gaivku;

  /// No description provided for @st_yuri.
  ///
  /// In uk, this message translates to:
  /// **'Свято весни / Свято Юрія'**
  String get st_yuri;

  /// No description provided for @pdf.
  ///
  /// In uk, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @version.
  ///
  /// In uk, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @user_not_auth.
  ///
  /// In uk, this message translates to:
  /// **'User not authenticated\''**
  String get user_not_auth;

  /// No description provided for @ulad.
  ///
  /// In uk, this message translates to:
  /// **'Улад'**
  String get ulad;

  /// No description provided for @level.
  ///
  /// In uk, this message translates to:
  /// **'Рівень'**
  String get level;

  /// No description provided for @role.
  ///
  /// In uk, this message translates to:
  /// **'Роль'**
  String get role;

  /// No description provided for @result.
  ///
  /// In uk, this message translates to:
  /// **'Результат'**
  String get result;

  /// No description provided for @meetupInfo.
  ///
  /// In uk, this message translates to:
  /// **'Інформація про сходини'**
  String get meetupInfo;

  /// No description provided for @meetupTheme.
  ///
  /// In uk, this message translates to:
  /// **'Тема'**
  String get meetupTheme;

  /// No description provided for @meetupDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата сходин'**
  String get meetupDate;

  /// No description provided for @meetupAttendees.
  ///
  /// In uk, this message translates to:
  /// **'Присутні'**
  String get meetupAttendees;

  /// No description provided for @meetupComment.
  ///
  /// In uk, this message translates to:
  /// **'Коментар'**
  String get meetupComment;

  /// No description provided for @addMeetup.
  ///
  /// In uk, this message translates to:
  /// **'Додати сходини'**
  String get addMeetup;

  /// No description provided for @editMeetup.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати сходини'**
  String get editMeetup;

  /// No description provided for @meetupSelectedAttendees.
  ///
  /// In uk, this message translates to:
  /// **'Вибрані присутні'**
  String get meetupSelectedAttendees;

  /// No description provided for @meetupAddAttendee.
  ///
  /// In uk, this message translates to:
  /// **'Додати присутнього'**
  String get meetupAddAttendee;

  /// No description provided for @meetupNoAttendeesAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Немає доступних учасників'**
  String get meetupNoAttendeesAvailable;

  /// No description provided for @meetupAttendeesEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Присутніх не вибрано'**
  String get meetupAttendeesEmpty;

  /// No description provided for @meetupSelectFromFirstUnit.
  ///
  /// In uk, this message translates to:
  /// **'З гуртка'**
  String get meetupSelectFromFirstUnit;

  /// No description provided for @meetupSelectFromKurin.
  ///
  /// In uk, this message translates to:
  /// **'З куреня'**
  String get meetupSelectFromKurin;

  /// No description provided for @addKurinMember.
  ///
  /// In uk, this message translates to:
  /// **'Додати учасника куреня'**
  String get addKurinMember;

  /// No description provided for @editKurinMember.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати учасника куреня'**
  String get editKurinMember;

  /// No description provided for @kurinMembers.
  ///
  /// In uk, this message translates to:
  /// **'Учасники куреня'**
  String get kurinMembers;

  /// No description provided for @noKurin.
  ///
  /// In uk, this message translates to:
  /// **'Курінь ще не створено'**
  String get noKurin;
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
      <String>['uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
