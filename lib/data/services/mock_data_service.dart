import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/reservation_model.dart';
import '../models/transaction_model.dart';

/// Mock data service for demo purposes
/// In production, this would be replaced with real Supabase queries
class MockDataService {
  static final MockDataService instance = MockDataService._();
  MockDataService._();

  // Mock Users
  static final Map<String, UserModel> _mockUsers = {
    'student@etisan.com': UserModel(
      id: 'student-1',
      email: 'student@etisan.com',
      fullName: 'Ahmet Yılmaz',
      schoolEmail: 'ahmet.yilmaz@student.edu.tr',
      phone: '+905551234567',
      studentNumber: '202012345',
      role: 'student',
      balance: 125.50,
      school: 'Erzincan Binali Yıldırım Üniversitesi',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    'admin@etisan.com': UserModel(
      id: 'admin-1',
      email: 'admin@etisan.com',
      fullName: 'Admin User',
      role: 'admin',
      balance: 0,
      school: 'Erzincan Binali Yıldırım Üniversitesi',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  };

  // Mock Meals - 15 günlük menü
  List<MealModel> getMockMeals() {
    final now = DateTime.now();
    final meals = <MealModel>[];
    
    // Sabah, öğle, akşam menüleri için şablonlar
    final breakfastMenus = [
      {'name': 'Kahvaltı Tabağı', 'items': 'Beyaz Peynir, Kaşar, Zeytin, Domates, Salatalık, Reçel, Bal, Tereyağı, Ekmek, Çay'},
      {'name': 'Serpme Kahvaltı', 'items': 'Menemen, Sosis, Sucuk, Peynir Çeşitleri, Zeytin, Börek, Poğaça, Çay'},
      {'name': 'Fit Kahvaltı', 'items': 'Yumurta, Avokado, Tahıl Ekmeği, Light Peynir, Meyve Tabağı, Yeşil Çay'},
    ];
    
    final lunchMenus = [
      {'name': 'Öğle Menüsü 1', 'items': 'Mercimek Çorbası, Karnıyarık, Pilav, Cacık, Salata, Ayran, Meyve'},
      {'name': 'Öğle Menüsü 2', 'items': 'Ezogelin Çorbası, Tavuk Şinitzel, Patates Kızartması, Makarna, Salata, Ayran, Sütlaç'},
      {'name': 'Öğle Menüsü 3', 'items': 'Yayla Çorbası, Etli Kuru Fasulye, Bulgur Pilavı, Turşu, Salata, Ayran, Tatlı'},
      {'name': 'Öğle Menüsü 4', 'items': 'Domates Çorbası, Köfte, Makarna, Yoğurt, Salata, Ayran, Meyve'},
      {'name': 'Öğle Menüsü 5', 'items': 'Tavuk Çorbası, İzmir Köfte, Pilav, Haydari, Salata, Ayran, Kemalpaşa'},
      {'name': 'Vejetaryen Öğle', 'items': 'Sebze Çorbası, Zeytinyağlı Taze Fasulye, Pilav, Yoğurt, Salata, Meyve'},
      {'name': 'Vegan Öğle', 'items': 'Mercimek Çorbası, Nohut Yemeği, Bulgur Pilavı, Salata, Meyve'},
    ];
    
    final dinnerMenus = [
      {'name': 'Akşam Menüsü 1', 'items': 'Tarhana Çorbası, Tavuk Sote, Makarna, Salata, Ayran, Revani'},
      {'name': 'Akşam Menüsü 2', 'items': 'Şehriye Çorbası, Izgara Köfte, Patates, Yoğurt, Salata, Ayran, Meyve'},
      {'name': 'Akşam Menüsü 3', 'items': 'Düğün Çorbası, Etli Nohut, Pilav, Cacık, Salata, Ayran, Kadayıf'},
      {'name': 'Akşam Menüsü 4', 'items': 'Mercimek Çorbası, Tavuk Kapama, Pilav, Turşu, Salata, Ayran, Meyve'},
      {'name': 'Akşam Menüsü 5', 'items': 'Domates Çorbası, Fırın Tavuk, Makarna, Haydari, Salata, Ayran, Sütlaç'},
      {'name': 'Vejetaryen Akşam', 'items': 'Sebze Çorbası, Imam Bayıldı, Pilav, Yoğurt, Salata, Meyve'},
      {'name': 'Balık Menüsü', 'items': 'Balık Çorbası, Izgara Balık, Pilav, Salata, Ayran, Meyve'},
    ];
    
    // Yemekhaneler
    final cafeterias = [
      {'id': 'cafeteria-1', 'name': 'Merkez Yemekhane'},
      {'id': 'cafeteria-2', 'name': 'Mühendislik Fakültesi Yemekhane'},
      {'id': 'cafeteria-3', 'name': 'Tıp Fakültesi Yemekhane'},
    ];
    
    // 15 gün için menü oluştur
    for (int day = 0; day < 15; day++) {
      final date = now.add(Duration(days: day));
      
      // Her gün için farklı yemekhanelerde yemekler
      for (int cafeteriaIndex = 0; cafeteriaIndex < cafeterias.length; cafeteriaIndex++) {
        final cafeteria = cafeterias[cafeteriaIndex];
        
        // Kahvaltı
        final breakfastMenu = breakfastMenus[(day + cafeteriaIndex) % breakfastMenus.length];
        meals.add(MealModel(
          id: 'meal-breakfast-$day-caf$cafeteriaIndex',
          name: breakfastMenu['name']!,
          description: breakfastMenu['items']!,
          mealType: 'normal',
          mealPeriod: 'breakfast',
          mealDate: DateTime(date.year, date.month, date.day, 7, 30),
          cafeteriaId: cafeteria['id']!,
          cafeteriaName: cafeteria['name']!,
          reservationPrice: 10.00,
          walkInPrice: 15.00,
          totalSpots: 100,
          availableSpots: 100 - (day * 3) - (cafeteriaIndex * 5),
          allergens: ['dairy', 'gluten'],
          createdAt: now,
        ));
      
        // Öğle Yemeği - Normal
        final lunchMenu = lunchMenus[(day + cafeteriaIndex) % lunchMenus.length];
        meals.add(MealModel(
          id: 'meal-lunch-$day-caf$cafeteriaIndex',
          name: lunchMenu['name']!,
          description: lunchMenu['items']!,
          mealType: day % 7 == 5 ? 'vegetarian' : 'normal',
          mealPeriod: 'lunch',
          mealDate: DateTime(date.year, date.month, date.day, 11, 30),
          cafeteriaId: cafeteria['id']!,
          cafeteriaName: cafeteria['name']!,
          reservationPrice: 15.00,
          walkInPrice: 22.00,
          totalSpots: 150,
          availableSpots: 150 - (day * 5) - (cafeteriaIndex * 10),
          allergens: day % 7 == 5 ? [] : ['dairy', 'gluten'],
          createdAt: now,
        ));
      
        // Öğle - Vejetaryen Alternatif
        if (day % 3 == 0 && cafeteriaIndex == 0) {
          meals.add(MealModel(
            id: 'meal-lunch-veg-$day-caf$cafeteriaIndex',
            name: 'Vejetaryen Öğle',
            description: 'Sebze Çorbası, Zeytinyağlı Enginar, Bulgur Pilavı, Yoğurt, Salata, Meyve',
            mealType: 'vegetarian',
            mealPeriod: 'lunch',
            mealDate: DateTime(date.year, date.month, date.day, 11, 30),
            cafeteriaId: cafeteria['id']!,
            cafeteriaName: cafeteria['name']!,
            reservationPrice: 14.00,
            walkInPrice: 20.00,
            totalSpots: 50,
            availableSpots: 50 - (day * 2),
            allergens: ['dairy'],
            createdAt: now,
          ));
        }
      
        // Akşam Yemeği
        final dinnerMenu = dinnerMenus[(day + cafeteriaIndex) % dinnerMenus.length];
        meals.add(MealModel(
          id: 'meal-dinner-$day-caf$cafeteriaIndex',
          name: dinnerMenu['name']!,
          description: dinnerMenu['items']!,
          mealType: day % 7 == 3 ? 'vegetarian' : (day % 10 == 6 ? 'vegan' : 'normal'),
          mealPeriod: 'dinner',
          mealDate: DateTime(date.year, date.month, date.day, 18, 0),
          cafeteriaId: cafeteria['id']!,
          cafeteriaName: cafeteria['name']!,
          reservationPrice: 16.00,
          walkInPrice: 23.00,
          totalSpots: 120,
          availableSpots: 120 - (day * 4) - (cafeteriaIndex * 8),
          allergens: day % 10 == 6 ? [] : ['dairy', 'gluten'],
          createdAt: now,
        ));
      
        // Akşam - Vegan Alternatif
        if (day % 4 == 0 && cafeteriaIndex == 1) {
          meals.add(MealModel(
            id: 'meal-dinner-vegan-$day-caf$cafeteriaIndex',
            name: 'Vegan Akşam Menüsü',
            description: 'Sebze Çorbası, Nohut Burger, Patates Kızartması, Salata, Meyve',
            mealType: 'vegan',
            mealPeriod: 'dinner',
            mealDate: DateTime(date.year, date.month, date.day, 18, 0),
            cafeteriaId: cafeteria['id']!,
            cafeteriaName: cafeteria['name']!,
            reservationPrice: 15.00,
            walkInPrice: 21.00,
            totalSpots: 40,
            availableSpots: 40 - (day * 2),
            allergens: [],
            createdAt: now,
          ));
        }
      }
    }
    
    return meals;
  }

  // Mock Reservations
  List<ReservationModel> getMockReservations(String userId) {
    print('🗄️ MockDataService: getMockReservations çağrıldı - userId: $userId');
    final now = DateTime.now();
    
    // Kendi rezervasyonları
    final myReservations = [
      ReservationModel(
        id: 'res-my-1',
        userId: userId,
        mealId: 'meal-lunch-1',
        mealName: 'Öğle Menüsü 2',
        mealDescription: 'Ezogelin Çorbası, Tavuk Şinitzel, Patates Kızartması, Makarna, Salata, Ayran, Sütlaç',
        mealType: 'normal',
        mealPeriod: 'lunch',
        mealDate: now.add(const Duration(days: 2, hours: 12)),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez Yemekhane',
        price: 15.00,
        status: 'reserved',
        qrCode: 'QR-MY-1-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ReservationModel(
        id: 'res-my-2',
        userId: userId,
        mealId: 'meal-dinner-1',
        mealName: 'Akşam Menüsü 1',
        mealDescription: 'Tarhana Çorbası, Tavuk Sote, Makarna, Salata, Ayran, Revani',
        mealType: 'normal',
        mealPeriod: 'dinner',
        mealDate: now.add(const Duration(days: 3, hours: 18)),
        cafeteriaId: 'cafeteria-2',
        cafeteriaName: 'Mühendislik Fakültesi Yemekhane',
        price: 16.00,
        status: 'reserved',
        qrCode: 'QR-MY-2-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      ReservationModel(
        id: 'res-my-3',
        userId: userId,
        mealId: 'meal-breakfast-0',
        mealName: 'Kahvaltı Tabağı',
        mealDescription: 'Beyaz Peynir, Kaşar, Zeytin, Domates, Salatalık, Reçel, Bal, Tereyağı, Ekmek, Çay',
        mealType: 'normal',
        mealPeriod: 'breakfast',
        mealDate: now.subtract(const Duration(days: 1, hours: -7)),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez Yemekhane',
        price: 10.00,
        status: 'consumed',
        qrCode: 'QR-MY-3-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: false,
        createdAt: now.subtract(const Duration(days: 2)),
        consumedAt: now.subtract(const Duration(days: 1)),
      ),
      ReservationModel(
        id: 'res-my-4',
        userId: userId,
        mealId: 'meal-lunch-2',
        mealName: 'Öğle Menüsü 3',
        mealDescription: 'Yayla Çorbası, Etli Kuru Fasulye, Bulgur Pilavı, Turşu, Salata, Ayran, Tatlı',
        mealType: 'normal',
        mealPeriod: 'lunch',
        mealDate: now.add(const Duration(days: 1, hours: 12)),
        cafeteriaId: 'cafeteria-3',
        cafeteriaName: 'Tıp Fakültesi Yemekhane',
        price: 15.00,
        status: 'reserved',
        qrCode: 'QR-MY-4-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ReservationModel(
        id: 'res-my-5',
        userId: userId,
        mealId: 'meal-dinner-2',
        mealName: 'Vejetaryen Akşam',
        mealDescription: 'Sebze Çorbası, Imam Bayıldı, Pilav, Yoğurt, Salata, Meyve',
        mealType: 'vegetarian',
        mealPeriod: 'dinner',
        mealDate: now.subtract(const Duration(days: 3, hours: -18)),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez Yemekhane',
        price: 14.00,
        status: 'consumed',
        qrCode: 'QR-MY-5-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: false,
        createdAt: now.subtract(const Duration(days: 4)),
        consumedAt: now.subtract(const Duration(days: 3)),
      ),
      ReservationModel(
        id: 'res-my-6',
        userId: userId,
        mealId: 'meal-breakfast-4',
        mealName: 'Serpme Kahvaltı',
        mealDescription: 'Menemen, Sosis, Sucuk, Peynir Çeşitleri, Zeytin, Börek, Poğaça, Çay',
        mealType: 'normal',
        mealPeriod: 'breakfast',
        mealDate: now.subtract(const Duration(days: 5, hours: -7, minutes: -30)),
        cafeteriaId: 'cafeteria-2',
        cafeteriaName: 'Mühendislik Fakültesi Yemekhane',
        price: 10.00,
        status: 'cancelled',
        qrCode: 'QR-MY-6-${DateTime.now().millisecondsSinceEpoch}',
        isTransferOpen: false,
        createdAt: now.subtract(const Duration(days: 6)),
        cancelledAt: now.subtract(const Duration(days: 5, hours: 2)),
      ),
    ];
    
    // Takas için açık rezervasyonlar (başka kullanıcılardan) - bugün ve gelecek günler için
    final transferOpenReservations = [
      // BUGÜN - Kahvaltı
      ReservationModel(
        id: 'res-transfer-today-1',
        userId: 'other-user-1',
        mealId: 'meal-breakfast-0-caf0',
        mealName: 'Kahvaltı Tabağı',
        mealDescription: 'Peynir, Zeytin, Tereyağı, Reçel, Bal, Yumurta, Domates, Salatalık, Çay',
        mealType: 'normal',
        mealPeriod: 'breakfast',
        mealDate: DateTime(now.year, now.month, now.day, 7, 30),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez',
        price: 10.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TODAY-1',
        isTransferOpen: true,
        swapInterestedCount: 2,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      // BUGÜN - Öğle
      ReservationModel(
        id: 'res-transfer-today-2',
        userId: 'other-user-2',
        mealId: 'meal-lunch-0-caf1',
        mealName: 'Öğle Menüsü 2',
        mealDescription: 'Mercimek Çorbası, Tavuk Şinitzel, Makarna, Salata, Cacık, Meyve',
        mealType: 'normal',
        mealPeriod: 'lunch',
        mealDate: DateTime(now.year, now.month, now.day, 12, 0),
        cafeteriaId: 'cafeteria-2',
        cafeteriaName: 'Mühendislik',
        price: 15.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TODAY-2',
        isTransferOpen: true,
        swapInterestedCount: 4,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ReservationModel(
        id: 'res-transfer-today-3',
        userId: 'other-user-3',
        mealId: 'meal-lunch-veg-0',
        mealName: 'Vejetaryen Öğle',
        mealDescription: 'Sebze Çorbası, Zeytinyağlı Enginar, Bulgur Pilavı, Yoğurt, Salata, Meyve',
        mealType: 'vegetarian',
        mealPeriod: 'lunch',
        mealDate: DateTime(now.year, now.month, now.day, 12, 0),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez',
        price: 14.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TODAY-3',
        isTransferOpen: true,
        swapInterestedCount: 1,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      // BUGÜN - Akşam
      ReservationModel(
        id: 'res-transfer-today-4',
        userId: 'other-user-4',
        mealId: 'meal-dinner-0-caf2',
        mealName: 'Akşam Menüsü 1',
        mealDescription: 'Domates Çorbası, Köfte, Pilav, Haydari, Salata, Ayran',
        mealType: 'normal',
        mealPeriod: 'dinner',
        mealDate: DateTime(now.year, now.month, now.day, 18, 30),
        cafeteriaId: 'cafeteria-3',
        cafeteriaName: 'Tıp',
        price: 16.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TODAY-4',
        isTransferOpen: true,
        swapInterestedCount: 3,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      // YARIN - Kahvaltı
      ReservationModel(
        id: 'res-transfer-tom-1',
        userId: 'other-user-5',
        mealId: 'meal-breakfast-1-caf0',
        mealName: 'Serpme Kahvaltı',
        mealDescription: 'Beyaz Peynir, Kaşar, Zeytin Çeşitleri, Yumurta, Sosis, Börek, Çay, Kahve',
        mealType: 'normal',
        mealPeriod: 'breakfast',
        mealDate: now.add(const Duration(days: 1)).copyWith(hour: 7, minute: 30),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez',
        price: 10.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TOM-1',
        isTransferOpen: true,
        swapInterestedCount: 5,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      ReservationModel(
        id: 'res-transfer-tom-2',
        userId: 'other-user-6',
        mealId: 'meal-breakfast-1-caf1',
        mealName: 'Kahvaltı Tabağı',
        mealDescription: 'Peynir, Zeytin, Yumurta, Simit, Çay',
        mealType: 'normal',
        mealPeriod: 'breakfast',
        mealDate: now.add(const Duration(days: 1)).copyWith(hour: 7, minute: 30),
        cafeteriaId: 'cafeteria-2',
        cafeteriaName: 'Mühendislik',
        price: 10.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TOM-2',
        isTransferOpen: true,
        swapInterestedCount: 2,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      // YARIN - Öğle
      ReservationModel(
        id: 'res-transfer-tom-3',
        userId: 'other-user-7',
        mealId: 'meal-lunch-1-caf0',
        mealName: 'Öğle Menüsü 3',
        mealDescription: 'Ezogelin Çorbası, Mantı, Ayran, Salata, Meyve',
        mealType: 'normal',
        mealPeriod: 'lunch',
        mealDate: now.add(const Duration(days: 1)).copyWith(hour: 12, minute: 0),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez',
        price: 15.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TOM-3',
        isTransferOpen: true,
        swapInterestedCount: 3,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      // YARIN - Akşam
      ReservationModel(
        id: 'res-transfer-tom-4',
        userId: 'other-user-8',
        mealId: 'meal-dinner-vegan-1',
        mealName: 'Vegan Akşam Menüsü',
        mealDescription: 'Sebze Çorbası, Nohut Burger, Patates Kızartması, Salata, Meyve',
        mealType: 'vegan',
        mealPeriod: 'dinner',
        mealDate: now.add(const Duration(days: 1)).copyWith(hour: 18, minute: 30),
        cafeteriaId: 'cafeteria-3',
        cafeteriaName: 'Tıp',
        price: 15.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-TOM-4',
        isTransferOpen: true,
        swapInterestedCount: 1,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      // 2 GÜN SONRA
      ReservationModel(
        id: 'res-transfer-2days-1',
        userId: 'other-user-9',
        mealId: 'meal-lunch-2-caf2',
        mealName: 'Öğle Menüsü 4',
        mealDescription: 'Yayla Çorbası, Tavuk Sote, Pilav, Cacık, Salata, Meyve',
        mealType: 'normal',
        mealPeriod: 'lunch',
        mealDate: now.add(const Duration(days: 2)).copyWith(hour: 12, minute: 0),
        cafeteriaId: 'cafeteria-3',
        cafeteriaName: 'Tıp',
        price: 15.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-2DAYS-1',
        isTransferOpen: true,
        swapInterestedCount: 2,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      ReservationModel(
        id: 'res-transfer-2days-2',
        userId: 'other-user-10',
        mealId: 'meal-dinner-2-caf1',
        mealName: 'Balık Menüsü',
        mealDescription: 'Balık Çorbası, Izgara Levrek, Patates Püresi, Salata, Limonata',
        mealType: 'normal',
        mealPeriod: 'dinner',
        mealDate: now.add(const Duration(days: 2)).copyWith(hour: 18, minute: 30),
        cafeteriaId: 'cafeteria-2',
        cafeteriaName: 'Mühendislik',
        price: 18.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-2DAYS-2',
        isTransferOpen: true,
        swapInterestedCount: 7,
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
      // Glutensiz seçenek
      ReservationModel(
        id: 'res-transfer-gluten-1',
        userId: 'other-user-11',
        mealId: 'meal-lunch-gluten-3',
        mealName: 'Glutensiz Öğle Menüsü',
        mealDescription: 'Glutensiz Makarna, Fırında Sebze, Salata, Yoğurt, Meyve',
        mealType: 'gluten_free',
        mealPeriod: 'lunch',
        mealDate: now.add(const Duration(days: 3)).copyWith(hour: 12, minute: 0),
        cafeteriaId: 'cafeteria-1',
        cafeteriaName: 'Merkez',
        price: 16.00,
        status: 'transferOpen',
        qrCode: 'QR-TRANSFER-GLUTEN-1',
        isTransferOpen: true,
        swapInterestedCount: 1,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    
    final allReservations = [...myReservations, ...transferOpenReservations];
    print('📦 MockDataService: Toplam ${allReservations.length} rezervasyon döndürülüyor');
    print('   👤 Kendi rezervasyonları: ${myReservations.length}');
    print('   🔄 Takas rezervasyonları: ${transferOpenReservations.length}');
    return allReservations;
  }

  // Mock Transactions
  List<TransactionModel> getMockTransactions(String userId) {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'trans-1',
        userId: userId,
        type: 'load',
        amount: 100.00,
        balanceAfter: 125.50,
        description: 'Bakiye Yükleme',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TransactionModel(
        id: 'trans-2',
        userId: userId,
        type: 'reservation',
        amount: -15.50,
        balanceAfter: 25.50,
        description: 'Rezervasyon Ödemesi - Erzincan Çorba',
        reservationId: 'res-1',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: 'trans-3',
        userId: userId,
        type: 'reservation',
        amount: -18.00,
        balanceAfter: 41.00,
        description: 'Rezervasyon Ödemesi - Izgara Tavuk',
        reservationId: 'res-2',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TransactionModel(
        id: 'trans-4',
        userId: userId,
        type: 'load',
        amount: 50.00,
        balanceAfter: 59.00,
        description: 'Bakiye Yükleme',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'trans-5',
        userId: userId,
        type: 'refund',
        amount: 6.00,
        balanceAfter: 9.00,
        description: 'İade - İptal Edilen Rezervasyon',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Mock Login
  Future<UserModel?> mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_mockUsers.containsKey(email) && password == 'password123') {
      return _mockUsers[email];
    }
    return null;
  }

  // Mock Register
  Future<UserModel> mockRegister({
    required String email,
    required String fullName,
    String? schoolEmail,
    String? phone,
    String? studentNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final newUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      schoolEmail: schoolEmail,
      phone: phone,
      studentNumber: studentNumber,
      role: 'student',
      balance: 0,
      school: 'Erzincan Binali Yıldırım Üniversitesi',
      createdAt: DateTime.now(),
    );
    
    _mockUsers[email] = newUser;
    return newUser;
  }

  // Mock Balance Load
  Future<void> mockLoadBalance(String userId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would update Supabase
  }

  // Mock Create Reservation
  Future<ReservationModel> mockCreateReservation({
    required String userId,
    required MealModel meal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return ReservationModel(
      id: 'res-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      mealId: meal.id,
      mealName: meal.name,
      mealType: meal.mealType,
      mealPeriod: meal.mealPeriod,
      mealDate: meal.mealDate,
      cafeteriaId: meal.cafeteriaId,
      cafeteriaName: meal.cafeteriaName,
      price: meal.reservationPrice,
      status: 'reserved',
      qrCode: 'QR-${DateTime.now().millisecondsSinceEpoch}',
      isTransferOpen: false,
      createdAt: DateTime.now(),
    );
  }

  // Mock Cancel Reservation
  Future<void> mockCancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would update Supabase
  }

  // Mock Open for Swap
  Future<void> mockOpenForSwap(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would update Supabase
  }

  // Mock Accept Swap
  Future<void> mockAcceptSwap(String reservationId, String newUserId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would update Supabase
  }

  // Update User Preferences
  void updateUserPreferences({
    required String userId,
    String? preferredCafeteriaId,
  }) {
    // Mock data'daki kullanıcıyı bul ve güncelle
    _mockUsers.forEach((email, user) {
      if (user.id == userId) {
        _mockUsers[email] = user.copyWith(
          preferredCafeteriaId: preferredCafeteriaId,
        );
      }
    });
  }
}

