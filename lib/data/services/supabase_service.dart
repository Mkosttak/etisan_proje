import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
  
  GoTrueClient get auth => client.auth;
  
  User? get currentUser => auth.currentUser;
  
  bool get isAuthenticated => currentUser != null;

  // Database Tables
  SupabaseQueryBuilder get users => client.from('users');
  SupabaseQueryBuilder get meals => client.from('meals');
  SupabaseQueryBuilder get reservations => client.from('reservations');
  SupabaseQueryBuilder get transactions => client.from('transactions');
  SupabaseQueryBuilder get schools => client.from('schools');

  // Auth Methods
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  Future<UserResponse> updateUser(UserAttributes attributes) async {
    return await auth.updateUser(attributes);
  }

  // Realtime Subscriptions
  // Note: These methods are commented out for mock data usage
  // Uncomment when using real Supabase backend
  
  /*
  RealtimeChannel subscribeToReservations(
    String userId,
    void Function(SupabaseStreamEvent) callback,
  ) {
    return client
        .from('reservations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen(callback);
  }

  RealtimeChannel subscribeToMeals(
    void Function(SupabaseStreamEvent) callback,
  ) {
    return client
        .from('meals')
        .stream(primaryKey: ['id'])
        .listen(callback);
  }
  */

  // Storage
  Future<String> uploadFile(String bucket, String path, List<int> fileBytes) async {
    // Convert List<int> to Uint8List
    final bytes = Uint8List.fromList(fileBytes);
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}

