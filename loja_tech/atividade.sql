USE loja_tech;

DROP PROCEDURE IF EXISTS atualizar_preco_categoria;

DELIMITER //

CREATE PROCEDURE atualizar_preco_categoria(
    IN p_id_categoria INT,
    IN p_percentual DECIMAL(5,2),
    OUT p_qtd_alterados INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_categoria_existe INT DEFAULT 0;
    DECLARE v_nome_categoria VARCHAR(100);

    SELECT COUNT(*), MAX(nome)
    INTO v_categoria_existe, v_nome_categoria
    FROM categorias
    WHERE id_categoria = p_id_categoria AND ativo = TRUE;

    IF v_categoria_existe = 0 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: Categoria não encontrada ou inativa.';
    ELSEIF p_percentual = 0 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'AVISO: Percentual informado é 0%. Nenhum preço foi alterado.';
    ELSEIF p_percentual < -50.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O desconto máximo permitido é de 50%.';
    ELSEIF p_percentual > 100.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O aumento máximo permitido é de 100%.';
    ELSE
        UPDATE produtos
        SET preco = preco + (preco * p_percentual / 100)
        WHERE id_categoria = p_id_categoria AND ativo = TRUE;

        SET p_qtd_alterados = ROW_COUNT();

        INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
        VALUES (
            'produtos',
            'UPDATE',
            CONCAT('Reajuste de ', p_percentual, '% na categoria "', v_nome_categoria, '" (ID: ', p_id_categoria, '). Produtos afetados: ', p_qtd_alterados)
        );

        SET p_mensagem = CONCAT('Sucesso! ', p_qtd_alterados, ' produto(s) atualizado(s) na categoria ', v_nome_categoria, '.');
    END IF;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS consultar_extrato_cliente;

DELIMITER //

CREATE PROCEDURE consultar_extrato_cliente(
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_cliente_existe INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_cliente_existe
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF v_cliente_existe = 0 THEN
        SELECT 'ERRO: Cliente não encontrado.' AS mensagem;
    ELSE
        SELECT 
            nome,
            email,
            telefone,
            criado_em AS data_cadastro
        FROM clientes
        WHERE id_cliente = p_id_cliente;

        SELECT 
            id_pedido AS numero_pedido,
            data_pedido,
            status,
            valor_total
        FROM pedidos
        WHERE id_cliente = p_id_cliente
        ORDER BY data_pedido DESC;

        SELECT 
            COUNT(id_pedido) AS total_pedidos,
            IFNULL(SUM(valor_total), 0.00) AS valor_total_gasto,
            IFNULL(ROUND(AVG(valor_total), 2), 0.00) AS ticket_medio,
            MAX(data_pedido) AS ultimo_pedido
        FROM pedidos
        WHERE id_cliente = p_id_cliente
          AND status <> 'cancelado';
    END IF;
END //

DELIMITER ;

CALL atualizar_preco_categoria(99, 10.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

CALL atualizar_preco_categoria(1, -60.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

CALL atualizar_preco_categoria(1, 150.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

CALL atualizar_preco_categoria(1, 0.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

CALL atualizar_preco_categoria(1, 10.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

SELECT * FROM log_operacoes;

CALL consultar_extrato_cliente(999);
CALL consultar_extrato_cliente(1);