// Import necessary packages for testing
import 'package:flutter_test/flutter_test.dart'; // Provides the Flutter testing framework.
import 'package:mockito/mockito.dart'; // Provides mocking capabilities for unit tests.
import 'package:sqflite/sqflite.dart'; // Provides database functionality.
import 'package:shared_preferences/shared_preferences.dart'; // Manages app preferences storage.
import 'package:cs442_mp6/services/db_helper.dart'; // Utility for database interactions.
import 'package:cs442_mp6/widgets/FavouritesUpdate.dart'; // View class to update favorites.

// Create mock for DBHelper
class MockDBHelper extends Mock implements DBHelper {
  final List<Map<String, dynamic>> mockData = []; // Mock database storage.

  // Override the query method to return mock data
  @override
  Future<List<Map<String, dynamic>>> query(String table, {String? where, String? orderBy}) async {
    return mockData; // Returns the mock database records.
  }

  // Override the insert method to add data to mock database
  @override
  Future<int> insertFavourites(String table, Map<String, dynamic> data) async {
    mockData.add(data); // Add data to mock database.
    return 1; // Return a success value.
  }

  // Override the delete method to remove data by ID
  @override
  Future<void> deleteFavourites(String id) async {
    mockData.removeWhere((item) => item['id'] == id); // Remove entry with matching ID.
  }

  // Override the deleteDatabase method to clear mock database
  @override
  Future<void> deleteDatabase(String path) async {
    mockData.clear(); // Clear all mock data.
  }

  // Stub for execute, returns empty list
  @override
  Future<List<Map<String, dynamic>>> execute(String str) async {
    return []; // No actual implementation, returns an empty list.
  }

  // Stub for rawQuery, returns mock data
  @override
  Future<List<Map<String, dynamic>>> rawQuery(String str) async {
    return mockData; // Return mock database records.
  }

  // Stub for database getter, returns null
  @override
  Future<Database?> get db async => null; // No actual database instance.
}

// Main function to group and execute tests
void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Ensures test environment is initialized for widgets.

  group('FavouritesStore Tests', () { // Group related tests for FavoritesStore.
    late FavouritesStore favStore; // Declare the FavoritesStore instance.
    late MockDBHelper mockDb; // Declare the mock DBHelper instance.

    // Setup before each test
    setUp(() async {
      SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences values.

      mockDb = MockDBHelper(); // Instantiate mock database helper.
      favStore = FavouritesStore(); // Instantiate FavoritesStore.
      favStore.dbHelper = mockDb; // Inject mock DBHelper into FavoritesStore.

      await favStore.init(); // Initialize the store.
    });

    // Test for the results getter
    test('Results getter works correctly', () {
      favStore.results = [{"title": "Test News"}]; // Set mock results.
      expect(favStore.Results, [{"title": "Test News"}]); // Verify getter returns the same results.
    });

    // Test for the ids getter
    test('Ids getter works correctly', () {
      favStore.ids = ["1", "2", "3"]; // Set mock IDs.
      expect(favStore.Ids, ["1", "2", "3"]); // Verify getter returns the same IDs.
    });

    // Test retriveDB function
    test('retriveDB updates results and ids', () async {
      mockDb.mockData.addAll([ // Add mock data to database.
        {
          'id': 'test_id_1',
          'title': 'Test News',
          'descr': 'Description',
          'content': 'Content',
        }
      ]);

      await favStore.retriveDB(); // Call retrieve database function.

      expect(favStore.results.length, 1); // Verify results updated correctly.
      expect(favStore.ids.length, 1); // Verify IDs updated correctly.
      expect(favStore.ids.first, 'test_id_1'); // Verify correct ID added.
    });

    // Test addFavorite function
    test('addFavorite adds article and updates state', () async {
      final article = { // Create a mock article.
        'id': 'test_id_2',
        'title': 'New Article',
        'descr': 'New Description',
        'content': 'New Content',
      };

      await favStore.addFavorite(article); // Add article to favorites.

      expect(mockDb.mockData.length, 1); // Verify article added to mock database.
      expect(favStore.results.length, 1); // Verify results updated.
      expect(favStore.ids.contains('test_id_2'), true); // Verify ID updated.
    });

    // Test removeFavorite function
    test('removeFavorite removes article and updates state', () async {
      final article = { // Add a mock article to remove later.
        'id': 'test_id_3',
        'title': 'Article to Remove',
        'descr': 'Description',
        'content': 'Content',
      };
      await favStore.addFavorite(article); // Add article to favorites.

      await favStore.removeFavorite('test_id_3'); // Remove the article by ID.

      expect(mockDb.mockData.length, 0); // Verify mock database is empty.
      expect(favStore.results.length, 0); // Verify results cleared.
      expect(favStore.ids.contains('test_id_3'), false); // Verify ID removed.
    });

    // Test clearFavorites function
    test('clearFavorites removes all articles and updates state', () async {
      await favStore.addFavorite({ // Add multiple articles.
        'id': 'test_id_4',
        'title': 'Article 1',
        'descr': 'Description 1',
        'content': 'Content 1',
      });
      await favStore.addFavorite({
        'id': 'test_id_5',
        'title': 'Article 2',
        'descr': 'Description 2',
        'content': 'Content 2',
      });

      await favStore.clearFavorites(); // Clear all favorites.

      expect(mockDb.mockData.length, 0); // Verify mock database cleared.
      expect(favStore.results.length, 0); // Verify results cleared.
      expect(favStore.ids.length, 0); // Verify IDs cleared.
    });
  });
}
