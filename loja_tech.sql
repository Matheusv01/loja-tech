-- Teste 1: Cliente inexistente (deve retornar apenas 1 aba com a mensagem de erro)
CALL consultar_extrato_cliente(999);

-- Teste 2: Cliente válido - Ana Silva (deve abrir 3 abas de resultados no Workbench)
CALL consultar_extrato_cliente(1);