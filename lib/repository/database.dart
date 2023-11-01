import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ?? await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'customerinfo.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(
        'CREATE TABLE customer (customerid int, customername varchar(300), contactnumber varchar(13), gender varchar(7), address text)');
    print('done creating customer table');
  }

  Future<int> insertItem(Map<String, dynamic> item, String tablename) async {
    Database db = await database;
    return await db.insert('$tablename', item);
  }

  Future<void> updateItem(Map<String, dynamic> data, String tablename,
      String condition, dynamic agrs) async {
    Database db = await database;

    await db.update(tablename, data, where: condition, whereArgs: [agrs]);
  }
}
