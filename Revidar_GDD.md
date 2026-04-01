# 🗡️ PARRY KNIGHT — Game Design Document
### Top-Down Parry-Based Action RPG | SpriteKit + Swift

---

## 📋 İçindekiler

1. [Proje Özeti](#1-proje-özeti)
2. [Teknik Mimari](#2-teknik-mimari)
3. [Oyun Mekaniği — Dövüş Sistemi](#3-oyun-mekaniği--dövüş-sistemi)
4. [Parry Sistemi (Çekirdek Mekanik)](#4-parry-sistemi-çekirdek-mekanik)
5. [Combo Sistemi](#5-combo-sistemi)
6. [Slow-Motion Sistemi](#6-slow-motion-sistemi)
7. [Düşman AI Sistemi](#7-düşman-ai-sistemi)
8. [Silah Sistemi](#8-silah-sistemi)
9. [Skill Tree / Yetenek Ağacı](#9-skill-tree--yetenek-ağacı)
10. [Level Tasarımı](#10-level-tasarımı)
11. [Boss Fight Tasarımı](#11-boss-fight-tasarımı)
12. [HUD & UI Tasarımı](#12-hud--ui-tasarımı)
13. [Kontrol Sistemi](#13-kontrol-sistemi)
14. [Kamera Sistemi](#14-kamera-sistemi)
15. [Fizik & Çarpışma Sistemi](#15-fizik--çarpışma-sistemi)
16. [Efekt & Juice Sistemi](#16-efekt--juice-sistemi)
17. [Ses Tasarımı](#17-ses-tasarımı)
18. [Lokalizasyon (TR/EN)](#18-lokalizasyon-tren)
19. [Performans & Optimizasyon](#19-performans--optimizasyon)
20. [Art Pipeline & Asset Yönetimi](#20-art-pipeline--asset-yönetimi)
21. [Geliştirme Aşamaları (Roadmap)](#21-geliştirme-aşamaları-roadmap)
22. [Dosya Yapısı](#22-dosya-yapısı)
23. [Matematik & Fizik Referansı](#23-matematik--fizik-referansı)

---

## 1. Proje Özeti

| Alan | Detay |
|------|-------|
| **İsim** | Parry Knight (çalışma adı) |
| **Tür** | Top-Down Action RPG |
| **Motor** | SpriteKit + SKShader (Metal backend) |
| **Dil** | Swift 5.9+ |
| **Platform** | iOS (iPhone) + macOS (Universal) |
| **Min. iOS** | 17.0 |
| **Min. macOS** | 14.0 |
| **Çerçeve** | SwiftUI lifecycle + SpriteKit view |
| **Perspektif** | Top-down 45° izometrik hissi (2D sprite'lar ile) |
| **Hedef FPS** | 60 FPS sabit (iPhone 12+), 120 FPS (ProMotion) |
| **Oyun Dili** | Türkçe + İngilizce |

### Temel Konsept

Batman Arkham serisinin parry/counter sisteminden ilham alan, Diablo tarzı top-down perspektifli bir aksiyon RPG. Oyuncunun refleksleri ve zamanlaması, brute-force saldırıdan daha ödüllendirici. Her düşman saldırısı bir fırsat — doğru zamanda parry yapan oyuncu savaşın akışını kontrol eder.

### Tasarım Felsefesi

```
"Kolay öğren, ustalaşması zor"

Saldırı butonu → herkes yapabilir
Parry butonu  → zamanlamayı öğrenmek gerekir
Perfect Parry → ustalık gerektirir, ödülü büyüktür
Combo Chain   → parry ustası olanlara açılan kapı
```

---

## 2. Teknik Mimari

### 2.1 Proje Yapısı — SwiftUI + SpriteKit Hibrit

```
ParryKnight/
├── App/
│   ├── ParryKnightApp.swift          // @main, SwiftUI lifecycle
│   └── ContentView.swift             // Ana SwiftUI container
│
├── Core/                             // Oyun motoru çekirdeği
│   ├── GameScene.swift               // Ana SKScene — oyun döngüsü burada
│   ├── GameStateMachine.swift        // GKStateMachine: Menu, Playing, Paused, GameOver
│   ├── EntityManager.swift           // Entity-Component sistemi yöneticisi
│   ├── PhysicsManager.swift          // Çarpışma kategorileri ve contact delegate
│   ├── CameraManager.swift           // Kamera takip, zoom, shake
│   └── TimeManager.swift             // Slow-motion, hitstop, deltaTime yönetimi
│
├── ECS/                              // Entity-Component-System
│   ├── Components/
│   │   ├── TransformComponent.swift  // Pozisyon, rotasyon, scale
│   │   ├── SpriteComponent.swift     // SKSpriteNode render
│   │   ├── HealthComponent.swift     // HP, damage, ölüm
│   │   ├── CombatComponent.swift     // Saldırı, parry state
│   │   ├── MovementComponent.swift   // Hız, yön, friction
│   │   ├── AIComponent.swift         // Düşman davranış ağacı
│   │   ├── AnimationComponent.swift  // Sprite animasyon state machine
│   │   ├── HitboxComponent.swift     // Saldırı hitbox (geçici)
│   │   ├── HurtboxComponent.swift    // Hasar alınabilir alan (kalıcı)
│   │   └── WeaponComponent.swift     // Silah stats ve davranışı
│   ├── Systems/
│   │   ├── MovementSystem.swift      // Hareket fiziği uygula
│   │   ├── CombatSystem.swift        // Saldırı/parry çözümleme
│   │   ├── AISystem.swift            // Düşman karar ağacı
│   │   ├── AnimationSystem.swift     // Animasyon geçişleri
│   │   ├── DamageSystem.swift        // Hasar hesaplama
│   │   └── CleanupSystem.swift       // Ölü entity temizliği
│   └── Entity.swift                  // Base entity sınıfı
│
├── Combat/                           // Dövüş sistemi detayları
│   ├── ParrySystem.swift             // Parry window, perfect parry, timing
│   ├── ComboManager.swift            // Combo zinciri, multiplier
│   ├── SlowMotionController.swift    // Bullet-time efekti
│   ├── HitstopController.swift       // Frame freeze — "ağırlık hissi"
│   ├── DamageCalculator.swift        // Hasar formülleri
│   ├── KnockbackCalculator.swift     // Geri tepme vektörleri
│   └── AttackPatternLibrary.swift    // Düşman saldırı desenleri
│
├── Enemies/                          // Düşman tanımları
│   ├── EnemyFactory.swift            // Düşman spawn factory
│   ├── Types/
│   │   ├── GruntEnemy.swift          // Basit yakın dövüş
│   │   ├── ShieldEnemy.swift         // Kalkanlı, parry zorunlu
│   │   ├── FastEnemy.swift           // Hızlı, combo saldırı
│   │   ├── HeavyEnemy.swift          // Yavaş, güçlü, unblockable
│   │   └── EliteEnemy.swift          // Mini-boss kalitesinde
│   └── BehaviorTrees/
│       ├── AggressiveBT.swift        // Saldırgan davranış
│       ├── CautiousBT.swift          // Temkinli, çember çizer
│       └── SwarmerBT.swift           // Grup halinde saldırır
│
├── Weapons/                          // Silah sistemi
│   ├── WeaponBase.swift              // Protocol: tüm silahlar bunu uygular
│   ├── Sword.swift                   // Dengeli, orta hız/hasar
│   ├── GreatSword.swift              // Yavaş, yüksek hasar, geniş arc
│   ├── DualDaggers.swift             // Çok hızlı, düşük hasar, dar arc
│   └── Mace.swift                    // Orta hız, yüksek knockback
│
├── Levels/                           // Level yönetimi
│   ├── LevelManager.swift            // Level yükleme, geçiş
│   ├── WaveSpawner.swift             // Düşman dalga sistemi
│   ├── LevelData/
│   │   ├── Level1_Crypt.json         // Level 1 verisi
│   │   ├── Level2_Courtyard.json     // Level 2 verisi
│   │   ├── Level3_Throne.json        // Level 3 verisi
│   │   └── BossArena.json            // Boss arena verisi
│   └── TileMapManager.swift          // SKTileMapNode yönetimi
│
├── Skills/                           // Yetenek ağacı
│   ├── SkillTree.swift               // Skill tree veri yapısı
│   ├── SkillNode.swift               // Tek yetenek tanımı
│   └── SkillData.json                // Tüm yetenekler ve bağlantıları
│
├── UI/                               // Kullanıcı arayüzü
│   ├── HUD/
│   │   ├── HealthBarNode.swift       // HP bar (SpriteKit overlay)
│   │   ├── ComboCounterNode.swift    // Combo sayacı + multiplier
│   │   ├── ParryIndicatorNode.swift  // Parry timing feedback
│   │   └── BossHealthBarNode.swift   // Boss HP bar (ekran üstü)
│   ├── Controls/
│   │   ├── VirtualJoystick.swift     // Sol el — hareket
│   │   ├── ActionButtons.swift       // Sağ el — saldırı, parry, dodge
│   │   └── InputManager.swift        // Touch → game action çevirici
│   └── Menus/
│       ├── MainMenuView.swift        // SwiftUI ana menü
│       ├── PauseMenuView.swift       // SwiftUI pause overlay
│       ├── SkillTreeView.swift       // SwiftUI skill tree ekranı
│       └── SettingsView.swift        // Ayarlar (dil, ses, kontrol)
│
├── VFX/                              // Görsel efektler
│   ├── Shaders/
│   │   ├── hit_flash.fsh             // Hasar alma flash (beyaz)
│   │   ├── parry_flash.fsh           // Parry başarı efekti (altın)
│   │   ├── perfect_parry_glow.fsh    // Perfect parry (parlak altın + dalga)
│   │   ├── health_bar_gradient.fsh   // HP bar renk geçişi
│   │   └── outline.fsh              // Seçili/hedef düşman outline
│   ├── ParticleEffects/
│   │   ├── Sparks.sks               // Kılıç çarpışma kıvılcımı
│   │   ├── PerfectParryBurst.sks    // Perfect parry patlama
│   │   ├── DustTrail.sks            // Hareket tozu
│   │   ├── BloodHit.sks             // Hasar vuruş efekti
│   │   └── LevelUp.sks             // Seviye atlama efekti
│   └── ScreenEffects/
│       ├── ScreenShake.swift         // Ekran sarsıntısı
│       ├── ChromaticAberration.swift // Güçlü vuruşlarda renk kayması
│       └── Vignette.swift            // Düşük HP karartma
│
├── Audio/                            // Ses sistemi
│   ├── AudioManager.swift            // Merkezi ses yöneticisi
│   ├── SFXBank.swift                 // Ses efektleri katalog
│   └── MusicController.swift         // Dinamik müzik (combat intensity)
│
├── Localization/                     // Çoklu dil
│   ├── Localizable.xcstrings         // String Catalog (Xcode 15+)
│   └── LocalizationManager.swift     // Dil değiştirme mantığı
│
├── Data/                             // Veri katmanı
│   ├── GameDataManager.swift         // Kaydetme/yükleme (UserDefaults + JSON)
│   ├── PlayerProgress.swift          // Oyuncu ilerlemesi Codable model
│   └── BalanceConfig.json            // Tüm denge değerleri (hasar, HP, hız)
│
└── Utilities/
    ├── Extensions/
    │   ├── CGPoint+Math.swift        // Vektör matematiği
    │   ├── CGFloat+Lerp.swift        // Interpolasyon
    │   ├── SKNode+SafeRemove.swift   // Güvenli node kaldırma
    │   └── TimeInterval+Format.swift // Süre formatlama
    ├── Constants.swift               // Oyun sabitleri
    └── DebugOverlay.swift            // FPS, entity sayısı, hitbox görselleştirme
```

### 2.2 Entity-Component-System (ECS) Mimarisi

SpriteKit'in `GKEntity` / `GKComponent` sistemini kullanıyoruz ama kendi lightweight ECS wrapper'ımızla. Neden ECS?

- **Performans**: Aynı tip component'ler bellekte yan yana → cache-friendly
- **Esneklik**: Yeni düşman = mevcut component'lerin yeni kombinasyonu
- **Test edilebilirlik**: Her system bağımsız test edilebilir

```
Entity (GKEntity)
  ├── TransformComponent  → pozisyon, rotasyon
  ├── SpriteComponent     → görsel temsil
  ├── HealthComponent     → can, zırh
  ├── CombatComponent     → saldırı state, parry state
  ├── MovementComponent   → hız vektörü, sürtünme
  └── [optional] AIComponent → düşman davranışı
```

### 2.3 GameScene Update Döngüsü

```swift
// Her frame çağrılır (60 FPS = 16.67ms bütçe)
override func update(_ currentTime: TimeInterval) {
    // 1. TimeManager — deltaTime hesapla (slow-motion dahil)
    let dt = timeManager.update(currentTime)
    
    // 2. Input — touch/joystick verilerini oku
    inputManager.processInput()
    
    // 3. AI System — düşman kararları (her 3 frame'de bir = ~20Hz)
    if frameCount % 3 == 0 {
        aiSystem.update(dt)
    }
    
    // 4. Movement System — pozisyon güncelle
    movementSystem.update(dt)
    
    // 5. Combat System — saldırı/parry çözümleme
    combatSystem.update(dt)
    
    // 6. Damage System — hasar uygula
    damageSystem.update(dt)
    
    // 7. Animation System — sprite animasyonları
    animationSystem.update(dt)
    
    // 8. Camera — takip + efektler
    cameraManager.update(dt)
    
    // 9. Cleanup — ölü entity'leri kaldır
    cleanupSystem.update(dt)
    
    // 10. HUD — UI güncelle
    hudManager.update(dt)
    
    frameCount += 1
}
```

**Bütçe dağılımı (16.67ms @ 60FPS):**
| Sistem | Maks. Süre | Not |
|--------|-----------|-----|
| Input | 0.5ms | Touch okuma |
| AI | 2ms | 20Hz'de çalışır |
| Movement | 1ms | Basit vektör math |
| Combat | 3ms | Hitbox overlap check |
| Damage | 1ms | Hasar hesaplama |
| Animation | 2ms | Texture atlas swap |
| Camera | 1ms | Lerp + shake |
| Render (SpriteKit) | 5ms | Motor tarafında |
| **Toplam** | **~15.5ms** | **1.17ms boşluk** |

---

## 3. Oyun Mekaniği — Dövüş Sistemi

### 3.1 Combat State Machine

Oyuncu her an tek bir combat state'te bulunur:

```
                    ┌─────────────┐
                    │    IDLE     │ ← Hiçbir şey yapmıyor
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ ATTACKING│ │ PARRYING │ │ DODGING  │
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ RECOVERY │ │ COUNTER  │ │ RECOVERY │
        └────┬─────┘ │ ATTACK   │ └────┬─────┘
             │       └────┬─────┘      │
             └────────────┼────────────┘
                          ▼
                    ┌──────────┐
                    │   IDLE   │
                    └──────────┘

        Ayrı dal:
        ┌──────────┐
        │  HIT     │ ← Hasar alınca (hitstun)
        │  STUN    │
        └────┬─────┘
             ▼
        ┌──────────┐
        │   IDLE   │
        └──────────┘
```

### 3.2 Saldırı Sistemi

Her saldırı 4 fazdan oluşur:

```
[Anticipation] → [Active] → [Hit Confirm] → [Recovery]
   (wind-up)     (hitbox)    (hitstop)       (cooldown)

Zaman çizelgesi (Sword örneği):
0.0s          0.15s        0.25s          0.35s         0.55s
|──────────────|─────────────|──────────────|──────────────|
  Anticipation    Active       Hit Confirm     Recovery
  (kol kalkar)   (kılıç       (ekran donar    (geri çekilir)
                  sallanır)    0.05s)
```

**Anticipation fazı neden önemli:**
- Oyuncuya "saldırı geliyor" sinyali verir
- Düşmanlar için de geçerli → oyuncu parry zamanını hesaplar
- Uzun anticipation = güçlü saldırı, kısa = zayıf ama hızlı

**Active fazı:**
- Hitbox aktif, hasar verebilir
- Her hitbox bir kez hasar verir (multi-hit önleme seti)
- Arc şeklinde sweep: silaha göre dar (45°) veya geniş (180°)

**Hit Confirm (Hitstop):**
- Vuruş anında hem saldıran hem yiyen 2-4 frame donar
- "Ağırlık hissi" verir — bu olmadan saldırılar havada kalır
- Hitstop süresi hasar miktarıyla orantılı

**Recovery fazı:**
- Oyuncu savunmasız (saldıramaz, parry yapamaz)
- Risk/ödül dengesi: güçlü saldırı = uzun recovery
- Animation cancelling YOK (bilinçli tasarım kararı)

### 3.3 Hasar Formülü

```
baseDamage = weapon.damage × attackType.multiplier

// Combo bonus (ardışık başarılı vuruşlar)
comboMultiplier = 1.0 + (comboCount × 0.15)  // max 2.5x @ 10 combo

// Counter attack bonus (parry sonrası)
counterMultiplier = isCounterAttack ? 2.0 : 1.0

// Perfect parry bonus
perfectMultiplier = isPerfectParryCounter ? 1.5 : 1.0

// Zırh azaltması (düşman için)
armorReduction = max(0, baseDamage - target.armor)

// Final hasar
finalDamage = armorReduction × comboMultiplier × counterMultiplier × perfectMultiplier

// Knockback kuvveti
knockbackForce = weapon.knockback × (1.0 + comboCount × 0.1)
knockbackDirection = normalize(target.position - attacker.position)
```

---

## 4. Parry Sistemi (Çekirdek Mekanik)

Bu oyunun kalbi. Her şey parry etrafında dönüyor.

### 4.1 Parry Penceresi (Timing Windows)

```
Düşman saldırı timeline:
|████████████░░░░░░░░░░░░░░░░░░░░░░░░████████████████|
 Anticipation  ▲         ▲         ▲       Active→Hit
               │         │         │
               │    PERFECT PARRY  │
               │     (±3 frame)    │
               │     ±50ms         │
               │                   │
          PARRY WINDOW START   PARRY WINDOW END
          (düşman active        (düşman active
           fazına girmeden       fazı başlangıcı
           200ms önce)           + 100ms)

Toplam parry penceresi: ~300ms (18 frame @ 60fps)
Perfect parry penceresi: ~100ms (6 frame @ 60fps) — tam ortada
```

### 4.2 Parry Türleri ve Ödülleri

```
┌─────────────────┬────────────────┬───────────────────────┬──────────────────┐
│ Parry Türü      │ Timing         │ Ödül                  │ Görsel Feedback  │
├─────────────────┼────────────────┼───────────────────────┼──────────────────┤
│ Miss (kaçırma)  │ Pencere dışı   │ Hasar yersin           │ Kırmızı flash    │
│                 │                │                       │                  │
│ Late Parry      │ Pencere sonu   │ %50 hasar azalt       │ Gri kıvılcım     │
│                 │ (son 100ms)    │ Küçük knockback        │                  │
│                 │                │                       │                  │
│ Normal Parry    │ Pencere ortası │ %100 hasar engelle    │ Beyaz kıvılcım   │
│                 │                │ Düşman stagger (0.5s) │ Kısa hitstop     │
│                 │                │ Counter attack fırsatı│                  │
│                 │                │                       │                  │
│ Perfect Parry   │ ±50ms tam      │ %100 hasar engelle    │ ALTIN PATLAMA    │
│                 │ zamanlama      │ Düşman stagger (1.2s) │ Slow-motion 0.5s │
│                 │                │ Counter attack 2x dmg │ Ekran shake      │
│                 │                │ Combo +2 bonus        │ Ses: metalik çınl│
│                 │                │ Özel counter animasyon│ Chromatic aberr. │
└─────────────────┴────────────────┴───────────────────────┴──────────────────┘
```

### 4.3 Parry Sistemi Kodu Taslağı

```swift
class ParrySystem {
    // Timing sabitleri (frame cinsinden, 60fps)
    static let parryWindowFrames: Int = 18        // 300ms
    static let perfectWindowFrames: Int = 6        // 100ms
    static let parryStartupFrames: Int = 2         // 33ms (buton basma → aktif)
    static let parryCooldownFrames: Int = 12       // 200ms (spam önleme)
    
    enum ParryResult {
        case miss
        case late(damageReduction: CGFloat)   // 0.5
        case normal
        case perfect
    }
    
    /// Düşman saldırısı oyuncunun parry penceresine denk mi?
    func evaluateParry(
        playerParryFrame: Int,       // Oyuncu ne zaman parry bastı
        enemyAttackFrame: Int,       // Düşman active faz başlangıcı
        enemyAnticipation: Int       // Düşman wind-up süresi
    ) -> ParryResult {
        
        // Düşman saldırısının "ideal parry anı"
        let idealFrame = enemyAttackFrame  // Active faz başlangıcı
        
        // Oyuncunun parry'si ne kadar erken/geç?
        let delta = playerParryFrame - idealFrame  // Negatif = erken, pozitif = geç
        let absDelta = abs(delta)
        
        // Perfect parry: ±3 frame (±50ms)
        if absDelta <= ParrySystem.perfectWindowFrames / 2 {
            return .perfect
        }
        
        // Normal parry: ±9 frame (±150ms) ama perfect değil
        if absDelta <= ParrySystem.parryWindowFrames / 2 {
            // Son %33'lük dilim → late parry
            if absDelta > ParrySystem.parryWindowFrames / 3 {
                return .late(damageReduction: 0.5)
            }
            return .normal
        }
        
        return .miss
    }
}
```

### 4.4 Parry Feedback Katmanları

İyi bir parry hissi için 7 katman feedback gerekir (hepsi aynı anda, <16ms içinde):

```
1. GÖRSEL  → Hit flash shader (1 frame beyaz/altın)
2. PARÇACIK → Kıvılcım emitter (parry noktasında)
3. ANİMASYON → Özel parry stance animasyonu
4. HITSTOP  → 3-6 frame dondurma (ağırlık hissi)
5. SES      → Metalik çınlama SFX
6. KAMERA   → Micro-shake (2px, 100ms)
7. HAPTIC   → UIImpactFeedbackGenerator (iPhone'da titreşim)
```

Perfect parry'de ek katmanlar:
```
8. SLOW-MO  → 0.3x hız, 0.5 saniye
9. ZOOM     → Kamera %110 zoom-in (0.2s ease-in-out)
10. SHADER  → Radial shockwave efekti
11. CHROMATIC → Renk kayması efekti (0.1s)
12. VIGNETTE → Altın kenar parlaması
```

### 4.5 Parry Spam Önleme

Oyuncuların sürekli parry basmasını engellemek için:

```
1. Cooldown: Parry sonrası 200ms bekleme (başarılı veya değil)
2. Whiff Penalty: Boşa parry → 400ms recovery (savunmasız)
3. Stamina Cost: Her parry denemesi 10 stamina harcar
4. Degrading Window: Ardışık parry denemeleri pencereyi %20 daraltır
   - 1. deneme: 300ms pencere
   - 2. deneme: 240ms pencere
   - 3. deneme: 192ms pencere
   - Reset: 1 saniye parry yapmayınca normal pencereye döner
```

---

## 5. Combo Sistemi

### 5.1 Combo Zinciri Mantığı

```
Combo başlangıcı: Herhangi bir başarılı vuruş
Combo devamı: 2 saniye içinde bir sonraki başarılı vuruş
Combo kırılması: 2 saniye vuruş yapamama VEYA hasar alma

Combo sayacı:
  Hit → 1x → Hit → 2x → Hit → 3x → ... → max 15x
  
  Perfect Parry → Combo'ya +2 bonus eklenir
  Counter Attack → Combo'ya +1 bonus eklenir

Combo multiplier (hasar çarpanı):
  combo 1-3:   1.0x (bonus yok, ısınma)
  combo 4-6:   1.3x
  combo 7-9:   1.6x
  combo 10-12: 2.0x
  combo 13-15: 2.5x (maksimum)

Combo aşamaları ve görsel feedback:
  1-3:   Beyaz sayaç (normal)
  4-6:   Sarı sayaç + hafif ekran pulse
  7-9:   Turuncu sayaç + speed lines
  10-12: Kırmızı sayaç + arka plan kararır + müzik yoğunlaşır
  13-15: ALTIN sayaç + tam görsel şölen + "UNSTOPPABLE!" yazısı
```

### 5.2 Combo Puanlama

```
Her vuruşun puan değeri:
baseScore = 100

hitScore = baseScore × comboMultiplier × hitTypeBonus

hitTypeBonus:
  Normal saldırı:        1.0x
  Counter attack:        2.0x
  Perfect parry counter: 3.0x
  Combo finisher (15x):  5.0x

Level sonu skor = Σ(tüm hitScore'lar) + zaman bonusu + hasar almama bonusu
```

---

## 6. Slow-Motion Sistemi

### 6.1 TimeManager Tasarımı

```swift
class TimeManager {
    private var realDeltaTime: TimeInterval = 0
    private var timeScale: CGFloat = 1.0
    private var targetTimeScale: CGFloat = 1.0
    private var transitionSpeed: CGFloat = 8.0  // Ne kadar hızlı geçiş yapılır
    
    /// Game-wide scaled delta time
    var deltaTime: TimeInterval {
        return realDeltaTime * TimeInterval(timeScale)
    }
    
    /// UI ve input için her zaman gerçek zaman kullan
    var unscaledDeltaTime: TimeInterval {
        return realDeltaTime
    }
    
    func update(_ currentTime: TimeInterval) -> TimeInterval {
        // ... deltaTime hesapla ...
        
        // Smooth geçiş (lerp)
        timeScale = lerp(timeScale, targetTimeScale, transitionSpeed * realDeltaTime)
        
        return deltaTime
    }
    
    /// Perfect parry slow-motion
    func triggerParrySlowMo() {
        targetTimeScale = 0.3          // %30 hız
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.targetTimeScale = 1.0  // Normal hıza dön
        }
    }
    
    /// Hitstop (tam dondurma)
    func triggerHitstop(frames: Int) {
        timeScale = 0.0
        let duration = TimeInterval(frames) / 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.timeScale = self.targetTimeScale
        }
    }
}
```

### 6.2 Slow-Motion Tetikleyiciler

```
Tetikleyici              │ Hız  │ Süre   │ Not
─────────────────────────┼──────┼────────┼─────────────────
Perfect Parry            │ 0.3x │ 0.5s   │ En sık kullanılan
Son düşman öldürme       │ 0.2x │ 0.8s   │ Wave/arena temizleme
Boss critical hit        │ 0.15x│ 1.0s   │ Dramatik an
Oyuncu düşük HP (<20%)   │ 0.8x │ sürekli│ Hafif, "tehlike" hissi
Combo 10+ hit            │ 0.5x │ 0.3s   │ Kısa vurgulama
```

**ÖNEMLİ: Slow-motion'dan etkilenMEyen sistemler:**
- UI animasyonları (combo counter, HP bar)
- Input okuma (joystick, butonlar)
- Müzik (pitch değişmez, sadece volume efektleri)
- Parçacık efektleri (gerçek zamanda devam eder)

---

## 7. Düşman AI Sistemi

### 7.1 Düşman Türleri

```
┌────────────────┬──────┬───────┬────────┬───────────┬──────────────────────────┐
│ Düşman         │ HP   │ Hasar │ Hız    │ Saldırı   │ Özel Mekanik             │
│                │      │       │        │ Hızı      │                          │
├────────────────┼──────┼───────┼────────┼───────────┼──────────────────────────┤
│ Grunt          │ 60   │ 10    │ 80     │ Yavaş     │ Basit, öğretici düşman   │
│ (İskelet)      │      │       │        │ (1.2s)    │ Uzun anticipation        │
│                │      │       │        │           │                          │
│ Shield Bearer  │ 100  │ 15    │ 60     │ Orta      │ Ön kalkan: sadece parry  │
│ (Kalkanlı)     │      │       │        │ (0.9s)    │ ile kırılır, arkadan     │
│                │      │       │        │           │ vurulamaz                │
│                │      │       │        │           │                          │
│ Assassin       │ 40   │ 20    │ 140    │ Çok hızlı │ 2-3'lü combo saldırı    │
│ (Suikastçi)    │      │       │        │ (0.5s)    │ Her biri ayrı parry      │
│                │      │       │        │           │ gerektirir               │
│                │      │       │        │           │                          │
│ Brute          │ 200  │ 35    │ 40     │ Çok yavaş │ UNBLOCKABLE saldırı     │
│ (Dev)          │      │       │        │ (2.0s)    │ Parry değil dodge gerekir│
│                │      │       │        │           │ Zemin dalgası            │
│                │      │       │        │           │                          │
│ Elite Knight   │ 150  │ 25    │ 90     │ Değişken  │ Feint yapabilir (sahte   │
│ (Elit)         │      │       │        │ (0.4-1.5s)│ saldırı başlatıp iptal) │
│                │      │       │        │           │ Parry'ni punish eder     │
└────────────────┴──────┴───────┴────────┴───────────┴──────────────────────────┘
```

### 7.2 Behaviour Tree Yapısı

```
Root (Selector)
├── [Priority 1] Retreat (HP < 20%?)
│   └── Flee from player → heal if possible
│
├── [Priority 2] Attack (in range + cooldown OK?)
│   ├── Selector
│   │   ├── Combo Attack (Assassin tipi, %30 şans)
│   │   ├── Heavy Attack (uzun wind-up, %20 şans)
│   │   └── Light Attack (hızlı, %50 şans)
│   └── Post-attack: strafe veya retreat
│
├── [Priority 3] Approach (out of range?)
│   ├── Path to player (A* veya basit seek)
│   └── Circle strafe (menzile yakınken)
│
└── [Priority 4] Idle
    └── Patrol veya alert stance
```

### 7.3 Düşman Koordinasyon Sistemi

Arkham serisinin en güzel özelliği: düşmanlar SIRA İLE saldırır.

```swift
class EnemyCoordinator {
    /// Aynı anda kaç düşman saldırabilir
    var maxSimultaneousAttackers: Int {
        switch difficulty {
        case .easy:   return 1
        case .normal: return 2
        case .hard:   return 3
        }
    }
    
    /// Mevcut saldıranlar
    private var activeAttackers: Set<Entity> = []
    
    /// Düşman saldırmak istiyor mu?
    func requestAttackPermission(for enemy: Entity) -> Bool {
        guard activeAttackers.count < maxSimultaneousAttackers else {
            return false  // "Bekle, sıran değil"
        }
        activeAttackers.insert(enemy)
        return true
    }
    
    /// Saldırı arasındaki minimum bekleme
    var attackCooldownBetweenEnemies: TimeInterval = 0.8  // 800ms
}
```

**Bu sayede:**
- 10 düşman varken bile 1-2 tanesi saldırır
- Diğerleri çember çizer, yaklaşır-uzaklaşır (tehdit oluşturur ama saldırmaz)
- Oyuncu hiçbir zaman "unfair" hissetmez
- Saldırı arası boşluk = combo fırsatı

### 7.4 Attack Telegraph Sistemi

Düşman saldırmadan önce oyuncuya görsel sinyal:

```
1. Exclamation mark (❗) — düşman kafasının üstünde, 0.5s önceden
2. Kırmızı flash — düşman sprite'ı kırmızı yanıp söner
3. Wind-up animasyon — kol/silah geriye çekilir
4. Attack line — saldırı yönünde kırmızı çizgi (opsiyonel, hard'da kapalı)
5. Audio cue — "swoosh" wind-up sesi

Zorluk bazlı telegraph:
  Easy:   Tüm 5 sinyal aktif, 0.8s önceden
  Normal: 1-3 aktif, 0.5s önceden
  Hard:   Sadece 2-3, 0.3s önceden
```

---

## 8. Silah Sistemi

### 8.1 Silah Protokolü

```swift
protocol WeaponProtocol {
    var name: String { get }
    var damage: CGFloat { get }
    var attackSpeed: TimeInterval { get }     // Toplam saldırı süresi
    var anticipationRatio: CGFloat { get }    // Wind-up oranı (0.0-1.0)
    var activeRatio: CGFloat { get }          // Active faz oranı
    var recoveryRatio: CGFloat { get }        // Recovery oranı
    var arcAngle: CGFloat { get }             // Saldırı açısı (derece)
    var arcRange: CGFloat { get }             // Saldırı menzili (piksel)
    var knockback: CGFloat { get }            // Geri tepme kuvveti
    var comboSequence: [AttackType] { get }   // Combo zinciri deseni
    var parryWindowBonus: CGFloat { get }     // Parry penceresi bonusu (±ms)
}
```

### 8.2 Silah Karşılaştırması

```
                  Sword         GreatSword      DualDaggers     Mace
                  (Kılıç)       (Büyük Kılıç)   (İkili Hançer)  (Topuz)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hasar             20            40              10 (×2)         25
Saldırı Hızı      0.55s         0.9s            0.35s           0.65s
Arc Açısı          90°          180°             45° (×2)       120°
Menzil            60px          80px             40px            55px
Knockback         Orta          Yüksek          Düşük           Çok Yüksek
Parry Bonus       +0ms          +30ms           -20ms           +15ms
Combo Zinciri     L-L-H         L-H             L-L-L-L-H      L-L-H

Karakter:
  Sword       → Dengeli, yeni başlayanlar için ideal
  GreatSword  → Risk/ödül: yavaş ama dev hasar + geniş alan
  DualDaggers → Combo makinesi: hızlı ama parry daha zor
  Mace        → Kontrol: düşmanları fırlatarak alan yönetimi

L = Light attack, H = Heavy attack (combo dizisi)
```

### 8.3 Silah Swing Arc Hesaplaması

```
Matematiksel model:

Saldırı arc'ı bir sektör (dilim) şeklinde:
  - Merkez: oyuncu pozisyonu
  - Yön: oyuncunun baktığı yön
  - Açı: weapon.arcAngle (±yarısı her yöne)
  - Yarıçap: weapon.arcRange

Hitbox check (her frame active fazda):
  for each enemy in nearbyEnemies:
      let toEnemy = enemy.position - player.position
      let distance = toEnemy.length()
      let angle = atan2(toEnemy.y, toEnemy.x)
      
      let facingAngle = player.facingDirection
      let angleDiff = angleDifference(angle, facingAngle)
      
      if distance <= weapon.arcRange && abs(angleDiff) <= weapon.arcAngle / 2:
          // HIT! Hasar uygula
          applyDamage(to: enemy)
```

---

## 9. Skill Tree / Yetenek Ağacı

### 9.1 Üç Ana Dal

```
                         ⚔️ COMBAT
                        (Saldırı Gücü)
                             │
                    ┌────────┼────────┐
                    │        │        │
                    ▼        ▼        ▼
              
         🛡️ PARRY          ⚔️ OFFENSE        ⚡ UTILITY
         (Savunma)          (Saldırı)          (Destek)
              │                  │                  │
         ┌────┴────┐       ┌────┴────┐       ┌────┴────┐
         │         │       │         │       │         │
    Iron Wall  Counter   Power     Combo   Swift    Vitality
    Master     Slash     Strike    Master  Feet     Surge
```

### 9.2 Yetenek Listesi

```
🛡️ PARRY DALI:
──────────────────────────────────────────────────────────────
Tier 1: Steady Guard
  └─ Parry penceresi +50ms genişler (300ms → 350ms)
  └─ Maliyet: 1 puan

Tier 2: Iron Wall  
  └─ Late parry hasar azaltması %50 → %75
  └─ Maliyet: 2 puan
  └─ Gereksinim: Steady Guard

Tier 2: Counter Slash
  └─ Başarılı parry sonrası counter attack hasar +50%
  └─ Maliyet: 2 puan
  └─ Gereksinim: Steady Guard

Tier 3: Perfect Reflex
  └─ Perfect parry penceresi +30ms (100ms → 130ms)
  └─ Maliyet: 3 puan
  └─ Gereksinim: Iron Wall VEYA Counter Slash

Tier 4: Parry Master
  └─ Perfect parry düşmanı %100 stagger süresi ekstra
  └─ Perfect parry sırasında yakın düşmanlara AoE shockwave
  └─ Maliyet: 4 puan
  └─ Gereksinim: Perfect Reflex

⚔️ OFFENSE DALI:
──────────────────────────────────────────────────────────────
Tier 1: Sharp Edge
  └─ Tüm silah hasarı +15%
  └─ Maliyet: 1 puan

Tier 2: Power Strike
  └─ Heavy attack hasarı +40%
  └─ Heavy attack AoE alanı +20%
  └─ Maliyet: 2 puan
  └─ Gereksinim: Sharp Edge

Tier 2: Combo Adept
  └─ Combo multiplier başlangıcı 1.0x → 1.2x
  └─ Combo timeout 2s → 2.5s
  └─ Maliyet: 2 puan
  └─ Gereksinim: Sharp Edge

Tier 3: Whirlwind
  └─ Heavy attack sırasında 360° dönüş saldırısı (yeni combo finisher)
  └─ Maliyet: 3 puan
  └─ Gereksinim: Power Strike

Tier 4: Combo Master
  └─ Max combo multiplier 2.5x → 3.5x
  └─ 10+ combo'da her vuruş küçük AoE shockwave
  └─ Maliyet: 4 puan
  └─ Gereksinim: Combo Adept

⚡ UTILITY DALI:
──────────────────────────────────────────────────────────────
Tier 1: Swift Feet
  └─ Hareket hızı +15%
  └─ Dodge mesafesi +20%
  └─ Maliyet: 1 puan

Tier 2: Vitality Surge
  └─ Max HP +25%
  └─ Maliyet: 2 puan
  └─ Gereksinim: Swift Feet

Tier 2: Adrenaline Rush
  └─ Perfect parry 5% HP geri kazandırır
  └─ Maliyet: 2 puan
  └─ Gereksinim: Swift Feet

Tier 3: Second Wind
  └─ Ölüm anında 1 kez %30 HP ile hayatta kal (level başına 1 kez)
  └─ Maliyet: 3 puan
  └─ Gereksinim: Vitality Surge

Tier 4: Time Bender
  └─ Perfect parry slow-motion süresi 0.5s → 1.0s
  └─ Slow-motion sırasında hareket hızı %100 (normal hızda)
  └─ Maliyet: 4 puan
  └─ Gereksinim: Adrenaline Rush

Yetenek puanı kazanma:
  - Level atlama: +1 puan
  - Boss öldürme: +2 puan
  - Mükemmel level tamamlama (hasar almadan): +1 bonus puan
```

---

## 10. Level Tasarımı

### 10.1 Level Yapısı

```
Oyun akışı:

  Level 1: Crypt (Mahzen) — Öğretici
  ├── Wave 1: 3× Grunt (parry öğret)
  ├── Wave 2: 5× Grunt (grup dövüşü)
  ├── Wave 3: 2× Grunt + 1× Shield (kalkan mekaniği)
  └── Mini-boss: Elite Grunt (güçlendirilmiş)
  
  Level 2: Courtyard (Avlu) — Hız tanıtımı
  ├── Wave 1: 4× Grunt + 1× Assassin (hızlı düşman öğret)
  ├── Wave 2: 2× Shield + 2× Assassin
  ├── Wave 3: 6× Grunt (combo fırsatı)
  └── Mini-boss: Twin Assassins
  
  Level 3: Armory (Silah Deposu) — Ağır düşman
  ├── Wave 1: 3× Grunt + 1× Brute (dodge öğret)
  ├── Wave 2: 2× Shield + 1× Brute + 2× Assassin
  ├── Wave 3: 1× Brute + 4× Grunt (kaos yönetimi)
  └── Mini-boss: Armored Brute
  
  Level 4: Throne Room (Taht Odası) — Final
  ├── Wave 1: 2× Elite + 2× Shield
  ├── Wave 2: 1× Brute + 2× Assassin + 3× Grunt
  ├── Wave 3: 2× Elite + 1× Brute + 2× Shield (tam kaos)
  └── BOSS: The Dark Knight
```

### 10.2 Level JSON Yapısı

```json
{
  "levelId": "level_1_crypt",
  "displayName": {
    "tr": "Karanlık Mahzen",
    "en": "The Dark Crypt"
  },
  "tileMap": "crypt_tilemap",
  "ambientTrack": "crypt_ambient",
  "combatTrack": "crypt_combat",
  "waves": [
    {
      "waveNumber": 1,
      "spawnDelay": 1.0,
      "enemies": [
        { "type": "grunt", "count": 3, "spawnPoints": ["north", "east", "south"] }
      ],
      "dialogueBefore": {
        "tr": "Dikkatli ol, karanlıktan geliyorlar...",
        "en": "Be careful, they come from the darkness..."
      }
    }
  ],
  "completionRewards": {
    "xp": 200,
    "skillPoints": 1,
    "weaponUnlock": null
  },
  "parEstimate": {
    "time": 180,
    "maxDamageTaken": 50,
    "minCombo": 5
  }
}
```

### 10.3 Arena Tasarım Prensipleri

```
Her arena:
  - Minimum 400×400 piksel (karakter 32×32 baz alınırsa ~12×12 karakter)
  - Engeller (sütunlar, duvarlar) → düşmanlardan kaçmak için
  - Açık alan → combo zinciri kurmak için
  - Spawn noktaları → 4 yönden (N, S, E, W) + opsiyonel köşeler

Arena layout mantığı:
  ┌──────────────────────────┐
  │  S          S            │  S = Spawn noktası
  │     ▓▓                   │  ▓ = Engel (sütun/kaya)
  │     ▓▓        ▓▓         │  ★ = Oyuncu başlangıç
  │                ▓▓        │
  │ S       ★           S    │
  │                          │
  │     ▓▓        ▓▓         │
  │     ▓▓        ▓▓         │
  │                          │
  │  S              S        │
  └──────────────────────────┘
```

---

## 11. Boss Fight Tasarımı

### 11.1 The Dark Knight (Final Boss)

```
═══════════════════════════════════════════════════════
                    THE DARK KNIGHT
                    HP: 1000 | 3 Faz
═══════════════════════════════════════════════════════

FAZ 1 (HP %100-60): "The Duel"
─────────────────────────────────
Saldırılar:
  1. Sword Combo (3 hit): L-L-H pattern
     → Her saldırı parry edilebilir
     → Anticipation: 0.4s, 0.3s, 0.6s
  
  2. Shield Bash: Hızlı itme saldırısı
     → Parry edilebilir ama pencere dar (200ms)
     → Başarılı parry: kalkanı düşürür (5s)
  
  3. Charge: Koşarak saldırı
     → UNBLOCKABLE — dodge gerekir
     → Kaçırırsa duvara çarpar → 2s stagger

Strateji: Sword combo'yu parry et, counter attack yap

FAZ 2 (HP %60-25): "Unleashed"
─────────────────────────────────
Yeni saldırılar:
  4. Feint Attack: Sahte wind-up → gerçek saldırı
     → İlk saldırıyı parry edersin → O sahte
     → Gerçek saldırı 0.3s sonra gelir
     → Oyuncu adaptasyon gerektirir
  
  5. Ground Slam (AoE): Yere vurma, shockwave
     → UNBLOCKABLE
     → Zıplama animasyonu var → dodge zamanı
     → Shockwave yarıçapı: 120px

Mevcut saldırılar hızlanır (%20 daha kısa anticipation)
2 Grunt spawn olur (dikkat dağıtma)

Strateji: Feint'i tanımayı öğren, Grunt'ları önce temizle

FAZ 3 (HP %25-0): "Desperate"
─────────────────────────────────
Yeni saldırılar:
  6. Blade Storm (8-hit combo): Çılgın saldırı dizisi
     → Her biri parry edilebilir
     → Hepsini parry edersen: "LEGENDARY PARRY" → 3s stagger
     → Her parry miss: büyük hasar
  
  7. Dark Wave: Ekranın yarısını kaplayan dalga
     → Arena'nın bir tarafı güvensiz → doğru yöne dodge

Mevcut saldırılar daha da hızlı (%40)
Daha az telegraph (sadece animasyon, exclamation mark yok)

Boss ölüm anı:
  - Son vuruşta ekstra uzun slow-motion (0.2x, 2 saniye)
  - Kamera zoom-in
  - Özel ölüm animasyonu
  - "VICTORY" splash screen

═══════════════════════════════════════════════════════
```

### 11.2 Boss Sağlık Barı

```
Ekranın üstünde, tam genişlikte:

┌─────────────────────────────────────────┐
│ ⚔️ THE DARK KNIGHT                      │
│ [████████████████████░░░░░░░░░░░░░░░░░] │
│  FAZ 1                  FAZ 2    FAZ 3  │
│  ████████████████████   ░░░░░    ░░░░░  │
│                     ^faz geçiş noktaları │
└─────────────────────────────────────────┘

Faz geçişi:
  - HP faz eşiğine düşünce: 1s invulnerability
  - Boss özel geçiş animasyonu oynar
  - Ekran shake + flash
  - Müzik intensity artar
```

---

## 12. HUD & UI Tasarımı

### 12.1 In-Game HUD Layout

```
┌─────────────────────────────────────────────────────────┐
│                  [Boss HP Bar - sadece boss fight]       │
│                                                         │
│  ┌─────────┐                           ┌───────────┐   │
│  │ COMBO   │                           │  SCORE    │   │
│  │  12x    │                           │  48,200   │   │
│  │ ████    │                           │           │   │
│  └─────────┘                           └───────────┘   │
│                                                         │
│                                                         │
│                    [OYUN ALANI]                          │
│                                                         │
│                                                         │
│                                                         │
│                                                         │
│  ┌──────────────┐                                       │
│  │ HP ██████░░░ │                                       │
│  │ 75/100       │                                       │
│  └──────────────┘                                       │
│                                                         │
│  ┌─────────┐              ┌─────┐ ┌─────┐ ┌─────┐     │
│  │         │              │  🗡️  │ │ 🛡️  │ │  💨  │     │
│  │JOYSTICK │              │ ATK  │ │PARRY│ │DODGE│     │
│  │         │              │     │ │     │ │     │     │
│  └─────────┘              └─────┘ └─────┘ └─────┘     │
│                                                         │
│  [WAVE 2/3]                      [PAUSE ⏸️]             │
└─────────────────────────────────────────────────────────┘

Not: Butonlar sağ alt köşede, başparmak erişim bölgesinde
Joystick sol alt köşede
HP sol üst/alt (platforma göre)
```

### 12.2 Parry Feedback UI

```
Başarılı parry anında (ekranın ortasında, kısa süre):

Normal Parry:     "PARRY!" (beyaz, 0.3s fade)
Perfect Parry:    "PERFECT!" (altın, 0.5s fade, büyük font, glow efekti)
Late Parry:       "BLOCK" (gri, 0.2s fade)
Miss:             (gösterme, sadece hasar efekti)

Combo milestone'ları:
  5x:  "NICE!"
  10x: "AMAZING!"
  15x: "UNSTOPPABLE!"
```

---

## 13. Kontrol Sistemi

### 13.1 Touch Kontrolleri (iPhone)

```swift
class InputManager {
    // Sol taraf: Sanal joystick
    // Sağ taraf: Aksiyon butonları
    
    struct InputState {
        var moveDirection: CGVector = .zero    // -1...1 normalize
        var attackPressed: Bool = false
        var parryPressed: Bool = false
        var dodgePressed: Bool = false
        var parryPressTimestamp: TimeInterval = 0  // Hassas timing için
    }
    
    // Touch bölgeleri
    let joystickRegion: CGRect  // Ekranın sol %40'ı
    let buttonRegion: CGRect    // Ekranın sağ %40'ı
}
```

### 13.2 Joystick Implementasyonu

```
Joystick parametreleri:
  - Base yarıçap: 60pt (görsel daire)
  - Thumb yarıçap: 25pt (hareket eden iç daire)
  - Dead zone: 15% (çok küçük hareketleri yok say)
  - Max range: 50pt (base'den maksimum uzaklık)
  
  Hareket hesaplama:
    rawInput = touchPosition - joystickCenter
    distance = clamp(rawInput.length(), 0, maxRange)
    
    // Dead zone uygula
    if distance < maxRange * deadZone:
        moveDirection = .zero
    else:
        // 0...1 arası normalize (dead zone sonrası)
        magnitude = (distance - deadZone * maxRange) / (maxRange * (1 - deadZone))
        moveDirection = rawInput.normalized() * magnitude
    
    // Karakter hızına çevir
    velocity = moveDirection * character.maxSpeed
```

### 13.3 macOS Kontrolleri

```
Klavye + Mouse VEYA Gamepad:

Klavye:
  WASD / Arrow Keys → Hareket
  Mouse Click (Sol) → Saldırı (mouse yönüne)
  Mouse Click (Sağ) → Parry
  Space             → Dodge
  ESC               → Pause
  
Gamepad (GCController):
  Left Stick   → Hareket
  Right Stick  → Bakış yönü
  R1/RB        → Saldırı
  L1/LB        → Parry
  A/Cross      → Dodge
  Start        → Pause
```

### 13.4 Input Buffer Sistemi

```
Oyuncu bir animasyon sırasında (örn: recovery) buton basarsa,
input kaybetmemek için buffer'la:

Buffer süresi: 150ms (9 frame)

Örnek senaryo:
  Frame 1-10:  Saldırı recovery animasyonu (input kabul etmez)
  Frame 8:     Oyuncu parry basar → buffer'a ekle
  Frame 11:    Recovery biter → buffer'dan parry oku → hemen parry başlat

Bu olmadan oyuncu "buton bastım ama çalışmadı" hisseder.
Input buffer oyun hissini DRAMATIK olarak iyileştirir.
```

---

## 14. Kamera Sistemi

### 14.1 Kamera Takip

```swift
class CameraManager {
    let camera = SKCameraNode()
    
    // Takip parametreleri
    var followSpeed: CGFloat = 5.0        // Lerp hızı
    var lookAheadDistance: CGFloat = 40.0  // Hareket yönünde ileri bakma
    var deadZone: CGFloat = 20.0          // Bu alan içinde kamera hareket etmez
    
    func update(_ dt: TimeInterval) {
        guard let target = followTarget else { return }
        
        // Hedef pozisyon = oyuncu + hareket yönünde look-ahead
        let lookAhead = target.moveDirection * lookAheadDistance
        let targetPos = target.position + lookAhead
        
        // Dead zone check
        let diff = targetPos - camera.position
        if diff.length() < deadZone { return }
        
        // Smooth follow (lerp)
        camera.position = lerp(camera.position, targetPos, followSpeed * dt)
    }
}
```

### 14.2 Kamera Efektleri

```
Screen Shake:
  - Intensity: 2-15px (vuruş gücüne göre)
  - Duration: 0.1-0.3s
  - Decay: Exponential (hızla azalır)
  - Direction: Vuruş yönüne paralel (yönlü shake)
  
  Implementasyon:
    offset.x = sin(time * frequency) * intensity * decay
    offset.y = cos(time * frequency * 1.1) * intensity * decay  // Biraz farklı frekans
    decay = pow(0.9, elapsedFrames)  // Her frame %10 azalma

Zoom:
  - Perfect parry: 1.0 → 1.1 (0.2s ease-in-out, sonra 0.3s geri)
  - Boss faz geçişi: 1.0 → 0.8 (zoom out, arena'yı göster)
  - Ölüm anı: 1.0 → 1.3 (zoom in, karakter odak)
```

---

## 15. Fizik & Çarpışma Sistemi

### 15.1 Çarpışma Kategorileri

```swift
struct PhysicsCategory {
    static let none:        UInt32 = 0
    static let player:      UInt32 = 0b0001      // 1
    static let enemy:       UInt32 = 0b0010      // 2
    static let playerAttack: UInt32 = 0b0100     // 4
    static let enemyAttack: UInt32 = 0b1000      // 8
    static let wall:        UInt32 = 0b10000     // 16
    static let obstacle:    UInt32 = 0b100000    // 32
}

// Çarpışma matrisi:
// Player     vs Wall, Obstacle, EnemyAttack
// Enemy      vs Wall, Obstacle, PlayerAttack, Enemy (birbirini iter)
// PlayerAtk  vs Enemy
// EnemyAtk   vs Player
```

### 15.2 Hitbox / Hurtbox Sistemi

```
Her entity'de iki ayrı çarpışma alanı:

HURTBOX (hasar alınabilir alan) — daima aktif
  - Karakter gövdesini temsil eder
  - Dikdörtgen veya daire
  - Karakter boyutuyla aynı
  
HITBOX (hasar veren alan) — sadece saldırı sırasında aktif
  - Silahın/yumruğun ulaştığı alan
  - Arc (fan) şeklinde
  - Sadece attack'ın active fazında var
  - Bir saldırıda aynı hedefE bir kez hasar verir (set ile takip)

Neden ikisini ayırıyoruz?
  → Bir düşman saldırırken kendi hitbox'ı aktif
  → Ama aynı anda oyuncunun saldırısına karşı hurtbox'ı açık
  → İki taraf da aynı anda birbirine hasar verebilir
```

### 15.3 Knockback Fiziği

```
Knockback uygulanması:

1. Vuruş anında:
   direction = normalize(target.position - attacker.position)
   knockbackVelocity = direction * weapon.knockback * comboKnockbackMultiplier

2. Her frame:
   // Knockback velocity zamanla azalır (friction)
   knockbackVelocity *= 0.85  // Frame başına %15 azalma
   
   // Çok küçükse sıfırla
   if knockbackVelocity.length() < 1.0:
       knockbackVelocity = .zero
   
   // Pozisyona ekle
   position += knockbackVelocity * deltaTime

3. Duvar çarpışması:
   // Knockback sırasında duvara çarparsa
   → Ekstra 0.2s stagger
   → "Wall splat" efekti + ses
   → Bonus hasar (%10)
```

---

## 16. Efekt & Juice Sistemi

### 16.1 "Juice" Nedir?

Oyun hissini (game feel) oluşturan küçük detaylar. Juice olmadan saldırılar "karton" gibi hisseder.

### 16.2 Vuruş Efektleri Katmanları

```
Bir saldırı vuruşu anında (tüm bunlar <16ms içinde olur):

Zamanlama (frame bazlı, 60fps):
  Frame 0 (vuruş anı):
    ├── Hit flash shader aktif (sprite beyaza döner)
    ├── Kıvılcım parçacık emit (vuruş noktasında)
    ├── Screen shake başlat (intensity: hasar/10, süre: 0.1s)
    ├── Hitstop başlat (3-6 frame)
    ├── Knockback velocity ata
    ├── SFX çal (hit_impact_01)
    ├── Haptic feedback (UIImpactFeedbackGenerator.medium)
    └── Combo sayacı güncelle (+1)
    
  Frame 1-3 (hitstop sırasında):
    ├── Her şey donuk (timeScale = 0)
    ├── Hit flash devam
    └── Kıvılcımlar havada asılı

  Frame 4 (hitstop biter):
    ├── Hit flash söner
    ├── Knockback başlar
    ├── Hasar sayısı popup (head üstünde)
    └── HP bar animasyonu (smooth azalma)
    
  Frame 4-15 (knockback):
    ├── Düşman geriye kayar
    ├── Toz bulutu parçacık (ayak altında)
    └── Speed lines (knockback yönünde)
```

### 16.3 SKShader Örnekleri

```glsl
// hit_flash.fsh — Sprite'ı beyaza çevirir
void main() {
    vec4 color = texture2D(u_texture, v_tex_coord);
    float flash = u_flash_amount; // 0.0 - 1.0, Swift'ten kontrol
    color.rgb = mix(color.rgb, vec3(1.0), flash);
    gl_FragColor = color;
}

// perfect_parry_glow.fsh — Altın shockwave
void main() {
    vec4 color = texture2D(u_texture, v_tex_coord);
    float dist = distance(v_tex_coord, vec2(0.5));
    float wave = smoothstep(u_radius - 0.05, u_radius, dist) 
               - smoothstep(u_radius, u_radius + 0.05, dist);
    vec3 gold = vec3(1.0, 0.84, 0.0);
    color.rgb += gold * wave * u_intensity;
    gl_FragColor = color;
}
```

---

## 17. Ses Tasarımı

### 17.1 Dinamik Müzik Sistemi

```
Her level 2 müzik katmanına sahip:
  1. Ambient layer (her zaman çalar, düşük volume)
  2. Combat layer (düşmanla savaş sırasında crossfade ile girer)

Combat intensity seviyeleri:
  Intensity 0: Ambient only (düşman yok)
  Intensity 1: Light combat (1-3 düşman) → hafif percussion
  Intensity 2: Heavy combat (4+ düşman veya boss) → full combat track
  Intensity 3: Boss faz 3 / düşük HP → intense, hızlı tempo

Crossfade süresi: 1.5 saniye (smooth geçiş)
```

### 17.2 SFX Listesi

```
Saldırı:
  sword_swing_light_01-03     (3 varyasyon)
  sword_swing_heavy_01-02
  sword_hit_flesh_01-04       (4 varyasyon, random seçim)
  sword_hit_armor_01-03

Parry:
  parry_normal_01-02          (metalik çarpışma)
  parry_perfect_01            (özel, güçlü, reverb'li)
  parry_late_01               (tok, kısa)
  parry_miss_01               (woosh, boşa sallanma)

Düşman:
  enemy_grunt_attack_01-02    (nefes/bağırma)
  enemy_hurt_01-03
  enemy_death_01-02
  enemy_alert_01              (oyuncuyu fark etme)

UI:
  combo_milestone_5           (ding)
  combo_milestone_10          (büyük ding)
  combo_milestone_15          (fanfare)
  level_complete              (zafer müziği)
  wave_start                  (davul)

Ortam:
  footstep_stone_01-04        (random, hareketle senkron)
  dodge_whoosh_01-02
```

---

## 18. Lokalizasyon (TR/EN)

### 18.1 String Catalog Yapısı

Xcode 15+'ın `Localizable.xcstrings` formatı (String Catalog):

```
Lokalize edilecek alanlar:
  - Menü metinleri (başlat, ayarlar, devam et)
  - HUD metinleri (combo isimleri, PARRY!, PERFECT!)
  - Düşman isimleri
  - Level isimleri ve açıklamaları
  - Skill tree isimleri ve açıklamaları
  - Diyaloglar
  - Tutorial metinleri
  - Ayarlar menüsü

Lokalize EDİLMEYECEK:
  - Sayılar (hasar, HP)
  - İkonlar
  - Ses efektleri
```

### 18.2 Dil Değiştirme

```swift
class LocalizationManager {
    static let shared = LocalizationManager()
    
    enum Language: String {
        case turkish = "tr"
        case english = "en"
    }
    
    var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    // Kullanım: LocalizationManager.shared.localized("parry_perfect")
}
```

---

## 19. Performans & Optimizasyon

### 19.1 Hedef Performans Metrikleri

```
┌────────────────────┬──────────────────┬─────────────────────┐
│ Metrik             │ Hedef            │ Minimum Kabul        │
├────────────────────┼──────────────────┼─────────────────────┤
│ FPS                │ 60 sabit         │ 55 (nadiren düşme)  │
│ Frame time         │ <16.67ms         │ <18ms               │
│ Bellek (iPhone)    │ <200MB           │ <300MB              │
│ Bellek (macOS)     │ <400MB           │ <500MB              │
│ Başlangıç süresi   │ <2s              │ <3s                 │
│ Level yükleme      │ <0.5s            │ <1s                 │
│ Eşzamanlı entity  │ 30+              │ 20 minimum          │
│ Particle emitters  │ 15 aynı anda     │ 10 minimum          │
│ Draw calls         │ <50 per frame    │ <80                 │
│ Battery drain      │ <15%/saat        │ <25%/saat           │
└────────────────────┴──────────────────┴─────────────────────┘
```

### 19.2 Optimizasyon Teknikleri

```
1. TEXTURE ATLAS
   - Tüm sprite'lar atlas'ta (.spriteatlas)
   - Max atlas boyutu: 2048×2048 (iPhone uyumluluğu)
   - Ayrı atlas grupları: characters, enemies, effects, UI
   - 1 atlas = 1 draw call (büyük kazanç)

2. OBJECT POOLING
   - Mermi, parçacık, hasar popup → havuzdan al, geri koy
   - Enemy death → pool'a geri dön, yeni wave'de tekrar kullan
   - Pool boyutu: her tip için 20 adet pre-allocate
   
   class ObjectPool<T: SKNode> {
       private var available: [T] = []
       private let factory: () -> T
       
       func acquire() -> T {
           if let obj = available.popLast() {
               obj.isHidden = false
               return obj
           }
           return factory()
       }
       
       func release(_ obj: T) {
           obj.isHidden = true
           obj.removeAllActions()
           available.append(obj)
       }
   }

3. AI THROTTLING
   - AI kararları her frame DEĞİL, her 3 frame'de (20Hz)
   - Ekran dışı düşmanlar: her 10 frame'de (6Hz)
   - Çok uzak düşmanlar: AI durdur, sadece pozisyon güncelle

4. COLLISION OPTIMIZATION
   - Spatial hashing (grid-based) broad phase
   - Grid hücre boyutu: 64×64px
   - Sadece aynı/komşu hücrelerdeki entity'leri kontrol et
   - Ortalama çarpışma kontrolü: O(n) → O(1) per entity

5. SHADER PERFORMANCE
   - Shader uniform'ları her frame güncelle (texture swap yerine)
   - Hit flash: shader uniform ile, texture kopyası YAPMA
   - Karmaşık shaderları sadece etkilenen sprite'a ata

6. PARTICLE BUDGETING
   - Max aktif emitter: 15
   - Particle sayısı limit: 200 toplam
   - Auto-cleanup: 3 saniyeden eski emitter'ları kaldır
   - LOD: düşük performansta particle sayısını %50 azalt

7. MEMORY MANAGEMENT
   - Level geçişinde tam cleanup
   - Texture atlas lazy loading (ihtiyaç anında)
   - Kullanılmayan texture'ları cache'ten at
   - Weak reference: delegate ve callback'lerde
```

### 19.3 Profiling Checklist

```
Her milestone'da kontrol et:

□ Instruments → Time Profiler: update() <16ms mi?
□ Instruments → Allocations: Memory leak var mı?
□ Instruments → Metal System Trace: GPU bottleneck var mı?
□ SpriteKit debug: nodeCount, drawCount, fps
□ Debug overlay: entity sayısı, active hitbox sayısı
□ iPhone SE (en düşük hedef) üzerinde test
□ 20 düşman aynı anda → FPS düşüyor mu?
□ 10 particle emitter aynı anda → FPS düşüyor mu?
□ 30 dakika oyun → memory yükseliyor mu? (leak testi)
```

---

## 20. Art Pipeline & Asset Yönetimi

### 20.1 Geliştirme Aşamaları

```
Aşama 1 — PLACEHOLDER (mekanik geliştirme):
  - Renkli dikdörtgenler/daireler
  - Oyuncu: mavi kare (32×32)
  - Düşman: kırmızı kare (32×32)
  - Saldırı arc: yarı saydam beyaz fan
  - Engel: gri dikdörtgen
  ➜ Öncelik: gameplay feel doğru mu?

Aşama 2 — PROTOTYPE ART (polish):
  - itch.io free sprite pack'ler
  - Önerilen paketler:
    → "Tiny Dungeon" (kenney.nl) — ücretsiz, top-down
    → "Dungeon Tileset II" (0x72) — itch.io, ücretsiz
  - 4-yönlü yürüme animasyonu (N, S, E, W)
  - 4-yönlü saldırı animasyonu
  - Idle, hurt, death animasyonları
  ➜ Öncelik: oyun "gerçek" hissetmeye başlasın

Aşama 3 — FINAL ART (yayın):
  - Özel çizim veya premium asset pack
  - 8-yönlü animasyon (daha akıcı rotasyon)
  - Silaha özel saldırı animasyonları
  - Ortam detayları (duvar dekorasyonu, zemin çeşitliliği)
```

### 20.2 Sprite Boyutları

```
Karakter sprite:  32×32 veya 48×48 piksel (base)
  → @2x: 64×64 veya 96×96 (Retina)
  → @3x: 96×96 veya 144×144 (iPhone Plus/Pro)

Tile boyutu: 16×16 veya 32×32 piksel
  → Tilemap grid: level boyutuna göre

Animasyon frame sayıları:
  Idle:   4 frame, 0.15s/frame = 0.6s döngü
  Walk:   6 frame, 0.1s/frame = 0.6s döngü
  Attack: 5 frame, weapon.attackSpeed / 5 = frame başına süre
  Hurt:   3 frame, 0.1s/frame
  Death:  6 frame, 0.12s/frame (loop etmez)
  Parry:  3 frame, 0.05s/frame (hızlı)
```

---

## 21. Geliştirme Aşamaları (Roadmap)

```
════════════════════════════════════════════════════════════════
   MILESTONE 1: "İlk Hareket" (Hafta 1-2)
════════════════════════════════════════════════════════════════
□ Xcode projesi oluştur (SwiftUI + SpriteKit)
□ GameScene boş sahne (gri zemin)
□ Placeholder oyuncu (mavi kare) sahneye ekle
□ Sanal joystick → oyuncu hareketi (4 yönlü)
□ Kamera takip sistemi (smooth follow)
□ FPS debug overlay
□ macOS: WASD hareket desteği

Başarı kriteri: Mavi kare joystick ile düzgün hareket ediyor,
kamera takip ediyor, 60 FPS.

════════════════════════════════════════════════════════════════
   MILESTONE 2: "İlk Yumruk" (Hafta 3-4)
════════════════════════════════════════════════════════════════
□ Saldırı butonu + state machine (Idle → Attack → Recovery → Idle)
□ Saldırı animasyonu (arc görseli, placeholder)
□ Hitbox sistemi (saldırı sırasında aktif)
□ Basit düşman (kırmızı kare, hareketsiz)
□ Hasar sistemi (hitbox ↔ hurtbox)
□ Hit flash shader
□ Hitstop (2 frame)
□ Düşman HP bar
□ Düşman ölüm (fade out + parçacık)

Başarı kriteri: Oyuncu saldırabilir, düşmana hasar verir,
vuruş "ağır" hisseder (hitstop + flash).

════════════════════════════════════════════════════════════════
   MILESTONE 3: "Parry!" (Hafta 5-6)
════════════════════════════════════════════════════════════════
□ Düşman saldırı AI (basit: yaklaş → saldır → bekle)
□ Düşman attack telegraph (exclamation mark + red flash)
□ Parry butonu + parry state
□ Parry window sistemi (300ms pencere)
□ Normal parry: hasar engelle + düşman stagger
□ Perfect parry: altın efekt + uzun stagger + counter fırsat
□ Late parry: %50 hasar azaltma
□ Parry feedback: kıvılcım, ses, ekran shake, haptic
□ Parry cooldown + whiff penalty (spam önleme)
□ Counter attack (parry sonrası güçlü vuruş)

Başarı kriteri: Parry sistemi "tatmin edici" hissediyor.
Perfect parry oyuncuyu ödüllendirilmiş hissettiriyor.

════════════════════════════════════════════════════════════════
   MILESTONE 4: "Combo Master" (Hafta 7-8)
════════════════════════════════════════════════════════════════
□ Combo sayacı (ardışık hit → multiplier)
□ Combo UI (sayaç + multiplier göstergesi)
□ Combo milestone'ları ("NICE!", "AMAZING!" vb.)
□ Combo timeout (2s)
□ Combo kırılma (hasar alınca)
□ Birden fazla düşman (3-5 aynı anda)
□ Düşman koordinasyon sistemi (sırayla saldırı)
□ Knockback fiziği
□ Object pooling (düşmanlar için)

Başarı kriteri: 5+ düşmana karşı savaş akıcı, combo zinciri
kurmak eğlenceli, düşmanlar "adil" saldırıyor.

════════════════════════════════════════════════════════════════
   MILESTONE 5: "Slow-Mo" (Hafta 9-10)
════════════════════════════════════════════════════════════════
□ TimeManager (scaled deltaTime)
□ Perfect parry slow-motion (0.3x, 0.5s)
□ Son düşman öldürme slow-motion
□ Kamera zoom efekti
□ Chromatic aberration shader (güçlü vuruşlarda)
□ Vignette shader (düşük HP)
□ Dodge mekaniği (kısa i-frame + hareket)
□ Input buffer sistemi (150ms)

Başarı kriteri: Oyun "sinematik" hissediyor.
Perfect parry anları epik.

════════════════════════════════════════════════════════════════
   MILESTONE 6: "Düşman Çeşitliliği" (Hafta 11-13)
════════════════════════════════════════════════════════════════
□ Shield Bearer düşmanı (kalkan mekaniği)
□ Assassin düşmanı (hızlı, çoklu saldırı)
□ Brute düşmanı (unblockable, AoE)
□ Elite Knight düşmanı (feint yapan)
□ Her düşman tipi için özel telegraph
□ Behaviour tree iyileştirme (retreat, flank)
□ Düşman spawn sistemi (wave-based)
□ Difficulty scaling (düşman hızı/hasarı)

Başarı kriteri: Her düşman tipi farklı strateji gerektiriyor.
Karışık düşman grupları zorlayıcı ama adil.

════════════════════════════════════════════════════════════════
   MILESTONE 7: "Silahlar & Yetenekler" (Hafta 14-16)
════════════════════════════════════════════════════════════════
□ Silah sistemi (protocol + 4 silah implementasyonu)
□ Silahlar arası geçiş (menüden)
□ Her silahın kendine özgü saldırı pattern'ı
□ Skill tree UI (SwiftUI ekranı)
□ Skill tree veri yapısı + kaydetme
□ 15 yetenek implementasyonu (3 dal × 5 tier)
□ XP sistemi + level atlama
□ Oyuncu ilerleme kaydetme (UserDefaults + Codable)

Başarı kriteri: Farklı silahlar farklı hissediyor.
Skill tree anlamlı seçimler sunuyor.

════════════════════════════════════════════════════════════════
   MILESTONE 8: "Dünya İnşası" (Hafta 17-19)
════════════════════════════════════════════════════════════════
□ TileMap sistemi (SKTileMapNode)
□ Level 1: Crypt (tilemap + wave'ler)
□ Level 2: Courtyard
□ Level 3: Armory
□ Level arası geçiş (fade + yükleme)
□ Level seçim ekranı (SwiftUI)
□ Wave başlangıç/bitiş UI
□ Level tamamlama ekranı (skor, yıldız)
□ Ortam parçacıkları (toz, yaprak vb.)

Başarı kriteri: 3 farklı level oynanabilir,
her biri görsel olarak farklı.

════════════════════════════════════════════════════════════════
   MILESTONE 9: "The Dark Knight" (Hafta 20-22)
════════════════════════════════════════════════════════════════
□ Boss arena tasarımı
□ Boss AI: Faz 1 (sword combo, shield bash, charge)
□ Boss AI: Faz 2 (feint, ground slam, minion spawn)
□ Boss AI: Faz 3 (blade storm, dark wave, hızlanma)
□ Boss HP bar (ekran üstü, faz göstergeli)
□ Faz geçiş animasyonları
□ Boss ölüm cinematik (slow-mo + zoom)
□ Boss intro sahne (kamera pan + isim kartı)
□ Zafer ekranı

Başarı kriteri: Boss fight zorlayıcı, adil ve epik.
Her faz yeni bir strateji gerektiriyor.

════════════════════════════════════════════════════════════════
   MILESTONE 10: "Polish & Ship" (Hafta 23-26)
════════════════════════════════════════════════════════════════
□ Ana menü (SwiftUI, animasyonlu)
□ Ayarlar ekranı (ses, dil, kontrol hassasiyeti)
□ Tutorial sistemi (Level 1'e entegre ipuçları)
□ Lokalizasyon (TR/EN tüm metinler)
□ Ses sistemi: SFX + dinamik müzik
□ Final art entegrasyonu (sprite pack veya özel)
□ Performans profiling + optimizasyon
□ iPhone SE → iPhone 15 Pro test
□ macOS test (klavye+mouse + gamepad)
□ Bug fixing sprint
□ App Store hazırlık (icon, screenshots, açıklama)
□ TestFlight beta
□ RELEASE 🚀
```

---

## 22. Dosya Yapısı

Bkz. Bölüm 2.1 — tüm dosya yapısı orada detaylı.

---

## 23. Matematik & Fizik Referansı

### 23.1 Vektör Matematiği (Her Yerde Kullanılır)

```swift
extension CGPoint {
    /// İki nokta arası mesafe
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)  // √(Δx² + Δy²)
    }
    
    /// Vektör uzunluğu
    var length: CGFloat {
        sqrt(x * x + y * y)
    }
    
    /// Birim vektör (yön, uzunluk 1)
    var normalized: CGPoint {
        let len = length
        guard len > 0 else { return .zero }
        return CGPoint(x: x / len, y: y / len)
    }
    
    /// Dot product — iki vektör ne kadar aynı yöne bakıyor
    func dot(_ other: CGPoint) -> CGFloat {
        x * other.x + y * other.y
    }
    
    /// İki açı arasındaki fark (-π...π)
    static func angleDifference(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        var diff = a - b
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
}
```

### 23.2 Lerp (Linear Interpolation)

```
Her yerde kullanılır: kamera, HP bar, slow-mo geçişi

lerp(a, b, t) = a + (b - a) × t

t = 0.0 → sonuç = a (başlangıç)
t = 1.0 → sonuç = b (hedef)
t = 0.5 → sonuç = tam orta

Smooth follow örneği:
  camera.x = lerp(camera.x, player.x, 5.0 * deltaTime)
  // deltaTime küçükse (60fps) → yavaş hareket
  // deltaTime büyükse (lag) → hızlı yakalama
  // = her zaman düzgün görünür
```

### 23.3 Easing Functions

```
Animasyonlarda doğal hareket için:

// Yavaş başla, hızlı bitir (vuruş hissi)
easeIn(t) = t²

// Hızlı başla, yavaş bitir (inişe geçiş)
easeOut(t) = 1 - (1-t)²

// Yavaş başla, yavaş bitir (kamera geçişi)
easeInOut(t) = t < 0.5 ? 2t² : 1 - (-2t + 2)² / 2

// Spring (zıplama hissi, combo counter popup)
spring(t, damping) = 1 - e^(-damping×t) × cos(frequency×t)
```

### 23.4 Çarpışma Algılama Formülleri

```
Daire-Daire çarpışması (en hızlı):
  overlap = (r1 + r2) - distance(c1, c2)
  çarpışıyor = overlap > 0

Nokta-Sektör çarpışması (saldırı arc'ı):
  1. Mesafe kontrolü: distance(player, enemy) ≤ arcRange?
  2. Açı kontrolü: |angleDiff(playerFacing, angleToEnemy)| ≤ arcAngle/2?
  3. İkisi de true → HIT

AABB (dikdörtgen) çarpışması:
  overlap = !(a.maxX < b.minX || a.minX > b.maxX || 
              a.maxY < b.minY || a.minY > b.maxY)
```

### 23.5 Spatial Hashing (Performans)

```
Ekranı grid'e böl. Her entity hangi hücrede → sadece komşu hücreleri kontrol et.

Grid hücre boyutu: en büyük entity'nin 2 katı (genelde 64×64px)

hash(x, y) = (floor(x/cellSize), floor(y/cellSize))

Çarpışma kontrolü:
  - Entity'nin hücresini bul
  - 9 komşu hücreyi kontrol et (3×3 grid)
  - Sadece o hücrelerdeki entity'lerle çarpışma testi yap

30 entity ile:
  Brute force: 30 × 30 = 900 kontrol/frame
  Spatial hash: ortalama ~30 × 4 = 120 kontrol/frame (7.5× daha hızlı)
```

---

## 📌 Hızlı Referans Tablosu

```
┌──────────────────────┬─────────────────────────────────┐
│ Parry penceresi      │ 300ms (18 frame)                │
│ Perfect parry        │ ±50ms (6 frame)                 │
│ Hitstop              │ 3-6 frame (50-100ms)            │
│ Slow-motion (parry)  │ 0.3x hız, 0.5s                 │
│ Combo timeout        │ 2 saniye                        │
│ Max combo            │ 15x (2.5x multiplier)           │
│ Input buffer         │ 150ms (9 frame)                 │
│ Parry cooldown       │ 200ms (12 frame)                │
│ Dodge i-frame        │ 150ms (9 frame)                 │
│ AI update rate       │ 20Hz (her 3 frame)              │
│ Max simultaneous atk │ 1-3 (zorluğa göre)              │
│ Object pool size     │ 20 per type                     │
│ Texture atlas max    │ 2048×2048                       │
│ Target FPS           │ 60 (120 ProMotion)              │
│ Frame bütçesi        │ 16.67ms                         │
└──────────────────────┴─────────────────────────────────┘
```

---

## ⚙️ Claude'a Not — Bu Projeyi Geliştirirken

Bu doküman Claude ile birlikte, aşama aşama geliştirilecek bir SpriteKit oyun projesi için referans niteliğindedir.

**Claude'un rolleri:**
- 🎮 **Senior iOS Game Developer** — SpriteKit, Swift, Metal bilgisi
- 🎯 **Game Designer** — Mekanik balans, oyuncu deneyimi
- 📐 **Fizik/Matematik Danışmanı** — Vektör math, çarpışma algılama, easing
- 🏗️ **Mimar** — ECS tasarımı, performans optimizasyon

**Öğretim yaklaşımı:**
- Socratic method: Cevabı vermeden önce "neden" sor
- Her konsepti gerçek hayat analojisiyle açıkla
- Kod vermeden önce konsepti anlat
- Her milestone sonunda "ne öğrendik" özeti

**Geliştirme kuralları:**
- Her milestone tek başına çalışır (incremental)
- Placeholder art ile başla, mekanik öncelikli
- Her yeni sistem için birim test yaz
- Git commit: her anlamlı değişiklikte
- Profiling: her milestone sonunda

---

*Bu doküman yaşayan bir belgedir. Geliştirme ilerledikçe güncellenecektir.*
*Son güncelleme: Nisan 2026*
*Proje sahibi: Cem — github.com/cemakkaya-dev*
