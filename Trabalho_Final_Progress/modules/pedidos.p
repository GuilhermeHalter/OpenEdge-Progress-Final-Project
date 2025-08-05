/*Pedidos.p*/

CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-primeiro LABEL "<<".
DEFINE BUTTON bt-anterior LABEL "<".
DEFINE BUTTON bt-proximo LABEL ">".
DEFINE BUTTON bt-ultimo LABEL ">>".
DEFINE BUTTON bt-adicionar LABEL "Adicionar".
DEFINE BUTTON bt-editar LABEL "Modificar".
DEFINE BUTTON bt-deletar LABEL "Eliminar".
DEFINE BUTTON bt-adicionarItem LABEL "Adicionar".
DEFINE BUTTON bt-editarItem LABEL "Modificar".
DEFINE BUTTON bt-deletarItem LABEL "Eliminar".
DEFINE BUTTON bt-salvar LABEL "Salvar".
DEFINE BUTTON bt-cancelar LABEL "Cancelar".
DEFINE BUTTON bt-exportar LABEL "Exportar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY q-pedidos FOR Pedidos, Clientes, Cidades SCROLLING.

/*Variaveis Itens*/

DEFINE VARIABLE iCodProduto AS INTEGER NO-UNDO.
DEFINE VARIABLE cNomProduto AS CHARACTER NO-UNDO.
DEFINE VARIABLE iNumQuantidade AS INTEGER NO-UNDO.
DEFINE VARIABLE dValTotal AS DECIMAL NO-UNDO.


DEFINE TEMP-TABLE ttItens NO-UNDO
    FIELD CodProduto    AS INTEGER
    FIELD NomProduto    AS CHARACTER
    FIELD NumQuantidade AS INTEGER
    FIELD ValUnitario   AS DECIMAL
    FIELD ValTotal      AS DECIMAL
    INDEX id-item IS PRIMARY UNIQUE CodProduto.
    
DEFINE QUERY q-itens FOR ttItens SCROLLING.

DEFINE BROWSE b-itens QUERY q-itens DISPLAY
    ttItens.CodProduto
    ttItens.NomProduto
    ttItens.NumQuantidade
    ttItens.ValUnitario
    ttItens.ValTotal LABEL "Total"
    WITH SEPARATORS 10 DOWN SIZE 120 BY 10.

DEFINE FRAME f-itens
    iCodProduto LABEL "Produto" COLON 20
    cNomProduto NO-LABEL 
    iNumQuantidade LABEL "Quantidade"  COLON 20
    dValTotal LABEL "Valor Total "COLON 20
    bt-salvar   COLON 20
    bt-cancelar  COLON 20
    WITH SIDE-LABELS SIZE 100 BY 10
        VIEW-AS DIALOG-BOX TITLE "Item".
    
/*FIM Variaveis Itens*/   

DEFINE BUFFER b-pedidos FOR Pedidos.
DEFINE BUFFER b-clientes FOR Clientes.

DEFINE FRAME f-pedidos
    bt-primeiro
    bt-anterior
    bt-proximo
    bt-ultimo
    bt-adicionar
    bt-editar
    bt-deletar
    bt-salvar
    bt-cancelar
    bt-exportar
    bt-sair
    Pedidos.CodPedido COLON 20
    Pedidos.DatPedido
    Pedidos.CodCliente COLON 20
    Clientes.NomCliente NO-LABEL
    Clientes.CodEndereco  COLON 20
    Clientes.CodCidade COLON 20
    Cidades.NomCidade NO-LABEL
    Pedidos.Observacao COLON 20 SKIP(1)
    b-itens COLON 1 SKIP(0.5)
    bt-adicionarItem  COLON 1 
    bt-editarItem
    bt-deletarItem
    WITH SIDE-LABELS SIZE 150 BY 23
        VIEW-AS DIALOG-BOX TITLE "Pedidos".

     


ON 'choose' OF bt-primeiro 
DO:
    GET FIRST q-pedidos.
    RUN pi-mostra.
END.

ON 'choose' OF bt-anterior 
DO:
    GET PREV q-pedidos.
    RUN pi-mostra.
END.

ON 'choose' OF bt-proximo 
DO:
    GET NEXT q-pedidos.
    RUN pi-mostra.
END.

ON 'choose' OF bt-ultimo 
DO:
    GET LAST q-pedidos.
    RUN pi-mostra.
END.

/*Adicionar*/
ON 'choose' OF bt-adicionar 
DO:
    ASSIGN cAction = "add".
    RUN pi-habilitaBotoes (INPUT FALSE).
    RUN pi-habilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-pedidos.
    DISPLAY NEXT-VALUE(seqPedido) @ Pedidos.CodPedido WITH FRAME f-pedidos. 
    DISPLAY TODAY @ Pedidos.DatPedido WITH FRAME f-pedidos.
END. /*FIM Adicionar*/

ON 'leave' OF Pedidos.CodCliente
DO:
    DEFINE VARIABLE cNomeCliente AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cEndereco AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cNomeCidade AS CHARACTER NO-UNDO.


    FIND FIRST Clientes WHERE Clientes.CodCliente = INTEGER(Pedidos.CodCliente:SCREEN-VALUE) NO-LOCK NO-ERROR.
    DISPLAY Clientes.CodCidade @ Clientes.CodCidade WITH FRAME f-pedidos.
    FIND FIRST Cidades WHERE Cidades.CodCidade = INTEGER(Clientes.CodCidade:SCREEN-VALUE) NO-LOCK NO-ERROR.
    
    IF AVAILABLE Clientes THEN DO:
        cNomeCliente = Cliente.NomCliente.
        cEndereco = Cliente.CodEndereco.
        IF AVAILABLE Cidades THEN
            cNomeCidade = Cidades.NomCidade.
        ELSE
            cNomeCidade = "invalid".
        END. 
    ELSE DO:
        cNomeCliente = "invalid".
        cEndereco = "invalid".
    END.

    DISPLAY cNomeCliente @ Cliente.NomCliente
            cEndereco @ Cliente.CodEndereco
            cNomeCidade @ Cidades.NomCidade
            WITH FRAME f-pedidos.
END.

ON 'choose' OF bt-cancelar 
DO:
    RUN pi-habilitaBotoes (INPUT TRUE).
    RUN pi-habilitaCampos (INPUT FALSE).
    RUN pi-mostra.
END.

/*Triggers Itens*/

ON 'CHOOSE' OF bt-adicionarItem 
DO:
    ASSIGN
        iCodProduto    = 0
        cNomProduto    = ""
        iNumQuantidade = 0
        dValTotal      = 0.
    DISPLAY iCodProduto cNomProduto iNumQuantidade dValTotal WITH FRAME f-itens.
    ENABLE iCodProduto iNumQuantidade bt-cancelar bt-salvar WITH FRAME f-itens.
    ON 'leave' OF iCodProduto 
    DO:
        FOR EACH Produtos WHERE Produtos.CodProduto = INPUT iCodProduto NO-LOCK:
            DISPLAY Produtos.NomProduto @ cNomProduto WITH FRAME f-itens.
        END.
    END.
    
   WAIT-FOR "WINDOW-CLOSE" OF FRAME f-itens.
   HIDE FRAME f-itens.
   ENABLE bt-adicionarItem WITH FRAME f-pedidos.
                                 
END.

RUN pi-abrirQuery.         
RUN pi-habilitaBotoes (INPUT TRUE).
DISPLAY WITH FRAME f-pedidos.
WAIT-FOR ENDKEY OF FRAME f-pedidos.


PROCEDURE pi-abrirQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Pedidos THEN
    DO:
        ASSIGN rRecord = ROWID(Pedidos).    
    END.
    
    OPEN QUERY q-pedidos
        FOR EACH Pedidos,
            FIRST Clientes WHERE Clientes.CodCliente = Pedidos.CodCliente,
            FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade.
        
    REPOSITION q-pedidos TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE pi-mostra:
    IF AVAILABLE Pedidos THEN
    DO:
        DISPLAY Pedidos.CodPedido 
                Pedidos.DatPedido
                Pedidos.CodCliente  
                Clientes.NomCliente 
                Clientes.CodEndereco   
                Clientes.CodCidade  
                Cidades.NomCidade 
                Pedidos.Observacao  
                WITH FRAME f-pedidos.
    END.
    ELSE DO:
        CLEAR FRAME f-pedidos.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-pedidos:
        ASSIGN Pedidos.DatPedido:SENSITIVE = pEnable 
                Pedidos.CodCliente:SENSITIVE = pEnable   
                Pedidos.Observacao:SENSITIVE = pEnable. 
    END.
END PROCEDURE.

PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-pedidos:
        ASSIGN bt-primeiro:SENSITIVE = pEnable
            bt-anterior:SENSITIVE = pEnable
            bt-proximo:SENSITIVE = pEnable
            bt-ultimo:SENSITIVE = pEnable
            bt-adicionar:SENSITIVE = pEnable
            bt-editar:SENSITIVE = pEnable
            bt-deletar:SENSITIVE = pEnable
            bt-salvar:SENSITIVE = NOT pEnable
            bt-cancelar:SENSITIVE = NOT pEnable
            bt-exportar:SENSITIVE = pEnable
            bt-sair:SENSITIVE = pEnable    
            bt-adicionarItem:SENSITIVE = pEnable  
            bt-editarItem:SENSITIVE = pEnable
            bt-deletarItem:SENSITIVE = pEnable
            b-itens:SENSITIVE = pEnable.
    END.
END PROCEDURE.
