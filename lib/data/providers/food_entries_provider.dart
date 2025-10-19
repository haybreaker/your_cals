import 'package:flutter/material.dart';
import 'package:your_cals/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_cals/data/objects/entry.dart';
import 'package:your_cals/data/objects/food.dart';

class FoodEntriesProvider extends ChangeNotifier {
  final DatabaseHelperInterface db;
  FoodEntriesProvider(this.db);

  void insertEntry(Entry entry) => db.insertEntry(entry);
  Future<List<Entry>> getTodaysEntries() async => await db.getTodaysEntries();

  Future<List<Entry>> getEntriesByDate(DateTime date) async => db.getEntriesByDate(date);

  Future<Map<String, Food>> getFoodsByIds(List<String> foodIds) async {
    return await db.findFoodsById(foodIds);
  }

  Future<void> removeEntry(Entry entry) async => await db.deleteEntry(entry);
}
