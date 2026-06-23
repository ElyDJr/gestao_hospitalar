//scrip do meu banco

class Config {
  static const String sql = '''
-- SQLite armazena tudo em um arquivo de banco único, portanto "CREATE DATABASE" e "USE" não são utilizados aqui.

CREATE TABLE convenio(
    id_convenio INTEGER PRIMARY KEY AUTOINCREMENT,
    ativo INTEGER DEFAULT 1,
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
    ativo INTEGER DEFAULT 1,
    id_especialidade INTEGER NOT NULL,
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    crm TEXT UNIQUE NOT NULL,
    honorario REAL,
    FOREIGN KEY (id_especialidade) REFERENCES especialidade(id_especialidade)
);

CREATE TABLE escala_medica(
    id_escala INTEGER PRIMARY KEY AUTOINCREMENT,
    id_medico INTEGER NOT NULL,
    data_escala TEXT NOT NULL, -- Formato ISO: 'YYYY-MM-DD'
    hora_inicio TEXT NOT NULL, -- 'HH:MM'
    hora_fim TEXT NOT NULL,    -- 'HH:MM'
    is_plantao INTEGER DEFAULT 0 CHECK (is_plantao IN (0, 1)),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);


CREATE TABLE paciente(
    id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
    ativo INTEGER DEFAULT 1,
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
    nome_sala TEXT,
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
    id_sala INTEGER,
    risco_evasao TEXT NOT NULL,
    isolamento TEXT NOT NULL,
    evolucao TEXT,
    data_abertura TEXT DEFAULT CURRENT_TIMESTAMP,
    status_prontuario TEXT DEFAULT 'ATIVO' CHECK (status_prontuario IN ('ATIVO', 'ARQUIVADO')),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_triagem) REFERENCES triagem(id_triagem),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

CREATE TABLE ala (
  id_ala INTEGER PRIMARY KEY AUTOINCREMENT,
  nome_ala TEXT NOT NULL,
  andar TEXT NOT NULL
);

CREATE TABLE leito(
    id_leito INTEGER PRIMARY KEY AUTOINCREMENT,
    id_ala INTEGER NOT NULL,
    numero TEXT,
    data_higienizacao TEXT,
    situacao TEXT DEFAULT 'VAGO' CHECK (situacao IN ('VAGO', 'OCUPADO', 'HIGIENIZACAO'))
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

static const String mockData = '''
    
  INSERT INTO convenio (nome_convenio, tipo_leito, cobre_internacao, cobre_exames, cobre_cirurgia, limite_medicamento, percentual_cobertura) VALUES ('Unimed', 'PREMIUM', 1, 1, 1, 5000.0, 100.0);
  INSERT INTO convenio (nome_convenio, tipo_leito, cobre_internacao, cobre_exames, cobre_cirurgia, limite_medicamento, percentual_cobertura) VALUES ('SulAmérica', 'PRIVADO', 1, 1, 1, 3000.0, 90.0);
  INSERT INTO convenio (nome_convenio, tipo_leito, cobre_internacao, cobre_exames, cobre_cirurgia, limite_medicamento, percentual_cobertura) VALUES ('Bradesco Saúde', 'COMUM', 1, 1, 0, 2000.0, 80.0);
  INSERT INTO convenio (nome_convenio, tipo_leito, cobre_internacao, cobre_exames, cobre_cirurgia, limite_medicamento, percentual_cobertura) VALUES ('Amil', 'PRIVADO', 1, 1, 1, 4000.0, 95.0);
  INSERT INTO convenio (nome_convenio, tipo_leito, cobre_internacao, cobre_exames, cobre_cirurgia, limite_medicamento, percentual_cobertura) VALUES ('SUS', 'COMUM', 1, 1, 1, 0.0, 100.0);
    
  INSERT INTO especialidade (descricao_especialidade) VALUES ('Cardiologia');
  INSERT INTO especialidade (descricao_especialidade) VALUES ('Pediatria');
  INSERT INTO especialidade (descricao_especialidade) VALUES ('Clínica Geral');
  INSERT INTO especialidade (descricao_especialidade) VALUES ('Ortopedia');
  INSERT INTO especialidade (descricao_especialidade) VALUES ('Neurologia');

  INSERT INTO sala (nome, tipo, status) VALUES ('Sala 101', 'Consultorio', 'LIVRE');
  INSERT INTO sala (nome, tipo, status) VALUES ('Sala 102', 'Consultorio', 'OCUPADA');
  INSERT INTO sala (nome, tipo, status) VALUES ('Sala 103', 'Exames', 'LIVRE');
  INSERT INTO sala (nome, tipo, status) VALUES ('Sala 104', 'Cirurgia', 'MANUTENCAO');
  INSERT INTO sala (nome, tipo, status) VALUES ('Sala 105', 'Emergencia', 'LIVRE');

  INSERT INTO exame (nome, valor, descricao) VALUES ('Hemograma', 50.0, 'Exame de sangue'), ('Raio-X Torax', 150.0, 'Imagem');
  INSERT INTO exame (nome, valor, descricao) VALUES ('Eletrocardiograma', 200.0, 'Coracao'), ('Ultrassom', 300.0, 'Imagem'), ('Tomografia', 600.0, 'Imagem'); 
    
  INSERT INTO almoxarifado (nome, categoria, quantidade, valor_unitario) VALUES ('Dipirona 500mg', 'MEDICAMENTO', 100, 1.5), ('Luvas', 'EPI', 500, 0.5);
  INSERT INTO almoxarifado (nome, categoria, quantidade, valor_unitario) VALUES ('Seringa 10ml', 'DESCARTAVEL', 200, 0.8), ('Detergente', 'LIMPEZA', 20, 10.0), ('Gaze', 'INSUMO', 300, 0.3);  
  
  INSERT INTO ala (nome_ala, andar) VALUES ('Pronto Socorro', 'Terreo');
  INSERT INTO ala (nome_ala, andar) VALUES ('Consultorio 01', 'Terreo');
  INSERT INTO ala (nome_ala, andar) VALUES ('Consultorio 02', 'Térreo');
  INSERT INTO ala (nome_ala, andar) VALUES ('Consultorio 03', 'Terreo');
  INSERT INTO ala (nome_ala, andar) VALUES ('UTI', '1º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Iternação Comum', '1º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Cardiologia', '2º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Centro Cirurgico', '2º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Ortopedia', '2º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Maternidade', '3º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Pediatria', '3º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('UTI Neonatal', '3º Andar');
  INSERT INTO ala (nome_ala, andar) VALUES ('Iternação Premium', '4º Andar');

  -- TÉRREO (Alas 1 a 4)
-- Pronto Socorro (id_ala 1)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (1, '001', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (1, '002', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (1, '003', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (1, '004', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (1, '005', NULL, 'VAGO');

-- Consultorio 01 (id_ala 2)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (2, '006', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (2, '007', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (2, '008', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (2, '009', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (2, '010', NULL, 'VAGO');

-- Consultorio 02 (id_ala 3)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (3, '011', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (3, '012', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (3, '013', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (3, '014', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (3, '015', NULL, 'VAGO');

-- Consultorio 03 (id_ala 4)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (4, '016', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (4, '017', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (4, '018', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (4, '019', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (4, '020', NULL, 'VAGO');

-- 1º ANDAR (Alas 5 e 6)
-- UTI (id_ala 5)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (5, '101', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (5, '102', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (5, '103', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (5, '104', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (5, '105', NULL, 'VAGO');

-- Iternação Comum (id_ala 6)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (6, '106', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (6, '107', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (6, '108', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (6, '109', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (6, '110', NULL, 'VAGO');

-- 2º ANDAR (Alas 7 a 9)
-- Cardiologia (id_ala 7)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (7, '201', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (7, '202', NULL, 'HIGIENIZACAO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (7, '203', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (7, '204', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (7, '205', NULL, 'VAGO');

-- Centro Cirurgico (id_ala 8)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (8, '206', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (8, '207', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (8, '208', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (8, '209', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (8, '210', NULL, 'VAGO');

-- Ortopedia (id_ala 9)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (9, '211', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (9, '212', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (9, '213', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (9, '214', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (9, '215', NULL, 'VAGO');

-- 3º ANDAR (Alas 10 a 12)
-- Maternidade (id_ala 10)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (10, '301', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (10, '302', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (10, '303', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (10, '304', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (10, '305', NULL, 'VAGO');

-- Pediatria (id_ala 11)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (11, '306', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (11, '307', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (11, '308', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (11, '309', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (11, '310', NULL, 'VAGO');
-- UTI Neonatal (id_ala 12)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (12, '311', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (12, '312', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (12, '313', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (12, '314', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (12, '315', NULL, 'VAGO');

-- 4º ANDAR (Ala 13)
-- Iternação Premium (id_ala 13)
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (13, '401', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (13, '402', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (13, '403', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (13, '404', NULL, 'VAGO');
INSERT INTO leito (id_ala, numero, data_higienizacao, situacao) VALUES (13, '405', NULL, 'VAGO');

  INSERT INTO medico (id_especialidade, nome, crm, honorario) VALUES (1, 'Dr. Roberto Santos', 'CRM12345', 500.0);
  INSERT INTO medico (id_especialidade, nome, crm, honorario) VALUES (2, 'Dra. Maria Silva', 'CRM23456', 450.0);
  INSERT INTO medico (id_especialidade, nome, crm, honorario) VALUES (3, 'Dr. Carlos Souza', 'CRM34567', 400.0);
  INSERT INTO medico (id_especialidade, nome, crm, honorario) VALUES (4, 'Dra. Ana Pereira', 'CRM45678', 550.0);
  INSERT INTO medico (id_especialidade, nome, crm, honorario) VALUES (5, 'Dr. Jorge Lima', 'CRM56789', 600.0);
    
  INSERT INTO paciente (nome, cpf, sexo, nascimento, alergias, tipo_sanguineo) VALUES ('João da Silva', '11111111111', 'MASCULINO', '1985-05-15', 'Nenhuma', 'O+');
  INSERT INTO paciente (nome, cpf, sexo, nascimento, alergias, tipo_sanguineo) VALUES ('Maria Oliveira', '22222222222', 'FEMININO', '1990-08-20', 'Penicilina', 'A+');
  INSERT INTO paciente (nome, cpf, sexo, nascimento, alergias, tipo_sanguineo) VALUES ('Pedro Santos', '33333333333', 'MASCULINO', '1970-01-10', 'Nenhuma', 'B-');
  INSERT INTO paciente (nome, cpf, sexo, nascimento, alergias, tipo_sanguineo) VALUES ('Ana Costa', '44444444444', 'FEMININO', '2005-12-05', 'Nenhuma', 'AB+');
  INSERT INTO paciente (nome, cpf, sexo, nascimento, alergias, tipo_sanguineo) VALUES ('Lucas Rocha', '55555555555', 'MASCULINO', '1995-03-22', 'Iodo', 'O-');

  INSERT INTO paciente_convenio (id_paciente, id_convenio, numero_carteira, validade) VALUES (1, 1, 'UN123456', '2026-12-31');
  INSERT INTO paciente_convenio (id_paciente, id_convenio, numero_carteira, validade) VALUES (2, 2, 'SL987654', '2025-06-30');
  INSERT INTO paciente_convenio (id_paciente, id_convenio, numero_carteira, validade) VALUES (3, 3, 'BR112233', '2027-01-01');
  INSERT INTO paciente_convenio (id_paciente, id_convenio, numero_carteira, validade) VALUES (4, 4, 'AM445566', '2025-10-15');
  INSERT INTO paciente_convenio (id_paciente, id_convenio, numero_carteira, validade) VALUES (5, 5, 'SUS00000', '2099-12-31');
    
  INSERT INTO triagem (id_paciente, risco, queixa, internacao) VALUES (1, 'VERDE', 'Dor de cabeça', 'NAO');

  INSERT INTO agendamento (id_paciente, id_medico, id_sala, data_hora, status) VALUES (1, 1, 1, '2026-06-07 09:00', 'AGENDADO');
  INSERT INTO agendamento (id_paciente, id_medico, id_sala, data_hora, status) VALUES (2, 2, 2, '2026-06-07 10:00', 'CONFIRMADO');
  INSERT INTO agendamento (id_paciente, id_medico, id_sala, data_hora, status) VALUES (3, 3, 5, '2026-06-07 11:00', 'CONFIRMADO');
  INSERT INTO agendamento (id_paciente, id_medico, id_sala, data_hora, status) VALUES (4, 4, 3, '2026-06-07 14:00', 'AGENDADO');
  INSERT INTO agendamento (id_paciente, id_medico, id_sala, data_hora, status) VALUES (5, 5, 1, '2026-06-07 15:00', 'AGENDADO');  

  INSERT INTO medicamento (id_almoxarifado, principio_ativo) VALUES (1, 'Dipirona');

  -- ==========================================
  -- 1. ESCALAS MÉDICAS (Junho de 2026)
  -- ==========================================
  
  -- Plantões Diários (Fechando de 15/06 a 30/06) - Médico ID 3 assumindo a maioria
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (3, '2026-06-15', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (1, '2026-06-16', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (2, '2026-06-17', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (4, '2026-06-18', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (3, '2026-06-19', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (1, '2026-06-20', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (2, '2026-06-21', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (3, '2026-06-22', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (4, '2026-06-23', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (1, '2026-06-24', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (2, '2026-06-25', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (3, '2026-06-26', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (3, '2026-06-27', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (1, '2026-06-28', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (2, '2026-06-29', '00:00', '23:59', 1);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (5, '2026-06-30', '00:00', '23:59', 1);

  -- Expedientes Regulares (Consultas) para agendamentos futuros
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (2, '2026-06-16', '08:00', '18:00', 0);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (5, '2026-06-17', '13:00', '19:00', 0);
  INSERT INTO escala_medica (id_medico, data_escala, hora_inicio, hora_fim, is_plantao) VALUES (1, '2026-06-18', '08:00', '12:00', 0);
  ''';
}
