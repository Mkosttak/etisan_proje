import 'package:flutter/material.dart';
import '../data/models/reservation_model.dart';
import '../data/models/meal_model.dart';
import '../data/services/mock_data_service.dart';

class ReservationProvider with ChangeNotifier {
  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get Upcoming Reservations
  List<ReservationModel> get upcomingReservations {
    return _reservations
        .where((r) => !r.isPast && r.isActive)
        .toList()
      ..sort((a, b) => a.mealDate.compareTo(b.mealDate));
  }

  // Get Past Reservations
  List<ReservationModel> get pastReservations {
    return _reservations
        .where((r) => r.isPast || !r.isActive)
        .toList()
      ..sort((a, b) => b.mealDate.compareTo(a.mealDate));
  }

  // Get Transfer Open Reservations (for Swap Screen) - sadece başkalarının rezervasyonları
  List<ReservationModel> getTransferOpenReservations(String currentUserId) {
    return _reservations
        .where((r) => r.isTransferOpen && !r.isPast && r.userId != currentUserId)
        .toList()
      ..sort((a, b) => a.mealDate.compareTo(b.mealDate));
  }
  
  // Get User's Own Reservations (including transferred ones)
  List<ReservationModel> getUserReservations(String userId) {
    return _reservations
        .where((r) => r.userId == userId || r.transferredToUserId == userId)
        .toList()
      ..sort((a, b) => a.mealDate.compareTo(b.mealDate));
  }

  // Load Reservations
  Future<void> loadReservations(String userId) async {
    print('🔄 Provider: loadReservations çağrıldı - userId: $userId');
    _isLoading = true;
    notifyListeners();

    try {
      _reservations = MockDataService.instance.getMockReservations(userId);
      print('✅ Provider: ${_reservations.length} rezervasyon yüklendi');
      for (var res in _reservations) {
        print('   📋 ${res.id}: ${res.mealName} - ${res.status} - User: ${res.userId}');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Provider HATA: $e');
      _errorMessage = 'Rezervasyonlar yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Reservation
  Future<bool> createReservation({
    required String userId,
    required MealModel meal,
  }) async {
    // Aynı gün farklı yemekhane kontrolü
    final mealDate = DateTime(meal.mealDate.year, meal.mealDate.month, meal.mealDate.day);
    final existingReservationOnSameDay = _reservations.where((r) {
      final resDate = DateTime(r.mealDate.year, r.mealDate.month, r.mealDate.day);
      return r.userId == userId && 
             r.status == 'reserved' && 
             resDate.isAtSameMomentAs(mealDate);
    }).toList();

    if (existingReservationOnSameDay.isNotEmpty) {
      final existingCafeteria = existingReservationOnSameDay.first.cafeteriaId;
      if (existingCafeteria != meal.cafeteriaId) {
        _errorMessage = 'Aynı gün içinde farklı yemekhaneye rezervasyon yapamazsınız. Önce ${existingReservationOnSameDay.first.cafeteriaName} rezervasyonunuzu iptal edin.';
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final reservation = await MockDataService.instance.mockCreateReservation(
        userId: userId,
        meal: meal,
      );

      _reservations.add(reservation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Rezervasyon oluşturulamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel Reservation
  Future<bool> cancelReservation(String reservationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await MockDataService.instance.mockCancelReservation(reservationId);

      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = _reservations[index].copyWith(
          status: 'cancelled',
          cancelledAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Rezervasyon iptal edilemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Open for Swap
  Future<bool> openForSwap(String reservationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await MockDataService.instance.mockOpenForSwap(reservationId);

      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        final currentState = _reservations[index].isTransferOpen;
        _reservations[index] = _reservations[index].copyWith(
          isTransferOpen: !currentState,
          status: !currentState ? 'transferOpen' : 'reserved',
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Rezervasyon takasa açılamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Alias for compatibility
  Future<bool> openForTransfer(String reservationId) => openForSwap(reservationId);

  // Accept Swap - Rezervasyonu yeni kullanıcıya transfer et
  Future<bool> acceptSwap(String reservationId, String newUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await MockDataService.instance.mockAcceptSwap(reservationId, newUserId);

      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        // Rezervasyonu yeni kullanıcıya transfer et
        _reservations[index] = _reservations[index].copyWith(
          userId: newUserId, // Artık bu rezervasyon yeni kullanıcının
          status: 'reserved', // Aktif rezervasyon olarak devam ediyor
          transferredToUserId: newUserId,
          isTransferOpen: false,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Takas kabul edilemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get Reservation by ID
  ReservationModel? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

