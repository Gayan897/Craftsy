// ignore: file_names

import 'dart:io';

import 'package:appwrite/appwrite.dart';
// ignore: unused_import
import 'package:appwrite/models.dart' as models;
import 'package:craft/appwriter_initializer.dart';
import 'package:craft/models/product.dart';

class ProductService {
  final Client client = AppwriteInitializer.client;
  final Databases database;
  final Storage storage;

  final String databaseId = '681ee2fd003584396ab0';
  final String collectionId = '681ee321003da521f73a';
  final String bucketId = '681ee4d30013fa331636';

  ProductService()
      : database = Databases(AppwriteInitializer.client),
        storage = Storage(AppwriteInitializer.client);

  Future<Product> addProduct(Product product, File imageFile) async {
    // Upload file to Appwrite Storage
    final uploadedFile = await storage.createFile(
      bucketId: bucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: imageFile.path),
    );

    // Build image URL from uploaded file
    final imageUrl =
        'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/${uploadedFile.$id}/view?project=681ee1ba001cd0029007';

    // Create product document in Appwrite Database
    final doc = await database.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: product
          .copyWith(
            imagePath: imageUrl,
            createdAt: DateTime.now(), // ✅ Explicitly add createdAt
          )
          .toMap(),
    );

    return Product.fromJson(doc.data);
  }

  Future<List<Product>> fetchAllProducts() async {
    final docs = await database.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );

    return docs.documents.map((doc) => Product.fromJson(doc.data)).toList();
  }
}
