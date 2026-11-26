-- Projeto: Sistema de Reserva de Livros da Biblioteca
-- Apêndice A - Script DDL (MySQL)
-- Fonte: documentação acadêmica do projeto

CREATE DATABASE IF NOT EXISTS biblioteca
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE biblioteca;

CREATE TABLE Pessoa (
    id_pessoa INT AUTO_INCREMENT,
    primeiro_nome VARCHAR(60) NOT NULL,
    sobrenome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    PRIMARY KEY (id_pessoa)
);

CREATE TABLE Telefone_Pessoa (
    id_pessoa INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_pessoa, telefone),
    CONSTRAINT fk_telefone_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Carteirinha (
    numero_carteirinha VARCHAR(20) NOT NULL,
    id_pessoa INT NOT NULL,
    data_emissao DATE NOT NULL DEFAULT (CURRENT_DATE),
    validade DATE NOT NULL,
    PRIMARY KEY (numero_carteirinha),
    CONSTRAINT fk_carteirinha_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_validade_carteirinha CHECK (validade > data_emissao)
);

CREATE TABLE Aluno (
    id_pessoa INT NOT NULL,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    turma VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Professor (
    id_pessoa INT NOT NULL,
    registro_funcional VARCHAR(20) NOT NULL UNIQUE,
    PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_professor_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Disciplina_Professor (
    id_pessoa INT NOT NULL,
    disciplina VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_pessoa, disciplina),
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_pessoa)
        REFERENCES Professor(id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Livro (
    id_livro INT AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    editora VARCHAR(100) NOT NULL,
    categoria VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_livro)
);

CREATE TABLE Livro_Autor (
    id_livro INT NOT NULL,
    autor VARCHAR(120) NOT NULL,
    PRIMARY KEY (id_livro, autor),
    CONSTRAINT fk_livro_autor FOREIGN KEY (id_livro)
        REFERENCES Livro(id_livro) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Exemplar (
    id_livro INT NOT NULL,
    numero_exemplar INT NOT NULL,
    estado_conservacao VARCHAR(10) NOT NULL DEFAULT 'BOM',
    situacao VARCHAR(12) NOT NULL DEFAULT 'DISPONIVEL',
    PRIMARY KEY (id_livro, numero_exemplar),
    CONSTRAINT fk_exemplar_livro FOREIGN KEY (id_livro)
        REFERENCES Livro(id_livro) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_num_exemplar CHECK (numero_exemplar > 0),
    CONSTRAINT chk_estado_conservacao CHECK (
        estado_conservacao IN ('NOVO', 'BOM', 'REGULAR', 'RUIM')
    ),
    CONSTRAINT chk_situacao_exemplar CHECK (
        situacao IN ('DISPONIVEL', 'EMPRESTADO', 'RESERVADO', 'PERDIDO', 'FURTADO')
    )
);

CREATE TABLE Funcionario (
    id_funcionario INT AUTO_INCREMENT,
    nome VARCHAR(160) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_funcionario)
);

CREATE TABLE Emprestimo (
    id_emprestimo INT AUTO_INCREMENT,
    id_pessoa INT NOT NULL,
    id_livro INT NOT NULL,
    numero_exemplar INT NOT NULL,
    id_funcionario INT NOT NULL,
    data_retirada DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao DATE NULL,
    PRIMARY KEY (id_emprestimo),
    CONSTRAINT fk_emprestimo_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_exemplar FOREIGN KEY (id_livro, numero_exemplar)
        REFERENCES Exemplar(id_livro, numero_exemplar) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES Funcionario(id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_prevista_devolucao CHECK (
        data_prevista_devolucao >= data_retirada
    ),
    CONSTRAINT chk_data_devolucao CHECK (
        data_devolucao IS NULL OR data_devolucao >= data_retirada
    )
);

CREATE TABLE Reserva (
    id_reserva INT AUTO_INCREMENT,
    id_pessoa INT NOT NULL,
    id_livro INT NOT NULL,
    data_solicitacao DATE NOT NULL DEFAULT (CURRENT_DATE),
    situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVA',
    PRIMARY KEY (id_reserva),
    CONSTRAINT fk_reserva_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES Pessoa(id_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_livro FOREIGN KEY (id_livro)
        REFERENCES Livro(id_livro) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_situacao_reserva CHECK (
        situacao IN ('ATIVA', 'ATENDIDA', 'CANCELADA')
    )
);

CREATE INDEX ix_carteirinha_pessoa ON Carteirinha (id_pessoa);
CREATE INDEX ix_livro_titulo ON Livro (titulo);
CREATE INDEX ix_livro_categoria ON Livro (categoria);
CREATE INDEX ix_exemplar_situacao ON Exemplar (id_livro, situacao);
CREATE INDEX ix_emprestimo_pessoa ON Emprestimo (id_pessoa, data_devolucao);
CREATE INDEX ix_emprestimo_exemplar ON Emprestimo (id_livro, numero_exemplar);
CREATE INDEX ix_emprestimo_prazo ON Emprestimo (data_prevista_devolucao, data_devolucao);
CREATE INDEX ix_reserva_fila ON Reserva (id_livro, situacao, data_solicitacao);

SHOW TABLES;
