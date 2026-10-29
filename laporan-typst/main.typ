// =====================================================================
// Template Laporan Tugas — Workshop Deep Learning (Teknik Telekomunikasi ITERA)
// Studi Ablasi RNN, LSTM, GRU vs ANN untuk Prediksi Trafik Seluler
//
// Format IEEE conference dua kolom (paket charged-ieee), MAKSIMAL 6 HALAMAN
// termasuk referensi.
// Compile: typst compile main.typ   (atau unggah folder ini ke typst.app)
// Bila muncul peringatan font "TeX Gyre Termes" saat compile lokal, pasang font TeX Gyre
// atau tambahkan --font-path ke folder font tersebut. Di typst.app font sudah tersedia.
//
// Teks abu-abu dalam #petunjuk[...] adalah petunjuk: HAPUS dan ganti dengan isi kalian.
// =====================================================================
#import "@preview/charged-ieee:0.1.4": ieee

#set text(lang: "id")
#let petunjuk(isi) = text(fill: gray.darken(20%))[[#isi]]

#show: ieee.with(
  title: [Studi Ablasi RNN, LSTM, dan GRU dibandingkan ANN untuk Prediksi Trafik Seluler Taman Kota Parco Sempione],
  abstract: [
    #petunjuk[150–200 kata. Tuliskan: masalah (prediksi trafik internet per jam), data (Telecom Italia, kotak Duomo dan lokasi kelompok), apa yang diuji (ablasi faktor apa saja, 3 seed), temuan utama dengan angka (misalnya "GRU terbaik dengan test MAE $x plus.minus y$, turun $z$ % dari acuan"), dan satu kalimat kesimpulan.]
  ],
  // Satu entri per anggota (maks. 3). Hapus yang tidak dipakai.
  authors: (
    (name: "Tyodonrau", department: [NIM 124400052], organization: [Teknik Telekomunikasi, ITERA], email: "tyodonrau.124400052@student.itera.ac.id"),
    (name: "Adryan Ari Nur Hakim P", department: [NIM 124400026], organization: [Teknik Telekomunikasi, ITERA], email: "email@student.itera.ac.id"),
    (name: "Joan Felix Tampubolon", department: [NIM 124400088], organization: [Teknik Telekomunikasi, ITERA], email: "email@student.itera.ac.id"),
  ),
  index-terms: ("prediksi trafik seluler", "RNN", "LSTM", "GRU", "studi ablasi"),
  bibliography: bibliography("references.bib", title: [Pustaka]),
  figure-supplement: [Gambar],
)

= Pendahuluan

Prediksi trafik seluler merupakan salah satu aspek penting dalam pengelolaan jaringan telekomunikasi. Peningkatan penggunaan layanan digital menyebabkan kebutuhan jaringan berubah dari waktu ke waktu dan berbeda pada setiap wilayah. Informasi mengenai pola trafik dapat membantu operator memahami permintaan jaringan, merencanakan kapasitas, serta mengalokasikan sumber daya secara lebih efisien. Oleh karena itu, diperlukan metode prediksi yang mampu mempelajari pola historis trafik untuk memperkirakan kebutuhan jaringan pada periode berikutnya.

Trafik seluler memiliki karakteristik data deret waktu (*time series*) karena nilai pengamatan pada suatu waktu dapat berkaitan dengan nilai pada waktu sebelumnya. Salah satu pendekatan yang dapat digunakan untuk mempelajari pola tersebut adalah jaringan saraf tiruan. *Artificial Neural Network* (ANN) dapat digunakan sebagai model pembanding, sedangkan *Recurrent Neural Network* (RNN) dirancang untuk memproses data berurutan dengan mempertimbangkan informasi dari langkah waktu sebelumnya. Namun, RNN standar dapat mengalami kesulitan dalam mempelajari ketergantungan temporal jangka panjang. Untuk mengatasi keterbatasan tersebut, *Long Short-Term Memory* (LSTM) menggunakan mekanisme gerbang untuk mengatur penyimpanan dan penggunaan informasi sepanjang urutan waktu @hochreiter1997lstm. Sementara itu, *Gated Recurrent Unit* (GRU) menggunakan mekanisme gerbang dengan struktur yang lebih ringkas untuk mempelajari hubungan temporal @cho2014gru. Perbandingan keempat arsitektur tersebut diperlukan untuk mengetahui perbedaan kinerjanya dalam memprediksi trafik seluler.

Penelitian ini dirancang menggunakan dataset trafik seluler Kota Milan dari Telecom Italia yang menyediakan informasi penggunaan jaringan berdasarkan lokasi dan waktu @barlacchi2015milan. Fokus pengamatan diarahkan pada kawasan Taman Kota Parco Sempione, Milan. Pemilihan kawasan ini bertujuan untuk mengkaji pola trafik seluler pada wilayah tertentu, bukan hanya pada skala kota secara keseluruhan. Sebelum eksperimen dilakukan, wilayah pengamatan perlu dicocokkan dengan metadata dan koordinat grid pada dataset agar data yang digunakan benar-benar mewakili kawasan yang diteliti.

Penelitian ini membandingkan ANN, RNN, LSTM, dan GRU menggunakan prosedur pelatihan dan evaluasi yang konsisten. Kinerja model direncanakan diukur menggunakan *Mean Absolute Error* (MAE), *Root Mean Squared Error* (RMSE), dan *Mean Absolute Percentage Error* (MAPE). Selain membandingkan arsitektur, penelitian ini menerapkan studi ablasi dengan mengubah konfigurasi tertentu secara terencana untuk mengamati pengaruhnya terhadap hasil prediksi. Pengujian juga dirancang untuk mengevaluasi kemampuan generalisasi model pada lokasi pengamatan yang berbeda. Dengan demikian, analisis diharapkan dapat memberikan gambaran mengenai kinerja model pada wilayah utama sekaligus keterbatasannya ketika diterapkan pada wilayah lain.

= Data dan Metode

== Dataset
#petunjuk[Telecom Italia Big Data Challenge @barlacchi2015milan, versi per jam dari @zhang2021fedda: periode, resolusi, fitur. Sebutkan kotak Duomo (5060) dan lokasi kelompok (kode, nama, nomor kotak). @fig:peta boleh dipakai.]

#figure(
  image("gambar/peta_lokasi_tugas.png", width: 85%),
  caption: [Rata-rata aktivitas internet per kotak di Milan. Lingkaran kuning: lokasi tugas (kode 0–9); lingkaran toska: Duomo.],
  placement: top,
) <fig:peta>

== Pembagian Data dan Praproses
#petunjuk[Pembagian berdasarkan waktu (train / val / test / Natal), standarisasi dengan statistik sebelum minggu validasi, _windowing_. Jelaskan mengapa data deret waktu tidak boleh diacak.]

== Model dan Konfigurasi Acuan
#petunjuk[Uraikan ANN, RNN, LSTM, GRU secara singkat (tanpa menyalin slide). Sajikan konfigurasi acuan dalam @tab:acuan.]

#figure(
  caption: [Konfigurasi acuan],
  placement: top,
  table(
    columns: 2,
    align: left,
    stroke: none,
    table.hline(),
    table.header([*Hyperparameter*], [*Nilai acuan*]),
    table.hline(stroke: 0.5pt),
    [Panjang jendela $W$], [24 jam],
    [Horizon], [1 jam],
    [Ukuran hidden], [ANN 32, RNN 68, LSTM 33, GRU 38],
    [Jumlah lapisan], [ANN 2, rekuren 1],
    [Fitur], [net, call, sms, jam, hari (7)],
    [Optimizer, _learning rate_], [Adam, $10^(-3)$],
    [_Batch size_], [64],
    [_Early stopping_], [_patience_ 30, maks. 300 epoch],
    table.hline(),
  ),
) <tab:acuan>

== Protokol Ablasi dan Evaluasi
#petunjuk[Satu faktor diubah setiap kali; daftar faktor dan nilainya (A1–A5 dan dua faktor B pilihan kalian beserta hipotesis awal). Setiap konfigurasi dilatih dengan 3 seed; dilaporkan rata-rata $plus.minus$ simpangan baku. Metrik: MAE, RMSE, MAPE pada skala asli. Pemilihan konfigurasi terbaik memakai val MAE. Sebutkan perangkat yang dipakai (CPU/GPU) dan total waktu training.]

= Hasil

== Baseline Naif dan Acuan
#petunjuk[Tabel baseline naif dan hasil konfigurasi acuan (Bagian 0).]

== Ablasi Wajib
#petunjuk[Satu subbagian atau paragraf per faktor A1–A5. Gunakan grafik dari folder `hasil/` (boleh digabung beberapa dalam satu gambar agar hemat tempat) dan tabel seperti @tab:contoh. Setiap gambar dan tabel harus dirujuk dan dibahas di teks.]

#figure(
  caption: [Contoh format: pengaruh panjang jendela $W$ terhadap test MAE (rata-rata $plus.minus$ simpangan baku, 3 seed). Angka di bawah hanya contoh.],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*$W$ (jam)*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    [6], [$000 plus.minus 00$], [$000 plus.minus 00$], [$000 plus.minus 00$], [$000 plus.minus 00$],
    [24], [$000 plus.minus 00$], [$bold(000 plus.minus 00)$], [$000 plus.minus 00$], [$000 plus.minus 00$],
    [168], [$000 plus.minus 00$], [$000 plus.minus 00$], [$000 plus.minus 00$], [$000 plus.minus 00$],
    table.hline(),
  ),
) <tab:contoh>

== Ablasi Pilihan
#petunjuk[Dua faktor B pilihan kalian: hipotesis awal, hasil, dan apakah hipotesis terbukti.]

== Konfigurasi Terbaik
#petunjuk[Konfigurasi terbaik tiap model (dipilih dengan val MAE), lalu hasilnya pada minggu test dan Natal dibandingkan dengan acuan dan baseline naif.]

== Uji Generalisasi
#petunjuk[Hasil acuan vs terbaik di lokasi kelompok. Apakah urutan model berubah? Kaitkan dengan pola trafik lokasi tersebut.]

= Pembahasan
#petunjuk[Bagian terpenting. Jangan hanya mengulang angka: jelaskan _mengapa_. Hyperparameter mana yang paling berpengaruh dan mana yang tidak? Apakah perbedaan antar model lebih besar daripada perbedaan antar seed? Apa keterbatasan studi ini (satu kota, 4 minggu train, satu kali pembagian waktu)?]

= Kesimpulan
#petunjuk[3–5 kalimat yang menjawab pertanyaan studi, dengan angka.]

#heading(numbering: none)[Kontribusi Anggota]
#table(
  columns: (auto, 1fr),
  stroke: none,
  [Nama Anggota 1], petunjuk[contoh: Bagian A1–A3, penulisan Hasil],
  [Nama Anggota 2], petunjuk[...],
  [Nama Anggota 3], petunjuk[...],
)

#heading(numbering: none)[Pernyataan Penggunaan AI]
#petunjuk[Tuliskan alat AI yang dipakai (misalnya ChatGPT, Claude, Copilot) dan untuk apa (memperbaiki kode, merapikan bahasa, dll.). Bila tidak memakai, tulis "Tidak ada." Seluruh angka harus berasal dari run kalian sendiri.]

#heading(numbering: none)[Kode dan Data]
Kode, notebook beserta output, dan seluruh hasil run tersedia di #link("https://github.com/username/nama-repo").
