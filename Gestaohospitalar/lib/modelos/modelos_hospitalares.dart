enum BedStatus {
  disponivel,
  ocupado,
  limpeza,
}

class Bed {
  final String id;
  BedStatus status;

  Bed({
    required this.id,
    this.status = BedStatus.disponivel,
  });
}

class StockItem {
  String name;
  String category;
  int quantity;
  double price;

  StockItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });
}

class BillingItem {
  String material;
  int quantity;
  double unitPrice;

  BillingItem({
    required this.material,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class Patient {
  String name;
  String age;
  String cpf;
  String bedId;
  String insurance;
  String riskLevel;

  String observation;
  String medicalHistory;
  String evolution;
  String exams;
  String medication;

  String? doctorName;

  bool discharged;

  List<BillingItem> prescriptions;

  Patient({
    required this.name,
    required this.age,
    required this.cpf,
    required this.bedId,
    required this.insurance,
    required this.riskLevel,
    this.observation = "",
    this.medicalHistory = "",
    this.evolution = "",
    this.exams = "",
    this.medication = "",
    this.doctorName,
    this.discharged = false,
    List<BillingItem>? prescriptions,
  }) : prescriptions = prescriptions ?? [];
}

class Doctor {
  String name;
  String specialty;
  String crm;

  Doctor({
    required this.name,
    required this.specialty,
    required this.crm,
  });
}

class Insurance {
  String name;

  // 👇 padronizado para funcionar no seu sistema atual
  String planType;
  double consultationPrice;
  double discount;

  Insurance({
    required this.name,
    required this.planType,
    required this.consultationPrice,
    required this.discount,
  });
}