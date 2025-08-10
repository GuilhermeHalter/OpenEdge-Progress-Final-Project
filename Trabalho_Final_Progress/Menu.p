/*Menu.p*/
CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-cidades  LABEL "Cidades" SIZE 15 BY 1.
DEFINE BUTTON bt-produtos LABEL "Produtos" SIZE 15 BY 1.
DEFINE BUTTON bt-clientes LABEL "Clientes" SIZE 15 BY 1.
DEFINE BUTTON bt-pedidos LABEL "Pedidos" SIZE 15 BY 1.
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY SIZE 15 BY 1.
DEFINE BUTTON bt-relatClientes LABEL "Relatorio de Clientes" SIZE 25 BY 1.
DEFINE BUTTON bt-relatPedidos LABEL "Relatorio de Pedidos" SIZE 25 BY 1.

DEFINE FRAME f-Menu
    bt-cidades AT 10
    bt-produtos
    bt-clientes
    bt-pedidos 
    bt-sair AT 100 SKIP(1)
    bt-relatClientes AT 10
    bt-relatPedidos
    WITH SIZE 120 BY 10
        VIEW-AS DIALOG-BOX TITLE "Hamburgueria Xtudo".
        
ON 'choose' OF bt-cidades 
DO:
    RUN c:/Trabalho_Final_Progress/modules/cidades.p.
END.

ON 'choose' OF bt-produtos
DO:
    RUN c:/Trabalho_Final_Progress/modules/produtos.p.
END.
        
ON 'choose' OF bt-clientes
DO:
    RUN c:/Trabalho_Final_Progress/modules/clientes.p.
END.

ON 'choose' OF bt-pedidos 
DO:
    RUN c:/Trabalho_Final_Progress/modules/pedidos.p.
END.

ON 'choose' OF bt-relatClientes
DO:
    RUN pi-relatorioClientes.
END.

ON 'choose' OF bt-relatPedidos 
DO:
    RUN pi-relatorioPedidos.
END.



RUN pi-habilitaBotoes (INPUT TRUE).
DISPLAY WITH FRAME f-Menu.
WAIT-FOR ENDKEY OF FRAME f-Menu.
        
PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-Menu:
        ASSIGN bt-cidades:SENSITIVE        = pEnable
        bt-produtos:SENSITIVE       = pEnable
        bt-clientes:SENSITIVE       = pEnable
        bt-pedidos:SENSITIVE        = pEnable
        bt-sair:SENSITIVE           = pEnable
        bt-relatClientes:SENSITIVE  = pEnable
        bt-relatPedidos:SENSITIVE   = pEnable.
    END.
END PROCEDURE.

PROCEDURE pi-relatorioClientes:   
    DEFINE VARIABLE c-arquivo    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c-cidadeStr  AS CHARACTER NO-UNDO.
    
    DEFINE FRAME f-clientes HEADER
        "Relatório de Clientes" AT 1
        TODAY TO 100
        WITH CENTERED PAGE-TOP WIDTH 150.
        
    DEFINE FRAME f-dadosClientes 
        Clientes.CodCliente    LABEL "Código"     FORMAT ">>9"
        Clientes.NomCliente    LABEL "Nome"       FORMAT "x(30)"
        Clientes.CodEndereco   LABEL "Endereço"   FORMAT "x(25)"
        c-cidadeStr            LABEL "Cidade"     FORMAT "x(25)"
        Clientes.Observacao    LABEL "Observação" FORMAT "x(40)"
        WITH DOWN WIDTH 150.

    ASSIGN c-arquivo = SESSION:TEMP-DIRECTORY + "clientes.txt". 
    OUTPUT TO VALUE(c-arquivo) PAGE-SIZE 30 PAGED.
    VIEW FRAME f-clientes.

    FOR EACH Clientes NO-LOCK:
        FIND FIRST Cidades
            WHERE Cidades.CodCidade = Clientes.CodCidade
            NO-LOCK NO-ERROR.
        
        IF AVAILABLE Cidades THEN
            ASSIGN c-cidadeStr = STRING(Clientes.CodCidade) + "-" + Cidades.NomCidade.
        ELSE
            ASSIGN c-cidadeStr = STRING(Clientes.CodCidade) + "-??".

        DISPLAY 
            Clientes.CodCliente
            Clientes.NomCliente
            Clientes.CodEndereco
            c-cidadeStr
            Clientes.Observacao 
            WITH FRAME f-dadosClientes DOWN.
    END.

    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + c-arquivo).
END PROCEDURE.

PROCEDURE pi-relatorioPedidos:
    DEFINE VARIABLE c-arquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE d-total AS DECIMAL NO-UNDO.
    DEFINE VARIABLE c-enderecoCompleto AS CHARACTER NO-UNDO.

    ASSIGN c-arquivo = SESSION:TEMP-DIRECTORY + "pedidos.txt".

    
    DEFINE FRAME f-cabecalho
        "RELATÓRIO DE PEDIDOS"
        SKIP
        WITH CENTERED PAGE-TOP WIDTH 80.

    
    DEFINE FRAME f-pedido
        Pedidos.CodPedido LABEL "Pedido" FORMAT ">>9"  COLON 20
        Pedidos.DatPedido LABEL "Data" FORMAT "99/99/9999"
        Clientes.NomCliente LABEL "Cliente" FORMAT "x(25)" COLON 19
        c-enderecoCompleto LABEL "Endereço" FORMAT "x(35)" COLON 21
        Pedidos.Observacao LABEL "Observação" FORMAT "x(40)" COLON 21
        WITH SIDE-LABELS WIDTH 100.

    
    DEFINE FRAME f-itens
        Itens.CodItem LABEL "Cod"
        Produtos.NomProduto LABEL "Produto" FORMAT "x(25)"
        Itens.NumQuantidade LABEL "Qtde" 
        Produtos.ValProduto LABEL "Valor Unit." 
        Itens.ValTotal LABEL "Total Item" 
        WITH DOWN WIDTH 90.

    
    DEFINE FRAME f-total
        d-total LABEL "Total do Pedido"
        WITH WIDTH 80.

    OUTPUT TO VALUE(c-arquivo) PAGE-SIZE 50 PAGED.

    VIEW FRAME f-cabecalho.

    FOR EACH Pedidos NO-LOCK:

        FIND Clientes NO-LOCK WHERE Clientes.CodCliente = Pedidos.CodCliente NO-ERROR.
        FIND Cidades NO-LOCK WHERE Cidades.CodCidade = Clientes.CodCidade NO-ERROR.

        
        ASSIGN c-enderecoCompleto = 
            Clientes.CodEndereco + " / " +
            (IF AVAILABLE(Cidades) THEN Cidades.NomCidade + "-" + Cidades.CodUF ELSE "???").

        DISPLAY
            Pedidos.CodPedido
            Pedidos.DatPedido
            Clientes.NomCliente
            c-enderecoCompleto
            Pedidos.Observacao
            WITH FRAME f-pedido.

        ASSIGN d-total = 0.

        FOR EACH Itens NO-LOCK WHERE Itens.CodPedido = Pedidos.CodPedido BREAK BY Itens.CodItem:

            FIND Produtos NO-LOCK WHERE Produtos.CodProduto = Itens.CodProduto NO-ERROR.

            IF AVAILABLE(Produtos) THEN DO:
                
                ASSIGN d-total = d-total + Itens.ValTotal.

                DISPLAY
                    Itens.CodItem
                    Produtos.NomProduto
                    Itens.NumQuantidade
                    Produtos.ValProduto
                    Itens.ValTotal
                    WITH FRAME f-itens.
            END.
        END.

        DISPLAY d-total
            LABEL "Total do Pedido"
            WITH FRAME f-total.

       
    END.

    OUTPUT CLOSE.

    OS-COMMAND NO-WAIT VALUE("notepad.exe " + c-arquivo).
END PROCEDURE.


