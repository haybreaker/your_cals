import 'package:file_picker/file_picker.dart';
import 'package:your_cals/data/objects/entry.dart';
import 'package:your_cals/data/objects/food.dart';

abstract class DatabaseHelperInterface {
  Future<void> init();

  Future<void> importDb(PlatformFile file);
  Future<void> exportDb(String? exportPath);
  Future<void> deleteDb();

  // CRUD helpers
  Future<void> insertFood(Food food);
  Future<void> insertAllFoods(List<Food> foods);
  Future<void> updateFood(Food food);
  Future<void> deleteFood(Food food);
  Future<List<Food>> findFoods(String? name, String? barcode);
  Future<Map<String, Food>> findFoodsById(List<String> id);

  // Log Entries
  insertEntry(Entry entry);
  updateEntry(Entry entry);
  deleteEntry(Entry entry);
  getTodaysEntries();
  getEntriesByDate(DateTime date);
}
