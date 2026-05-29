//scrip do meu banco

class Config {
  static const String sql = '''

//meu banco aqui
-- SQLite armazena tudo em um arquivo de banco único, portanto "CREATE DATABASE" e "USE" não são utilizados aqui.

CREATE TABLE convenio(
    id_convenio INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_convenio TEXT UNIQUE,
    tipo_leito TEXT CHECK (tipo_leito IN ('COMUM', 'PRIVADO', 'PREMIUM')),
    cobre_internacao INTEGER DEFAULT 1 CHECK (cobre_internacao IN (0, 1)),
    cobre_exames INTEGER DEFAULT 1 CHECK (cobre_exames IN (0, 1)),
    cobre_cirurgia INTEGER DEFAULT 1 CHECK (cobre_cirurgia IN (0, 1)),
    limite_medicamento REAL, 
    percentual_cobertura REAL
);

CREATE TABLE especialidade (
    id_especialidade INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao_especialidade TEXT NOT NULL
);

CREATE TABLE medico(
    id_medico INTEGER PRIMARY KEY AUTOINCREMENT,
    id_especialidade INTEGER NOT NULL,
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    crm TEXT UNIQUE NOT NULL,
    honorario REAL,
    FOREIGN KEY (id_especialidade) REFERENCES especialidade(id_especialidade)
);

CREATE TABLE paciente(
    id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    cpf TEXT UNIQUE CHECK (length(cpf) = 11),
    sexo TEXT CHECK (sexo IN ('MASCULINO', 'FEMININO', 'OUTRO')),
    nascimento TEXT, -- Datas no SQLite são recomendadas como TEXT no formato ISO8601 (YYYY-MM-DD)
    alergias TEXT,
    tipo_sanguineo TEXT,
    historico_clinico TEXT,
    telefone TEXT,
    rua TEXT,
    numero_casa INTEGER,
    bairro TEXT,
    cidade TEXT,
    estado TEXT,
    cep TEXT CHECK (length(cep) = 8),
    nome_responsavel TEXT
);

CREATE TABLE paciente_convenio (
    id_paciente_convenio INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER NOT NULL,
    id_convenio INTEGER NOT NULL,
    numero_carteira TEXT,
    validade TEXT NOT NULL,
    ativo INTEGER DEFAULT 1 CHECK (ativo IN (0, 1)),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_convenio) REFERENCES convenio(id_convenio)
);

CREATE TABLE sala (
    id_sala INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    tipo TEXT,
    status TEXT CHECK (status IN ('LIVRE', 'OCUPADA', 'MANUTENCAO'))
);

CREATE TABLE agendamento (
    id_agendamento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER,
    id_medico INTEGER,
    id_sala INTEGER,
    data_hora TEXT,
    status TEXT DEFAULT 'AGENDADO' CHECK (status IN ('AGENDADO', 'CONFIRMADO', 'CANCELADO', 'FINALIZADO')),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala)
);

CREATE TABLE triagem(
    id_triagem INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER NOT NULL,
    responsavel_triagem TEXT,
    pressao TEXT,
    temperatura REAL,
    frequencia_cardiaca INTEGER,
    saturacao INTEGER,
    escala_dor INTEGER,
    risco TEXT CHECK (risco IN ('VERMELHO', 'LARANJA', 'AMARELO', 'VERDE', 'AZUL')),
    queixa TEXT,
    alergias TEXT,
    observacoes TEXT,
    internacao TEXT CHECK (internacao IN ('SIM', 'NAO')),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
);

CREATE TABLE prontuario(
    id_prontuario INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER NOT NULL,
    id_triagem INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    risco_evasao TEXT NOT NULL,
    isolamento TEXT NOT NULL,
    evolucao TEXT,
    data_abertura TEXT DEFAULT CURRENT_TIMESTAMP,
    status_prontuario TEXT DEFAULT 'ATIVO' CHECK (status_prontuario IN ('ATIVO', 'ARQUIVADO')),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_triagem) REFERENCES triagem(id_triagem),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

CREATE TABLE leito(
    id_leito INTEGER PRIMARY KEY AUTOINCREMENT,
    numero TEXT,
    ala TEXT,
    data_higienizacao TEXT,
    situacao TEXT CHECK (situacao IN ('VAGO', 'OCUPADO', 'HIGIENIZACAO'))
);

CREATE TABLE internacao(
    id_internacao INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prontuario INTEGER NOT NULL,
    id_leito INTEGER NOT NULL,
    data_entrada TEXT DEFAULT CURRENT_TIMESTAMP,
    data_alta TEXT,
    isolamento TEXT CHECK (isolamento IN ('SIM', 'NAO')),
    status_internacao TEXT DEFAULT 'ATIVA' CHECK (status_internacao IN ('ATIVA', 'ALTA', 'TRANSFERIDO')),
    FOREIGN KEY (id_prontuario) REFERENCES prontuario(id_prontuario),
    FOREIGN KEY (id_leito) REFERENCES leito(id_leito)
);

CREATE TABLE almoxarifado(
    id_almoxarifado INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    categoria TEXT NOT NULL CHECK (categoria IN ('MEDICAMENTO', 'DESCARTAVEL', 'LIMPEZA', 'EPI', 'INSUMO')),
    descricao TEXT,
    quantidade INTEGER NOT NULL DEFAULT 0,
    unidade TEXT,
    valor_unitario REAL NOT NULL,
    estoque_minimo INTEGER DEFAULT 0,
    lote TEXT,
    validade TEXT
);

CREATE TABLE medicamento(
    id_medicamento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_almoxarifado INTEGER NOT NULL,
    principio_ativo TEXT,
    contraindicacoes TEXT,
    FOREIGN KEY (id_almoxarifado) REFERENCES almoxarifado(id_almoxarifado)
);

CREATE TABLE interacao_medicamentosa(
    id_interacao INTEGER PRIMARY KEY AUTOINCREMENT,
    id_medicamento_1 INTEGER NOT NULL,
    id_medicamento_2 INTEGER NOT NULL,
    gravidade TEXT CHECK (gravidade IN ('LEVE', 'MODERADA', 'GRAVE')),
    descricao TEXT,
    FOREIGN KEY (id_medicamento_1) REFERENCES medicamento(id_medicamento),
    FOREIGN KEY (id_medicamento_2) REFERENCES medicamento(id_medicamento)
);

CREATE TABLE prescricao(
    id_prescricao INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prontuario INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    id_medicamento INTEGER NOT NULL,
    dosagem TEXT,
    aplicacao TEXT,
    horario TEXT NOT NULL,
    observacao TEXT,
    FOREIGN KEY (id_prontuario) REFERENCES prontuario(id_prontuario),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

CREATE TABLE consumo_item (
    id_consumo INTEGER PRIMARY KEY AUTOINCREMENT,
    id_internacao INTEGER NOT NULL,
    id_almoxarifado INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    data_consumo TEXT DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT,
    FOREIGN KEY (id_internacao) REFERENCES internacao(id_internacao),
    FOREIGN KEY (id_almoxarifado) REFERENCES almoxarifado(id_almoxarifado)
);

CREATE TABLE exame(
    id_exame INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    valor REAL,
    descricao TEXT
);

CREATE TABLE solicitacao_exame(
    id_solicitacao INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prontuario INTEGER NOT NULL,
    id_exame INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    data_solicitacao TEXT DEFAULT CURRENT_TIMESTAMP,
    status_exame TEXT DEFAULT 'SOLICITADO' CHECK (status_exame IN ('SOLICITADO', 'EM ANDAMENTO', 'CONCLUIDO')),
    resultado TEXT,
    FOREIGN KEY (id_prontuario) REFERENCES prontuario(id_prontuario),
    FOREIGN KEY (id_exame) REFERENCES exame(id_exame),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

CREATE TABLE faturamento(
    id_faturamento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_internacao INTEGER NOT NULL,
    valor_medicamentos REAL DEFAULT 0,
    valor_exames REAL DEFAULT 0,
    valor_internacao REAL DEFAULT 0,
    valor_honorarios REAL DEFAULT 0,
    valor_consumo REAL DEFAULT 0,
    valor_total REAL,
    status_pagamento TEXT DEFAULT 'PENDENTE' CHECK (status_pagamento IN ('PENDENTE', 'PAGO')),
    data_fechamento TEXT DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT,
    FOREIGN KEY (id_internacao) REFERENCES internacao(id_internacao)
);

CREATE TABLE auditoria (
    id_auditoria INTEGER PRIMARY KEY AUTOINCREMENT,
    id_faturamento INTEGER,
    auditor TEXT,
    data_auditoria TEXT,
    status_auditoria TEXT DEFAULT 'PENDENTE' CHECK (status_auditoria IN ('PENDENTE', 'APROVADO', 'REPROVADO')),
    observacoes TEXT,
    conformidade INTEGER CHECK (conformidade IN (0, 1)),
    FOREIGN KEY (id_faturamento) REFERENCES faturamento(id_faturamento)
);

CREATE TABLE log_prontuario(
    id_log INTEGER PRIMARY KEY AUTOINCREMENT,
    id_prontuario INTEGER NOT NULL,
    responsavel TEXT,
    data_alteracao TEXT DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT,
    FOREIGN KEY (id_prontuario) REFERENCES prontuario(id_prontuario)
);
''';
}
