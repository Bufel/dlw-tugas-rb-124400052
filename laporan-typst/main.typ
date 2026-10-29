#import "@preview/charged-ieee:0.1.4": ieee

#set text(lang: "id")
#let petunjuk(isi) = text(fill: gray.darken(20%))[[#isi]]

#show: ieee.with(
  title: [Studi Ablasi RNN, LSTM, dan GRU dibandingkan ANN untuk Prediksi Trafik Seluler Taman Kota Parco Sempione],
  abstract: [
    Prediksi trafik seluler merupakan salah satu aspek penting dalam pengelolaan jaringan telekomunikasi karena pola penggunaan jaringan dapat berubah berdasarkan waktu dan lokasi. Penelitian ini bertujuan untuk membandingkan kinerja *Artificial Neural Network* (ANN), *Recurrent Neural Network* (RNN), *Long Short-Term Memory* (LSTM), dan *Gated Recurrent Unit* (GRU) dalam memprediksi trafik seluler di kawasan Taman Kota Parco Sempione, Milan, Italia. Data penelitian menggunakan dataset trafik seluler Kota Milan dari Telecom Italia, dengan fokus pada data wilayah yang mewakili kawasan Parco Sempione. Variabel target yang diprediksi adalah trafik internet (*net*) untuk satu jam berikutnya berdasarkan data historis selama 24 jam. Kinerja model dievaluasi menggunakan *Mean Absolute Error* (MAE), *Root Mean Squared Error* (RMSE), dan *Mean Absolute Percentage Error* (MAPE). Penelitian ini juga menerapkan studi ablasi untuk menganalisis pengaruh perubahan panjang jendela waktu, ukuran lapisan tersembunyi, jumlah lapisan, *learning rate*, kelompok fitur, dan fungsi *loss* terhadap kinerja prediksi. Setiap konfigurasi diuji menggunakan tiga *seed* untuk mengamati konsistensi hasil pelatihan. Konfigurasi terbaik ditentukan berdasarkan nilai MAE pada data validasi, kemudian dievaluasi menggunakan data pengujian. Selain itu, pengujian generalisasi dirancang untuk mengamati kemampuan model ketika diterapkan pada lokasi yang berbeda. Penelitian ini diharapkan dapat memberikan pemahaman mengenai perbandingan kinerja ANN, RNN, LSTM, dan GRU serta pengaruh konfigurasi model terhadap akurasi prediksi trafik seluler di kawasan Parco Sempione.

 Kata kunci: prediksi trafik seluler, Parco Sempione, ANN, RNN, LSTM, GRU, studi ablasi.
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
Peramalan trafik seluler per jam sangat krusial bagi operator telekomunikasi untuk mengoptimalkan alokasi sumber daya jaringan, menghemat konsumsi energi sel, dan mencegah terjadinya degradasi layanan (_congestion_). Karakteristik data trafik yang memiliki ketergantungan temporal yang kuat membuat model sekuensial seperti RNN, LSTM @hochreiter1997lstm, dan GRU @cho2014gru lebih diunggulkan dibanding ANN konvensional karena kemampuannya dalam menangani memori urutan waktu. Untuk memahami sensitivitas tiap arsitektur terhadap perubahan parameter, studi ablasi penting dilakukan dengan cara mengisolasi dan mengubah satu faktor konfigurasi dalam satu waktu. 

Kontribusi utama dari laporan ini adalah:
1. Mengevaluasi pengaruh lima _hyperparameter_ wajib (A1–A5) serta dua faktor pilihan (fungsi loss B4 dan horizon B6) terhadap akurasi prediksi model di lokasi Duomo.
2. Menentukan kombinasi konfigurasi terbaik untuk masing-masing model berdasarkan metrik validasi MAE.
3. Menguji kemampuan generalisasi spasial model terbaik tanpa perubahan parameter pada karakteristik trafik lokal Parco Sempione.


= Data dan Metode

== Dataset
Laporan ini menggunakan dataset yang bersumber dari *Telecom Italia Big Data Challenge* @barlacchi2015milan, khususnya versi agregasi per jam (*hourly*) yang telah dipraproses oleh @zhang2021fedda. Data ini mencakup wilayah metropolitan kota Milan, Italia, dengan resolusi temporal berbasis per jam. Fitur-fitur utama yang tersedia di dalam dataset meliputi data trafik telekomunikasi seluler, yaitu panggilan keluar/masuk (_call_), pesan teks singkat (_sms_), serta aktivitas internet (_net_) yang menjadi target prediksi utama.

Eksperimen studi ablasi ini mengevaluasi dua lokasi spesifik di kota Milan:
1. *Kotak Duomo*: Merupakan area pusat kota acuan dengan kode grid *5060*. Data dari lokasi ini digunakan sebagai basis utama pengembangan model dari Bagian 0 hingga Bagian C.
2. *Parco Sempione (Lokasi Kelompok 6)*: Merupakan lokasi spesifik yang ditugaskan kepada kelompok kami dengan kode wilayah *6* dan nomor grid *5455*. Data dari Parco Sempione ini digunakan secara khusus pada Bagian D untuk menguji kemampuan generalisasi spasial dari konfigurasi model terbaik yang telah ditemukan di Duomo. visualisasi spasial dari seluruh titik evaluasi di kota Milan dapat dilihat pada @fig:peta.


#figure(
  image("gambar/peta_lokasi_tugas.png", width: 85%),
  caption: [Rata-rata aktivitas internet per kotak di Milan. Lingkaran kuning: lokasi tugas (kode 0–9); lingkaran toska: Duomo.],
  placement: top,
) <fig:peta>

== Pembagian Data dan Praproses
Dataset deret waktu dalam eksperimen ini dibagi menjadi empat periode non-overlapping berdasarkan urutan kronologis waktu:
1. *Train (Pelatihan)*: Berlangsung dari tanggal 11 November hingga 8 Desember 2013, yang digunakan sebagai basis utama model untuk mempelajari pola temporal trafik seluler.
2. *Validation (Validasi)*: Berlangsung dari tanggal 9 Desember hingga 15 Desemeber 2013, yang berfungsi sebagai acuan untuk studi ablasi, penyetelan _hyperparameter_, serta penentuan arsitektur terbaik.
3. *Test (Pengujian)*: Berlangsung dari tanggal 16 Desember hingga 22 Desember 2013 untuk evaluasi akhir performa model pada kondisi normal.
4. *Natal (Kondisi Khusus)*: Berlangsung dari tanggal 23 Desember hingga 29 Desember 2013 yang digunakan khusus untuk menguji ketahanan model terhadap anomali atau lonjakan trafik musiman pada hari libur besar.
Adapun data pada minggu pertama (4–10 November 2013) tidak masuk ke dalam set pelatihan, melainkan hanya dipertahankan sebagai konteks awal jendela histori temporal.

Sebelum pembentukan jendela data (_windowing_), tahap praproses dilakukan menggunakan teknik standarisasi nilai Z-score. Untuk mencegah terjadinya _data leakage_ (kebocoran data), nilai rata-rata (_mean_) dan simpangan baku (_standard deviation_) dihitung secara ketat hanya menggunakan statistik data sebelum minggu validasi (data pelatihan). Nilai statistik ini kemudian digunakan untuk mentransformasikan seluruh partisi data ke skala yang seragam. 

Proses pembuatan sampel data menggunakan teknik _sliding window_ dengan panjang jendela $W$ jam untuk memetakan histori fitur masa lalu menjadi representasi matriks $X$, yang digunakan untuk memprediksi target trafik $y$ pada horizon $H$ jam ke depan. 

Dalam pemrosesan data deret waktu, data tidak boleh diacak (_shuffling_) sebelum proses _windowing_ dilakukan. Hal ini dikarenakan data deret waktu memiliki dependensi temporal yang kuat, di mana urutan kronologis antar baris data membawa informasi penting mengenai tren dan musiman (seperti pola harian dan mingguan). Pengacakan urutan data akan merusak struktur hubungan sebab-akibat temporal tersebut, merusak fungsionalitas memori pada model rekuren, dan menyebabkan bias evaluasi akibat kebocoran informasi masa depan ke masa lalu.


== Model dan Konfigurasi Acuan
Eksperimen ini mengevaluasi empat arsitektur jaringan saraf dengan karakteristik pemrosesan temporal yang berbeda untuk memprediksi trafik seluler:
1. *ANN (_Artificial Neural Network_)*: Model arsitektur maju (_feed-forward_) di mana seluruh fitur dalam dimensi jendela waktu ($W times "fitur"$) diratakan menjadi satu vektor panjang. Hubungan temporal tidak diproses secara sekuensial, melainkan dipetakan sekaligus melalui lapisan tersembunyi linier berdensitas penuh (*Fully Connected Layers*).
2. *RNN (_Recurrent Neural Network_)*: Model sekuensial dasar yang memproses urutan jam demi jam menggunakan mekanisme umpan balik internal (_recurrent loop_). Informasi masa lalu disimpan dalam sebuah vektor *hidden state*, namun arsitektur ini rentan terhadap masalah hilangnya gradien (*vanishing gradient*) pada urutan jangka panjang.
3. *LSTM (_Long Short-Term Memory_)*: Pengembangan dari RNN yang mengatasi masalah *vanishing gradient* dengan memperkenalkan struktur sel memori terproteksi. Model ini memanfaatkan tiga gerbang (_gate_) internal—yaitu *input gate*, *forget gate*, dan *output gate*—untuk menyaring, menyimpan, atau membuang informasi jangka panjang secara adaptif.
4. *GRU (_Gated Recurrent Unit_)*: Variasi arsitektur rekuren yang lebih ringkas dibandingkan LSTM. GRU menyederhanakan mekanisme gerbang menjadi hanya dua komponen, yaitu *reset gate* dan *update gate*, serta menggabungkan sel memori langsung ke dalam *hidden state*, menjadikannya lebih efisien secara komputasi dengan performa yang kompetitif.

Konfigurasi acuan dasar yang digunakan sebagai titik awal studi ablasi dirancang agar jumlah parameter model rekuren setara secara adil (berada pada kisaran $\pm$ 5,5 ribu parameter). Parameter spesifik untuk pengujian acuan ini dirangkum dalam @tab:acuan.

#figure(
  caption: [Konfigurasi acuan eksperimen],
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
    [Ukuran hidden], [ANN: 32, RNN: 68, LSTM: 33, GRU: 38 (Total parameter $\pm$ 5,5k)],
    [Jumlah lapisan], [ANN: 2 lapisan tersembunyi, Rekuren: 1 lapisan],
    [Kelompok Fitur], [semua (net, call, sms, jam_sin, jam_cos, hari_sin, hari_cos) [7 fitur]],
    [Optimizer, _learning rate_], [Adam, $10^(-3)$],
    [_Batch size_], [64],
    [Dropout], [0.0],
    [Fungsi loss], [MSE Loss],
    [_Early stopping_], [_patience_ 30, maksimum 300 epoch],
    table.hline(),
  ),
) <tab:acuan>


== Protokol Ablasi dan Evaluasi
Studi ablasi pada eksperimen ini mengikuti protokol isolasi parameter, di mana performa model dievaluasi dengan cara mengubah satu faktor eksperimen dalam satu waktu sementara parameter lainnya dipertahankan tetap sesuai dengan nilai acuan. Faktor eksperimen wajib yang diuji meliputi panjang jendela $W$ (A1), ukuran _hidden units_ (A2), jumlah lapisan (A3), _learning rate_ (A4), dan kelompok fitur (A5). Selain faktor wajib tersebut, kelompok kami memilih dua faktor tambahan pada Bagian B untuk dianalisis lebih lanjut, yaitu:
1. *Fungsi Loss (B4)*: Menguji pengaruh fungsi loss *MSE*, *MAE*, dan *Huber* terhadap optimasi model. Hipotesis awal kami adalah penggunaan fungsi loss MAE akan menghasilkan nilai metrik evaluasi MAE yang paling rendah karena mengoptimalkan fungsi objektif yang sejalan dengan metrik target.
2. *Horizon Prediksi (B6)*: Mengevaluasi batas kemampuan peramalan model pada jangka waktu $1$, $6$, dan $24$ jam ke depan. Hipotesis awal kami adalah performa model akan menurun drastis seiring bertambahnya jarak horizon prediksi, dan pada akhirnya akan kalah saing oleh _baseline_ naif temporal pada pengujian jangka panjang (24 jam).

Untuk menjamin keandalan hasil dan mengantisipasi bias akibat inisialisasi bobot acak, setiap konfigurasi dilatih secara otomatis menggunakan $3$ sandi acak (_seed_) yang berbeda ($0, 1, 2$). Nilai performa yang dilaporkan pada hasil eksperimen merupakan nilai ($"rata-rata" plus.minus "simpangan baku"$).Evaluasi performa model dihitung menggunakan tiga metrik standar pada skala asli data trafik: _Mean Absolute Error_ (MAE), _Root Mean Squared Error_ (RMSE), dan _Mean Absolute Percentage Error_ (MAPE). 

Konfigurasi terbaik untuk masing-masing arsitektur dipilih secara ketat berdasarkan nilai rata-rata MAE terkecil pada set validasi untuk mencegah fenomena _overfitting_ atau peninjauan data uji secara prematur (_data snooping_). Seluruh proses komputasi dan pelatihan model diselesaikan menggunakan perangkat keras berbasis *Central Processing Unit (CPU)* pada lingkungan kerja *PyTorch 2.15.0+cpu*. Total keseluruhan eksperimen mencakup $372$ kali _training run_ dengan akumulasi waktu komputasi selama *130.7 menit*.


= Hasil

== Baseline Naif dan Acuan
Evaluasi model diawali dengan menghitung performa dari tiga model _baseline_ naif (tanpa proses pembelajaran) pada horizon 1 jam dan 24 jam untuk menjadi ambang batas performa minimum. Berdasarkan data pengujian di lokasi Duomo pada @tab:naif, model _baseline_ "Naif: minggu lalu" memberikan performa terbaik untuk prediksi jangka panjang (horizon 24 jam) pada set pengujian normal (_test_) dengan nilai MAE sebesar 466.1. Sebaliknya, tebakan berbasis nilai terakhir ("Naif: nilai terakhir") mengalami lonjakan eror yang sangat ekstrem saat diuji pada horizon 24 jam (MAE mencapai 2769.3) akibat sifat fluktuatif data trafik seluler.

#figure(
  caption: [Performa metrik MAE dari baseline naif di lokasi Duomo],
  table(
    columns: (auto, 1.5fr, 1fr, 1fr, 1fr),
    align: (center, left, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Horizon*], [*Model Baseline*], [*Val*], [*Test*], [*Natal*]),
    table.hline(stroke: 0.5pt),
    [1 jam], [Naif: nilai terakhir], [662.6], [600.9], [431.2],
    [], [Naif: kemarin], [595.3], [552.2], [921.5],
    [], [Naif: minggu lalu], [492.8], [467.6], [1426.2],
    table.hline(stroke: 0.3pt),
    [24 jam], [Naif: nilai terakhir], [2750.4], [2769.3], [2052.0],
    [], [Naif: kemarin], [618.4], [563.4], [915.1],
    [], [Naif: minggu lalu], [493.5], [466.1], [1431.6],
    table.hline(),
  ),
) <tab:naif>

Setelah menetapkan batasan baseline, keempat arsitektur model dilatih menggunakan parameter acuan standar (Bagian 0) pada horizon 1 jam. Hasil rata-rata performa beserta simpangan baku dari 3 _seed_ dirangkum dalam @tab:hasil_acuan. 

Model berbasis rekuren terbukti jauh mengungguli arsitektur ANN konvensional. RNN meraih performa validasi terbaik dengan rata-rata MAE $206.1 plus.minus 7.4$, disusul sangat ketat oleh GRU dengan MAE $207.5 plus.minus 3.8$. Fenomena ini terjadi karena lapisan rekuren mampu mempertahankan representasi memori temporal sekuensial jam demi jam secara lebih efektif dibandingkan ANN yang meratakan seluruh dimensi waktu.

#figure(
  caption: [Performa metrik MAE konfigurasi acuan di Duomo (rata-rata $plus.minus$ simpangan baku)],
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (center, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model*], [*Total Param*], [*Epoch Rata-rata*], [*Val MAE*], [*Test MAE*]),
    table.hline(stroke: 0.5pt),
    [ANN], [6.497], [106.3], [$248.9 plus.minus 8.9$], [$309.9 plus.minus 5.9$],
    [RNN], [5.305], [163.7], [$206.1 plus.minus 7.4$], [$229.6 plus.minus 5.1$],
    [LSTM], [5.578], [168.7], [$230.5 plus.minus 12.2$], [$273.6 plus.minus 25.4$],
    [GRU], [5.397], [193.7], [$207.5 plus.minus 3.8$], [$237.2 plus.minus 9.3$],
    table.hline(),
  ),
) <tab:hasil_acuan>


== Ablasi Wajib

=== A1. Panjang Jendela ($W$)
Pengujian variasi panjang jendela $W in {6, 12, 24, 48, 168}$ jam menunjukkan pola yang bertolak belakang antara model ANN dan model rekuren. Berdasarkan data eksperimen, jendela yang lebih panjang *tidak selalu lebih baik* untuk semua arsitektur. 

Pada model ANN, penambahan panjang jendela menyebabkan jumlah parameter membengkak secara drastis (dari 2.465 parameter pada $W=6$ menjadi 38.753 parameter pada $W=168$). Lonjakan parameter ini menyebabkan ANN mengalami *overfitting* yang parah pada set data latih yang kecil ini, ditandai dengan pemburukan nilai validasi MAE dari $212.4$ ($W=6$) menjadi $298.2$ ($W=168$). 

Sebaliknya, jumlah parameter pada model rekuren (RNN, LSTM, GRU) bersifat konstan meskipun jendela waktu diperpanjang. Model rekuren, khususnya RNN, menunjukkan stabilitas yang sangat baik dengan performa terbaik pada $W=48$ (Val MAE: $200.1 plus.minus 5.3$). Hal ini membuktikan bahwa mekanisme pemrosesan sekuensial jauh lebih efisien dalam mengekstrak histori jangka panjang tanpa membebani kapasitas memori model.

=== A2. Ukuran Hidden
Ukuran dimensi tersembunyi (*hidden units*) divariasikan pada nilai ${16, 32, 64, 128}$. Karena nilai yang sama diterapkan pada keempat model, jumlah parameter internal tidak lagi setara; sebagai contoh, pada *hidden* 128, LSTM membengkak hingga 70.273 parameter sedangkan RNN hanya 17.665 parameter.

Hasil eksperimen menunjukkan bahwa model yang lebih besar *cenderung memberikan hasil lebih baik* meskipun data latih terbatas. Peningkatan ukuran *hidden* dari 16 ke 128 berhasil menurunkan rata-rata validasi MAE pada seluruh model. Performa paling optimal diraih oleh GRU dengan *hidden* 128 yang mencatatkan Val MAE terendah sebesar $188.7 plus.minus 4.2$. Meskipun kapasitas model meningkat, mekanisme *early stopping* berhasil menjaga model agar tidak mengalami degradasi performa akibat *overfitting*.

=== A3. Jumlah Lapisan
Eksperimen penumpukan lapisan (*stacked layers*) dilakukan pada tingkatan ${1, 2, 3}$. Berdasarkan metrik rata-rata epoch, model yang lebih dalam terbukti *lebih cepat mengalami overfit*. Hal ini terlihat jelas dari penurunan jumlah epoch bertahan seiring bertambahnya lapisan (misalnya, RNN menurun dari 163.7 epoch pada 1 lapisan menjadi 96.0 epoch pada 3 lapisan).

Dari segi performa, menumpuk lapisan rekuren justru *memperburuk* akurasi prediksi. Model LSTM merupakan yang paling sensitif, di mana penambahan menjadi 3 lapisan menyebabkan Val MAE melonjak drastis dari $230.5$ menjadi $338.9$ dengan tingkat ketidakstabilan antar-_seed_ yang sangat tinggi ($plus.minus 16.9$). Jaringan yang terlalu dalam pada data temporal pendek ini membuat ruang pencarian parameter menjadi terlalu kompleks dan memicu hilangnya gradien.

=== A4. Learning Rate ($lr$)
Pengujian dilakukan pada nilai $lr in {0.0001, 0.001, 0.01}$. Pada nilai *learning rate* yang terlalu kecil ($0.0001$), proses optimasi berjalan sangat lambat sehingga seluruh model terhenti secara prematur karena menyentuh batas maksimum `max_epochs` (300 epoch) sebelum konvergen. Akibatnya, eror validasi membengkak hingga mendekati kisaran $\pm 400$ MAE pada LSTM dan GRU.

Pada *learning rate* besar ($0.01$), model rekuren mampu berkonvergen lebih cepat dengan jumlah epoch yang jauh lebih sedikit. Namun, nilai $lr$ yang tinggi meningkatkan risiko ketidakstabilan fluktuasi gradien saat mendekati minimum lokal, yang ditandai dengan tingginya nilai simpangan baku antar-_seed_ (seperti terlihat pada LSTM dengan tingkat ketidakpastian sebesar $plus.minus 14.2$). Nilai acuan $0.001$ terbukti menjadi titik kompromi paling stabil bagi mayoritas model.

=== A5. Kelompok Fitur
Faktor terakhir mengevaluasi empat kombinasi masukan: `net`, `net+call+sms`, `net+waktu`, dan `semua`. Hasil eksperimen menunjukkan bahwa *informasi waktu (jam & hari) jauh lebih berguna* daripada riwayat trafik telepon/SMS. Penggunaan fitur `net+waktu` terbukti mengungguli fitur `net+call+sms` secara signifikan pada seluruh arsitektur.

Model rekuren terlihat sangat membutuhkan penyertaan fitur waktu secara eksplisit dibandingkan ANN. Ketika hanya diberikan fitur tunggal `net`, performa model rekuren memburuk tajam (GRU naik dari MAE $207.5$ menjadi $264.6$). Hal ini disebabkan karena model rekuren membaca urutan secara monoton jam demi jam; tanpa adanya fitur siklus waktu (`jam_sin`/`jam_cos`), model rekuren kesulitan menangani lompatan pola musiman harian (_diurnal cycle_) yang esensial pada data trafik telekomunikasi. Pilihan kelompok fitur `semua` memberikan performa terbaik karena menyediakan representasi konteks temporal yang lengkap.


#figure(
  caption: [Pengaruh panjang jendela $W$ terhadap validasi MAE di Duomo (rata-rata $plus.minus$ simpangan baku, 3 seed). Nilai terbaik dicetak tebal.],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*$W$ (jam)*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    [6], [$212.4 plus.minus 5.3$], [$215.5 plus.minus 4.1$], [$227.1 plus.minus 4.3$], [$212.6 plus.minus 11.5$],
    [12], [$238.5 plus.minus 4.5$], [$206.7 plus.minus 6.2$], [$235.6 plus.minus 2.0$], [$208.9 plus.minus 10.4$],
    [24], [$248.9 plus.minus 8.9$], [$206.1 plus.minus 7.4$], [$230.5 plus.minus 12.2$], [$207.5 plus.minus 3.8$],
    [48], [$261.7 plus.minus 2.8$], [$bold(200.1 plus.minus 5.3)$], [$249.1 plus.minus 21.8$], [$206.7 plus.minus 5.0$],
    [168], [$298.2 plus.minus 18.2$], [$204.8 plus.minus 10.2$], [$241.4 plus.minus 8.1$], [$bold(206.7 plus.minus 5.1)$],
    table.hline(),
  ),
) <tab:pengaruh_W>

== Ablasi Pilihan

=== B4. Fungsi Loss
Pengujian fungsi loss *MSE*, *MAE*, dan *Huber* menunjukkan bahwa loss MAE berhasil menurunkan nilai metrik validasi MAE secara konsisten pada arsitektur ANN dan GRU (@tab:ablasi_loss). Hal ini sesuai dengan hipotesis awal karena fungsi objektif MAE melatih bobot model secara langsung untuk meminimalkan penyimpangan absolut skala asli data trafik. Performa paling optimal dicatatkan oleh GRU dengan nilai MAE sebesar $204.2 plus.minus 4.8$.

#figure(
  caption: [Pengaruh fungsi loss terhadap validasi MAE di Duomo (rata-rata $plus.minus$ simpangan baku, 3 seed).],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Fungsi Loss*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    [mse], [$248.9 plus.minus 8.9$], [$206.1 plus.minus 7.4$], [$230.5 plus.minus 12.2$], [$207.5 plus.minus 3.8$],
    [mae], [$bold(240.6 plus.minus 7.1)$], [$219.2 plus.minus 10.1$], [$234.5 plus.minus 11.9$], [$bold(204.2 plus.minus 4.8)$],
    [huber], [$241.9 plus.minus 3.7$], [$206.3 plus.minus 10.0$], [$233.6 plus.minus 13.6$], [$207.8 plus.minus 5.1$],
    table.hline(),
  ),
) <tab:ablasi_loss>

=== B6. Horizon Prediksi ($H$)
Evaluasi pada jarak peramalan $H \in \{1, 6, 24\}$ jam membuktikan hipotesis awal bahwa akurasi model menurun drastis seiring bertambahnya horizon akibat tingginya ketidakpastian trafik di masa depan (@tab:ablasi_horizon). 

Pada horizon jangka panjang (24 jam), performa seluruh model memburuk hingga kisaran $\pm 440$ MAE. Pada titik ini, model deep learning mulai *kalah saing* dari baseline "Naif: minggu lalu" (Val MAE: 493.5). Hal ini membuktikan batas saturasi model sekuensial, di mana pola musiman mingguan yang berulang jauh lebih andal digunakan sebagai tebakan langsung untuk peramalan jangka panjang.

#figure(
  caption: [Pengaruh horizon prediksi $H$ terhadap validasi MAE di Duomo (rata-rata $plus.minus$ simpangan baku, 3 seed).],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Horizon*], [*ANN*], [*RNN*], [*LSTM*], [*GRU*]),
    table.hline(stroke: 0.5pt),
    [1 jam], [$248.9 plus.minus 8.9$], [$206.1 plus.minus 7.4$], [$230.5 plus.minus 12.2$], [$207.5 plus.minus 3.8$],
    [6 jam], [$337.2 plus.minus 2.4$], [$416.6 plus.minus 11.4$], [$392.9 plus.minus 24.5$], [$381.1 plus.minus 21.0$],
    [24 jam], [$449.0 plus.minus 7.6$], [$437.2 plus.minus 3.2$], [$456.9 plus.minus 19.8$], [$451.8 plus.minus 11.6$],
    table.hline(),
  ),
) <tab:ablasi_horizon>

== Konfigurasi Terbaik
Berdasarkan rata-rata MAE set validasi, konfigurasi parameter terbaik gabungan untuk masing-masing arsitektur model ditentukan sebagai berikut:
- *ANN*: $W=6$, _hidden_=128, _layers_=1, $lr=0.001$, fitur=`net+waktu`, _loss_=`mae`.
- *RNN*: $W=48$, _hidden_=64, _layers_=1, $lr=0.001$, fitur=`semua`, _loss_=`mse`.
- *LSTM*: $W=6$, _hidden_=128, _layers_=1, $lr=0.01$, fitur=`semua`, _loss_=`mse`.
- *GRU*: $W=48$, _hidden_=128, _layers_=2, $lr=0.001$, fitur=`semua`, _loss_=`mae`.

Perbandingan hasil evaluasi akhir pada minggu Test dan Natal dirangkum dalam @tab:terbaik_vs_acuan.

#figure(
  caption: [Perbandingan performa acuan vs terbaik pada minggu Test dan Natal di Duomo (rata-rata $plus.minus$ simpangan baku).],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model & Konfigurasi*], [*Total Param*], [*Val MAE*], [*Test MAE*], [*Natal MAE*]),
    table.hline(stroke: 0.5pt),
    [ANN Acuan], [6.497], [$248.9 plus.minus 8.9$], [$309.9 plus.minus 5.9$], [$680.1 plus.minus 52.0$],
    [ANN Terbaik], [5.297], [$238.8 plus.minus 12.8$], [$bold(293.6 plus.minus 21.3)$], [$bold(639.2 plus.minus 62.4)$],
    table.hline(stroke: 0.3pt),
    [RNN Acuan], [5.305], [$206.1 plus.minus 7.4$], [$229.6 plus.minus 5.1$], [$bold(421.2 plus.minus 2.4)$],
    [RNN Terbaik], [5.021], [$209.4 plus.minus 11.8$], [$238.6 plus.minus 17.2$], [$427.1 plus.minus 34.7$],
    table.hline(stroke: 0.3pt),
    [LSTM Acuan], [5.578], [$230.5 plus.minus 12.2$], [$273.6 plus.minus 25.4$], [$586.0 plus.minus 56.8$],
    [LSTM Terbaik], [37.925], [$225.5 plus.minus 13.4$], [$bold(258.9 plus.minus 25.5)$], [$bold(542.2 plus.minus 60.2)$],
    table.hline(stroke: 0.3pt),
    [GRU Acuan], [5.397], [$207.5 plus.minus 3.8$], [$207.5 plus.minus 3.8$], [$bold(468.2 plus.minus 21.8)$],
    [GRU Terbaik], [78.603], [$216.3 plus.minus 10.8$], [$bold(233.8 plus.minus 15.7)$], [$483.5 plus.minus 36.1$],
    table.hline(),
  ),
) <tab:terbaik_vs_acuan>

Hasil menunjukkan bahwa penggabungan parameter terbaik individu *tidak otomatis meningkatkan akurasi secara bersamaan*. Model ANN dan LSTM sukses memperbaiki performa uji secara signifikan. GRU Terbaik meraih eror paling optimal pada minggu Test ($233.8$), namun sedikit memburuk pada minggu Natal. 

Sebaliknya, model RNN terbaik justru mengalami degradasi performa dibanding versi acuan (Test MAE naik ke $238.6$). Hal ini menjustifikasi adanya interaksi negatif antar-faktor ($W=48$ dan _hidden_=64) yang merusak ruang optimal parameter. Seluruh arsitektur mengalami lonjakan eror hingga dua kali lipat pada minggu Natal akibat ketidakmampuan model dalam menangani anomali ekstrem mobilitas libur akhir tahun.


== Uji Generalisasi
Konfigurasi acuan dan terbaik diuji ulang pada lokasi kelompok yaitu *Parco Sempione (Lokasi 6)* untuk mengukur kemampuan generalisasi spasial model. Karakteristik fluktuasi dan volume trafik di Parco Sempione jauh lebih rendah dibandingkan pusat kota Duomo. Perbandingan performa akhir dirangkum dalam @tab:generalisasi_lokasi.

#figure(
  caption: [Hasil generalisasi acuan vs terbaik di Parco Sempione (rata-rata $plus.minus$ simpangan baku).],
  placement: top,
  table(
    columns: 5,
    align: (left, center, center, center, center),
    stroke: none,
    table.hline(),
    table.header([*Model & Konfigurasi*], [*Val MAE*], [*Test MAE*], [*Test MAPE*], [*Natal MAE*]),
    table.hline(stroke: 0.5pt),
    [ANN Acuan], [$113.2 plus.minus 5.7$], [$117.8 plus.minus 3.6$], [$11.5 plus.minus 0.4$], [$243.4 plus.minus 25.2$],
    [ANN Terbaik], [$109.4 plus.minus 5.4$], [$108.6 plus.minus 10.9$], [$10.7 plus.minus 1.0$], [$244.9 plus.minus 21.4$],
    table.hline(stroke: 0.3pt),
    [RNN Acuan], [$104.2 plus.minus 1.5$], [$bold(99.5 plus.minus 2.7)$], [$10.0 plus.minus 0.4$], [$bold(185.3 plus.minus 13.8)$],
    [RNN Terbaik], [$105.3 plus.minus 3.7$], [$99.7 plus.minus 3.3$], [$10.0 plus.minus 0.5$], [$184.1 plus.minus 9.5$],
    table.hline(stroke: 0.3pt),
    [LSTM Acuan], [$121.3 plus.minus 14.7$], [$119.8 plus.minus 19.2$], [$12.0 plus.minus 2.8$], [$309.6 plus.minus 55.3$],
    [LSTM Terbaik], [$113.7 plus.minus 12.5$], [$108.9 plus.minus 17.2$], [$10.6 plus.minus 2.4$], [$284.5 plus.minus 46.2$],
    table.hline(stroke: 0.3pt),
    [GRU Acuan], [$107.2 plus.minus 3.8$], [$108.4 plus.minus 8.9$], [$10.9 plus.minus 0.9$], [$217.4 plus.minus 28.3$],
    [GRU Terbaik], [$107.1 plus.minus 3.0$], [$105.6 plus.minus 7.7$], [$10.6 plus.minus 0.8$], [$231.8 plus.minus 28.0$],
    table.hline(),
  ),
) <tab:generalisasi_lokasi>

Hasil eksperimen menunjukkan bahwa urutan model terbaik di Parco Sempione *mengalami perubahan* dibanding Duomo. Di lokasi ini, RNN Acuan menjadi model paling optimal dengan Test MAE terkecil ($99.5 plus.minus 2.7$). 

Konfigurasi terbaik hasil optimasi Duomo tetap mampu mengungguli versi acuannya pada model ANN, LSTM, dan GRU di lokasi baru ini. Namun, seluruh model deep learning masih kalah saing terhadap model baseline "Naif: nilai terakhir" pada minggu Natal lokal yang mencatatkan eror MAE sebesar 77.6. Hal ini membuktikan bahwa konfigurasi terbaik yang ditala di satu lokasi padat (Duomo) tidak sepenuhnya adaptif terhadap karakteristik anomali lokal di area publik terbuka seperti Parco Sempione selama masa libur panjang.


= Pembahasan
Berdasarkan seluruh rangkaian eksperimen, _hyperparameter_ yang paling berpengaruh secara signifikan terhadap performa model adalah *learning rate* ($lr$) dan *panjang jendela* ($W$). Nilai $lr$ yang terlalu kecil ($0.0001$) menggagalkan konvergensi karena menyentuh batas maksimum epoch, sedangkan jendela $W$ yang terlalu panjang ($168$ jam) memicu pembengkakan parameter dan *overfitting* yang parah pada arsitektur non-sekuensial (ANN). 

Perbedaan hasil antar-arsitektur model terbukti jauh lebih besar dan menentukan dibandingkan variasi fluktuasi acak antar-_seed_, menegaskan bahwa pemilihan struktur fundamental jaringan (seperti penambahan gerbang rekuren pada LSTM/GRU) memegang peran krusial dalam keberhasilan ekstraksi fitur temporal. 

Keterbatasan utama dalam studi ablasi ini meliputi pemanfaatan basis data latih yang sangat terbatas ($672$ sampel train atau setara $4$ minggu) serta evaluasi yang berpusat pada satu kluster geografis kota. Hal ini menyebabkan konfigurasi terbaik yang telah ditala secara optimal di pusat kota padat (Duomo) mengalami penurunan adaptasi dan saturasi saat digeneralisasikan ke lokasi ruang publik terbuka dengan volume trafik rendah seperti Parco Sempione, terutama dalam mengantisipasi anomali mobilitas pada libur Natal.

= Kesimpulan
Studi ablasi ini berhasil mengevaluasi pengaruh variasi arsitektur dan _hyperparameter_ untuk prediksi trafik seluler di kota Milan. Model berbasis rekuren (RNN dan GRU) terbukti jauh lebih efisien dan unggul dalam mempertahankan memori urutan waktu harian dibandingkan arsitektur ANN konvensional. 

Optimasi parameter gabungan pada lokasi Duomo berhasil menempatkan GRU Terbaik sebagai model dengan akurasi paling optimal pada minggu normal dengan nilai Test MAE sebesar $233.8 plus.minus 15.7$. Namun, pengujian generalisasi spasial di Parco Sempione menunjukkan perubahan tren, di mana arsitektur RNN dasar justru meraih performa terbaik dengan eror Test MAE terkecil mencapai $99.5 plus.minus 2.7$. Nilai eror prediksi pada momen musiman khusus (Natal) melonjak hingga dua kali lipat pada seluruh model, membuktikan perlunya integrasi fitur eksternal musiman untuk meningkatkan ketahanan peramalan jangka panjang.

#heading(numbering: none)[Kontribusi Anggota]
#table(
  columns: (auto, 1fr),
  stroke: none,
  [Tyodonrau], [Menyusun bagian Pendahuluan, bab Metodologi (Dataset & Praproses), serta melakukan integrasi dan perapian teks pada template Typst.],
  [Adryan], [Menjalankan eksperimen kode, mengumpulkan data angka riil studi ablasi wajib (A1--A5), serta menulis draf analisis Hasil Ablasi Wajib.],
  [Joan], [Menjalankan eksperimen faktor pilihan (B4 & B6), menganalisis data Bagian C & D (Parco Sempione), serta menulis bab Pembahasan dan Kesimpulan.],
)


#heading(numbering: none)[Pernyataan Penggunaan AI]
Penulis menggunakan perangkat AI seperti ChatGPT dan Gemini untuk membantu memvalidasi struktur kode eksperimen serta memperbaiki tata bahasa laporan agar lebih rapi dan sistematis.

#heading(numbering: none)[Kode dan Data]
Kode, notebook beserta output, dan seluruh hasil run tersedia di #link("https://github.com/Bufel/dlw-tugas-rb-124400052").
