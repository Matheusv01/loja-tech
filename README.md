# Stored Procedures no MySQL - TechStore (`loja_tech`)

Resolução da atividade prática sobre desenvolvimento de **Stored Procedures** no MySQL. O projeto simula rotinas de negócio, validações e relatórios gerenciais para o banco de dados de um e-commerce de tecnologia fictício chamado **TechStore**.

---

## Estrutura do Projeto

* **`01_banco_e_dados.sql`**: Script DDL e DML contendo a criação do banco de dados `loja_tech`, suas 6 tabelas relacionais e a carga de dados iniciais para testes.
* **`02_procedures_e_testes.sql`**: Script contendo a criação das Stored Procedures (`atualizar_preco_categoria` e `consultar_extrato_cliente`) e os comandos `CALL` para validação de todos os cenários.

---

## Estrutura do Banco de Dados

O banco de dados `loja_tech` é composto pelas seguintes tabelas:

* **`categorias`**: Agrupamento dos produtos (Notebooks, Smartphones, Periféricos, Monitores e Armazenamento).
* **`produtos`**: Catálogo de itens com controle de preço, estoque atual e estoque mínimo.
* **`clientes`**: Dados cadastrais dos clientes da loja.
* **`pedidos`**: Registro dos pedidos realizados e seus respectivos status (`pendente`, `processando`, `enviado`, `entregue`, `cancelado`).
* **`itens_pedido`**: Detalhamento dos produtos, quantidades, preços unitários e subtotais calculados de cada pedido.
* **`log_operacoes`**: Tabela de auditoria para rastrear alterações críticas realizadas via procedures.

---

## Funcionalidades Implementadas

### 1. `atualizar_preco_categoria`
Procedimento armazenado responsável por aplicar reajustes percentuais (aumentos ou descontos) em lote para todos os produtos ativos de uma categoria específica.

* **Parâmetros de Entrada (`IN`)**:
  * `p_id_categoria` (`INT`): Identificador da categoria.
  * `p_percentual` (`DECIMAL(5,2)`): Percentual de ajuste (valores positivos aplicam aumento; negativos aplicam desconto).
* **Parâmetros de Saída (`OUT`)**:
  * `p_qtd_alterados` (`INT`): Quantidade de produtos que tiveram o preço atualizado.
  * `p_mensagem` (`VARCHAR(255)`): Feedback de sucesso ou descrição do erro de validação.
* **Regras de Negócio e Validações**:
  * Verifica se a categoria existe e está ativa.
  * Impede descontos superiores a **50%** (`< -50%`).
  * Impede aumentos superiores a **100%** (`> 100%`).
  * Trata o envio de percentual igual a **0%** sem realizar alterações desnecessárias.
  * Registra automaticamente a operação e o total de itens afetados na tabela `log_operacoes`.

### 2. `consultar_extrato_cliente`
Procedimento armazenado que gera um extrato consolidado com o perfil, histórico de compras e métricas financeiras de um cliente.

* **Parâmetro de Entrada (`IN`)**:
  * `p_id_cliente` (`INT`): Identificador do cliente.
* **Retorno (Múltiplos Result Sets)**:
  * **Result Set 1 (Dados Cadastrais)**: Nome, e-mail, telefone e data de cadastro.
  * **Result Set 2 (Histórico de Pedidos)**: Número do pedido, data, status e valor total ordenados do mais recente para o mais antigo.
  * **Result Set 3 (Resumo Financeiro)**: Total de pedidos válidos, valor total gasto, ticket médio e data do último pedido (desconsiderando pedidos cancelados).
  * *Tratamento de Erro*: Caso o `id_cliente` não exista, retorna uma mensagem de erro via `SELECT` (sem lançar exceção com `SIGNAL`).

---

## Como Executar

1. **Pré-requisitos**: Ter o **MySQL Server 8.0+** instalado (junto ao MySQL Workbench, DBeaver ou cliente CLI).
2. **Criação do Ambiente**: Abra e execute todo o conteúdo do arquivo `01_banco_e_dados.sql`.
3. **Criação das Procedures e Testes**: Abra e execute todo o conteúdo do arquivo `02_procedures_e_testes.sql`.

### Exemplos de Chamada

```sql
-- Reajuste de 10% na categoria 1 (Notebooks)
CALL atualizar_preco_categoria(1, 10.00, @qtd, @msg);
SELECT @qtd AS alterados, @msg AS mensagem;

-- Consulta do extrato completo da cliente ID 1 (Ana Silva)
CALL consultar_extrato_cliente(1);
