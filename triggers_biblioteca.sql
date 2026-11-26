-- Projeto: Sistema de Reserva de Livros da Biblioteca
-- Apêndice B - Regras de negócio (triggers MySQL)
-- Executar depois do script_biblioteca.sql.

USE biblioteca;

DELIMITER $$

CREATE TRIGGER trg_emprestimo_before_insert
BEFORE INSERT ON Emprestimo
FOR EACH ROW
BEGIN
    DECLARE v_abertos INT;
    DECLARE v_situacao VARCHAR(12);

    SELECT COUNT(*) INTO v_abertos
    FROM Emprestimo
    WHERE id_pessoa = NEW.id_pessoa
      AND data_devolucao IS NULL;

    IF v_abertos >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite de 3 emprestimos simultaneos atingido.';
    END IF;

    SELECT situacao INTO v_situacao
    FROM Exemplar
    WHERE id_livro = NEW.id_livro
      AND numero_exemplar = NEW.numero_exemplar
    FOR UPDATE;

    IF v_situacao IS NULL OR v_situacao <> 'DISPONIVEL' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exemplar inexistente ou indisponivel.';
    END IF;

    IF NEW.data_prevista_devolucao > DATE_ADD(NEW.data_retirada, INTERVAL 14 DAY) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo maximo de devolucao e de 14 dias.';
    END IF;

    UPDATE Exemplar
    SET situacao = 'EMPRESTADO'
    WHERE id_livro = NEW.id_livro
      AND numero_exemplar = NEW.numero_exemplar;
END$$

CREATE TRIGGER trg_emprestimo_devolucao
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE Exemplar
        SET situacao = 'DISPONIVEL'
        WHERE id_livro = NEW.id_livro
          AND numero_exemplar = NEW.numero_exemplar
          AND situacao = 'EMPRESTADO';
    END IF;
END$$

DELIMITER ;
