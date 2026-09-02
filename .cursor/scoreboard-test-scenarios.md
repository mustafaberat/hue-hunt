# Skorboard — test senaryoları

Hue Hunt skorboard davranışını doğrulamak için. Agent sonraki turda: **bu dosyaya göre test et, her maddeye sonuç yaz.**

Can: tur başında 3. Seviye atlamak can doldurmaz. Skor = ulaşılan seviye. Tablo top-5; doluysa yalnızca 5. sıradan **yüksek** level yazılır. İsim 2–16, `harf / rakam / boşluk / _ . -`.

API: `https://arusoft.vercel.app/api/hue-hunt/scores`  
GET: son can (`lives == 1`) veya Game Over, yalnızca ağ varsa.  
POST: Kaydet; UI hemen yerel tabloyu günceller, istek arkada.

| Ortam | Nasıl |
|---|---|
| Internetsiz | Uçak modu veya Chrome DevTools → Offline. Oyun **açıkken** kes. |
| Internetli | Normal ağ. DevTools Network’te `hue-hunt/scores` filtresi. |

Her senaryoda: overlay’de **Oyun bitti + ulaşılan seviye + Tekrar oyna + Ana sayfa** her zaman var. Skorboard yalnızca ağ + başarılı/beklenen GET varsa.

---

## Internetsiz

Ağ yok. `scores` GET/POST **hiç** gitmemeli. Skor tablosu, isim alanı, Kaydet **yok**. Oyun tam oynanır.

### I-1 — Seviye 1, 3 yanlış

1. Oyna. Seviye 1.
2. 3 kez yanlış kutu (aynı kutuya tekrar basma; can yakmaz).
3. Game Over overlay.

**Beklenen:** Tablo yok, loading yok, Kaydet yok. Can 3→2→1→0. Overlay kısa gecikmeyle. Network’te `scores` yok.

### I-2 — Seviye 1, 2 yanlış + 1 doğru + 3. yanlış

1. 2 yanlış (can 1).
2. Doğru kutu → seviye 2.
3. Seviye 2’de yanlış → Game Over (can 0). Ulaşılan seviye 2.

**Beklenen:** Yine skorboard yok, istek yok. Overlay “ulaşılan seviye 2”.

### I-3 — Birkaç seviye, sonra 3 can bitene kadar yanlış

1. Birkaç doğru (ör. seviye 4–5).
2. 3 yanlış ile bitir.

**Beklenen:** Oyun akışı normal. Overlay’de tablo yok, `scores` yok.

### I-4 — Tekrar oyna (offline)

1. I-1 veya I-3 sonrası **Tekrar oyna**.
2. Yine 3 yanlış.

**Beklenen:** Yeni tur, 3 can, seviye 1. Yine tablo yok, istek yok.

### I-5 — Ana sayfa (offline)

1. Game Over → **Ana sayfa**.
2. Ayarlar aç/kapa, tekrar Oyna, 1 yanlış.

**Beklenen:** Çökme yok. Hâlâ istek yok.

### I-6 — İlk iki yanlışta istek yok

1. Seviye 1, 1 yanlış (can 2), 2. yanlış (can 1).
2. Overlay henüz yok. Network.

**Beklenen:** Can 2 iken GET yok. Can 1 olsa da **offline** olduğu için GET yok.

---

## Internetli

Ağ var. DevTools’ta GET/POST görünür. Boş tablo: “Henüz skor yok” + form (board < 5 ise her level yeter). Dolu tablo: form yalnızca `level > 5. sıranın level’i`.

### N-1 — Seviye 1, 3 yanlış (boş veya dolu olmayan tablo)

1. Network açık, Oyna, seviye 1, 3 yanlış.
2. Overlay.

**Beklenen:** 2. yanlışta (can 1) **GET** `.../scores`. Overlay’de top-5 (veya boş metin). Board < 5 ise isim + Kaydet. GET 3. yanlışta tekrarlanmaz (aynı Future).

### N-2 — Kaydet: anında yerel, POST arkada

1. N-1, form açık.
2. Geçerli isim (ör. `Ada`), **Kaydet**. Network yavaşlat (Slow 3G) isteğe bağlı.

**Beklenen:** Form hemen kapanır, isim tabloda (level 1), POST beklenmez. Arkada POST `{ "name", "level" }`. 200 + `accepted: true` ise liste sunucu sırasına çekilebilir. Overlay kapanmaz.

### N-3 — Geçersiz isim

1. Form açık.
2. Kaydet: boş / 1 karakter / 17+ / `Ada!` veya emoji.

**Beklenen:** Tablo değişmez, form açık, POST yok.

### N-4 — Geçerli isim sınırları

1. 2 karakter (ör. `Al`) → kaydolur.
2. Yeni tur: 16 karakter → kaydolur.
3. `A_b.1- x` (izinli işaretler) → kaydolur.

**Beklenen:** Her geçerli denemede POST. Geçersizde yok.

### N-5 — Tablo dolu, level yetmez

Önkoşul: API’de 5 kayıt, 5. sıra level **≥ 1** (tipik: hepsi ≥ 1).

1. Seviye 1, 3 yanlış, overlay.

**Beklenen:** GET var, 5 satır. Form **yok** (`1 > 5. sıra` değilse). Kaydet yok.

### N-6 — Tablo dolu, level yeter

Önkoşul: 5. sıra örneğin 3. Oyunda 5. sıradan yüksek seviyeye çık, 3 canı bitir.

1. Overlay.

**Beklenen:** Form var. Kaydet → hemen tabloya girer (5. düşük düşer), POST gider. `accepted: true`.

### N-7 — Prefetch zamanı

1. Network log, seviye 1.
2. 1. yanlış (can 2) → GET yok.
3. 2. yanlış (can 1) → GET **bir kez**.
4. 3. yanlış (Game Over) → ikinci GET yok.

### N-8 — Tekrar oyna (online)

1. Overlay’den Tekrar oyna.
2. Yine can 1’e düş.

**Beklenen:** Yeni GET (oturum reset). Eski tablo overlay’de kalmaz.

### N-9 — GET hata / timeout

1. Network’te `scores` GET → Block veya offline **GET anında** (bağlantı “var” görünüp istek düşer).

**Beklenen:** Overlay açılır; skorboard gizlenir (spinner kalıcı değil). Oyun bitmiş kalır. POST yok.

### N-10 — Ana sayfa (online)

1. Overlay → Ana sayfa. Çökme yok.

---

## Karışık (ağ değişir)

### K-1 — Can 1 online, overlay öncesi offline

1. 2 yanlış (GET başladı).
2. Hemen uçak modu.
3. 3. yanlış, overlay.

**Beklenen:** GET zaten atıldıysa tablo gelebilir veya hata ile gizlenir. Overlay (seviye + butonlar) durur. Yeni GET yok.

### K-2 — Overlay açık, Kaydet’ten hemen önce offline

1. Online bitir, form görünür.
2. Offline, geçerli isim, Kaydet.

**Beklenen:** İsim **hemen** tabloda, form kapanır. POST yok (veya fail, UI geri alınmaz).

### K-3 — Can 1 offline, 3. yanlışta online

1. Offline 2 yanlış (can 1, GET yok).
2. Ağı aç.
3. 3. yanlış (Game Over prefetch tekrar dener).

**Beklenen:** Game Over anında GET. Overlay’de tablo (gecikmeli gelebilir).

### K-4 — Kayıt sonrası Tekrar oyna, offline bitir

1. Online kaydet.
2. Tekrar oyna, uçak, 3 yanlış.

**Beklenen:** İkinci overlay’de tablo yok, istek yok.

---

## Sonuç (sonraki turda doldur)

| ID | Ortam | Sonuç | Not |
|---|---|---|---|
| I-1 | internetsiz | | |
| I-2 | internetsiz | | |
| I-3 | internetsiz | | |
| I-4 | internetsiz | | |
| I-5 | internetsiz | | |
| I-6 | internetsiz | | |
| N-1 | internetli | | |
| N-2 | internetli | | |
| N-3 | internetli | | |
| N-4 | internetli | | |
| N-5 | internetli | | |
| N-6 | internetli | | |
| N-7 | internetli | | |
| N-8 | internetli | | |
| N-9 | internetli | | |
| N-10 | internetli | | |
| K-1 | karışık | | |
| K-2 | karışık | | |
| K-3 | karışık | | |
| K-4 | karışık | | |

Sonuç: `geçti` / `kaldı` / `atlandı`. Kaldıysa Not’a ne göründü.
