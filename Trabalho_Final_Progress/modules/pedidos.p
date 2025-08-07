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

DEFINE VARIABLE iCodProduto AS INTEGER  NO-UNDO.
DEFINE VARIABLE cNomProduto AS CHARACTER NO-UNDO.
DEFINE VARIABLE iNumQuantidade AS INTEGER NO-UNDO.
DEFINE VARIABLE dValTotal AS DECIMAL NO-UNDO.


DEFINE TEMP-TABLE ttItens NO-UNDO
    FIELD CodItem       AS INTEGER
    FIELD CodProduto    AS INTEGER
    FIELD NomProduto    AS CHARACTER FORMAT "x(60)"
    FIELD NumQuantidade AS INTEGER
    FIELD ValUnitario   AS DECIMAL
    FIELD ValTotal      AS DECIMAL
    INDEX id-item IS PRIMARY UNIQUE CodItem.
    
DEFINE QUERY q-itens FOR ttItens SCROLLING.

DEFINE BROWSE b-itens QUERY q-itens DISPLAY
    ttItens.CodItem LABEL "Item"
    ttItens.CodProduto LABEL "Codigo"
    ttItens.NomProduto LABEL "Produto" WIDTH 50
    ttItens.NumQuantidade LABEL "Quantidade"
    ttItens.ValUnitario LABEL "Valor"
    ttItens.ValTotal LABEL "Total"
    WITH SEPARATORS 10 DOWN SIZE 120 BY 10.

DEFINE FRAME f-itens
    iCodProduto LABEL "Produto" COLON 20
    cNomProduto NO-LABEL 
    iNumQuantidade LABEL "Quantidade"  COLON 20
    dValTotal LABEL "Valor Total "COLON 20
    bt-salvar   COLON 10
    bt-cancelar
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

    /* Limpa a temp-table de itens e o browse */
    EMPTY TEMP-TABLE ttItens.
    IF QUERY q-itens:IS-OPEN THEN
        CLOSE QUERY q-itens.
    OPEN QUERY q-itens FOR EACH ttItens.

    DISPLAY NEXT-VALUE(seqPedido) @ Pedidos.CodPedido WITH FRAME f-pedidos. 
    DISPLAY TODAY @ Pedidos.DatPedido WITH FRAME f-pedidos.
END.
 /*FIM Adicionar*/

ON 'value-changed' OF Pedidos.CodCliente
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

ON 'choose' OF bt-salvar IN FRAME f-pedidos
DO:
    DEFINE VARIABLE iCodPedido   AS INTEGER NO-UNDO.
    DEFINE VARIABLE iCodCliente  AS INTEGER NO-UNDO.
    DEFINE VARIABLE dValPedido   AS DECIMAL NO-UNDO.
    DEFINE VARIABLE dtPedido     AS DATE NO-UNDO.
    DEFINE VARIABLE cObs         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iQtdItens    AS INTEGER NO-UNDO.

    /* Captura os valores da tela */
    ASSIGN
        iCodPedido  = INTEGER(Pedidos.CodPedido:SCREEN-VALUE)
        iCodCliente = INTEGER(Pedidos.CodCliente:SCREEN-VALUE)
        dtPedido    = DATE(Pedidos.DatPedido:SCREEN-VALUE)
        cObs        = Pedidos.Observacao:SCREEN-VALUE.

    /* Validação dos campos obrigatórios */
    IF iCodCliente = 0 THEN DO:
        MESSAGE "Código do cliente é obrigatório." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    IF dtPedido = ? THEN DO:
        MESSAGE "Data do pedido é obrigatória." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    /* Verifica se existem itens */
    iQtdItens = 0.
    FOR EACH ttItens:
        iQtdItens = iQtdItens + 1.
    END.

    IF iQtdItens = 0 THEN DO:
        MESSAGE "Adicione pelo menos um item ao pedido." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    /* Soma o valor total do pedido */
    dValPedido = 0.
    FOR EACH ttItens:
        dValPedido = dValPedido + ttItens.ValTotal.
    END.

    /* Cria o pedido no banco */
    CREATE Pedidos.
    ASSIGN
        Pedidos.CodPedido   = iCodPedido
        Pedidos.CodCliente  = iCodCliente
        Pedidos.DatPedido   = dtPedido
        Pedidos.ValPedido   = dValPedido
        Pedidos.Observacao  = cObs.

    /* Salva os itens no banco */
    FOR EACH ttItens:
        CREATE Itens.
        ASSIGN
            Itens.CodItem       = ttItens.CodItem
            Itens.CodPedido     = iCodPedido
            Itens.CodProduto    = ttItens.CodProduto
            Itens.NumQuantidade = ttItens.NumQuantidade
            Itens.ValTotal      = ttItens.ValTotal.
    END.

    /* Confirma operação e limpa temp-table */
    MESSAGE "Pedido salvo com sucesso!" VIEW-AS ALERT-BOX INFORMATION.

    EMPTY TEMP-TABLE ttItens.
    CLOSE QUERY q-itens.

    /* Recarrega a query principal */
    RUN pi-abrirQuery.
    RUN pi-habilitaBotoes (INPUT TRUE).
    RUN pi-habilitaCampos (INPUT FALSE).
    RUN pi-mostra.
END.



/*Triggers Itens*/

   
ON 'value-changed' OF iCodProduto 
  DO:
      DEFINE VARIABLE iCodigo AS INTEGER NO-UNDO.

      IF VALID-HANDLE(FRAME f-itens:HANDLE) THEN DO:
          iCodigo = INTEGER(iCodProduto:SCREEN-VALUE) NO-ERROR.
           
          IF iCodigo > 0 THEN DO:
              FIND Produtos WHERE Produtos.CodProduto = iCodigo NO-LOCK NO-ERROR.
              IF AVAILABLE Produtos THEN
                  DISPLAY Produtos.NomProduto @ cNomProduto WITH FRAME f-itens.
              ELSE
                  MESSAGE "Produto não encontrado." VIEW-AS ALERT-BOX WARNING.
          END.
      END.
END.

ON 'value-changed' OF iNumQuantidade 
DO:
    DEFINE VARIABLE dTotal AS DECIMAL NO-UNDO.
    FIND Produtos WHERE Produtos.CodProduto = INPUT iCodProduto NO-LOCK NO-ERROR.
    IF AVAILABLE Produtos THEN
    DO:
        ASSIGN dTotal = Produtos.ValProduto * INPUT iNumQuantidade.
        DISPLAY dTotal @ dValTotal WITH FRAME f-itens.    
    END.
END.

ON 'choose' OF bt-cancelar IN FRAME f-itens 
DO:
    ASSIGN
        iCodProduto    = 0
        cNomProduto    = ""
        iNumQuantidade = 0
        dValTotal      = 0.

    DISPLAY iCodProduto
            cNomProduto
            iNumQuantidade
            dValTotal
            WITH FRAME f-itens.

END.

ON 'choose' OF bt-salvar IN FRAME f-itens 
DO:
    DEFINE VARIABLE dUnitario         AS DECIMAL NO-UNDO.
    DEFINE VARIABLE iProximoCodItem   AS INTEGER NO-UNDO.
    DEFINE VARIABLE iUltimoCodItemBanco AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaiorCodTemp     AS INTEGER NO-UNDO.
    DEFINE VARIABLE iCount            AS INTEGER NO-UNDO.

    ASSIGN 
        iCodProduto    = INTEGER(iCodProduto:SCREEN-VALUE IN FRAME f-itens)
        cNomProduto    = cNomProduto:SCREEN-VALUE IN FRAME f-itens
        iNumQuantidade = INTEGER(iNumQuantidade:SCREEN-VALUE IN FRAME f-itens)
        dValTotal      = DECIMAL(dValTotal:SCREEN-VALUE IN FRAME f-itens).

    FIND Produtos WHERE Produtos.CodProduto = iCodProduto NO-LOCK NO-ERROR.
    IF NOT AVAILABLE Produtos THEN DO:
        MESSAGE "Produto não encontrado." VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.

    dUnitario = Produtos.ValProduto.

    /* Contar registros na temp-table e achar maior código */
    iCount = 0.
    iMaiorCodTemp = 0.

    FOR EACH ttItens NO-LOCK:
        iCount = iCount + 1.
        IF ttItens.CodItem > iMaiorCodTemp THEN
            iMaiorCodTemp = ttItens.CodItem.
    END.

    IF iCount = 0 THEN DO:
        FIND LAST Itens NO-LOCK NO-ERROR.
        IF AVAILABLE Itens THEN
            iUltimoCodItemBanco = Itens.CodItem.
        ELSE
            iUltimoCodItemBanco = 0.

        iProximoCodItem = iUltimoCodItemBanco + 1.
    END.
    ELSE DO:
        iProximoCodItem = iMaiorCodTemp + 1.
    END.

    /* Cria o registro na temp-table com o código calculado */
    CREATE ttItens.
    ASSIGN
        ttItens.CodItem      = iProximoCodItem
        ttItens.CodProduto   = iCodProduto
        ttItens.NomProduto   = cNomProduto
        ttItens.NumQuantidade = iNumQuantidade
        ttItens.ValUnitario  = dUnitario
        ttItens.ValTotal     = dUnitario * iNumQuantidade.

    /* Atualiza o browse */
    IF NOT QUERY q-itens:IS-OPEN THEN
        OPEN QUERY q-itens FOR EACH ttItens.
    ELSE DO:
        CLOSE QUERY q-itens.
        OPEN QUERY q-itens FOR EACH ttItens.
    END.

    b-itens:SELECT-ROW(b-itens:NUM-ITERATIONS) IN FRAME f-pedidos.

END.




ON 'CHOOSE' OF bt-adicionarItem 
DO:
    ASSIGN
        iCodProduto    = 0
        cNomProduto    = ""
        iNumQuantidade = 0
        dValTotal      = 0.
    DISPLAY iCodProduto cNomProduto iNumQuantidade dValTotal WITH FRAME f-itens.
    ENABLE iCodProduto iNumQuantidade bt-cancelar bt-salvar WITH FRAME f-itens.

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
    DEFINE VARIABLE iCodPedido AS INTEGER NO-UNDO.

    IF AVAILABLE Pedidos THEN
    DO:
        ASSIGN iCodPedido = Pedidos.CodPedido.

        DISPLAY Pedidos.CodPedido 
                Pedidos.DatPedido
                Pedidos.CodCliente  
                Clientes.NomCliente 
                Clientes.CodEndereco   
                Clientes.CodCidade  
                Cidades.NomCidade 
                Pedidos.Observacao  
                WITH FRAME f-pedidos.

        /* Limpa e carrega os itens do pedido selecionado na temp-table */
        EMPTY TEMP-TABLE ttItens.

        FOR EACH Itens NO-LOCK WHERE Itens.CodPedido = iCodPedido:
            FIND Produtos WHERE Produtos.CodProduto = Itens.CodProduto NO-LOCK NO-ERROR.

            CREATE ttItens.
            ASSIGN
                ttItens.CodItem       = Itens.CodItem
                ttItens.CodProduto    = Itens.CodProduto
                ttItens.NomProduto    = IF AVAILABLE Produtos THEN Produtos.NomProduto ELSE "Desconhecido"
                ttItens.NumQuantidade = Itens.NumQuantidade
                ttItens.ValUnitario   = IF AVAILABLE Produtos THEN Produtos.ValProduto ELSE 0
                ttItens.ValTotal      = Itens.ValTotal.
        END.

        /* Atualiza a query do browse */
        IF NOT QUERY q-itens:IS-OPEN THEN
            OPEN QUERY q-itens FOR EACH ttItens.
        ELSE DO:
            CLOSE QUERY q-itens.
            OPEN QUERY q-itens FOR EACH ttItens.
        END.

        b-itens:SELECT-ROW(1) IN FRAME f-pedidos.
    END.
    ELSE DO:
        CLEAR FRAME f-pedidos.
        EMPTY TEMP-TABLE ttItens.
        CLOSE QUERY q-itens.
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
            bt-adicionarItem:SENSITIVE = NOT pEnable
            bt-editarItem:SENSITIVE = NOT pEnable
            bt-deletarItem:SENSITIVE = NOT pEnable
            bt-exportar:SENSITIVE = pEnable
            bt-sair:SENSITIVE = pEnable    
            b-itens:SENSITIVE = pEnable.
    END.
END PROCEDURE.
