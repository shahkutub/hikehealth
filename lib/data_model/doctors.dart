class Doctors {
  bool success;
  List<doctor> data;
  String msg;

  Doctors({this.success, this.data, this.msg});

  Doctors.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new doctor.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class doctor {
  int id;
  int status;
  String image;
  String name;
  int treatmentId;
  bool isFaviroute;
  String fullImage;
  Treatment treatment;

  doctor(
      {this.id,
        this.status,
        this.image,
        this.name,
        this.treatmentId,
        this.isFaviroute,
        this.fullImage,
        this.treatment});

  doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    image = json['image'];
    name = json['name'];
    treatmentId = json['treatment_id'];
    isFaviroute = json['is_faviroute'];
    fullImage = json['fullImage'];
    treatment = json['treatment'] != null
        ? new Treatment.fromJson(json['treatment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['image'] = this.image;
    data['name'] = this.name;
    data['treatment_id'] = this.treatmentId;
    data['is_faviroute'] = this.isFaviroute;
    data['fullImage'] = this.fullImage;
    if (this.treatment != null) {
      data['treatment'] = this.treatment.toJson();
    }
    return data;
  }
}

class Treatment {
  int id;
  String name;
  String fullImage;

  Treatment({this.id, this.name, this.fullImage});

  Treatment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
