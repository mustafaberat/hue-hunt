# RFC V1 — Hue Hunt

Tek kişilik renk farkı oyunu. Backend yok. Flutter, Android / iOS / web.

## Oyun

Farklı renkteki kutuyu bul.

- Home → **Oyna** → Level 1. Mode / zorluk seçilmez.
- 3 can. Session boyunca can **yalnızca azalır**; level atlamak canı doldurmaz. Reset: Tekrar oyna / yeni oyun.
- Yanlış: can −1, **aynı round** devam. Aynı yanlış kutuya tekrar basmak can yakmaz.
- Doğru: sonraki level, yeni renkler, can aynı kalır.
- Can 0: input kapanır, doğru kutu işaretlenir, Game Over (ulaşılan level). Tekrar oyna = Level 1 + 3 can.

Timer yok.

## Grid

Dış kare sabit, kutu küçülür. Tavan **6×6**. Tablo: `lib/config/game_config.dart` → `levelSpecs`.

| Level | Grid |
| ---: | :---: |
| 1–2 | 2×2 |
| 3–4 | 3×3 |
| 5–6 | 4×4 |
| 7–8 | 5×5 |
| 9+ | 6×6 |

## Renk

OKLab. RGB delta yok. Arka plana minimum perceptual mesafe. Delta level ile küçülür, `minPlayableDelta` altına inmez. Üretim max 100 deneme + fallback. Clamp yok.

**Renk körü modu:** tarama/desen yok. Açıkken fark kırmızı-yeşil (OKLab a) ekseninde üretilmez; parlaklık ve mavi-sarı kullanılır. Çift, deuteranopia + protanopia simülasyonunda da ayırt edilebilir kalmak zorunda.

## Ekranlar

- **Home:** ad, tek satır açıklama, Oyna, Ayarlar
- **Oyun:** kapat, seviye, kalpler, grid
- **Ayarlar:** TR / EN, renk körü, ses, titreşim — local kayıt
- **Game Over:** overlay (Tekrar oyna / Ana sayfa)

## Kod

Sabitler `lib/config/` (`app_config.dart`). Ekranda magic number / ham string yok. Motor saf, renk UI’dan ayrı.

Kimlik: Hue Hunt, ARU SOFT, `com.arusoft.huehunt`.
