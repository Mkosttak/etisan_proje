# 🔧 Supabase Kurulum Rehberi

Bu rehber, ETİSAN projesini Supabase backend'i ile çalıştırmak için gerekli adımları içermektedir.

## 1. Supabase Projesi Oluşturma

1. [supabase.com](https://supabase.com) adresine gidin
2. "Start your project" butonuna tıklayın
3. Yeni bir organizasyon oluşturun (ücretsiz plan yeterli)
4. "New Project" butonuna tıklayın
5. Proje bilgilerini doldurun:
   - **Name:** etisan-project
   - **Database Password:** Güçlü bir şifre seçin (kaydedin!)
   - **Region:** Europe (Frankfurt) - size en yakın bölgeyi seçin
   - **Pricing Plan:** Free

## 2. Database Tabloları Oluşturma

Supabase Dashboard'da **SQL Editor** sekmesine gidin ve aşağıdaki SQL komutlarını çalıştırın:

### Users Tablosu
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  school_email TEXT,
  phone TEXT,
  student_number TEXT,
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'staff', 'admin')),
  balance DECIMAL(10,2) DEFAULT 0 CHECK (balance >= 0),
  school TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Index for faster queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Enable RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid()::text = id::text);

CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id::text = auth.uid()::text AND role = 'admin'
    )
  );
```

### Meals Tablosu
```sql
-- Meals table
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('normal', 'vegetarian', 'vegan', 'glutenFree')),
  meal_period TEXT NOT NULL CHECK (meal_period IN ('breakfast', 'lunch', 'dinner')),
  meal_date TIMESTAMP WITH TIME ZONE NOT NULL,
  reservation_price DECIMAL(10,2) NOT NULL CHECK (reservation_price > 0),
  walk_in_price DECIMAL(10,2) NOT NULL CHECK (walk_in_price >= reservation_price),
  total_spots INTEGER NOT NULL CHECK (total_spots > 0),
  available_spots INTEGER NOT NULL CHECK (available_spots >= 0 AND available_spots <= total_spots),
  allergens TEXT[] DEFAULT '{}',
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_meals_date ON meals(meal_date);
CREATE INDEX idx_meals_type ON meals(meal_type);
CREATE INDEX idx_meals_period ON meals(meal_period);

-- Enable RLS
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view meals" ON meals
  FOR SELECT USING (true);

CREATE POLICY "Only admins can manage meals" ON meals
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users WHERE id::text = auth.uid()::text AND role = 'admin'
    )
  );
```

### Reservations Tablosu
```sql
-- Reservations table
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
  meal_name TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  meal_period TEXT NOT NULL,
  meal_date TIMESTAMP WITH TIME ZONE NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price > 0),
  status TEXT DEFAULT 'reserved' CHECK (status IN ('reserved', 'consumed', 'cancelled', 'transferOpen', 'transferred')),
  qr_code TEXT,
  is_transfer_open BOOLEAN DEFAULT FALSE,
  transferred_to_user_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  consumed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_meal ON reservations(meal_id);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_reservations_date ON reservations(meal_date);

-- Enable RLS
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own reservations" ON reservations
  FOR SELECT USING (user_id::text = auth.uid()::text);

CREATE POLICY "Users can create reservations" ON reservations
  FOR INSERT WITH CHECK (user_id::text = auth.uid()::text);

CREATE POLICY "Users can update own reservations" ON reservations
  FOR UPDATE USING (user_id::text = auth.uid()::text);

CREATE POLICY "Admins can view all reservations" ON reservations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id::text = auth.uid()::text AND role = 'admin'
    )
  );

CREATE POLICY "Users can view transfer-open reservations" ON reservations
  FOR SELECT USING (is_transfer_open = true);
```

### Transactions Tablosu
```sql
-- Transactions table
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('load', 'reservation', 'refund', 'transfer')),
  amount DECIMAL(10,2) NOT NULL,
  balance_after DECIMAL(10,2) NOT NULL CHECK (balance_after >= 0),
  description TEXT NOT NULL,
  reservation_id UUID REFERENCES reservations(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_date ON transactions(created_at DESC);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own transactions" ON transactions
  FOR SELECT USING (user_id::text = auth.uid()::text);

CREATE POLICY "System can create transactions" ON transactions
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can view all transactions" ON transactions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id::text = auth.uid()::text AND role = 'admin'
    )
  );
```

### Schools Tablosu (Opsiyonel)
```sql
-- Schools table
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  domain TEXT UNIQUE NOT NULL,
  cancel_deadline_hours INTEGER DEFAULT 24,
  swap_deadline_hours INTEGER DEFAULT 48,
  refund_percentage DECIMAL(3,2) DEFAULT 0.50,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Default school
INSERT INTO schools (name, domain) VALUES 
  ('Erzincan Binali Yıldırım Üniversitesi', 'erzincan.edu.tr');
```

## 3. Database Functions (Triggers)

### Auto-update Updated_at Field
```sql
-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meals_updated_at BEFORE UPDATE ON meals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Update Meal Available Spots
```sql
-- Function to update meal available spots
CREATE OR REPLACE FUNCTION update_meal_spots()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE meals 
    SET available_spots = available_spots - 1 
    WHERE id = NEW.meal_id;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE meals 
    SET available_spots = available_spots + 1 
    WHERE id = OLD.meal_id;
  ELSIF (TG_OP = 'UPDATE' AND NEW.status = 'cancelled' AND OLD.status != 'cancelled') THEN
    UPDATE meals 
    SET available_spots = available_spots + 1 
    WHERE id = NEW.meal_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Apply trigger
CREATE TRIGGER update_meal_spots_trigger
AFTER INSERT OR DELETE OR UPDATE ON reservations
FOR EACH ROW EXECUTE FUNCTION update_meal_spots();
```

## 4. Demo Data (Test İçin)

```sql
-- Demo users
INSERT INTO users (id, email, full_name, role, balance, school) VALUES
  ('00000000-0000-0000-0000-000000000001', 'student@etisan.com', 'Ahmet Yılmaz', 'student', 125.50, 'Erzincan Binali Yıldırım Üniversitesi'),
  ('00000000-0000-0000-0000-000000000002', 'admin@etisan.com', 'Admin User', 'admin', 0, 'Erzincan Binali Yıldırım Üniversitesi');

-- Demo meals (adjust dates to future)
INSERT INTO meals (name, description, meal_type, meal_period, meal_date, reservation_price, walk_in_price, total_spots, available_spots, allergens) VALUES
  ('Erzincan Çorba', 'Kıymalı Karnabahar, Soslu Makarna, Ayran, Tatlı', 'vegetarian', 'lunch', NOW() + INTERVAL '1 day', 15.50, 22.00, 50, 25, ARRAY['dairy', 'gluten']),
  ('Izgara Tavuk', 'Izgara Tavuk Göğsü, Pilav, Salata, Ayran', 'normal', 'dinner', NOW() + INTERVAL '1 day', 18.00, 25.00, 60, 35, ARRAY['gluten']),
  ('Vegan Köfte', 'Vegan Köfte, Bulgur Pilavı, Zeytinyağlı Sebze', 'vegan', 'lunch', NOW() + INTERVAL '2 days', 16.00, 23.00, 40, 30, ARRAY[]::text[]),
  ('Kahvaltı Menüsü', 'Peynir, Zeytin, Yumurta, Reçel, Bal, Ekmek, Çay', 'normal', 'breakfast', NOW() + INTERVAL '1 day', 12.00, 18.00, 80, 50, ARRAY['dairy', 'gluten']),
  ('Glutensiz Menü', 'Glutensiz Makarna, Salata, Meyve', 'glutenFree', 'dinner', NOW() + INTERVAL '2 days', 17.50, 24.50, 30, 20, ARRAY[]::text[]);
```

## 5. Storage (Profil ve Yemek Fotoğrafları)

1. Supabase Dashboard'da **Storage** sekmesine gidin
2. Yeni bucket oluşturun:
   - **Name:** `profile-images`
   - **Public:** ✅ (checkbox'u işaretleyin)
   
3. Başka bir bucket oluşturun:
   - **Name:** `meal-images`
   - **Public:** ✅

## 6. Authentication Ayarları

1. **Authentication** > **Settings** sekmesine gidin
2. **Email Auth** etkinleştirin
3. **Email Templates** düzenleyin (opsiyonel)
4. **Redirect URLs** ekleyin:
   - `http://localhost:3000/**`
   - `myapp://**` (mobil için)

## 7. API Keys

1. **Settings** > **API** sekmesine gidin
2. Aşağıdaki bilgileri kopyalayın:
   - **Project URL**
   - **anon public** key

3. `lib/core/constants/app_constants.dart` dosyasını açın:
```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

## 8. Realtime Ayarları (Opsiyonel)

Gerçek zamanlı güncellemeler için:

1. **Database** > **Replication** sekmesine gidin
2. `meals` ve `reservations` tablolarını ekleyin
3. `lib/main.dart` dosyasında Supabase initialization'ı uncomment edin:

```dart
await SupabaseService.initialize();
```

## 9. Test

Tüm kurulum tamamlandıktan sonra:

1. Uygulamayı çalıştırın: `flutter run`
2. Demo hesaplarla giriş yapın:
   - **Öğrenci:** student@etisan.com / password123
   - **Admin:** admin@etisan.com / password123

## 10. Güvenlik Kontrol Listesi

- ✅ RLS tüm tablolarda etkin
- ✅ Policies doğru yapılandırılmış
- ✅ API keys güvende (.gitignore'da)
- ✅ Strong password kullanıldı
- ✅ Email verification etkin (üretim için)
- ✅ Rate limiting yapılandırıldı

## Sorun Giderme

### Bağlantı Hatası
- API URL ve Key'leri kontrol edin
- Internet bağlantınızı kontrol edin
- Supabase proje durumunu kontrol edin (dashboard'da)

### Authentication Hatası
- Email verification ayarlarını kontrol edin
- Redirect URLs'leri kontrol edin
- RLS policies'leri kontrol edin

### Database Hatası
- SQL sorgularını tek tek çalıştırın
- Error mesajlarını okuyun
- RLS policies'leri devre dışı bırakıp test edin (geliştirme için)

## Ek Kaynaklar

- 📚 [Supabase Documentation](https://supabase.com/docs)
- 🎥 [Supabase Flutter Tutorial](https://www.youtube.com/watch?v=zlhY7VrzS3M)
- 💬 [Supabase Discord](https://discord.supabase.com/)

---

**Not:** Bu kurulum rehberi geliştirme ortamı içindir. Üretim ortamına geçmeden önce güvenlik ayarlarını gözden geçirin ve sıkılaştırın.

