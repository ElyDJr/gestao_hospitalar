// lib/domain/services/arquivo_service.dart

class ArquivoService {
  // Listas de arquivados (dados de teste)
  final List<Map<String, dynamic>> _pacientesArquivados = [
    {'id': 1, 'nome': 'José da Silva', 'cpf': '123.456.789-00', 'rg': 'MG-1234567'},
    {'id': 2, 'nome': 'Maria Souza', 'cpf': '987.654.321-00', 'rg': 'MG-7654321'},
  ];

  final List<Map<String, dynamic>> _medicosArquivados = [
    {'id': 1, 'nome': 'Dr. Carlos Pereira', 'cpf': '111.222.333-44', 'rg': 'MG-1112223'},
  ];

  // Listas de ativos (para onde os itens voltam ao restaurar ou saem ao arquivar)
  final List<Map<String, dynamic>> _pacientesAtivos = [];
  final List<Map<String, dynamic>> _medicosAtivos = [];

  // ================= PACIENTES =================

  Future<List<Map<String, dynamic>>> listarPacientesArquivados() async {
    return List.of(_pacientesArquivados);
  }

  Future<void> arquivarPaciente(Map<String, dynamic> paciente) async {
    _pacientesAtivos.removeWhere((p) => p['id'] == paciente['id']);
    _pacientesArquivados.add(paciente);
  }

  Future<void> restaurarPaciente(int id) async {
    final index = _pacientesArquivados.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      final pacienteRestaurado = _pacientesArquivados.removeAt(index);
      _pacientesAtivos.add(pacienteRestaurado);
    }
  }

  // ================= MÉDICOS =================

  Future<List<Map<String, dynamic>>> listarMedicosArquivados() async {
    return List.of(_medicosArquivados);
  }

  Future<void> arquivarMedico(Map<String, dynamic> medico) async {
    _medicosAtivos.removeWhere((m) => m['id'] == medico['id']);
    _medicosArquivados.add(medico);
  }

  Future<void> restaurarMedico(int id) async {
    final index = _medicosArquivados.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      final medicoRestaurado = _medicosArquivados.removeAt(index);
      _medicosAtivos.add(medicoRestaurado);
    }
  }
}