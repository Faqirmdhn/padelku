class Pelanggan {
  String? id;
  String nama;
  String noHp;

  Pelanggan({this.id, required this.nama, required this.noHp});

  factory Pelanggan.fromJson(Map<String, dynamic> json) => Pelanggan(
        id: json['id']?.toString(),
        nama: json['nama']?.toString() ?? '',
        noHp: json['no_hp']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'nama': nama, 'no_hp': noHp};
}
