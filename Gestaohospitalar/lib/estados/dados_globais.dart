import '../modelos/modelos_hospitalares.dart';

class DadosGlobais {

  static List<Bed> leitos = List.generate(
    15,
    (i) => Bed(id: 'L-${i + 100}'),
  );

  static List<StockItem> estoque = [

    StockItem(
      name: 'Seringas 5ml',
      category: 'Médico',
      quantity: 500,
      price: 1.50,
    ),

    StockItem(
      name: 'Detergente Hospitalar',
      category: 'Limpeza',
      quantity: 30,
      price: 12.90,
    ),

    StockItem(
      name: 'Máscara N95',
      category: 'EPI',
      quantity: 150,
      price: 5.50,
    ),
  ];

  static List<Patient> pacientes = [

    Patient(

      name: "João da Silva",

      age: "40",

      cpf: "123.456.789-00",

      bedId: "L-101",

      insurance: "Unimed",

      riskLevel: "Urgência",

      observation: "Paciente com dores no peito.",

      medicalHistory: "Hipertensão.",
    ),
  ];

  static List<Doctor> medicos = [];

  static List<Insurance> convenios = [];
}
class SessaoUsuario {
  static String? usuario;
  static String? perfil; // admin | medico | enfermagem
}