import 'dart:io';

import 'package:drift/drift.dart';
// These imports are only needed to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dolang/models/category.dart';
import 'package:dolang/models/transaction.dart';
import 'package:dolang/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
  // relative import for the drift file. Drift also supports `package:`
  // imports
  tables: [Categories, Transactions],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  // CRUD Category
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String newName) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(newName),
      ),
    );
  }

  Future sumAmount(int type) async {
    var sumExp = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..where(transactions.category_id.equals(type))
      ..addColumns([sumExp]);

    // print(await query.map((row) => row.read(sumExp)).getSingle());
    // print(query.map((row) => row.read(sumExp)).getSingle());

    return await query.map((row) => row.read(sumExp)).getSingle();

    // print(sum.runtimeType);
    // print(sum.toString());
    // return sum.toString();
    // var sum = await query.map((row) => row.read(sumExp)).getSingle();
    // return sum?.toInt();
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        description: Value(nameDetail),
        amount: Value(amount),
        transaction_date: Value(transactionDate),
        category_id: Value(categoryId),
      ),
    );
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future deleteTransaction(int id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // CRUD Transaction
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
