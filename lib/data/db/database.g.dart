// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoodsTable extends Foods with TableInfo<$FoodsTable, FoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultGramsMeta = const VerificationMeta(
    'defaultGrams',
  );
  @override
  late final GeneratedColumn<double> defaultGrams = GeneratedColumn<double>(
    'default_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  static const VerificationMeta _servingsJsonMeta = const VerificationMeta(
    'servingsJson',
  );
  @override
  late final GeneratedColumn<String> servingsJson = GeneratedColumn<String>(
    'servings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _liquidMeta = const VerificationMeta('liquid');
  @override
  late final GeneratedColumn<bool> liquid = GeneratedColumn<bool>(
    'liquid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("liquid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _satFatGMeta = const VerificationMeta(
    'satFatG',
  );
  @override
  late final GeneratedColumn<double> satFatG = GeneratedColumn<double>(
    'sat_fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sugarsGMeta = const VerificationMeta(
    'sugarsG',
  );
  @override
  late final GeneratedColumn<double> sugarsG = GeneratedColumn<double>(
    'sugars_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fiberGMeta = const VerificationMeta('fiberG');
  @override
  late final GeneratedColumn<double> fiberG = GeneratedColumn<double>(
    'fiber_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sodiumMgMeta = const VerificationMeta(
    'sodiumMg',
  );
  @override
  late final GeneratedColumn<double> sodiumMg = GeneratedColumn<double>(
    'sodium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitAMcgMeta = const VerificationMeta(
    'vitAMcg',
  );
  @override
  late final GeneratedColumn<double> vitAMcg = GeneratedColumn<double>(
    'vit_a_mcg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitB1MgMeta = const VerificationMeta(
    'vitB1Mg',
  );
  @override
  late final GeneratedColumn<double> vitB1Mg = GeneratedColumn<double>(
    'vit_b1_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitB2MgMeta = const VerificationMeta(
    'vitB2Mg',
  );
  @override
  late final GeneratedColumn<double> vitB2Mg = GeneratedColumn<double>(
    'vit_b2_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitB3MgMeta = const VerificationMeta(
    'vitB3Mg',
  );
  @override
  late final GeneratedColumn<double> vitB3Mg = GeneratedColumn<double>(
    'vit_b3_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitB6MgMeta = const VerificationMeta(
    'vitB6Mg',
  );
  @override
  late final GeneratedColumn<double> vitB6Mg = GeneratedColumn<double>(
    'vit_b6_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitB12UgMeta = const VerificationMeta(
    'vitB12Ug',
  );
  @override
  late final GeneratedColumn<double> vitB12Ug = GeneratedColumn<double>(
    'vit_b12_ug',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitCMgMeta = const VerificationMeta('vitCMg');
  @override
  late final GeneratedColumn<double> vitCMg = GeneratedColumn<double>(
    'vit_c_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _folateUgMeta = const VerificationMeta(
    'folateUg',
  );
  @override
  late final GeneratedColumn<double> folateUg = GeneratedColumn<double>(
    'folate_ug',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calciumMgMeta = const VerificationMeta(
    'calciumMg',
  );
  @override
  late final GeneratedColumn<double> calciumMg = GeneratedColumn<double>(
    'calcium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ironMgMeta = const VerificationMeta('ironMg');
  @override
  late final GeneratedColumn<double> ironMg = GeneratedColumn<double>(
    'iron_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _magnesiumMgMeta = const VerificationMeta(
    'magnesiumMg',
  );
  @override
  late final GeneratedColumn<double> magnesiumMg = GeneratedColumn<double>(
    'magnesium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _potassiumMgMeta = const VerificationMeta(
    'potassiumMg',
  );
  @override
  late final GeneratedColumn<double> potassiumMg = GeneratedColumn<double>(
    'potassium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zincMgMeta = const VerificationMeta('zincMg');
  @override
  late final GeneratedColumn<double> zincMg = GeneratedColumn<double>(
    'zinc_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    source,
    defaultGrams,
    servingsJson,
    liquid,
    kcal,
    proteinG,
    carbsG,
    fatG,
    satFatG,
    sugarsG,
    fiberG,
    sodiumMg,
    vitAMcg,
    vitB1Mg,
    vitB2Mg,
    vitB3Mg,
    vitB6Mg,
    vitB12Ug,
    vitCMg,
    folateUg,
    calciumMg,
    ironMg,
    magnesiumMg,
    potassiumMg,
    zincMg,
    searchText,
    barcode,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('default_grams')) {
      context.handle(
        _defaultGramsMeta,
        defaultGrams.isAcceptableOrUnknown(
          data['default_grams']!,
          _defaultGramsMeta,
        ),
      );
    }
    if (data.containsKey('servings_json')) {
      context.handle(
        _servingsJsonMeta,
        servingsJson.isAcceptableOrUnknown(
          data['servings_json']!,
          _servingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('liquid')) {
      context.handle(
        _liquidMeta,
        liquid.isAcceptableOrUnknown(data['liquid']!, _liquidMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('sat_fat_g')) {
      context.handle(
        _satFatGMeta,
        satFatG.isAcceptableOrUnknown(data['sat_fat_g']!, _satFatGMeta),
      );
    }
    if (data.containsKey('sugars_g')) {
      context.handle(
        _sugarsGMeta,
        sugarsG.isAcceptableOrUnknown(data['sugars_g']!, _sugarsGMeta),
      );
    }
    if (data.containsKey('fiber_g')) {
      context.handle(
        _fiberGMeta,
        fiberG.isAcceptableOrUnknown(data['fiber_g']!, _fiberGMeta),
      );
    }
    if (data.containsKey('sodium_mg')) {
      context.handle(
        _sodiumMgMeta,
        sodiumMg.isAcceptableOrUnknown(data['sodium_mg']!, _sodiumMgMeta),
      );
    }
    if (data.containsKey('vit_a_mcg')) {
      context.handle(
        _vitAMcgMeta,
        vitAMcg.isAcceptableOrUnknown(data['vit_a_mcg']!, _vitAMcgMeta),
      );
    }
    if (data.containsKey('vit_b1_mg')) {
      context.handle(
        _vitB1MgMeta,
        vitB1Mg.isAcceptableOrUnknown(data['vit_b1_mg']!, _vitB1MgMeta),
      );
    }
    if (data.containsKey('vit_b2_mg')) {
      context.handle(
        _vitB2MgMeta,
        vitB2Mg.isAcceptableOrUnknown(data['vit_b2_mg']!, _vitB2MgMeta),
      );
    }
    if (data.containsKey('vit_b3_mg')) {
      context.handle(
        _vitB3MgMeta,
        vitB3Mg.isAcceptableOrUnknown(data['vit_b3_mg']!, _vitB3MgMeta),
      );
    }
    if (data.containsKey('vit_b6_mg')) {
      context.handle(
        _vitB6MgMeta,
        vitB6Mg.isAcceptableOrUnknown(data['vit_b6_mg']!, _vitB6MgMeta),
      );
    }
    if (data.containsKey('vit_b12_ug')) {
      context.handle(
        _vitB12UgMeta,
        vitB12Ug.isAcceptableOrUnknown(data['vit_b12_ug']!, _vitB12UgMeta),
      );
    }
    if (data.containsKey('vit_c_mg')) {
      context.handle(
        _vitCMgMeta,
        vitCMg.isAcceptableOrUnknown(data['vit_c_mg']!, _vitCMgMeta),
      );
    }
    if (data.containsKey('folate_ug')) {
      context.handle(
        _folateUgMeta,
        folateUg.isAcceptableOrUnknown(data['folate_ug']!, _folateUgMeta),
      );
    }
    if (data.containsKey('calcium_mg')) {
      context.handle(
        _calciumMgMeta,
        calciumMg.isAcceptableOrUnknown(data['calcium_mg']!, _calciumMgMeta),
      );
    }
    if (data.containsKey('iron_mg')) {
      context.handle(
        _ironMgMeta,
        ironMg.isAcceptableOrUnknown(data['iron_mg']!, _ironMgMeta),
      );
    }
    if (data.containsKey('magnesium_mg')) {
      context.handle(
        _magnesiumMgMeta,
        magnesiumMg.isAcceptableOrUnknown(
          data['magnesium_mg']!,
          _magnesiumMgMeta,
        ),
      );
    }
    if (data.containsKey('potassium_mg')) {
      context.handle(
        _potassiumMgMeta,
        potassiumMg.isAcceptableOrUnknown(
          data['potassium_mg']!,
          _potassiumMgMeta,
        ),
      );
    }
    if (data.containsKey('zinc_mg')) {
      context.handle(
        _zincMgMeta,
        zincMg.isAcceptableOrUnknown(data['zinc_mg']!, _zincMgMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      defaultGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_grams'],
      )!,
      servingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servings_json'],
      )!,
      liquid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}liquid'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      satFatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sat_fat_g'],
      )!,
      sugarsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars_g'],
      )!,
      fiberG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_g'],
      )!,
      sodiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg'],
      )!,
      vitAMcg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_a_mcg'],
      )!,
      vitB1Mg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_b1_mg'],
      )!,
      vitB2Mg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_b2_mg'],
      )!,
      vitB3Mg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_b3_mg'],
      )!,
      vitB6Mg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_b6_mg'],
      )!,
      vitB12Ug: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_b12_ug'],
      )!,
      vitCMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_c_mg'],
      )!,
      folateUg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}folate_ug'],
      )!,
      calciumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calcium_mg'],
      )!,
      ironMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_mg'],
      )!,
      magnesiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnesium_mg'],
      )!,
      potassiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium_mg'],
      )!,
      zincMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}zinc_mg'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class FoodRow extends DataClass implements Insertable<FoodRow> {
  final String id;
  final String name;
  final String brand;
  final String source;
  final double defaultGrams;
  final String servingsJson;
  final bool liquid;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double satFatG;
  final double sugarsG;
  final double fiberG;
  final double sodiumMg;
  final double vitAMcg;
  final double vitB1Mg;
  final double vitB2Mg;
  final double vitB3Mg;
  final double vitB6Mg;
  final double vitB12Ug;
  final double vitCMg;
  final double folateUg;
  final double calciumMg;
  final double ironMg;
  final double magnesiumMg;
  final double potassiumMg;
  final double zincMg;

  /// Lowercased "name brand" for substring search.
  final String searchText;
  final String? barcode;
  final bool isFavorite;
  const FoodRow({
    required this.id,
    required this.name,
    required this.brand,
    required this.source,
    required this.defaultGrams,
    required this.servingsJson,
    required this.liquid,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.satFatG,
    required this.sugarsG,
    required this.fiberG,
    required this.sodiumMg,
    required this.vitAMcg,
    required this.vitB1Mg,
    required this.vitB2Mg,
    required this.vitB3Mg,
    required this.vitB6Mg,
    required this.vitB12Ug,
    required this.vitCMg,
    required this.folateUg,
    required this.calciumMg,
    required this.ironMg,
    required this.magnesiumMg,
    required this.potassiumMg,
    required this.zincMg,
    required this.searchText,
    this.barcode,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['source'] = Variable<String>(source);
    map['default_grams'] = Variable<double>(defaultGrams);
    map['servings_json'] = Variable<String>(servingsJson);
    map['liquid'] = Variable<bool>(liquid);
    map['kcal'] = Variable<double>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['sat_fat_g'] = Variable<double>(satFatG);
    map['sugars_g'] = Variable<double>(sugarsG);
    map['fiber_g'] = Variable<double>(fiberG);
    map['sodium_mg'] = Variable<double>(sodiumMg);
    map['vit_a_mcg'] = Variable<double>(vitAMcg);
    map['vit_b1_mg'] = Variable<double>(vitB1Mg);
    map['vit_b2_mg'] = Variable<double>(vitB2Mg);
    map['vit_b3_mg'] = Variable<double>(vitB3Mg);
    map['vit_b6_mg'] = Variable<double>(vitB6Mg);
    map['vit_b12_ug'] = Variable<double>(vitB12Ug);
    map['vit_c_mg'] = Variable<double>(vitCMg);
    map['folate_ug'] = Variable<double>(folateUg);
    map['calcium_mg'] = Variable<double>(calciumMg);
    map['iron_mg'] = Variable<double>(ironMg);
    map['magnesium_mg'] = Variable<double>(magnesiumMg);
    map['potassium_mg'] = Variable<double>(potassiumMg);
    map['zinc_mg'] = Variable<double>(zincMg);
    map['search_text'] = Variable<String>(searchText);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      brand: Value(brand),
      source: Value(source),
      defaultGrams: Value(defaultGrams),
      servingsJson: Value(servingsJson),
      liquid: Value(liquid),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      satFatG: Value(satFatG),
      sugarsG: Value(sugarsG),
      fiberG: Value(fiberG),
      sodiumMg: Value(sodiumMg),
      vitAMcg: Value(vitAMcg),
      vitB1Mg: Value(vitB1Mg),
      vitB2Mg: Value(vitB2Mg),
      vitB3Mg: Value(vitB3Mg),
      vitB6Mg: Value(vitB6Mg),
      vitB12Ug: Value(vitB12Ug),
      vitCMg: Value(vitCMg),
      folateUg: Value(folateUg),
      calciumMg: Value(calciumMg),
      ironMg: Value(ironMg),
      magnesiumMg: Value(magnesiumMg),
      potassiumMg: Value(potassiumMg),
      zincMg: Value(zincMg),
      searchText: Value(searchText),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      isFavorite: Value(isFavorite),
    );
  }

  factory FoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      source: serializer.fromJson<String>(json['source']),
      defaultGrams: serializer.fromJson<double>(json['defaultGrams']),
      servingsJson: serializer.fromJson<String>(json['servingsJson']),
      liquid: serializer.fromJson<bool>(json['liquid']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      satFatG: serializer.fromJson<double>(json['satFatG']),
      sugarsG: serializer.fromJson<double>(json['sugarsG']),
      fiberG: serializer.fromJson<double>(json['fiberG']),
      sodiumMg: serializer.fromJson<double>(json['sodiumMg']),
      vitAMcg: serializer.fromJson<double>(json['vitAMcg']),
      vitB1Mg: serializer.fromJson<double>(json['vitB1Mg']),
      vitB2Mg: serializer.fromJson<double>(json['vitB2Mg']),
      vitB3Mg: serializer.fromJson<double>(json['vitB3Mg']),
      vitB6Mg: serializer.fromJson<double>(json['vitB6Mg']),
      vitB12Ug: serializer.fromJson<double>(json['vitB12Ug']),
      vitCMg: serializer.fromJson<double>(json['vitCMg']),
      folateUg: serializer.fromJson<double>(json['folateUg']),
      calciumMg: serializer.fromJson<double>(json['calciumMg']),
      ironMg: serializer.fromJson<double>(json['ironMg']),
      magnesiumMg: serializer.fromJson<double>(json['magnesiumMg']),
      potassiumMg: serializer.fromJson<double>(json['potassiumMg']),
      zincMg: serializer.fromJson<double>(json['zincMg']),
      searchText: serializer.fromJson<String>(json['searchText']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'source': serializer.toJson<String>(source),
      'defaultGrams': serializer.toJson<double>(defaultGrams),
      'servingsJson': serializer.toJson<String>(servingsJson),
      'liquid': serializer.toJson<bool>(liquid),
      'kcal': serializer.toJson<double>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'satFatG': serializer.toJson<double>(satFatG),
      'sugarsG': serializer.toJson<double>(sugarsG),
      'fiberG': serializer.toJson<double>(fiberG),
      'sodiumMg': serializer.toJson<double>(sodiumMg),
      'vitAMcg': serializer.toJson<double>(vitAMcg),
      'vitB1Mg': serializer.toJson<double>(vitB1Mg),
      'vitB2Mg': serializer.toJson<double>(vitB2Mg),
      'vitB3Mg': serializer.toJson<double>(vitB3Mg),
      'vitB6Mg': serializer.toJson<double>(vitB6Mg),
      'vitB12Ug': serializer.toJson<double>(vitB12Ug),
      'vitCMg': serializer.toJson<double>(vitCMg),
      'folateUg': serializer.toJson<double>(folateUg),
      'calciumMg': serializer.toJson<double>(calciumMg),
      'ironMg': serializer.toJson<double>(ironMg),
      'magnesiumMg': serializer.toJson<double>(magnesiumMg),
      'potassiumMg': serializer.toJson<double>(potassiumMg),
      'zincMg': serializer.toJson<double>(zincMg),
      'searchText': serializer.toJson<String>(searchText),
      'barcode': serializer.toJson<String?>(barcode),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  FoodRow copyWith({
    String? id,
    String? name,
    String? brand,
    String? source,
    double? defaultGrams,
    String? servingsJson,
    bool? liquid,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? satFatG,
    double? sugarsG,
    double? fiberG,
    double? sodiumMg,
    double? vitAMcg,
    double? vitB1Mg,
    double? vitB2Mg,
    double? vitB3Mg,
    double? vitB6Mg,
    double? vitB12Ug,
    double? vitCMg,
    double? folateUg,
    double? calciumMg,
    double? ironMg,
    double? magnesiumMg,
    double? potassiumMg,
    double? zincMg,
    String? searchText,
    Value<String?> barcode = const Value.absent(),
    bool? isFavorite,
  }) => FoodRow(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    source: source ?? this.source,
    defaultGrams: defaultGrams ?? this.defaultGrams,
    servingsJson: servingsJson ?? this.servingsJson,
    liquid: liquid ?? this.liquid,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    satFatG: satFatG ?? this.satFatG,
    sugarsG: sugarsG ?? this.sugarsG,
    fiberG: fiberG ?? this.fiberG,
    sodiumMg: sodiumMg ?? this.sodiumMg,
    vitAMcg: vitAMcg ?? this.vitAMcg,
    vitB1Mg: vitB1Mg ?? this.vitB1Mg,
    vitB2Mg: vitB2Mg ?? this.vitB2Mg,
    vitB3Mg: vitB3Mg ?? this.vitB3Mg,
    vitB6Mg: vitB6Mg ?? this.vitB6Mg,
    vitB12Ug: vitB12Ug ?? this.vitB12Ug,
    vitCMg: vitCMg ?? this.vitCMg,
    folateUg: folateUg ?? this.folateUg,
    calciumMg: calciumMg ?? this.calciumMg,
    ironMg: ironMg ?? this.ironMg,
    magnesiumMg: magnesiumMg ?? this.magnesiumMg,
    potassiumMg: potassiumMg ?? this.potassiumMg,
    zincMg: zincMg ?? this.zincMg,
    searchText: searchText ?? this.searchText,
    barcode: barcode.present ? barcode.value : this.barcode,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  FoodRow copyWithCompanion(FoodsCompanion data) {
    return FoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      source: data.source.present ? data.source.value : this.source,
      defaultGrams: data.defaultGrams.present
          ? data.defaultGrams.value
          : this.defaultGrams,
      servingsJson: data.servingsJson.present
          ? data.servingsJson.value
          : this.servingsJson,
      liquid: data.liquid.present ? data.liquid.value : this.liquid,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      satFatG: data.satFatG.present ? data.satFatG.value : this.satFatG,
      sugarsG: data.sugarsG.present ? data.sugarsG.value : this.sugarsG,
      fiberG: data.fiberG.present ? data.fiberG.value : this.fiberG,
      sodiumMg: data.sodiumMg.present ? data.sodiumMg.value : this.sodiumMg,
      vitAMcg: data.vitAMcg.present ? data.vitAMcg.value : this.vitAMcg,
      vitB1Mg: data.vitB1Mg.present ? data.vitB1Mg.value : this.vitB1Mg,
      vitB2Mg: data.vitB2Mg.present ? data.vitB2Mg.value : this.vitB2Mg,
      vitB3Mg: data.vitB3Mg.present ? data.vitB3Mg.value : this.vitB3Mg,
      vitB6Mg: data.vitB6Mg.present ? data.vitB6Mg.value : this.vitB6Mg,
      vitB12Ug: data.vitB12Ug.present ? data.vitB12Ug.value : this.vitB12Ug,
      vitCMg: data.vitCMg.present ? data.vitCMg.value : this.vitCMg,
      folateUg: data.folateUg.present ? data.folateUg.value : this.folateUg,
      calciumMg: data.calciumMg.present ? data.calciumMg.value : this.calciumMg,
      ironMg: data.ironMg.present ? data.ironMg.value : this.ironMg,
      magnesiumMg: data.magnesiumMg.present
          ? data.magnesiumMg.value
          : this.magnesiumMg,
      potassiumMg: data.potassiumMg.present
          ? data.potassiumMg.value
          : this.potassiumMg,
      zincMg: data.zincMg.present ? data.zincMg.value : this.zincMg,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('source: $source, ')
          ..write('defaultGrams: $defaultGrams, ')
          ..write('servingsJson: $servingsJson, ')
          ..write('liquid: $liquid, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('satFatG: $satFatG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('vitAMcg: $vitAMcg, ')
          ..write('vitB1Mg: $vitB1Mg, ')
          ..write('vitB2Mg: $vitB2Mg, ')
          ..write('vitB3Mg: $vitB3Mg, ')
          ..write('vitB6Mg: $vitB6Mg, ')
          ..write('vitB12Ug: $vitB12Ug, ')
          ..write('vitCMg: $vitCMg, ')
          ..write('folateUg: $folateUg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('ironMg: $ironMg, ')
          ..write('magnesiumMg: $magnesiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('zincMg: $zincMg, ')
          ..write('searchText: $searchText, ')
          ..write('barcode: $barcode, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    brand,
    source,
    defaultGrams,
    servingsJson,
    liquid,
    kcal,
    proteinG,
    carbsG,
    fatG,
    satFatG,
    sugarsG,
    fiberG,
    sodiumMg,
    vitAMcg,
    vitB1Mg,
    vitB2Mg,
    vitB3Mg,
    vitB6Mg,
    vitB12Ug,
    vitCMg,
    folateUg,
    calciumMg,
    ironMg,
    magnesiumMg,
    potassiumMg,
    zincMg,
    searchText,
    barcode,
    isFavorite,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.source == this.source &&
          other.defaultGrams == this.defaultGrams &&
          other.servingsJson == this.servingsJson &&
          other.liquid == this.liquid &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.satFatG == this.satFatG &&
          other.sugarsG == this.sugarsG &&
          other.fiberG == this.fiberG &&
          other.sodiumMg == this.sodiumMg &&
          other.vitAMcg == this.vitAMcg &&
          other.vitB1Mg == this.vitB1Mg &&
          other.vitB2Mg == this.vitB2Mg &&
          other.vitB3Mg == this.vitB3Mg &&
          other.vitB6Mg == this.vitB6Mg &&
          other.vitB12Ug == this.vitB12Ug &&
          other.vitCMg == this.vitCMg &&
          other.folateUg == this.folateUg &&
          other.calciumMg == this.calciumMg &&
          other.ironMg == this.ironMg &&
          other.magnesiumMg == this.magnesiumMg &&
          other.potassiumMg == this.potassiumMg &&
          other.zincMg == this.zincMg &&
          other.searchText == this.searchText &&
          other.barcode == this.barcode &&
          other.isFavorite == this.isFavorite);
}

class FoodsCompanion extends UpdateCompanion<FoodRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> brand;
  final Value<String> source;
  final Value<double> defaultGrams;
  final Value<String> servingsJson;
  final Value<bool> liquid;
  final Value<double> kcal;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<double> satFatG;
  final Value<double> sugarsG;
  final Value<double> fiberG;
  final Value<double> sodiumMg;
  final Value<double> vitAMcg;
  final Value<double> vitB1Mg;
  final Value<double> vitB2Mg;
  final Value<double> vitB3Mg;
  final Value<double> vitB6Mg;
  final Value<double> vitB12Ug;
  final Value<double> vitCMg;
  final Value<double> folateUg;
  final Value<double> calciumMg;
  final Value<double> ironMg;
  final Value<double> magnesiumMg;
  final Value<double> potassiumMg;
  final Value<double> zincMg;
  final Value<String> searchText;
  final Value<String?> barcode;
  final Value<bool> isFavorite;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.source = const Value.absent(),
    this.defaultGrams = const Value.absent(),
    this.servingsJson = const Value.absent(),
    this.liquid = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.satFatG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.vitAMcg = const Value.absent(),
    this.vitB1Mg = const Value.absent(),
    this.vitB2Mg = const Value.absent(),
    this.vitB3Mg = const Value.absent(),
    this.vitB6Mg = const Value.absent(),
    this.vitB12Ug = const Value.absent(),
    this.vitCMg = const Value.absent(),
    this.folateUg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.magnesiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.zincMg = const Value.absent(),
    this.searchText = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    required String id,
    required String name,
    this.brand = const Value.absent(),
    required String source,
    this.defaultGrams = const Value.absent(),
    this.servingsJson = const Value.absent(),
    this.liquid = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.satFatG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.vitAMcg = const Value.absent(),
    this.vitB1Mg = const Value.absent(),
    this.vitB2Mg = const Value.absent(),
    this.vitB3Mg = const Value.absent(),
    this.vitB6Mg = const Value.absent(),
    this.vitB12Ug = const Value.absent(),
    this.vitCMg = const Value.absent(),
    this.folateUg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.magnesiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.zincMg = const Value.absent(),
    required String searchText,
    this.barcode = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       source = Value(source),
       searchText = Value(searchText);
  static Insertable<FoodRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? source,
    Expression<double>? defaultGrams,
    Expression<String>? servingsJson,
    Expression<bool>? liquid,
    Expression<double>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<double>? satFatG,
    Expression<double>? sugarsG,
    Expression<double>? fiberG,
    Expression<double>? sodiumMg,
    Expression<double>? vitAMcg,
    Expression<double>? vitB1Mg,
    Expression<double>? vitB2Mg,
    Expression<double>? vitB3Mg,
    Expression<double>? vitB6Mg,
    Expression<double>? vitB12Ug,
    Expression<double>? vitCMg,
    Expression<double>? folateUg,
    Expression<double>? calciumMg,
    Expression<double>? ironMg,
    Expression<double>? magnesiumMg,
    Expression<double>? potassiumMg,
    Expression<double>? zincMg,
    Expression<String>? searchText,
    Expression<String>? barcode,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (source != null) 'source': source,
      if (defaultGrams != null) 'default_grams': defaultGrams,
      if (servingsJson != null) 'servings_json': servingsJson,
      if (liquid != null) 'liquid': liquid,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (satFatG != null) 'sat_fat_g': satFatG,
      if (sugarsG != null) 'sugars_g': sugarsG,
      if (fiberG != null) 'fiber_g': fiberG,
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
      if (vitAMcg != null) 'vit_a_mcg': vitAMcg,
      if (vitB1Mg != null) 'vit_b1_mg': vitB1Mg,
      if (vitB2Mg != null) 'vit_b2_mg': vitB2Mg,
      if (vitB3Mg != null) 'vit_b3_mg': vitB3Mg,
      if (vitB6Mg != null) 'vit_b6_mg': vitB6Mg,
      if (vitB12Ug != null) 'vit_b12_ug': vitB12Ug,
      if (vitCMg != null) 'vit_c_mg': vitCMg,
      if (folateUg != null) 'folate_ug': folateUg,
      if (calciumMg != null) 'calcium_mg': calciumMg,
      if (ironMg != null) 'iron_mg': ironMg,
      if (magnesiumMg != null) 'magnesium_mg': magnesiumMg,
      if (potassiumMg != null) 'potassium_mg': potassiumMg,
      if (zincMg != null) 'zinc_mg': zincMg,
      if (searchText != null) 'search_text': searchText,
      if (barcode != null) 'barcode': barcode,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? brand,
    Value<String>? source,
    Value<double>? defaultGrams,
    Value<String>? servingsJson,
    Value<bool>? liquid,
    Value<double>? kcal,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<double>? satFatG,
    Value<double>? sugarsG,
    Value<double>? fiberG,
    Value<double>? sodiumMg,
    Value<double>? vitAMcg,
    Value<double>? vitB1Mg,
    Value<double>? vitB2Mg,
    Value<double>? vitB3Mg,
    Value<double>? vitB6Mg,
    Value<double>? vitB12Ug,
    Value<double>? vitCMg,
    Value<double>? folateUg,
    Value<double>? calciumMg,
    Value<double>? ironMg,
    Value<double>? magnesiumMg,
    Value<double>? potassiumMg,
    Value<double>? zincMg,
    Value<String>? searchText,
    Value<String?>? barcode,
    Value<bool>? isFavorite,
    Value<int>? rowid,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      source: source ?? this.source,
      defaultGrams: defaultGrams ?? this.defaultGrams,
      servingsJson: servingsJson ?? this.servingsJson,
      liquid: liquid ?? this.liquid,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      satFatG: satFatG ?? this.satFatG,
      sugarsG: sugarsG ?? this.sugarsG,
      fiberG: fiberG ?? this.fiberG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      vitAMcg: vitAMcg ?? this.vitAMcg,
      vitB1Mg: vitB1Mg ?? this.vitB1Mg,
      vitB2Mg: vitB2Mg ?? this.vitB2Mg,
      vitB3Mg: vitB3Mg ?? this.vitB3Mg,
      vitB6Mg: vitB6Mg ?? this.vitB6Mg,
      vitB12Ug: vitB12Ug ?? this.vitB12Ug,
      vitCMg: vitCMg ?? this.vitCMg,
      folateUg: folateUg ?? this.folateUg,
      calciumMg: calciumMg ?? this.calciumMg,
      ironMg: ironMg ?? this.ironMg,
      magnesiumMg: magnesiumMg ?? this.magnesiumMg,
      potassiumMg: potassiumMg ?? this.potassiumMg,
      zincMg: zincMg ?? this.zincMg,
      searchText: searchText ?? this.searchText,
      barcode: barcode ?? this.barcode,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (defaultGrams.present) {
      map['default_grams'] = Variable<double>(defaultGrams.value);
    }
    if (servingsJson.present) {
      map['servings_json'] = Variable<String>(servingsJson.value);
    }
    if (liquid.present) {
      map['liquid'] = Variable<bool>(liquid.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (satFatG.present) {
      map['sat_fat_g'] = Variable<double>(satFatG.value);
    }
    if (sugarsG.present) {
      map['sugars_g'] = Variable<double>(sugarsG.value);
    }
    if (fiberG.present) {
      map['fiber_g'] = Variable<double>(fiberG.value);
    }
    if (sodiumMg.present) {
      map['sodium_mg'] = Variable<double>(sodiumMg.value);
    }
    if (vitAMcg.present) {
      map['vit_a_mcg'] = Variable<double>(vitAMcg.value);
    }
    if (vitB1Mg.present) {
      map['vit_b1_mg'] = Variable<double>(vitB1Mg.value);
    }
    if (vitB2Mg.present) {
      map['vit_b2_mg'] = Variable<double>(vitB2Mg.value);
    }
    if (vitB3Mg.present) {
      map['vit_b3_mg'] = Variable<double>(vitB3Mg.value);
    }
    if (vitB6Mg.present) {
      map['vit_b6_mg'] = Variable<double>(vitB6Mg.value);
    }
    if (vitB12Ug.present) {
      map['vit_b12_ug'] = Variable<double>(vitB12Ug.value);
    }
    if (vitCMg.present) {
      map['vit_c_mg'] = Variable<double>(vitCMg.value);
    }
    if (folateUg.present) {
      map['folate_ug'] = Variable<double>(folateUg.value);
    }
    if (calciumMg.present) {
      map['calcium_mg'] = Variable<double>(calciumMg.value);
    }
    if (ironMg.present) {
      map['iron_mg'] = Variable<double>(ironMg.value);
    }
    if (magnesiumMg.present) {
      map['magnesium_mg'] = Variable<double>(magnesiumMg.value);
    }
    if (potassiumMg.present) {
      map['potassium_mg'] = Variable<double>(potassiumMg.value);
    }
    if (zincMg.present) {
      map['zinc_mg'] = Variable<double>(zincMg.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('source: $source, ')
          ..write('defaultGrams: $defaultGrams, ')
          ..write('servingsJson: $servingsJson, ')
          ..write('liquid: $liquid, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('satFatG: $satFatG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('vitAMcg: $vitAMcg, ')
          ..write('vitB1Mg: $vitB1Mg, ')
          ..write('vitB2Mg: $vitB2Mg, ')
          ..write('vitB3Mg: $vitB3Mg, ')
          ..write('vitB6Mg: $vitB6Mg, ')
          ..write('vitB12Ug: $vitB12Ug, ')
          ..write('vitCMg: $vitCMg, ')
          ..write('folateUg: $folateUg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('ironMg: $ironMg, ')
          ..write('magnesiumMg: $magnesiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('zincMg: $zincMg, ')
          ..write('searchText: $searchText, ')
          ..write('barcode: $barcode, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('g'),
  );
  static const VerificationMeta _servingCountMeta = const VerificationMeta(
    'servingCount',
  );
  @override
  late final GeneratedColumn<double> servingCount = GeneratedColumn<double>(
    'serving_count',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingGramsMeta = const VerificationMeta(
    'servingGrams',
  );
  @override
  late final GeneratedColumn<double> servingGrams = GeneratedColumn<double>(
    'serving_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _satFatGMeta = const VerificationMeta(
    'satFatG',
  );
  @override
  late final GeneratedColumn<double> satFatG = GeneratedColumn<double>(
    'sat_fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sugarsGMeta = const VerificationMeta(
    'sugarsG',
  );
  @override
  late final GeneratedColumn<double> sugarsG = GeneratedColumn<double>(
    'sugars_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fiberGMeta = const VerificationMeta('fiberG');
  @override
  late final GeneratedColumn<double> fiberG = GeneratedColumn<double>(
    'fiber_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sodiumMgMeta = const VerificationMeta(
    'sodiumMg',
  );
  @override
  late final GeneratedColumn<double> sodiumMg = GeneratedColumn<double>(
    'sodium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vitCMgMeta = const VerificationMeta('vitCMg');
  @override
  late final GeneratedColumn<double> vitCMg = GeneratedColumn<double>(
    'vit_c_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calciumMgMeta = const VerificationMeta(
    'calciumMg',
  );
  @override
  late final GeneratedColumn<double> calciumMg = GeneratedColumn<double>(
    'calcium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ironMgMeta = const VerificationMeta('ironMg');
  @override
  late final GeneratedColumn<double> ironMg = GeneratedColumn<double>(
    'iron_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _potassiumMgMeta = const VerificationMeta(
    'potassiumMg',
  );
  @override
  late final GeneratedColumn<double> potassiumMg = GeneratedColumn<double>(
    'potassium_mg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    meal,
    foodId,
    name,
    brand,
    source,
    grams,
    unit,
    servingCount,
    servingGrams,
    servingLabel,
    kcal,
    proteinG,
    carbsG,
    fatG,
    satFatG,
    sugarsG,
    fiberG,
    sodiumMg,
    vitCMg,
    calciumMg,
    ironMg,
    potassiumMg,
    photoPath,
    createdAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('serving_count')) {
      context.handle(
        _servingCountMeta,
        servingCount.isAcceptableOrUnknown(
          data['serving_count']!,
          _servingCountMeta,
        ),
      );
    }
    if (data.containsKey('serving_grams')) {
      context.handle(
        _servingGramsMeta,
        servingGrams.isAcceptableOrUnknown(
          data['serving_grams']!,
          _servingGramsMeta,
        ),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('sat_fat_g')) {
      context.handle(
        _satFatGMeta,
        satFatG.isAcceptableOrUnknown(data['sat_fat_g']!, _satFatGMeta),
      );
    }
    if (data.containsKey('sugars_g')) {
      context.handle(
        _sugarsGMeta,
        sugarsG.isAcceptableOrUnknown(data['sugars_g']!, _sugarsGMeta),
      );
    }
    if (data.containsKey('fiber_g')) {
      context.handle(
        _fiberGMeta,
        fiberG.isAcceptableOrUnknown(data['fiber_g']!, _fiberGMeta),
      );
    }
    if (data.containsKey('sodium_mg')) {
      context.handle(
        _sodiumMgMeta,
        sodiumMg.isAcceptableOrUnknown(data['sodium_mg']!, _sodiumMgMeta),
      );
    }
    if (data.containsKey('vit_c_mg')) {
      context.handle(
        _vitCMgMeta,
        vitCMg.isAcceptableOrUnknown(data['vit_c_mg']!, _vitCMgMeta),
      );
    }
    if (data.containsKey('calcium_mg')) {
      context.handle(
        _calciumMgMeta,
        calciumMg.isAcceptableOrUnknown(data['calcium_mg']!, _calciumMgMeta),
      );
    }
    if (data.containsKey('iron_mg')) {
      context.handle(
        _ironMgMeta,
        ironMg.isAcceptableOrUnknown(data['iron_mg']!, _ironMgMeta),
      );
    }
    if (data.containsKey('potassium_mg')) {
      context.handle(
        _potassiumMgMeta,
        potassiumMg.isAcceptableOrUnknown(
          data['potassium_mg']!,
          _potassiumMgMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      servingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_count'],
      ),
      servingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_grams'],
      ),
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      satFatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sat_fat_g'],
      )!,
      sugarsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars_g'],
      )!,
      fiberG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_g'],
      )!,
      sodiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg'],
      )!,
      vitCMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vit_c_mg'],
      )!,
      calciumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calcium_mg'],
      )!,
      ironMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_mg'],
      )!,
      potassiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium_mg'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }
}

class LogEntryRow extends DataClass implements Insertable<LogEntryRow> {
  final String id;
  final String day;
  final String meal;
  final String foodId;
  final String name;
  final String brand;
  final String source;

  /// Amount consumed. [unit] interprets grams: 'g' | 'ml' | 'serving'.
  /// [grams] always stores the resolved gram weight.
  final double grams;
  final String unit;
  final double? servingCount;
  final double? servingGrams;
  final String? servingLabel;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double satFatG;
  final double sugarsG;
  final double fiberG;
  final double sodiumMg;
  final double vitCMg;
  final double calciumMg;
  final double ironMg;
  final double potassiumMg;
  final String? photoPath;
  final DateTime createdAt;

  /// Manual ordering within (day, meal) (v3). Legacy rows backfilled by
  /// created_at.
  final int sortOrder;
  const LogEntryRow({
    required this.id,
    required this.day,
    required this.meal,
    required this.foodId,
    required this.name,
    required this.brand,
    required this.source,
    required this.grams,
    required this.unit,
    this.servingCount,
    this.servingGrams,
    this.servingLabel,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.satFatG,
    required this.sugarsG,
    required this.fiberG,
    required this.sodiumMg,
    required this.vitCMg,
    required this.calciumMg,
    required this.ironMg,
    required this.potassiumMg,
    this.photoPath,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['meal'] = Variable<String>(meal);
    map['food_id'] = Variable<String>(foodId);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['source'] = Variable<String>(source);
    map['grams'] = Variable<double>(grams);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || servingCount != null) {
      map['serving_count'] = Variable<double>(servingCount);
    }
    if (!nullToAbsent || servingGrams != null) {
      map['serving_grams'] = Variable<double>(servingGrams);
    }
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    map['kcal'] = Variable<double>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['sat_fat_g'] = Variable<double>(satFatG);
    map['sugars_g'] = Variable<double>(sugarsG);
    map['fiber_g'] = Variable<double>(fiberG);
    map['sodium_mg'] = Variable<double>(sodiumMg);
    map['vit_c_mg'] = Variable<double>(vitCMg);
    map['calcium_mg'] = Variable<double>(calciumMg);
    map['iron_mg'] = Variable<double>(ironMg);
    map['potassium_mg'] = Variable<double>(potassiumMg);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      day: Value(day),
      meal: Value(meal),
      foodId: Value(foodId),
      name: Value(name),
      brand: Value(brand),
      source: Value(source),
      grams: Value(grams),
      unit: Value(unit),
      servingCount: servingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(servingCount),
      servingGrams: servingGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(servingGrams),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      satFatG: Value(satFatG),
      sugarsG: Value(sugarsG),
      fiberG: Value(fiberG),
      sodiumMg: Value(sodiumMg),
      vitCMg: Value(vitCMg),
      calciumMg: Value(calciumMg),
      ironMg: Value(ironMg),
      potassiumMg: Value(potassiumMg),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory LogEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntryRow(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      meal: serializer.fromJson<String>(json['meal']),
      foodId: serializer.fromJson<String>(json['foodId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      source: serializer.fromJson<String>(json['source']),
      grams: serializer.fromJson<double>(json['grams']),
      unit: serializer.fromJson<String>(json['unit']),
      servingCount: serializer.fromJson<double?>(json['servingCount']),
      servingGrams: serializer.fromJson<double?>(json['servingGrams']),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      satFatG: serializer.fromJson<double>(json['satFatG']),
      sugarsG: serializer.fromJson<double>(json['sugarsG']),
      fiberG: serializer.fromJson<double>(json['fiberG']),
      sodiumMg: serializer.fromJson<double>(json['sodiumMg']),
      vitCMg: serializer.fromJson<double>(json['vitCMg']),
      calciumMg: serializer.fromJson<double>(json['calciumMg']),
      ironMg: serializer.fromJson<double>(json['ironMg']),
      potassiumMg: serializer.fromJson<double>(json['potassiumMg']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'meal': serializer.toJson<String>(meal),
      'foodId': serializer.toJson<String>(foodId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'source': serializer.toJson<String>(source),
      'grams': serializer.toJson<double>(grams),
      'unit': serializer.toJson<String>(unit),
      'servingCount': serializer.toJson<double?>(servingCount),
      'servingGrams': serializer.toJson<double?>(servingGrams),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'kcal': serializer.toJson<double>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'satFatG': serializer.toJson<double>(satFatG),
      'sugarsG': serializer.toJson<double>(sugarsG),
      'fiberG': serializer.toJson<double>(fiberG),
      'sodiumMg': serializer.toJson<double>(sodiumMg),
      'vitCMg': serializer.toJson<double>(vitCMg),
      'calciumMg': serializer.toJson<double>(calciumMg),
      'ironMg': serializer.toJson<double>(ironMg),
      'potassiumMg': serializer.toJson<double>(potassiumMg),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LogEntryRow copyWith({
    String? id,
    String? day,
    String? meal,
    String? foodId,
    String? name,
    String? brand,
    String? source,
    double? grams,
    String? unit,
    Value<double?> servingCount = const Value.absent(),
    Value<double?> servingGrams = const Value.absent(),
    Value<String?> servingLabel = const Value.absent(),
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? satFatG,
    double? sugarsG,
    double? fiberG,
    double? sodiumMg,
    double? vitCMg,
    double? calciumMg,
    double? ironMg,
    double? potassiumMg,
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
    int? sortOrder,
  }) => LogEntryRow(
    id: id ?? this.id,
    day: day ?? this.day,
    meal: meal ?? this.meal,
    foodId: foodId ?? this.foodId,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    source: source ?? this.source,
    grams: grams ?? this.grams,
    unit: unit ?? this.unit,
    servingCount: servingCount.present ? servingCount.value : this.servingCount,
    servingGrams: servingGrams.present ? servingGrams.value : this.servingGrams,
    servingLabel: servingLabel.present ? servingLabel.value : this.servingLabel,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    satFatG: satFatG ?? this.satFatG,
    sugarsG: sugarsG ?? this.sugarsG,
    fiberG: fiberG ?? this.fiberG,
    sodiumMg: sodiumMg ?? this.sodiumMg,
    vitCMg: vitCMg ?? this.vitCMg,
    calciumMg: calciumMg ?? this.calciumMg,
    ironMg: ironMg ?? this.ironMg,
    potassiumMg: potassiumMg ?? this.potassiumMg,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LogEntryRow copyWithCompanion(LogEntriesCompanion data) {
    return LogEntryRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      source: data.source.present ? data.source.value : this.source,
      grams: data.grams.present ? data.grams.value : this.grams,
      unit: data.unit.present ? data.unit.value : this.unit,
      servingCount: data.servingCount.present
          ? data.servingCount.value
          : this.servingCount,
      servingGrams: data.servingGrams.present
          ? data.servingGrams.value
          : this.servingGrams,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      satFatG: data.satFatG.present ? data.satFatG.value : this.satFatG,
      sugarsG: data.sugarsG.present ? data.sugarsG.value : this.sugarsG,
      fiberG: data.fiberG.present ? data.fiberG.value : this.fiberG,
      sodiumMg: data.sodiumMg.present ? data.sodiumMg.value : this.sodiumMg,
      vitCMg: data.vitCMg.present ? data.vitCMg.value : this.vitCMg,
      calciumMg: data.calciumMg.present ? data.calciumMg.value : this.calciumMg,
      ironMg: data.ironMg.present ? data.ironMg.value : this.ironMg,
      potassiumMg: data.potassiumMg.present
          ? data.potassiumMg.value
          : this.potassiumMg,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntryRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('source: $source, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('servingCount: $servingCount, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('satFatG: $satFatG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('vitCMg: $vitCMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('ironMg: $ironMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    day,
    meal,
    foodId,
    name,
    brand,
    source,
    grams,
    unit,
    servingCount,
    servingGrams,
    servingLabel,
    kcal,
    proteinG,
    carbsG,
    fatG,
    satFatG,
    sugarsG,
    fiberG,
    sodiumMg,
    vitCMg,
    calciumMg,
    ironMg,
    potassiumMg,
    photoPath,
    createdAt,
    sortOrder,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntryRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.meal == this.meal &&
          other.foodId == this.foodId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.source == this.source &&
          other.grams == this.grams &&
          other.unit == this.unit &&
          other.servingCount == this.servingCount &&
          other.servingGrams == this.servingGrams &&
          other.servingLabel == this.servingLabel &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.satFatG == this.satFatG &&
          other.sugarsG == this.sugarsG &&
          other.fiberG == this.fiberG &&
          other.sodiumMg == this.sodiumMg &&
          other.vitCMg == this.vitCMg &&
          other.calciumMg == this.calciumMg &&
          other.ironMg == this.ironMg &&
          other.potassiumMg == this.potassiumMg &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntryRow> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> meal;
  final Value<String> foodId;
  final Value<String> name;
  final Value<String> brand;
  final Value<String> source;
  final Value<double> grams;
  final Value<String> unit;
  final Value<double?> servingCount;
  final Value<double?> servingGrams;
  final Value<String?> servingLabel;
  final Value<double> kcal;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<double> satFatG;
  final Value<double> sugarsG;
  final Value<double> fiberG;
  final Value<double> sodiumMg;
  final Value<double> vitCMg;
  final Value<double> calciumMg;
  final Value<double> ironMg;
  final Value<double> potassiumMg;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.source = const Value.absent(),
    this.grams = const Value.absent(),
    this.unit = const Value.absent(),
    this.servingCount = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.satFatG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.vitCMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    required String id,
    required String day,
    required String meal,
    required String foodId,
    required String name,
    this.brand = const Value.absent(),
    required String source,
    required double grams,
    this.unit = const Value.absent(),
    this.servingCount = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    required double kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
    this.satFatG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.vitCMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.photoPath = const Value.absent(),
    required DateTime createdAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       meal = Value(meal),
       foodId = Value(foodId),
       name = Value(name),
       source = Value(source),
       grams = Value(grams),
       kcal = Value(kcal),
       proteinG = Value(proteinG),
       carbsG = Value(carbsG),
       fatG = Value(fatG),
       createdAt = Value(createdAt);
  static Insertable<LogEntryRow> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? meal,
    Expression<String>? foodId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? source,
    Expression<double>? grams,
    Expression<String>? unit,
    Expression<double>? servingCount,
    Expression<double>? servingGrams,
    Expression<String>? servingLabel,
    Expression<double>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<double>? satFatG,
    Expression<double>? sugarsG,
    Expression<double>? fiberG,
    Expression<double>? sodiumMg,
    Expression<double>? vitCMg,
    Expression<double>? calciumMg,
    Expression<double>? ironMg,
    Expression<double>? potassiumMg,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (meal != null) 'meal': meal,
      if (foodId != null) 'food_id': foodId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (source != null) 'source': source,
      if (grams != null) 'grams': grams,
      if (unit != null) 'unit': unit,
      if (servingCount != null) 'serving_count': servingCount,
      if (servingGrams != null) 'serving_grams': servingGrams,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (satFatG != null) 'sat_fat_g': satFatG,
      if (sugarsG != null) 'sugars_g': sugarsG,
      if (fiberG != null) 'fiber_g': fiberG,
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
      if (vitCMg != null) 'vit_c_mg': vitCMg,
      if (calciumMg != null) 'calcium_mg': calciumMg,
      if (ironMg != null) 'iron_mg': ironMg,
      if (potassiumMg != null) 'potassium_mg': potassiumMg,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? meal,
    Value<String>? foodId,
    Value<String>? name,
    Value<String>? brand,
    Value<String>? source,
    Value<double>? grams,
    Value<String>? unit,
    Value<double?>? servingCount,
    Value<double?>? servingGrams,
    Value<String?>? servingLabel,
    Value<double>? kcal,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<double>? satFatG,
    Value<double>? sugarsG,
    Value<double>? fiberG,
    Value<double>? sodiumMg,
    Value<double>? vitCMg,
    Value<double>? calciumMg,
    Value<double>? ironMg,
    Value<double>? potassiumMg,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      meal: meal ?? this.meal,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      source: source ?? this.source,
      grams: grams ?? this.grams,
      unit: unit ?? this.unit,
      servingCount: servingCount ?? this.servingCount,
      servingGrams: servingGrams ?? this.servingGrams,
      servingLabel: servingLabel ?? this.servingLabel,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      satFatG: satFatG ?? this.satFatG,
      sugarsG: sugarsG ?? this.sugarsG,
      fiberG: fiberG ?? this.fiberG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      vitCMg: vitCMg ?? this.vitCMg,
      calciumMg: calciumMg ?? this.calciumMg,
      ironMg: ironMg ?? this.ironMg,
      potassiumMg: potassiumMg ?? this.potassiumMg,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (servingCount.present) {
      map['serving_count'] = Variable<double>(servingCount.value);
    }
    if (servingGrams.present) {
      map['serving_grams'] = Variable<double>(servingGrams.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (satFatG.present) {
      map['sat_fat_g'] = Variable<double>(satFatG.value);
    }
    if (sugarsG.present) {
      map['sugars_g'] = Variable<double>(sugarsG.value);
    }
    if (fiberG.present) {
      map['fiber_g'] = Variable<double>(fiberG.value);
    }
    if (sodiumMg.present) {
      map['sodium_mg'] = Variable<double>(sodiumMg.value);
    }
    if (vitCMg.present) {
      map['vit_c_mg'] = Variable<double>(vitCMg.value);
    }
    if (calciumMg.present) {
      map['calcium_mg'] = Variable<double>(calciumMg.value);
    }
    if (ironMg.present) {
      map['iron_mg'] = Variable<double>(ironMg.value);
    }
    if (potassiumMg.present) {
      map['potassium_mg'] = Variable<double>(potassiumMg.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('source: $source, ')
          ..write('grams: $grams, ')
          ..write('unit: $unit, ')
          ..write('servingCount: $servingCount, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('satFatG: $satFatG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('vitCMg: $vitCMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('ironMg: $ironMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, RecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, servings, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeRow extends DataClass implements Insertable<RecipeRow> {
  final String id;
  final String name;
  final int servings;
  final DateTime createdAt;
  const RecipeRow({
    required this.id,
    required this.name,
    required this.servings,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['servings'] = Variable<int>(servings);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      servings: Value(servings),
      createdAt: Value(createdAt),
    );
  }

  factory RecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      servings: serializer.fromJson<int>(json['servings']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'servings': serializer.toJson<int>(servings),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecipeRow copyWith({
    String? id,
    String? name,
    int? servings,
    DateTime? createdAt,
  }) => RecipeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    servings: servings ?? this.servings,
    createdAt: createdAt ?? this.createdAt,
  );
  RecipeRow copyWithCompanion(RecipesCompanion data) {
    return RecipeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      servings: data.servings.present ? data.servings.value : this.servings,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, servings, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.servings == this.servings &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<RecipeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> servings;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.servings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String name,
    this.servings = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<RecipeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? servings,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (servings != null) 'servings': servings,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? servings,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeItemsTable extends RecipeItems
    with TableInfo<$RecipeItemsTable, RecipeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('g'),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    foodId,
    name,
    brand,
    grams,
    qty,
    unit,
    kcal,
    proteinG,
    carbsG,
    fatG,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
    );
  }

  @override
  $RecipeItemsTable createAlias(String alias) {
    return $RecipeItemsTable(attachedDatabase, alias);
  }
}

class RecipeItem extends DataClass implements Insertable<RecipeItem> {
  final String id;
  final String recipeId;
  final String foodId;
  final String name;
  final String brand;
  final double grams;

  /// User-entered amount + unit (v4). [grams] stays the resolved canonical
  /// weight; [qty]/[unit] preserve display intent (e.g. 1.5 tbsp).
  final double qty;
  final String unit;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  const RecipeItem({
    required this.id,
    required this.recipeId,
    required this.foodId,
    required this.name,
    required this.brand,
    required this.grams,
    required this.qty,
    required this.unit,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['food_id'] = Variable<String>(foodId);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['grams'] = Variable<double>(grams);
    map['qty'] = Variable<double>(qty);
    map['unit'] = Variable<String>(unit);
    map['kcal'] = Variable<double>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    return map;
  }

  RecipeItemsCompanion toCompanion(bool nullToAbsent) {
    return RecipeItemsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      foodId: Value(foodId),
      name: Value(name),
      brand: Value(brand),
      grams: Value(grams),
      qty: Value(qty),
      unit: Value(unit),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
    );
  }

  factory RecipeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeItem(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      grams: serializer.fromJson<double>(json['grams']),
      qty: serializer.fromJson<double>(json['qty']),
      unit: serializer.fromJson<String>(json['unit']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'foodId': serializer.toJson<String>(foodId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'grams': serializer.toJson<double>(grams),
      'qty': serializer.toJson<double>(qty),
      'unit': serializer.toJson<String>(unit),
      'kcal': serializer.toJson<double>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
    };
  }

  RecipeItem copyWith({
    String? id,
    String? recipeId,
    String? foodId,
    String? name,
    String? brand,
    double? grams,
    double? qty,
    String? unit,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) => RecipeItem(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    foodId: foodId ?? this.foodId,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    grams: grams ?? this.grams,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
  );
  RecipeItem copyWithCompanion(RecipeItemsCompanion data) {
    return RecipeItem(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      grams: data.grams.present ? data.grams.value : this.grams,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItem(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('grams: $grams, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    foodId,
    name,
    brand,
    grams,
    qty,
    unit,
    kcal,
    proteinG,
    carbsG,
    fatG,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeItem &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.foodId == this.foodId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.grams == this.grams &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG);
}

class RecipeItemsCompanion extends UpdateCompanion<RecipeItem> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> foodId;
  final Value<String> name;
  final Value<String> brand;
  final Value<double> grams;
  final Value<double> qty;
  final Value<String> unit;
  final Value<double> kcal;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<int> rowid;
  const RecipeItemsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.grams = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeItemsCompanion.insert({
    required String id,
    required String recipeId,
    required String foodId,
    required String name,
    this.brand = const Value.absent(),
    required double grams,
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       foodId = Value(foodId),
       name = Value(name),
       grams = Value(grams);
  static Insertable<RecipeItem> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? foodId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<double>? grams,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<double>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (foodId != null) 'food_id': foodId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (grams != null) 'grams': grams,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String>? foodId,
    Value<String>? name,
    Value<String>? brand,
    Value<double>? grams,
    Value<double>? qty,
    Value<String>? unit,
    Value<double>? kcal,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<int>? rowid,
  }) {
    return RecipeItemsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      grams: grams ?? this.grams,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeItemsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodId: $foodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('grams: $grams, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<String> activity = GeneratedColumn<String>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyRateKgMeta = const VerificationMeta(
    'weeklyRateKg',
  );
  @override
  late final GeneratedColumn<double> weeklyRateKg = GeneratedColumn<double>(
    'weekly_rate_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _customKcalTargetMeta = const VerificationMeta(
    'customKcalTarget',
  );
  @override
  late final GeneratedColumn<int> customKcalTarget = GeneratedColumn<int>(
    'custom_kcal_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinPctMeta = const VerificationMeta(
    'proteinPct',
  );
  @override
  late final GeneratedColumn<double> proteinPct = GeneratedColumn<double>(
    'protein_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.30),
  );
  static const VerificationMeta _carbsPctMeta = const VerificationMeta(
    'carbsPct',
  );
  @override
  late final GeneratedColumn<double> carbsPct = GeneratedColumn<double>(
    'carbs_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.40),
  );
  static const VerificationMeta _fatPctMeta = const VerificationMeta('fatPct');
  @override
  late final GeneratedColumn<double> fatPct = GeneratedColumn<double>(
    'fat_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.30),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sex,
    ageYears,
    heightCm,
    weightKg,
    activity,
    goal,
    weeklyRateKg,
    customKcalTarget,
    proteinPct,
    carbsPct,
    fatPct,
    onboarded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    } else if (isInserting) {
      context.missing(_activityMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('weekly_rate_kg')) {
      context.handle(
        _weeklyRateKgMeta,
        weeklyRateKg.isAcceptableOrUnknown(
          data['weekly_rate_kg']!,
          _weeklyRateKgMeta,
        ),
      );
    }
    if (data.containsKey('custom_kcal_target')) {
      context.handle(
        _customKcalTargetMeta,
        customKcalTarget.isAcceptableOrUnknown(
          data['custom_kcal_target']!,
          _customKcalTargetMeta,
        ),
      );
    }
    if (data.containsKey('protein_pct')) {
      context.handle(
        _proteinPctMeta,
        proteinPct.isAcceptableOrUnknown(data['protein_pct']!, _proteinPctMeta),
      );
    }
    if (data.containsKey('carbs_pct')) {
      context.handle(
        _carbsPctMeta,
        carbsPct.isAcceptableOrUnknown(data['carbs_pct']!, _carbsPctMeta),
      );
    }
    if (data.containsKey('fat_pct')) {
      context.handle(
        _fatPctMeta,
        fatPct.isAcceptableOrUnknown(data['fat_pct']!, _fatPctMeta),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      weeklyRateKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_rate_kg'],
      )!,
      customKcalTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_kcal_target'],
      ),
      proteinPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_pct'],
      )!,
      carbsPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_pct'],
      )!,
      fatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_pct'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String name;
  final String sex;
  final int ageYears;
  final double heightCm;
  final double weightKg;
  final String activity;
  final String goal;
  final double weeklyRateKg;
  final int? customKcalTarget;
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final bool onboarded;
  const ProfileRow({
    required this.id,
    required this.name,
    required this.sex,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.goal,
    required this.weeklyRateKg,
    this.customKcalTarget,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.onboarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<String>(sex);
    map['age_years'] = Variable<int>(ageYears);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['activity'] = Variable<String>(activity);
    map['goal'] = Variable<String>(goal);
    map['weekly_rate_kg'] = Variable<double>(weeklyRateKg);
    if (!nullToAbsent || customKcalTarget != null) {
      map['custom_kcal_target'] = Variable<int>(customKcalTarget);
    }
    map['protein_pct'] = Variable<double>(proteinPct);
    map['carbs_pct'] = Variable<double>(carbsPct);
    map['fat_pct'] = Variable<double>(fatPct);
    map['onboarded'] = Variable<bool>(onboarded);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      sex: Value(sex),
      ageYears: Value(ageYears),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      activity: Value(activity),
      goal: Value(goal),
      weeklyRateKg: Value(weeklyRateKg),
      customKcalTarget: customKcalTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(customKcalTarget),
      proteinPct: Value(proteinPct),
      carbsPct: Value(carbsPct),
      fatPct: Value(fatPct),
      onboarded: Value(onboarded),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<String>(json['sex']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      activity: serializer.fromJson<String>(json['activity']),
      goal: serializer.fromJson<String>(json['goal']),
      weeklyRateKg: serializer.fromJson<double>(json['weeklyRateKg']),
      customKcalTarget: serializer.fromJson<int?>(json['customKcalTarget']),
      proteinPct: serializer.fromJson<double>(json['proteinPct']),
      carbsPct: serializer.fromJson<double>(json['carbsPct']),
      fatPct: serializer.fromJson<double>(json['fatPct']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<String>(sex),
      'ageYears': serializer.toJson<int>(ageYears),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'activity': serializer.toJson<String>(activity),
      'goal': serializer.toJson<String>(goal),
      'weeklyRateKg': serializer.toJson<double>(weeklyRateKg),
      'customKcalTarget': serializer.toJson<int?>(customKcalTarget),
      'proteinPct': serializer.toJson<double>(proteinPct),
      'carbsPct': serializer.toJson<double>(carbsPct),
      'fatPct': serializer.toJson<double>(fatPct),
      'onboarded': serializer.toJson<bool>(onboarded),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? name,
    String? sex,
    int? ageYears,
    double? heightCm,
    double? weightKg,
    String? activity,
    String? goal,
    double? weeklyRateKg,
    Value<int?> customKcalTarget = const Value.absent(),
    double? proteinPct,
    double? carbsPct,
    double? fatPct,
    bool? onboarded,
  }) => ProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    ageYears: ageYears ?? this.ageYears,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    activity: activity ?? this.activity,
    goal: goal ?? this.goal,
    weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
    customKcalTarget: customKcalTarget.present
        ? customKcalTarget.value
        : this.customKcalTarget,
    proteinPct: proteinPct ?? this.proteinPct,
    carbsPct: carbsPct ?? this.carbsPct,
    fatPct: fatPct ?? this.fatPct,
    onboarded: onboarded ?? this.onboarded,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      activity: data.activity.present ? data.activity.value : this.activity,
      goal: data.goal.present ? data.goal.value : this.goal,
      weeklyRateKg: data.weeklyRateKg.present
          ? data.weeklyRateKg.value
          : this.weeklyRateKg,
      customKcalTarget: data.customKcalTarget.present
          ? data.customKcalTarget.value
          : this.customKcalTarget,
      proteinPct: data.proteinPct.present
          ? data.proteinPct.value
          : this.proteinPct,
      carbsPct: data.carbsPct.present ? data.carbsPct.value : this.carbsPct,
      fatPct: data.fatPct.present ? data.fatPct.value : this.fatPct,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('ageYears: $ageYears, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('weeklyRateKg: $weeklyRateKg, ')
          ..write('customKcalTarget: $customKcalTarget, ')
          ..write('proteinPct: $proteinPct, ')
          ..write('carbsPct: $carbsPct, ')
          ..write('fatPct: $fatPct, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    ageYears,
    heightCm,
    weightKg,
    activity,
    goal,
    weeklyRateKg,
    customKcalTarget,
    proteinPct,
    carbsPct,
    fatPct,
    onboarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.ageYears == this.ageYears &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.activity == this.activity &&
          other.goal == this.goal &&
          other.weeklyRateKg == this.weeklyRateKg &&
          other.customKcalTarget == this.customKcalTarget &&
          other.proteinPct == this.proteinPct &&
          other.carbsPct == this.carbsPct &&
          other.fatPct == this.fatPct &&
          other.onboarded == this.onboarded);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> sex;
  final Value<int> ageYears;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<String> activity;
  final Value<String> goal;
  final Value<double> weeklyRateKg;
  final Value<int?> customKcalTarget;
  final Value<double> proteinPct;
  final Value<double> carbsPct;
  final Value<double> fatPct;
  final Value<bool> onboarded;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activity = const Value.absent(),
    this.goal = const Value.absent(),
    this.weeklyRateKg = const Value.absent(),
    this.customKcalTarget = const Value.absent(),
    this.proteinPct = const Value.absent(),
    this.carbsPct = const Value.absent(),
    this.fatPct = const Value.absent(),
    this.onboarded = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String sex,
    required int ageYears,
    required double heightCm,
    required double weightKg,
    required String activity,
    required String goal,
    this.weeklyRateKg = const Value.absent(),
    this.customKcalTarget = const Value.absent(),
    this.proteinPct = const Value.absent(),
    this.carbsPct = const Value.absent(),
    this.fatPct = const Value.absent(),
    this.onboarded = const Value.absent(),
  }) : sex = Value(sex),
       ageYears = Value(ageYears),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       activity = Value(activity),
       goal = Value(goal);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<int>? ageYears,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? activity,
    Expression<String>? goal,
    Expression<double>? weeklyRateKg,
    Expression<int>? customKcalTarget,
    Expression<double>? proteinPct,
    Expression<double>? carbsPct,
    Expression<double>? fatPct,
    Expression<bool>? onboarded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (ageYears != null) 'age_years': ageYears,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activity != null) 'activity': activity,
      if (goal != null) 'goal': goal,
      if (weeklyRateKg != null) 'weekly_rate_kg': weeklyRateKg,
      if (customKcalTarget != null) 'custom_kcal_target': customKcalTarget,
      if (proteinPct != null) 'protein_pct': proteinPct,
      if (carbsPct != null) 'carbs_pct': carbsPct,
      if (fatPct != null) 'fat_pct': fatPct,
      if (onboarded != null) 'onboarded': onboarded,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? sex,
    Value<int>? ageYears,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<String>? activity,
    Value<String>? goal,
    Value<double>? weeklyRateKg,
    Value<int?>? customKcalTarget,
    Value<double>? proteinPct,
    Value<double>? carbsPct,
    Value<double>? fatPct,
    Value<bool>? onboarded,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      ageYears: ageYears ?? this.ageYears,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activity: activity ?? this.activity,
      goal: goal ?? this.goal,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      customKcalTarget: customKcalTarget ?? this.customKcalTarget,
      proteinPct: proteinPct ?? this.proteinPct,
      carbsPct: carbsPct ?? this.carbsPct,
      fatPct: fatPct ?? this.fatPct,
      onboarded: onboarded ?? this.onboarded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (activity.present) {
      map['activity'] = Variable<String>(activity.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (weeklyRateKg.present) {
      map['weekly_rate_kg'] = Variable<double>(weeklyRateKg.value);
    }
    if (customKcalTarget.present) {
      map['custom_kcal_target'] = Variable<int>(customKcalTarget.value);
    }
    if (proteinPct.present) {
      map['protein_pct'] = Variable<double>(proteinPct.value);
    }
    if (carbsPct.present) {
      map['carbs_pct'] = Variable<double>(carbsPct.value);
    }
    if (fatPct.present) {
      map['fat_pct'] = Variable<double>(fatPct.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('ageYears: $ageYears, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('weeklyRateKg: $weeklyRateKg, ')
          ..write('customKcalTarget: $customKcalTarget, ')
          ..write('proteinPct: $proteinPct, ')
          ..write('carbsPct: $carbsPct, ')
          ..write('fatPct: $fatPct, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _metMeta = const VerificationMeta('met');
  @override
  late final GeneratedColumn<double> met = GeneratedColumn<double>(
    'met',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metOlderAdultMeta = const VerificationMeta(
    'metOlderAdult',
  );
  @override
  late final GeneratedColumn<double> metOlderAdult = GeneratedColumn<double>(
    'met_older_adult',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    met,
    metOlderAdult,
    searchText,
    isFavorite,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('met')) {
      context.handle(
        _metMeta,
        met.isAcceptableOrUnknown(data['met']!, _metMeta),
      );
    }
    if (data.containsKey('met_older_adult')) {
      context.handle(
        _metOlderAdultMeta,
        metOlderAdult.isAcceptableOrUnknown(
          data['met_older_adult']!,
          _metOlderAdultMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      met: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}met'],
      )!,
      metOlderAdult: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}met_older_adult'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;
  final String name;
  final String category;

  /// Compendium MET intensity (× kg × h = kcal).
  final double met;

  /// 2024 Older-Adult MET60+ value; null → approximate with met × 0.810.
  final double? metOlderAdult;

  /// Lowercased "name category" for substring search.
  final String searchText;
  final bool isFavorite;
  final bool isCustom;
  const ActivityRow({
    required this.id,
    required this.name,
    required this.category,
    required this.met,
    this.metOlderAdult,
    required this.searchText,
    required this.isFavorite,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['met'] = Variable<double>(met);
    if (!nullToAbsent || metOlderAdult != null) {
      map['met_older_adult'] = Variable<double>(metOlderAdult);
    }
    map['search_text'] = Variable<String>(searchText);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      met: Value(met),
      metOlderAdult: metOlderAdult == null && nullToAbsent
          ? const Value.absent()
          : Value(metOlderAdult),
      searchText: Value(searchText),
      isFavorite: Value(isFavorite),
      isCustom: Value(isCustom),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      met: serializer.fromJson<double>(json['met']),
      metOlderAdult: serializer.fromJson<double?>(json['metOlderAdult']),
      searchText: serializer.fromJson<String>(json['searchText']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'met': serializer.toJson<double>(met),
      'metOlderAdult': serializer.toJson<double?>(metOlderAdult),
      'searchText': serializer.toJson<String>(searchText),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? name,
    String? category,
    double? met,
    Value<double?> metOlderAdult = const Value.absent(),
    String? searchText,
    bool? isFavorite,
    bool? isCustom,
  }) => ActivityRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    met: met ?? this.met,
    metOlderAdult: metOlderAdult.present
        ? metOlderAdult.value
        : this.metOlderAdult,
    searchText: searchText ?? this.searchText,
    isFavorite: isFavorite ?? this.isFavorite,
    isCustom: isCustom ?? this.isCustom,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      met: data.met.present ? data.met.value : this.met,
      metOlderAdult: data.metOlderAdult.present
          ? data.metOlderAdult.value
          : this.metOlderAdult,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('met: $met, ')
          ..write('metOlderAdult: $metOlderAdult, ')
          ..write('searchText: $searchText, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    met,
    metOlderAdult,
    searchText,
    isFavorite,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.met == this.met &&
          other.metOlderAdult == this.metOlderAdult &&
          other.searchText == this.searchText &&
          other.isFavorite == this.isFavorite &&
          other.isCustom == this.isCustom);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<double> met;
  final Value<double?> metOlderAdult;
  final Value<String> searchText;
  final Value<bool> isFavorite;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.met = const Value.absent(),
    this.metOlderAdult = const Value.absent(),
    this.searchText = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.met = const Value.absent(),
    this.metOlderAdult = const Value.absent(),
    required String searchText,
    this.isFavorite = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchText = Value(searchText);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? met,
    Expression<double>? metOlderAdult,
    Expression<String>? searchText,
    Expression<bool>? isFavorite,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (met != null) 'met': met,
      if (metOlderAdult != null) 'met_older_adult': metOlderAdult,
      if (searchText != null) 'search_text': searchText,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<double>? met,
    Value<double?>? metOlderAdult,
    Value<String>? searchText,
    Value<bool>? isFavorite,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      met: met ?? this.met,
      metOlderAdult: metOlderAdult ?? this.metOlderAdult,
      searchText: searchText ?? this.searchText,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (met.present) {
      map['met'] = Variable<double>(met.value);
    }
    if (metOlderAdult.present) {
      map['met_older_adult'] = Variable<double>(metOlderAdult.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('met: $met, ')
          ..write('metOlderAdult: $metOlderAdult, ')
          ..write('searchText: $searchText, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseEntriesTable extends ExerciseEntries
    with TableInfo<$ExerciseEntriesTable, ExerciseEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<double> minutes = GeneratedColumn<double>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _manualKcalMeta = const VerificationMeta(
    'manualKcal',
  );
  @override
  late final GeneratedColumn<double> manualKcal = GeneratedColumn<double>(
    'manual_kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metUsedMeta = const VerificationMeta(
    'metUsed',
  );
  @override
  late final GeneratedColumn<double> metUsed = GeneratedColumn<double>(
    'met_used',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    activityId,
    name,
    minutes,
    weightKg,
    kcal,
    manualKcal,
    metUsed,
    createdAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('manual_kcal')) {
      context.handle(
        _manualKcalMeta,
        manualKcal.isAcceptableOrUnknown(data['manual_kcal']!, _manualKcalMeta),
      );
    }
    if (data.containsKey('met_used')) {
      context.handle(
        _metUsedMeta,
        metUsed.isAcceptableOrUnknown(data['met_used']!, _metUsedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minutes'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      manualKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_kcal'],
      ),
      metUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}met_used'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ExerciseEntriesTable createAlias(String alias) {
    return $ExerciseEntriesTable(attachedDatabase, alias);
  }
}

class ExerciseEntryRow extends DataClass
    implements Insertable<ExerciseEntryRow> {
  final String id;
  final String day;
  final String activityId;
  final String name;
  final double minutes;
  final double weightKg;

  /// Snapshot burn at log time (MET estimate with that day's weight/age).
  final double kcal;

  /// Watch override; null = use the estimate.
  final double? manualKcal;
  final double metUsed;
  final DateTime createdAt;
  final int sortOrder;
  const ExerciseEntryRow({
    required this.id,
    required this.day,
    required this.activityId,
    required this.name,
    required this.minutes,
    required this.weightKg,
    required this.kcal,
    this.manualKcal,
    required this.metUsed,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['activity_id'] = Variable<String>(activityId);
    map['name'] = Variable<String>(name);
    map['minutes'] = Variable<double>(minutes);
    map['weight_kg'] = Variable<double>(weightKg);
    map['kcal'] = Variable<double>(kcal);
    if (!nullToAbsent || manualKcal != null) {
      map['manual_kcal'] = Variable<double>(manualKcal);
    }
    map['met_used'] = Variable<double>(metUsed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ExerciseEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEntriesCompanion(
      id: Value(id),
      day: Value(day),
      activityId: Value(activityId),
      name: Value(name),
      minutes: Value(minutes),
      weightKg: Value(weightKg),
      kcal: Value(kcal),
      manualKcal: manualKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(manualKcal),
      metUsed: Value(metUsed),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory ExerciseEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEntryRow(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      activityId: serializer.fromJson<String>(json['activityId']),
      name: serializer.fromJson<String>(json['name']),
      minutes: serializer.fromJson<double>(json['minutes']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      kcal: serializer.fromJson<double>(json['kcal']),
      manualKcal: serializer.fromJson<double?>(json['manualKcal']),
      metUsed: serializer.fromJson<double>(json['metUsed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'activityId': serializer.toJson<String>(activityId),
      'name': serializer.toJson<String>(name),
      'minutes': serializer.toJson<double>(minutes),
      'weightKg': serializer.toJson<double>(weightKg),
      'kcal': serializer.toJson<double>(kcal),
      'manualKcal': serializer.toJson<double?>(manualKcal),
      'metUsed': serializer.toJson<double>(metUsed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ExerciseEntryRow copyWith({
    String? id,
    String? day,
    String? activityId,
    String? name,
    double? minutes,
    double? weightKg,
    double? kcal,
    Value<double?> manualKcal = const Value.absent(),
    double? metUsed,
    DateTime? createdAt,
    int? sortOrder,
  }) => ExerciseEntryRow(
    id: id ?? this.id,
    day: day ?? this.day,
    activityId: activityId ?? this.activityId,
    name: name ?? this.name,
    minutes: minutes ?? this.minutes,
    weightKg: weightKg ?? this.weightKg,
    kcal: kcal ?? this.kcal,
    manualKcal: manualKcal.present ? manualKcal.value : this.manualKcal,
    metUsed: metUsed ?? this.metUsed,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ExerciseEntryRow copyWithCompanion(ExerciseEntriesCompanion data) {
    return ExerciseEntryRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      name: data.name.present ? data.name.value : this.name,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      manualKcal: data.manualKcal.present
          ? data.manualKcal.value
          : this.manualKcal,
      metUsed: data.metUsed.present ? data.metUsed.value : this.metUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEntryRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('activityId: $activityId, ')
          ..write('name: $name, ')
          ..write('minutes: $minutes, ')
          ..write('weightKg: $weightKg, ')
          ..write('kcal: $kcal, ')
          ..write('manualKcal: $manualKcal, ')
          ..write('metUsed: $metUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    activityId,
    name,
    minutes,
    weightKg,
    kcal,
    manualKcal,
    metUsed,
    createdAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEntryRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.activityId == this.activityId &&
          other.name == this.name &&
          other.minutes == this.minutes &&
          other.weightKg == this.weightKg &&
          other.kcal == this.kcal &&
          other.manualKcal == this.manualKcal &&
          other.metUsed == this.metUsed &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class ExerciseEntriesCompanion extends UpdateCompanion<ExerciseEntryRow> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> activityId;
  final Value<String> name;
  final Value<double> minutes;
  final Value<double> weightKg;
  final Value<double> kcal;
  final Value<double?> manualKcal;
  final Value<double> metUsed;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ExerciseEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.activityId = const Value.absent(),
    this.name = const Value.absent(),
    this.minutes = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.kcal = const Value.absent(),
    this.manualKcal = const Value.absent(),
    this.metUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEntriesCompanion.insert({
    required String id,
    required String day,
    required String activityId,
    required String name,
    this.minutes = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.kcal = const Value.absent(),
    this.manualKcal = const Value.absent(),
    this.metUsed = const Value.absent(),
    required DateTime createdAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       activityId = Value(activityId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<ExerciseEntryRow> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? activityId,
    Expression<String>? name,
    Expression<double>? minutes,
    Expression<double>? weightKg,
    Expression<double>? kcal,
    Expression<double>? manualKcal,
    Expression<double>? metUsed,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (activityId != null) 'activity_id': activityId,
      if (name != null) 'name': name,
      if (minutes != null) 'minutes': minutes,
      if (weightKg != null) 'weight_kg': weightKg,
      if (kcal != null) 'kcal': kcal,
      if (manualKcal != null) 'manual_kcal': manualKcal,
      if (metUsed != null) 'met_used': metUsed,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? activityId,
    Value<String>? name,
    Value<double>? minutes,
    Value<double>? weightKg,
    Value<double>? kcal,
    Value<double?>? manualKcal,
    Value<double>? metUsed,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ExerciseEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      activityId: activityId ?? this.activityId,
      name: name ?? this.name,
      minutes: minutes ?? this.minutes,
      weightKg: weightKg ?? this.weightKg,
      kcal: kcal ?? this.kcal,
      manualKcal: manualKcal ?? this.manualKcal,
      metUsed: metUsed ?? this.metUsed,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<double>(minutes.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (manualKcal.present) {
      map['manual_kcal'] = Variable<double>(manualKcal.value);
    }
    if (metUsed.present) {
      map['met_used'] = Variable<double>(metUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('activityId: $activityId, ')
          ..write('name: $name, ')
          ..write('minutes: $minutes, ')
          ..write('weightKg: $weightKg, ')
          ..write('kcal: $kcal, ')
          ..write('manualKcal: $manualKcal, ')
          ..write('metUsed: $metUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, weightKg, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntryRow extends DataClass implements Insertable<WeightEntryRow> {
  final String id;
  final double weightKg;
  final DateTime createdAt;
  const WeightEntryRow({
    required this.id,
    required this.weightKg,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['weight_kg'] = Variable<double>(weightKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      weightKg: Value(weightKg),
      createdAt: Value(createdAt),
    );
  }

  factory WeightEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntryRow(
      id: serializer.fromJson<String>(json['id']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weightKg': serializer.toJson<double>(weightKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WeightEntryRow copyWith({
    String? id,
    double? weightKg,
    DateTime? createdAt,
  }) => WeightEntryRow(
    id: id ?? this.id,
    weightKg: weightKg ?? this.weightKg,
    createdAt: createdAt ?? this.createdAt,
  );
  WeightEntryRow copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntryRow(
      id: data.id.present ? data.id.value : this.id,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntryRow(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weightKg, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntryRow &&
          other.id == this.id &&
          other.weightKg == this.weightKg &&
          other.createdAt == this.createdAt);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntryRow> {
  final Value<String> id;
  final Value<double> weightKg;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    required String id,
    required double weightKg,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weightKg = Value(weightKg),
       createdAt = Value(createdAt);
  static Insertable<WeightEntryRow> custom({
    Expression<String>? id,
    Expression<double>? weightKg,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightKg != null) 'weight_kg': weightKg,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<String>? id,
    Value<double>? weightKg,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeItemsTable recipeItems = $RecipeItemsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $ExerciseEntriesTable exerciseEntries = $ExerciseEntriesTable(
    this,
  );
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final Index idxFoodsBarcode = Index(
    'idx_foods_barcode',
    'CREATE INDEX idx_foods_barcode ON foods (barcode)',
  );
  late final Index idxFoodsSearch = Index(
    'idx_foods_search',
    'CREATE INDEX idx_foods_search ON foods (search_text)',
  );
  late final Index idxActivitiesSearch = Index(
    'idx_activities_search',
    'CREATE INDEX idx_activities_search ON activities (search_text)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foods,
    logEntries,
    recipes,
    recipeItems,
    profiles,
    settings,
    activities,
    exerciseEntries,
    weightEntries,
    idxFoodsBarcode,
    idxFoodsSearch,
    idxActivitiesSearch,
  ];
}

typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      required String id,
      required String name,
      Value<String> brand,
      required String source,
      Value<double> defaultGrams,
      Value<String> servingsJson,
      Value<bool> liquid,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<double> satFatG,
      Value<double> sugarsG,
      Value<double> fiberG,
      Value<double> sodiumMg,
      Value<double> vitAMcg,
      Value<double> vitB1Mg,
      Value<double> vitB2Mg,
      Value<double> vitB3Mg,
      Value<double> vitB6Mg,
      Value<double> vitB12Ug,
      Value<double> vitCMg,
      Value<double> folateUg,
      Value<double> calciumMg,
      Value<double> ironMg,
      Value<double> magnesiumMg,
      Value<double> potassiumMg,
      Value<double> zincMg,
      required String searchText,
      Value<String?> barcode,
      Value<bool> isFavorite,
      Value<int> rowid,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> brand,
      Value<String> source,
      Value<double> defaultGrams,
      Value<String> servingsJson,
      Value<bool> liquid,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<double> satFatG,
      Value<double> sugarsG,
      Value<double> fiberG,
      Value<double> sodiumMg,
      Value<double> vitAMcg,
      Value<double> vitB1Mg,
      Value<double> vitB2Mg,
      Value<double> vitB3Mg,
      Value<double> vitB6Mg,
      Value<double> vitB12Ug,
      Value<double> vitCMg,
      Value<double> folateUg,
      Value<double> calciumMg,
      Value<double> ironMg,
      Value<double> magnesiumMg,
      Value<double> potassiumMg,
      Value<double> zincMg,
      Value<String> searchText,
      Value<String?> barcode,
      Value<bool> isFavorite,
      Value<int> rowid,
    });

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultGrams => $composableBuilder(
    column: $table.defaultGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingsJson => $composableBuilder(
    column: $table.servingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get liquid => $composableBuilder(
    column: $table.liquid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get satFatG => $composableBuilder(
    column: $table.satFatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarsG => $composableBuilder(
    column: $table.sugarsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitAMcg => $composableBuilder(
    column: $table.vitAMcg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitB1Mg => $composableBuilder(
    column: $table.vitB1Mg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitB2Mg => $composableBuilder(
    column: $table.vitB2Mg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitB3Mg => $composableBuilder(
    column: $table.vitB3Mg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitB6Mg => $composableBuilder(
    column: $table.vitB6Mg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitB12Ug => $composableBuilder(
    column: $table.vitB12Ug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitCMg => $composableBuilder(
    column: $table.vitCMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get folateUg => $composableBuilder(
    column: $table.folateUg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnesiumMg => $composableBuilder(
    column: $table.magnesiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get zincMg => $composableBuilder(
    column: $table.zincMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultGrams => $composableBuilder(
    column: $table.defaultGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingsJson => $composableBuilder(
    column: $table.servingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get liquid => $composableBuilder(
    column: $table.liquid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get satFatG => $composableBuilder(
    column: $table.satFatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarsG => $composableBuilder(
    column: $table.sugarsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitAMcg => $composableBuilder(
    column: $table.vitAMcg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitB1Mg => $composableBuilder(
    column: $table.vitB1Mg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitB2Mg => $composableBuilder(
    column: $table.vitB2Mg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitB3Mg => $composableBuilder(
    column: $table.vitB3Mg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitB6Mg => $composableBuilder(
    column: $table.vitB6Mg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitB12Ug => $composableBuilder(
    column: $table.vitB12Ug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitCMg => $composableBuilder(
    column: $table.vitCMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get folateUg => $composableBuilder(
    column: $table.folateUg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnesiumMg => $composableBuilder(
    column: $table.magnesiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get zincMg => $composableBuilder(
    column: $table.zincMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get defaultGrams => $composableBuilder(
    column: $table.defaultGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingsJson => $composableBuilder(
    column: $table.servingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get liquid =>
      $composableBuilder(column: $table.liquid, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get satFatG =>
      $composableBuilder(column: $table.satFatG, builder: (column) => column);

  GeneratedColumn<double> get sugarsG =>
      $composableBuilder(column: $table.sugarsG, builder: (column) => column);

  GeneratedColumn<double> get fiberG =>
      $composableBuilder(column: $table.fiberG, builder: (column) => column);

  GeneratedColumn<double> get sodiumMg =>
      $composableBuilder(column: $table.sodiumMg, builder: (column) => column);

  GeneratedColumn<double> get vitAMcg =>
      $composableBuilder(column: $table.vitAMcg, builder: (column) => column);

  GeneratedColumn<double> get vitB1Mg =>
      $composableBuilder(column: $table.vitB1Mg, builder: (column) => column);

  GeneratedColumn<double> get vitB2Mg =>
      $composableBuilder(column: $table.vitB2Mg, builder: (column) => column);

  GeneratedColumn<double> get vitB3Mg =>
      $composableBuilder(column: $table.vitB3Mg, builder: (column) => column);

  GeneratedColumn<double> get vitB6Mg =>
      $composableBuilder(column: $table.vitB6Mg, builder: (column) => column);

  GeneratedColumn<double> get vitB12Ug =>
      $composableBuilder(column: $table.vitB12Ug, builder: (column) => column);

  GeneratedColumn<double> get vitCMg =>
      $composableBuilder(column: $table.vitCMg, builder: (column) => column);

  GeneratedColumn<double> get folateUg =>
      $composableBuilder(column: $table.folateUg, builder: (column) => column);

  GeneratedColumn<double> get calciumMg =>
      $composableBuilder(column: $table.calciumMg, builder: (column) => column);

  GeneratedColumn<double> get ironMg =>
      $composableBuilder(column: $table.ironMg, builder: (column) => column);

  GeneratedColumn<double> get magnesiumMg => $composableBuilder(
    column: $table.magnesiumMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get zincMg =>
      $composableBuilder(column: $table.zincMg, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          FoodRow,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (FoodRow, BaseReferences<_$AppDatabase, $FoodsTable, FoodRow>),
          FoodRow,
          PrefetchHooks Function()
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> defaultGrams = const Value.absent(),
                Value<String> servingsJson = const Value.absent(),
                Value<bool> liquid = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> satFatG = const Value.absent(),
                Value<double> sugarsG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<double> vitAMcg = const Value.absent(),
                Value<double> vitB1Mg = const Value.absent(),
                Value<double> vitB2Mg = const Value.absent(),
                Value<double> vitB3Mg = const Value.absent(),
                Value<double> vitB6Mg = const Value.absent(),
                Value<double> vitB12Ug = const Value.absent(),
                Value<double> vitCMg = const Value.absent(),
                Value<double> folateUg = const Value.absent(),
                Value<double> calciumMg = const Value.absent(),
                Value<double> ironMg = const Value.absent(),
                Value<double> magnesiumMg = const Value.absent(),
                Value<double> potassiumMg = const Value.absent(),
                Value<double> zincMg = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                name: name,
                brand: brand,
                source: source,
                defaultGrams: defaultGrams,
                servingsJson: servingsJson,
                liquid: liquid,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                satFatG: satFatG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                sodiumMg: sodiumMg,
                vitAMcg: vitAMcg,
                vitB1Mg: vitB1Mg,
                vitB2Mg: vitB2Mg,
                vitB3Mg: vitB3Mg,
                vitB6Mg: vitB6Mg,
                vitB12Ug: vitB12Ug,
                vitCMg: vitCMg,
                folateUg: folateUg,
                calciumMg: calciumMg,
                ironMg: ironMg,
                magnesiumMg: magnesiumMg,
                potassiumMg: potassiumMg,
                zincMg: zincMg,
                searchText: searchText,
                barcode: barcode,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> brand = const Value.absent(),
                required String source,
                Value<double> defaultGrams = const Value.absent(),
                Value<String> servingsJson = const Value.absent(),
                Value<bool> liquid = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> satFatG = const Value.absent(),
                Value<double> sugarsG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<double> vitAMcg = const Value.absent(),
                Value<double> vitB1Mg = const Value.absent(),
                Value<double> vitB2Mg = const Value.absent(),
                Value<double> vitB3Mg = const Value.absent(),
                Value<double> vitB6Mg = const Value.absent(),
                Value<double> vitB12Ug = const Value.absent(),
                Value<double> vitCMg = const Value.absent(),
                Value<double> folateUg = const Value.absent(),
                Value<double> calciumMg = const Value.absent(),
                Value<double> ironMg = const Value.absent(),
                Value<double> magnesiumMg = const Value.absent(),
                Value<double> potassiumMg = const Value.absent(),
                Value<double> zincMg = const Value.absent(),
                required String searchText,
                Value<String?> barcode = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                source: source,
                defaultGrams: defaultGrams,
                servingsJson: servingsJson,
                liquid: liquid,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                satFatG: satFatG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                sodiumMg: sodiumMg,
                vitAMcg: vitAMcg,
                vitB1Mg: vitB1Mg,
                vitB2Mg: vitB2Mg,
                vitB3Mg: vitB3Mg,
                vitB6Mg: vitB6Mg,
                vitB12Ug: vitB12Ug,
                vitCMg: vitCMg,
                folateUg: folateUg,
                calciumMg: calciumMg,
                ironMg: ironMg,
                magnesiumMg: magnesiumMg,
                potassiumMg: potassiumMg,
                zincMg: zincMg,
                searchText: searchText,
                barcode: barcode,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      FoodRow,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (FoodRow, BaseReferences<_$AppDatabase, $FoodsTable, FoodRow>),
      FoodRow,
      PrefetchHooks Function()
    >;
typedef $$LogEntriesTableCreateCompanionBuilder =
    LogEntriesCompanion Function({
      required String id,
      required String day,
      required String meal,
      required String foodId,
      required String name,
      Value<String> brand,
      required String source,
      required double grams,
      Value<String> unit,
      Value<double?> servingCount,
      Value<double?> servingGrams,
      Value<String?> servingLabel,
      required double kcal,
      required double proteinG,
      required double carbsG,
      required double fatG,
      Value<double> satFatG,
      Value<double> sugarsG,
      Value<double> fiberG,
      Value<double> sodiumMg,
      Value<double> vitCMg,
      Value<double> calciumMg,
      Value<double> ironMg,
      Value<double> potassiumMg,
      Value<String?> photoPath,
      required DateTime createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LogEntriesTableUpdateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String> meal,
      Value<String> foodId,
      Value<String> name,
      Value<String> brand,
      Value<String> source,
      Value<double> grams,
      Value<String> unit,
      Value<double?> servingCount,
      Value<double?> servingGrams,
      Value<String?> servingLabel,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<double> satFatG,
      Value<double> sugarsG,
      Value<double> fiberG,
      Value<double> sodiumMg,
      Value<double> vitCMg,
      Value<double> calciumMg,
      Value<double> ironMg,
      Value<double> potassiumMg,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingCount => $composableBuilder(
    column: $table.servingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get satFatG => $composableBuilder(
    column: $table.satFatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarsG => $composableBuilder(
    column: $table.sugarsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitCMg => $composableBuilder(
    column: $table.vitCMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingCount => $composableBuilder(
    column: $table.servingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get satFatG => $composableBuilder(
    column: $table.satFatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarsG => $composableBuilder(
    column: $table.sugarsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitCMg => $composableBuilder(
    column: $table.vitCMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get servingCount => $composableBuilder(
    column: $table.servingCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get satFatG =>
      $composableBuilder(column: $table.satFatG, builder: (column) => column);

  GeneratedColumn<double> get sugarsG =>
      $composableBuilder(column: $table.sugarsG, builder: (column) => column);

  GeneratedColumn<double> get fiberG =>
      $composableBuilder(column: $table.fiberG, builder: (column) => column);

  GeneratedColumn<double> get sodiumMg =>
      $composableBuilder(column: $table.sodiumMg, builder: (column) => column);

  GeneratedColumn<double> get vitCMg =>
      $composableBuilder(column: $table.vitCMg, builder: (column) => column);

  GeneratedColumn<double> get calciumMg =>
      $composableBuilder(column: $table.calciumMg, builder: (column) => column);

  GeneratedColumn<double> get ironMg =>
      $composableBuilder(column: $table.ironMg, builder: (column) => column);

  GeneratedColumn<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogEntriesTable,
          LogEntryRow,
          $$LogEntriesTableFilterComposer,
          $$LogEntriesTableOrderingComposer,
          $$LogEntriesTableAnnotationComposer,
          $$LogEntriesTableCreateCompanionBuilder,
          $$LogEntriesTableUpdateCompanionBuilder,
          (
            LogEntryRow,
            BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntryRow>,
          ),
          LogEntryRow,
          PrefetchHooks Function()
        > {
  $$LogEntriesTableTableManager(_$AppDatabase db, $LogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> servingCount = const Value.absent(),
                Value<double?> servingGrams = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> satFatG = const Value.absent(),
                Value<double> sugarsG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<double> vitCMg = const Value.absent(),
                Value<double> calciumMg = const Value.absent(),
                Value<double> ironMg = const Value.absent(),
                Value<double> potassiumMg = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogEntriesCompanion(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                name: name,
                brand: brand,
                source: source,
                grams: grams,
                unit: unit,
                servingCount: servingCount,
                servingGrams: servingGrams,
                servingLabel: servingLabel,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                satFatG: satFatG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                sodiumMg: sodiumMg,
                vitCMg: vitCMg,
                calciumMg: calciumMg,
                ironMg: ironMg,
                potassiumMg: potassiumMg,
                photoPath: photoPath,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required String meal,
                required String foodId,
                required String name,
                Value<String> brand = const Value.absent(),
                required String source,
                required double grams,
                Value<String> unit = const Value.absent(),
                Value<double?> servingCount = const Value.absent(),
                Value<double?> servingGrams = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                required double kcal,
                required double proteinG,
                required double carbsG,
                required double fatG,
                Value<double> satFatG = const Value.absent(),
                Value<double> sugarsG = const Value.absent(),
                Value<double> fiberG = const Value.absent(),
                Value<double> sodiumMg = const Value.absent(),
                Value<double> vitCMg = const Value.absent(),
                Value<double> calciumMg = const Value.absent(),
                Value<double> ironMg = const Value.absent(),
                Value<double> potassiumMg = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required DateTime createdAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogEntriesCompanion.insert(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                name: name,
                brand: brand,
                source: source,
                grams: grams,
                unit: unit,
                servingCount: servingCount,
                servingGrams: servingGrams,
                servingLabel: servingLabel,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                satFatG: satFatG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                sodiumMg: sodiumMg,
                vitCMg: vitCMg,
                calciumMg: calciumMg,
                ironMg: ironMg,
                potassiumMg: potassiumMg,
                photoPath: photoPath,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogEntriesTable,
      LogEntryRow,
      $$LogEntriesTableFilterComposer,
      $$LogEntriesTableOrderingComposer,
      $$LogEntriesTableAnnotationComposer,
      $$LogEntriesTableCreateCompanionBuilder,
      $$LogEntriesTableUpdateCompanionBuilder,
      (
        LogEntryRow,
        BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntryRow>,
      ),
      LogEntryRow,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      required String id,
      required String name,
      Value<int> servings,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> servings,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          RecipeRow,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
          RecipeRow,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                servings: servings,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> servings = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                servings: servings,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      RecipeRow,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
      RecipeRow,
      PrefetchHooks Function()
    >;
typedef $$RecipeItemsTableCreateCompanionBuilder =
    RecipeItemsCompanion Function({
      required String id,
      required String recipeId,
      required String foodId,
      required String name,
      Value<String> brand,
      required double grams,
      Value<double> qty,
      Value<String> unit,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<int> rowid,
    });
typedef $$RecipeItemsTableUpdateCompanionBuilder =
    RecipeItemsCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String> foodId,
      Value<String> name,
      Value<String> brand,
      Value<double> grams,
      Value<double> qty,
      Value<String> unit,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<int> rowid,
    });

class $$RecipeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeItemsTable> {
  $$RecipeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);
}

class $$RecipeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeItemsTable,
          RecipeItem,
          $$RecipeItemsTableFilterComposer,
          $$RecipeItemsTableOrderingComposer,
          $$RecipeItemsTableAnnotationComposer,
          $$RecipeItemsTableCreateCompanionBuilder,
          $$RecipeItemsTableUpdateCompanionBuilder,
          (
            RecipeItem,
            BaseReferences<_$AppDatabase, $RecipeItemsTable, RecipeItem>,
          ),
          RecipeItem,
          PrefetchHooks Function()
        > {
  $$RecipeItemsTableTableManager(_$AppDatabase db, $RecipeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeItemsCompanion(
                id: id,
                recipeId: recipeId,
                foodId: foodId,
                name: name,
                brand: brand,
                grams: grams,
                qty: qty,
                unit: unit,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required String foodId,
                required String name,
                Value<String> brand = const Value.absent(),
                required double grams,
                Value<double> qty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeItemsCompanion.insert(
                id: id,
                recipeId: recipeId,
                foodId: foodId,
                name: name,
                brand: brand,
                grams: grams,
                qty: qty,
                unit: unit,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeItemsTable,
      RecipeItem,
      $$RecipeItemsTableFilterComposer,
      $$RecipeItemsTableOrderingComposer,
      $$RecipeItemsTableAnnotationComposer,
      $$RecipeItemsTableCreateCompanionBuilder,
      $$RecipeItemsTableUpdateCompanionBuilder,
      (
        RecipeItem,
        BaseReferences<_$AppDatabase, $RecipeItemsTable, RecipeItem>,
      ),
      RecipeItem,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      required String sex,
      required int ageYears,
      required double heightCm,
      required double weightKg,
      required String activity,
      required String goal,
      Value<double> weeklyRateKg,
      Value<int?> customKcalTarget,
      Value<double> proteinPct,
      Value<double> carbsPct,
      Value<double> fatPct,
      Value<bool> onboarded,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> sex,
      Value<int> ageYears,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<String> activity,
      Value<String> goal,
      Value<double> weeklyRateKg,
      Value<int?> customKcalTarget,
      Value<double> proteinPct,
      Value<double> carbsPct,
      Value<double> fatPct,
      Value<bool> onboarded,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customKcalTarget => $composableBuilder(
    column: $table.customKcalTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPct => $composableBuilder(
    column: $table.proteinPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPct => $composableBuilder(
    column: $table.carbsPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPct => $composableBuilder(
    column: $table.fatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customKcalTarget => $composableBuilder(
    column: $table.customKcalTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPct => $composableBuilder(
    column: $table.proteinPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPct => $composableBuilder(
    column: $table.carbsPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPct => $composableBuilder(
    column: $table.fatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<double> get weeklyRateKg => $composableBuilder(
    column: $table.weeklyRateKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customKcalTarget => $composableBuilder(
    column: $table.customKcalTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPct => $composableBuilder(
    column: $table.proteinPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPct =>
      $composableBuilder(column: $table.carbsPct, builder: (column) => column);

  GeneratedColumn<double> get fatPct =>
      $composableBuilder(column: $table.fatPct, builder: (column) => column);

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> activity = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<double> weeklyRateKg = const Value.absent(),
                Value<int?> customKcalTarget = const Value.absent(),
                Value<double> proteinPct = const Value.absent(),
                Value<double> carbsPct = const Value.absent(),
                Value<double> fatPct = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                sex: sex,
                ageYears: ageYears,
                heightCm: heightCm,
                weightKg: weightKg,
                activity: activity,
                goal: goal,
                weeklyRateKg: weeklyRateKg,
                customKcalTarget: customKcalTarget,
                proteinPct: proteinPct,
                carbsPct: carbsPct,
                fatPct: fatPct,
                onboarded: onboarded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                required String sex,
                required int ageYears,
                required double heightCm,
                required double weightKg,
                required String activity,
                required String goal,
                Value<double> weeklyRateKg = const Value.absent(),
                Value<int?> customKcalTarget = const Value.absent(),
                Value<double> proteinPct = const Value.absent(),
                Value<double> carbsPct = const Value.absent(),
                Value<double> fatPct = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                ageYears: ageYears,
                heightCm: heightCm,
                weightKg: weightKg,
                activity: activity,
                goal: goal,
                weeklyRateKg: weeklyRateKg,
                customKcalTarget: customKcalTarget,
                proteinPct: proteinPct,
                carbsPct: carbsPct,
                fatPct: fatPct,
                onboarded: onboarded,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String name,
      Value<String> category,
      Value<double> met,
      Value<double?> metOlderAdult,
      required String searchText,
      Value<bool> isFavorite,
      Value<bool> isCustom,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<double> met,
      Value<double?> metOlderAdult,
      Value<String> searchText,
      Value<bool> isFavorite,
      Value<bool> isCustom,
      Value<int> rowid,
    });

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get met => $composableBuilder(
    column: $table.met,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metOlderAdult => $composableBuilder(
    column: $table.metOlderAdult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get met => $composableBuilder(
    column: $table.met,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metOlderAdult => $composableBuilder(
    column: $table.metOlderAdult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get met =>
      $composableBuilder(column: $table.met, builder: (column) => column);

  GeneratedColumn<double> get metOlderAdult => $composableBuilder(
    column: $table.metOlderAdult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (
            ActivityRow,
            BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>,
          ),
          ActivityRow,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> met = const Value.absent(),
                Value<double?> metOlderAdult = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                name: name,
                category: category,
                met: met,
                metOlderAdult: metOlderAdult,
                searchText: searchText,
                isFavorite: isFavorite,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> category = const Value.absent(),
                Value<double> met = const Value.absent(),
                Value<double?> metOlderAdult = const Value.absent(),
                required String searchText,
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                name: name,
                category: category,
                met: met,
                metOlderAdult: metOlderAdult,
                searchText: searchText,
                isFavorite: isFavorite,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (
        ActivityRow,
        BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow>,
      ),
      ActivityRow,
      PrefetchHooks Function()
    >;
typedef $$ExerciseEntriesTableCreateCompanionBuilder =
    ExerciseEntriesCompanion Function({
      required String id,
      required String day,
      required String activityId,
      required String name,
      Value<double> minutes,
      Value<double> weightKg,
      Value<double> kcal,
      Value<double?> manualKcal,
      Value<double> metUsed,
      required DateTime createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ExerciseEntriesTableUpdateCompanionBuilder =
    ExerciseEntriesCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String> activityId,
      Value<String> name,
      Value<double> minutes,
      Value<double> weightKg,
      Value<double> kcal,
      Value<double?> manualKcal,
      Value<double> metUsed,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ExerciseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualKcal => $composableBuilder(
    column: $table.manualKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metUsed => $composableBuilder(
    column: $table.metUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualKcal => $composableBuilder(
    column: $table.manualKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metUsed => $composableBuilder(
    column: $table.metUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseEntriesTable> {
  $$ExerciseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get manualKcal => $composableBuilder(
    column: $table.manualKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metUsed =>
      $composableBuilder(column: $table.metUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ExerciseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseEntriesTable,
          ExerciseEntryRow,
          $$ExerciseEntriesTableFilterComposer,
          $$ExerciseEntriesTableOrderingComposer,
          $$ExerciseEntriesTableAnnotationComposer,
          $$ExerciseEntriesTableCreateCompanionBuilder,
          $$ExerciseEntriesTableUpdateCompanionBuilder,
          (
            ExerciseEntryRow,
            BaseReferences<
              _$AppDatabase,
              $ExerciseEntriesTable,
              ExerciseEntryRow
            >,
          ),
          ExerciseEntryRow,
          PrefetchHooks Function()
        > {
  $$ExerciseEntriesTableTableManager(
    _$AppDatabase db,
    $ExerciseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> minutes = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double?> manualKcal = const Value.absent(),
                Value<double> metUsed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEntriesCompanion(
                id: id,
                day: day,
                activityId: activityId,
                name: name,
                minutes: minutes,
                weightKg: weightKg,
                kcal: kcal,
                manualKcal: manualKcal,
                metUsed: metUsed,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required String activityId,
                required String name,
                Value<double> minutes = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double?> manualKcal = const Value.absent(),
                Value<double> metUsed = const Value.absent(),
                required DateTime createdAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEntriesCompanion.insert(
                id: id,
                day: day,
                activityId: activityId,
                name: name,
                minutes: minutes,
                weightKg: weightKg,
                kcal: kcal,
                manualKcal: manualKcal,
                metUsed: metUsed,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseEntriesTable,
      ExerciseEntryRow,
      $$ExerciseEntriesTableFilterComposer,
      $$ExerciseEntriesTableOrderingComposer,
      $$ExerciseEntriesTableAnnotationComposer,
      $$ExerciseEntriesTableCreateCompanionBuilder,
      $$ExerciseEntriesTableUpdateCompanionBuilder,
      (
        ExerciseEntryRow,
        BaseReferences<_$AppDatabase, $ExerciseEntriesTable, ExerciseEntryRow>,
      ),
      ExerciseEntryRow,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      required String id,
      required double weightKg,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<String> id,
      Value<double> weightKg,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightEntryRow,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            WeightEntryRow,
            BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntryRow>,
          ),
          WeightEntryRow,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion(
                id: id,
                weightKg: weightKg,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double weightKg,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                id: id,
                weightKg: weightKg,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightEntryRow,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        WeightEntryRow,
        BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntryRow>,
      ),
      WeightEntryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeItemsTableTableManager get recipeItems =>
      $$RecipeItemsTableTableManager(_db, _db.recipeItems);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$ExerciseEntriesTableTableManager get exerciseEntries =>
      $$ExerciseEntriesTableTableManager(_db, _db.exerciseEntries);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
}
