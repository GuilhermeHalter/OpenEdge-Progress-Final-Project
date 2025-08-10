# Trabalho Final Progress OpenEdge - Hamburgueria XTudo

## 1. Sobre o Projeto

### Descriçao do Projeto
Este projeto tem como objetivo o desenvolvimento de um sistema de gestão para uma hamburgueria, utilizando a linguagem Progress 4GL (OpenEdge). O sistema visa facilitar e organizar o gerenciamento de cadastros essenciais ao negócio, como cidades, clientes, produtos, pedidos e itens dos pedidos.

A aplicação oferece uma interface simples e funcional, com foco na integridade dos dados e validação de informações. Todas as operações de cadastro, alteração e exclusão seguem regras de negócio bem definidas para evitar inconsistências no banco de dados.


## Explicação de como o sistema funciona

O Projeto é composto por 5 Telas.
  - MENU 
  - CIDADES
  - CLIENTES
  - PRODUTOS
  - PEDIDOS

**1. Tela de Menu** <br>
A Tela de Menu é a interface inicial do sistema.
Principais funcionalidades:

- Navegar entre os módulos Cidades, Clientes, Produtos e Pedidos.
- Acessar as rotinas de geração de relatórios de Clientes e Pedidos.

![Menu](media/MenuXtudo.png)

**2. Tela de Cidades** <br>
A Tela de Cidades é utilizada para o gerenciamento das informações de localidades.
Principais funcionalidades:

- Cadastro, edição e exclusão de registros de cidades.
- Associação de cidades aos cadastros de Clientes.

![Cidades](media/CidadesXtudo.png)

**3. Tela de Clientes** <br>
A Tela de Clientes centraliza as operações de cadastro e manutenção de clientes.
Principais funcionalidades:

- Inserção, alteração e exclusão de clientes.
- Associação de endereços e cidades ao cliente.

![Clientes](media/ClientesXtudo.png)

**4. Tela de Produtos** <br>
A Tela de Produtos é responsável pela gestão do catálogo de produtos.
Principais funcionalidades:

- Cadastro e atualização de informações de produtos.
- Definição de preços e códigos de identificação.

![Produtos](media/ProdutosXtudo.png)

**5. Tela de Pedidos** <br>
A Tela de Pedidos permite o registro e gerenciamento de pedidos de clientes.
Principais funcionalidades:

- Inclusão de pedidos vinculados a clientes e produtos.
- Cálculo automático de valores totais.
- Consulta e impressão de pedidos registrados.

![Pedidos](media/PedidosXtudo.png)

## 2. Execução e Estrutura
[2.1 Pré-requisitos para Execução do Projeto](###2.1-Pré-requisitos-para-Execução-do-Projeto)
### 2.1 Pré-requisitos para Execução do Projeto
Para executar corretamente o projeto em sua máquina local, é necessário que os seguintes componentes estejam previamente instalados:<br>
- [JAVA Development Kit - JDK 20.0.2](https://jdk.java.net/archive/)
- [Progress OpenEdge (4GL)](https://www.progress.com/oedk)

Certifique-se de que ambas as ferramentas estejam devidamente configuradas nas variáveis de ambiente do sistema operacional.

### 2.2 Instalando Projeto
**Instalando Projeto via `.Zip`:**<br>
Acesse o repositório no GitHub e faça o download do projeto compactado em `.zip`.
![GitHubZip](media/Image1.png)

Estraia tudo no `disco-local (c:)` do seu PC

![DiscoC](media/Image2.png)



### Como executar o projeto


conectar no banco de dados:


```
c:/Trabalho_Final_Progress/db/xtudo
```
