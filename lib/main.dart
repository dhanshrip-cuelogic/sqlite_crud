import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Employee {
  final int id;
  final String name;
  final String dept;

  Employee({this.id, this.name, this.dept});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dept': dept,
    };
  }

  @override
  String toString() {
    return 'Employee{id: $id, name: $name, age: $dept}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'employee_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE employee(id INTEGER PRIMARY KEY, name TEXT, dept TEXT)",
      );
    },
    version: 1,
  );

  Future<void> insertEmployee(Employee emp) async {
    final Database db = await database;

    await db.insert(
      'employee',
      emp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Employee>> employees() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('employee');

    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        dept: maps[i]['dept'],
      );
    });
  }

  Future<void> updateEmployee(Employee emp) async {
    // Get a reference to the database.
    final db = await database;

    await db.update(
      'employee',
      emp.toMap(),
      where: "id = ?",
      whereArgs: [emp.id],
    );
  }

  Future<void> deleteEmployee(int id) async {
    final db = await database;

    await db.delete(
      'employee',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  var fido = Employee(
    id: 0,
    name: 'Fido',
    dept: 'Accounts',
  );

  await insertEmployee(fido);

  print(await employees());

  fido = Employee(
    id: fido.id,
    name: fido.name,
    dept: 'HR',
  );
  await updateEmployee(fido);

  print(await employees());

  await deleteEmployee(fido.id);

  print(await employees());
}
