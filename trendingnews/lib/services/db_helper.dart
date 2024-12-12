// Import necessary packages for file path management and database operations
import 'package:path/path.dart' as path; // Handles platform-aware file path management
import 'package:path_provider/path_provider.dart'; // Provides platform-specific paths
import 'package:sqflite/sqflite.dart'; // SQLite database package for Flutter

// DBHelper is a Singleton class (ensures only one instance exists in the app)
class DBHelper {
  static const String _databaseName = 'FavNews.db'; // Name of the database file
  static const int _databaseVersion = 1; // Database version for handling migrations

  DBHelper._(); // Private constructor to prevent direct instantiation

  // The single instance of DBHelper
  static final DBHelper _singleton = DBHelper._();

  // Factory constructor to always return the single instance of DBHelper
  factory DBHelper() => _singleton;

  // Reference to the database once opened
  Database? _database;

  // Getter to initialize the database if it's not already initialized
  get db async {
    try {
      _database ??= await _initDatabase(); // If null, initialize the database
      return _database; // Return the database instance
    } catch (e) {
      throw Exception('Failed to get database: $e'); // Throw exception if database access fails
    }
  }

  // Private method to initialize the database
  Future<Database> _initDatabase() async {
    try {
      // Get the platform-dependent documents directory
      var dbDir = await getApplicationDocumentsDirectory().catchError((error) {
        throw Exception('Failed to get application documents directory: $error'); // Handle directory access error
      });

      // Join the directory path with the database name to get the full database path
      var dbPath = path.join(dbDir.path, _databaseName);

      // Uncomment the next line to delete the database (useful for testing)
      // await deleteDatabase(dbPath);

      // Open the database with error handling
      var db = await openDatabase(
        dbPath, // Path to the database
        version: _databaseVersion, // Database version for migrations
        onCreate: (Database db, int version) async {
          try {
            // Execute SQL to create the "favourites" table
            await db.execute('''
              create table favourites(
                id STRING PRIMARY KEY, // Unique identifier for a favourite
                urlToImage TEXT, // URL of the associated image
                url TEXT, // URL of the news article
                title TEXT, // Title of the news article
                descr TEXT, // Short description of the news article
                content TEXT // Full content of the news article
              )
            ''');
          } catch (e) {
            throw Exception('Failed to create database tables: $e'); // Handle table creation error
          }
        },
      ).catchError((error) {
        throw Exception('Failed to open database: $error'); // Handle database opening error
      });

      return db; // Return the initialized database
    } catch (e) {
      throw Exception('Database initialization failed: $e'); // Handle overall initialization error
    }
  }

  // Method to fetch records from a table with optional "where" and "orderBy" clauses
  Future<List<Map<String, dynamic>>> query(String table, {String? where, String? orderBy}) async {
    try {
      final db = await this.db; // Ensure the database is initialized
      // Perform the query, with or without the "where" clause
      return await (where == null
          ? db.query(table, orderBy: orderBy)
          : db.query(table, where: where, orderBy: orderBy))
          .catchError((error) {
        throw Exception('Query execution failed: $error'); // Handle query execution error
      });
    } catch (e) {
      throw Exception('Failed to perform query: $e'); // Handle overall query error
    }
  }

  // Method to insert a record into a table
  Future<int> insertFavourites(String table, Map<String, dynamic> data) async {
    try {
      final db = await this.db; // Ensure the database is initialized
      // Insert the record and return the row ID of the inserted record
      return await db.insert(
        table, // Table name
        data, // Data to insert
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace existing record on conflict
      ).catchError((error) {
        throw Exception('Insert operation failed: $error'); // Handle insert operation error
      });
    } catch (e) {
      throw Exception('Failed to insert favourite: $e'); // Handle overall insert error
    }
  }

  // Method to delete a record from the "favourites" table by ID
  Future<void> deleteFavourites(String id) async {
    try {
      final db = await this.db; // Ensure the database is initialized
      // Delete the record matching the given ID
      await db.delete(
        'favourites', // Table name
        where: 'id = ?', // WHERE clause to specify the record to delete
        whereArgs: [id], // Arguments for the WHERE clause
      ).catchError((error) {
        throw Exception('Delete operation failed: $error'); // Handle delete operation error
      });
    } catch (e) {
      throw Exception('Failed to delete favourite: $e'); // Handle overall delete error
    }
  }

  // Method to execute a raw SQL command
  Future<List<Map<String, dynamic>>> execute(String str) async {
    try {
      final db = await this.db; // Ensure the database is initialized
      return await db.execute(str).catchError((error) { // Execute the raw SQL command
        throw Exception('SQL execution failed: $error'); // Handle SQL execution error
      });
    } catch (e) {
      throw Exception('Failed to execute SQL command: $e'); // Handle overall execution error
    }
  }

  // Method to perform a raw SQL query and return the results
  Future<List<Map<String, dynamic>>> rawQuery(String str) async {
    try {
      final db = await this.db; // Ensure the database is initialized
      return await db.rawQuery(str).catchError((error) { // Execute the raw SQL query
        throw Exception('Raw query execution failed: $error'); // Handle query execution error
      });
    } catch (e) {
      throw Exception('Failed to perform raw query: $e'); // Handle overall query error
    }
  }

  // Method to delete the entire database
  Future<void> deleteDatabase(String path) async {
    try {
      await databaseFactory.deleteDatabase(path).catchError((error) { // Delete the database at the given path
        throw Exception('Database deletion failed: $error'); // Handle deletion error
      });
    } catch (e) {
      throw Exception('Failed to delete database: $e'); // Handle overall deletion error
    }
  }
}