# JunkFinder

macOS'ta kullanıcının normalde hiç açıp bakmadığı ama diskte sessizce yer kaplayan dosyaları bulan, native bir SwiftUI uygulaması.

Uygulama önbellekleri, log dosyaları, Xcode'un derleme artıkları, simülatör önbellekleri ve Downloads'ta unutulmuş eski kurulum dosyaları gibi bilinen "junk" konumlarını tarar; her birinin boyutunu ve son erişim tarihini gösterir. Hiçbir şeyi otomatik veya kalıcı olarak silmez — sen seçersin, uygulama yalnızca seçtiklerini **Çöp Kutusu'na** taşır.


## Özellikler

- **Sadece bilinen, güvenli konumları tarar** — rastgele disk taraması yapmaz, aşağıdaki listedeki sabit konumlara bakar.
- **Hiçbir şeyi kalıcı silmez** — seçilen öğeler macOS Çöp Kutusu'na taşınır, oradan istediğin an geri alabilirsin.
- **Boyut ve "son erişim" bilgisi** — her dosya/klasör için gerçek disk boyutu ve ne zamandır dokunulmadığı gösterilir.
- **Kategori bazlı güven seviyesi** — "Güvenli" ve "Dikkatli ol" etiketleriyle hangi kategorinin ne kadar riskli olduğu belirtilir.
- **Finder entegrasyonu** — herhangi bir öğeye sağdaki klasör ikonundan Finder'da doğrudan ulaşabilirsin.

## Taranan konumlar

| Kategori | Konum | Açıklama |
| --- | --- | --- |
| Uygulama önbellekleri | `~/Library/Caches` | Uygulamaların ürettiği, yeniden oluşturulabilir geçici dosyalar |
| Uygulama günlükleri | `~/Library/Logs` | Log ve çökme raporu dosyaları |
| Kaydedilmiş pencere durumları | `~/Library/Saved Application State` | Pencere konumu hatırlama dosyaları |
| Xcode Derived Data | `~/Library/Developer/Xcode/DerivedData` | Derleme ara dosyaları |
| Xcode arşivleri | `~/Library/Developer/Xcode/Archives` | Eski uygulama arşivleri |
| Eski cihaz sembol dosyaları | `~/Library/Developer/Xcode/{iOS,watchOS,tvOS} DeviceSupport` | Artık bağlı olmayan cihazlar için indirilen semboller |
| Simülatör önbellekleri | `~/Library/Developer/CoreSimulator/Caches` | iOS Simulator önbelleği |
| Unutulmuş kurulum dosyaları | `~/Downloads` (`.dmg`, `.pkg`, `.iso`, `.zip`, 90+ gün dokunulmamış) | Kurulduktan sonra unutulan yükleyiciler |

## Gereksinimler

- macOS 13 (Ventura) veya üzeri
- Derlemek için: Xcode 15+ veya Swift 5.9+ komut satırı araçları (`xcode-select --install`)

## Kurulum

### 1. Depoyu klonla

```bash
git clone https://github.com/kutluhanozbakan/JunkFinder.git
cd JunkFinder
```

### 2. Uygulamayı derle ve `.app` paketi oluştur

```bash
./Scripts/build_app.sh
```

Bu script `swift build -c release` ile derler ve çalıştığı klasörde çift tıklanabilir bir `JunkFinder.app` oluşturur.

### 3. Uygulamalar klasörüne taşı (opsiyonel)

```bash
cp -R JunkFinder.app ~/Applications/
```

Böylece Launchpad'den de açabilirsin.

### Alternatif: doğrudan çalıştırma (geliştirme için)

```bash
swift run
```

## İlk çalıştırma

Uygulama açıldığında otomatik olarak taramaya başlar. Downloads klasörüne erişim için macOS bir izin penceresi gösterebilir — bunu onaylaman gerekir, aksi halde o kategori boş görünür.

## Nasıl çalışır

- Tarama tamamen `FileManager` ile dosya sistemini okuyarak yapılır; hiçbir veri dışarıya gönderilmez, uygulama internet erişimi kullanmaz.
- Boyutlar her klasör için özyinelemeli olarak hesaplanır; büyük klasörlerde (özellikle Xcode Derived Data) tarama birkaç saniye sürebilir.
- "Son erişim" tarihi dosyanın `contentAccessDate` değerine dayanır; bu değer bulunamazsa değişiklik tarihine düşülür.
- Çöp Kutusu'na taşıma işlemi `FileManager.trashItem(at:resultingItemURL:)` ile yapılır — bu, Finder'daki "Çöp Kutusu'na Taşı" ile aynı, geri alınabilir işlemdir.

## Lisans

Bu proje kişisel kullanım için hazırlanmıştır; dilediğin gibi kullanabilir, değiştirebilirsin.
