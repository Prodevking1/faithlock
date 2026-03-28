// ignore_for_file: non_constant_identifier_names

import 'package:faithlock/core/localization/de_DE.dart';
import 'package:faithlock/core/localization/fr_FR.dart';
import 'package:faithlock/core/localization/ja_JP.dart';
import 'package:faithlock/core/localization/pt_BR.dart';
import 'package:get/get.dart';

import 'en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'fr_FR': fr_FR,
        'pt_BR': pt_BR,
        'de_DE': de_DE,
        'ja_JP': ja_JP,
      };
}
