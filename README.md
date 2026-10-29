# Studi Ablasi RNN, LSTM, GRU vs ANN untuk Prediksi Trafik Seluler Taman Kota Parco Sempione

Tugas Workshop Deep Learning — Teknik Telekomunikasi ITERA.

## Kelompok

| Peran | Nama | NIM |
|---|---|---|
| Ketua | [Tyodonrau] | [124400052] |
| Anggota | [Adryan Ari Nur Hakim P] | [124400026] |
| Anggota | [Joan Felix Tampubolon] | [124400088] |

- **Kelas:** [RB]
- **Lokasi kelompok:** [5455] — [Parco Sempione] (6)
- **Laporan:** [https://github.com/Bufel/dlw-tugas-rb-124400052/blob/main/laporan-typst/main.pdf]

## Cara Menjalankan

```bash
uv sync
uv run jupyter lab
```

Buka `tugas_ablasi.ipynb`, isi `LOKASI_KELOMPOK`, lalu jalankan semua sel. Semua run tercatat di `hasil/ablasi.csv`.

Perangkat yang kami pakai: Intel i3-1115G4 / VS Code, total waktu training : 130.7 menit

## 📊 Ringkasan Hasil Eksperimen

Berdasarkan studi ablasi yang dilakukan pada data trafik seluler Kota Milan (lokasi pusat kota Duomo), model berbasis rekuren secara konsisten mengungguli arsitektur ANN konvensional. Penerapan konfigurasi terbaik hasil talaan hyperparameter terbukti berhasil meningkatkan akurasi uji pada mayoritas model. 

Berikut adalah performa akurasi final pada minggu pengujian normal (**Test MAE**) untuk masing-masing arsitektur model (nilai terbaik dicetak tebal):

* **GRU Terbaik:** **233.8 ± 15.7** (Performa optimal keseluruhan)
* **RNN Terbaik:** 238.6 ± 17.2 (Model RNN Acuan meraih 229.6 ± 5.1)
* **LSTM Terbaik:** 258.9 ± 25.5 
* **ANN Terbaik:** 293.6 ± 21.3

### Temuan Utama:
1. **Sensitivitas Hyperparameter:** Panjang jendela ($W$) dan *learning rate* ($lr$) merupakan faktor paling berpengaruh. Jendela yang terlalu panjang (168 jam) memicu *overfitting* ekstrem pada ANN, sementara model rekuren tetap stabil.
2. **Keterbatasan Spasial & Temporal:** Saat diuji generalisasi di lokasi **Parco Sempione (Lokasi 6)**, urutan model terbaik berubah di mana RNN acuan dasar meraih hasil optimal (Test MAE: 99.5 ± 2.7). 
3. **Anomali Musiman:** Seluruh model mengalami lonjakan eror hingga dua kali lipat pada minggu libur Natal akibat perubahan pola mobilitas masyarakat yang ekstrem.

## Data

Telecom Italia Big Data Challenge (Barlacchi dkk., 2015, *Scientific Data*, lisensi ODbL), versi per jam dari Zhang dkk. (INFOCOM 2021). Disiapkan oleh pengajar di repo [mctosima/dl-workshop](https://github.com/mctosima/dl-workshop).
