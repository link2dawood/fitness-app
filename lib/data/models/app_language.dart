enum AppLanguage {
  english('en', 'English'),
  portuguese('pt', 'português'),
  russian('ru', 'Русский'),
  arabic('ar', 'العربية', rtl: true),
  german('de', 'Deutsch'),
  traditionalChinese('zh-Hant', '繁體中文'),
  simplifiedChinese('zh-Hans', '简体中文'),
  french('fr', 'Français'),
  spanish('es', 'Español'),
  italian('it', 'Italiano'),
  korean('ko', '한국어'),
  japanese('ja', '日本語'),
  polish('pl', 'Polski'),
  turkish('tr', 'Türkçe'),
  dutch('nl', 'Nederlands'),
  indonesian('id', 'Indonesia'),
  vietnamese('vi', 'Tiếng Việt'),
  persian('fa', 'فارسی', rtl: true),
  thai('th', 'ไทย');

  const AppLanguage(this.code, this.label, {this.rtl = false});
  final String code;
  final String label;
  final bool rtl;

  static AppLanguage fromCode(String? code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => english,
  );
}
