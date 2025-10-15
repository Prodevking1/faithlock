// ignore_for_file: non_constant_identifier_names

import 'package:faithlock/core/localization/fr_FR.dart';
import 'package:get/get.dart';

import 'en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'fr_FR': fr_FR,
      };
}
