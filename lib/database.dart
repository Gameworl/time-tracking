import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DateTimeObject.dart';
import 'nameObject.dart';

class DatabaseHelper {
  Database? _database = null;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join("./", 'bdd.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE datetime(
            id INTEGER PRIMARY KEY,
            nameId INTEGER,
            date INTEGER,
            time INTEGER
          )
        ''');
        await db.execute('''
           CREATE TABLE name(
            id INTEGER PRIMARY KEY,
            firstName TEXT,
            lastName TEXT
          )
        ''');
      },
    );
  }

  Future insertDatetime(DateTimeObject datetime) async {
    final db = await database;
    await db!.insert(
      'datetime',
      datetime.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DateTimeObject>> getAllDatetime() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db!.query('datetime');

    return List.generate(maps.length, (i) {
      return DateTimeObject.fromMap(maps[i]);
    });
  }

  Future<DateTimeObject?> getDateTimeObject(int id) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = await db!.query('datetime',
        where: 'id = ? AND date = ?',
        whereArgs: [id, today.millisecondsSinceEpoch]);
    if (result.isEmpty) {
      return null;
    }
    final dateTimeObject = DateTimeObject.fromMap(result.first);
    return dateTimeObject;
  }

  Future<int?> getDateTimeObjectWithDate(int id, DateTime now) async {
    final db = await database;
    final today = DateTime(now.year, now.month, now.day);

    final result = await db!.query('datetime',
        where: 'nameid = ? AND date = ?',
        whereArgs: [id, today.millisecondsSinceEpoch]);
    if (result.isEmpty) {
      return 0;
    }
    final dateTimeObject = DateTimeObject.fromMap(result.first);

    return dateTimeObject.time;
  }

  Future getNameTimeObject(int id) async {
    final db = await database;
    final result =
        await db!.query('datetime', where: 'nameid = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return 0;
    }

    return Future.delayed(const Duration(seconds: 1), () => result);
  }

  Future<int> updateDatetime(DateTimeObject datetime) async {
    final db = await database;

    return await db!.update(
      'datetime',
      datetime.toMap(),
      where: 'id = ?',
      whereArgs: [datetime.id],
    );
  }

  Future<int> deleteDatetime(int id) async {
    final db = await database;

    return await db!.delete(
      'datetime',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertName(NameObject nameObject) async {
    final db = await database;

    return await db!.insert(
      'name',
      nameObject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NameObject>> getAllName() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db!.query('name');

    return List.generate(maps.length, (i) {
      return NameObject.fromMap(maps[i]);
    });
  }

  Future<int> updateName(NameObject nameObject) async {
    final db = await database;

    return await db!.update(
      'name',
      nameObject.toMap(),
      where: 'id = ?',
      whereArgs: [nameObject.id],
    );
  }

  Future<int> deleteName(int id) async {
    final db = await database;

    return await db!.delete(
      'name',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
