/*Pedidos.p*/
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

DEFINE VARIABLE c-action AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-actionItem AS CHARACTER NO-UNDO.

DEFINE VARIABLE c-acao AS CHARACTER NO-UNDO.
DEFINE VARIABLE l-selecao AS LOGICAL NO-UNDO.
DEFINE VARIABLE i-seqItem AS INTEGER NO-UNDO.

{c:/Trabalho_Final_Progress/includes/navbar.i}

DEFINE BUTTON bt-adicionarItem LABEL "Adicionar".
DEFINE BUTTON bt-editarItem LABEL "Modificar".
DEFINE BUTTON bt-eliminarItem LABEL "Eliminar".

DEFINE BUFFER b-pedidos FOR Pedidos.
DEFINE BUFFER b-clientes FOR Clientes.
DEFINE BUFFER b-cidades FOR Cidades.
DEFINE BUFFER b-itens FOR Itens.
DEFINE BUFFER bf-itens FOR itens.
DEFINE BUFFER bf-produtos FOR produtos.

DEFINE QUERY q-pedidos FOR Pedidos, Clientes, Cidades SCROLLING.
DEFINE QUERY q-itens FOR itens, produtos SCROLLING.

DEFINE BROWSE bw-itens QUERY q-itens NO-LOCK
    DISPLAY Itens.CodItem
            Itens.CodProduto
            Produtos.NomProduto FORMAT "x(40)"
            Itens.NumQuantidade
            Produtos.ValProduto
            Itens.ValTotal
            WITH SEPARATORS 15 DOWN SIZE 100 BY 10.

          

/*FRAMES*/
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
    bt-sair SKIP(1)            
    Pedidos.CodPedido COLON 20 
    Pedidos.DatPedido
    Pedidos.CodCliente LABEL "Cliente" COLON 20 
    Clientes.NomCliente NO-LABELS
    Clientes.CodEndereco COLON 20
    Clientes.CodCidade COLON 20 
    Cidades.NomCidade NO-LABELS
    Pedidos.Observacao COLON 20 SKIP(1)
    bw-itens COLON 1 SKIP
    bt-adicionarItem COLON 1
    bt-editarItem
    bt-eliminarItem
    WITH SIDE-LABELS THREE-D SIZE 120 BY 25
        VIEW-AS DIALOG-BOX TITLE "Pedidos".


/*FIM FRAMES*/

ON 'choose' OF bt-primeiro 
DO:
    GET FIRST q-pedidos.
    RUN pi-mostra.
    RUN pi-mostraItens.
END.

ON 'choose' OF bt-anterior 
DO:
    GET PREV q-pedidos.
    IF NOT AVAILABLE Pedidos THEN
    DO:
        GET LAST q-pedidos.        
    END.
    RUN pi-mostra.
    RUN pi-mostraItens.
END.

ON 'choose' OF bt-proximo 
DO:
    GET NEXT q-pedidos.
    IF NOT AVAILABLE Pedidos THEN
    DO:
        GET FIRST q-pedidos.        
    END.
    RUN pi-mostra.
    RUN pi-mostraItens.
END.

ON 'choose' OF bt-ultimo 
DO:
    GET LAST q-pedidos.
    RUN pi-mostra.
    RUN pi-mostraItens.
END.

ON 'choose' OF bt-adicionar 
DO:
    ASSIGN c-action = "add".
    RUN pi-habilitaBotoes(INPUT FALSE).
    RUN pi-habilitaCampos(INPUT TRUE).
    
    CLEAR FRAME f-pedidos.
    CLOSE QUERY q-itens.
    
    DISPLAY NEXT-VALUE(seqPedido) @ Pedidos.CodPedido
            TODAY @ Pedidos.DatPedido
            WITH FRAME f-pedidos.
END.

ON 'choose' OF bt-editar 
DO:
    ASSIGN c-action = "edit".
    RUN pi-habilitaBotoes(INPUT FALSE).
    RUN pi-habilitaCampos(INPUT TRUE).
    
    RUN pi-mostra.
END.

ON 'choose' OF bt-deletar 
DO:
    MESSAGE "Deseja mesmo excluir esse pedido e seus itens ?"
        UPDATE l-selecao VIEW-AS ALERT-BOX
        BUTTONS YES-NO TITLE "Excluir".
    IF l-selecao = YES THEN
    DO:
        FIND FIRST b-pedidos EXCLUSIVE-LOCK
            WHERE b-pedidos.CodPedido = Pedidos.CodPedido.
            
        FOR EACH b-itens EXCLUSIVE-LOCK
            WHERE b-itens.codpedido = b-pedidos.CodPedido:
            DELETE b-itens.
        END.
        DELETE b-pedidos.
        
        MESSAGE "Pedido excluido !" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        APPLY "choose" TO bt-proximo.
    END.
END.

ON 'choose' OF bt-salvar 
DO:
    DEFINE VARIABLE l-valido AS LOGICAL NO-UNDO.
    RUN pi-validaCliente (INPUT Pedidos.CodCliente:SCREEN-VALUE,
                          OUTPUT l-valido).
    IF l-valido = NO THEN
    DO:
        RETURN NO-APPLY.    
    END.
    
    IF c-action = "add" THEN
    DO:
        CREATE b-pedidos.
        ASSIGN b-pedidos.CodPedido = INPUT Pedidos.CodPedido.
    END.
    IF c-action = "edit" THEN
    DO:
        FIND FIRST b-pedidos EXCLUSIVE-LOCK
            WHERE b-pedidos.CodPedido = Pedidos.CodPedido.
    END.
    
    ASSIGN b-pedidos.CodCliente = INPUT Pedidos.CodCliente
           b-pedidos.DatPedido = INPUT Pedidos.DatPedido
           b-pedidos.Observacao = INPUT Pedidos.Observacao.
           
    
    RUN pi-habilitaBotoes(INPUT TRUE).
    RUN pi-habilitaCampos(INPUT FALSE).
    RUN pi-abrirQuery.
    
    APPLY "choose" TO bt-ultimo.
END.


ON 'choose' OF bt-cancelar 
DO:
    RUN pi-habilitaBotoes(INPUT TRUE).
    RUN pi-habilitaCampos(INPUT FALSE).
    RUN pi-mostra.
    RUN pi-mostraItens.
END.

ON 'leave' OF Pedidos.CodCliente 
DO:
    DEFINE VARIABLE l-valido AS LOGICAL NO-UNDO.
    RUN pi-validaCliente (INPUT Pedidos.CodCliente:SCREEN-VALUE,
                          OUTPUT l-valido).
    IF l-valido = NO THEN
    DO:
        RETURN NO-APPLY.    
    END.
    
    DISPLAY b-clientes.NomCliente @ Clientes.NomCliente
            b-clientes.CodEndereco @ Clientes.CodEndereco
            b-cidades.CodCidade @ Clientes.CodCidade
            b-cidades.NomCidade @ Cidade.NomCidade
            WITH FRAME f-pedidos.
END.

ON 'choose' OF bt-exportar 
DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.    
    DEFINE VARIABLE oPedido AS JsonObject NO-UNDO.
    DEFINE VARIABLE oItem AS JsonObject NO-UNDO.
    DEFINE VARIABLE aPedido AS JsonArray NO-UNDO.
    DEFINE VARIABLE aItem AS JsonArray NO-UNDO.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "pedidos.json"
           aPedido = NEW JsonArray().
           
    FOR EACH Pedidos NO-LOCK:
        FIND FIRST Clientes NO-LOCK
            WHERE Clientes.CodCliente = Pedidos.CodCliente NO-ERROR.
        oPedido = NEW JsonObject().
        
        oPedido:ADD("Codigo", STRING(Pedidos.CodPedido)).
        oPedido:ADD("Data", Pedidos.DatPedido).
        oPedido:ADD("Cliente", STRING(Pedidos.CodCliente)).
        
        IF AVAILABLE Clientes THEN
        DO:
            oPedido:ADD("Cidade", STRING(Clientes.CodCidade)).
            oPedido:ADD("Endereco", Clientes.CodEndereco).
        END.
        
        oPedido:ADD("Observacao", Pedidos.Observacao).
        aItem = NEW JsonArray().
        FOR EACH Itens NO-LOCK
            WHERE Itens.CodPedido = Pedidos.CodPedido:
            FIND FIRST Produtos NO-LOCK
                WHERE Produtos.CodProduto = Itens.CodProduto.
                
            oItem = NEW JsonObject().
            oItem:ADD("Item", Itens.CodItem).
            oItem:ADD("Produto", Itens.CodProduto).
            oItem:ADD("Nome", Produtos.NomProduto).
            oItem:ADD("Quantidade", Itens.NumQuantidade).
            oItem:ADD("Valor Produto", Produtos.ValProduto).
            oItem:ADD(" Valor Total", Itens.ValTotal).
            aItem:ADD(oItem).
        END.
        
        oPedido:ADD("Itens", aItem).
        
        aPedido:ADD(oPedido).
    END.
    aPedido:WriteFile(INPUT cArq, INPUT YES, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
    
    ASSIGN cArquivo = SESSION:TEMP-DIRECTORY + "pedidos.csv".
    OUTPUT TO VALUE(cArquivo).
    FOR EACH Pedidos NO-LOCK:
        FIND FIRST Clientes NO-LOCK
            WHERE Clientes.CodCliente = Pedidos.CodCliente NO-ERROR.
        PUT UNFORMATTED Pedidos.CodPedido ";"
                        Pedidos.DatPedido ";"
                        Pedidos.CodCliente ";"
                        Clientes.CodEndereco ";"
                        Pedidos.Observacao.
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivo).
END.


/*------Itens Frame------*/

ON 'choose' OF bt-adicionarItem
DO:
    ASSIGN c-actionItem = "add".
   
    RUN pi-mostraFrameItem.       
    RUN pi-abrirQuery.
    
END.

ON 'choose' OF bt-editarItem
DO:
    /* Verifica se existe um registro atual na tabela Itens (que reflete a query q-itens) */
    IF NOT AVAILABLE Itens THEN DO:
        MESSAGE "Nenhum item selecionado para editar!" VIEW-AS ALERT-BOX.
        RETURN.
    END.

    /* Obt�m o CodItem do registro atual da tabela Itens */
    ASSIGN i-seqItem = Itens.CodItem.

    ASSIGN c-actionItem = "edit".

    RUN pi-mostraFrameItem.
    RUN pi-abrirQuery.
END.


ON 'choose' OF bt-eliminarItem
 
DO:
    MESSAGE "Deseja mesmo Excluir o item " itens.codItem "?" UPDATE l-selecao
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Excluir".
    IF l-selecao = YES THEN
    DO:
        FIND FIRST b-itens EXCLUSIVE-LOCK 
            WHERE b-itens.CodItem = itens.CodItem
            AND b-itens.codPedido = itens.CodPedido NO-ERROR.
        IF AVAILABLE b-itens THEN
        DO:
            DELETE b-itens.
            RUN pi-mostraItens.
            RUN pi-totalPedido.
            RUN pi-abrirQuery.
        END.
        ELSE
            MESSAGE "item nao encontrado!"
                VIEW-AS ALERT-BOX ERROR BUTTONS OK.            
            
    END.
END.



/*------FIM Itens Frame------*/


RUN pi-abrirQuery.
RUN pi-mostraItens.
RUN pi-habilitaBotoes (INPUT TRUE).
DISPLAY WITH FRAME f-pedidos.
APPLY "choose" TO bt-primeiro.



PROCEDURE pi-abrirQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Pedidos THEN
    DO:
        ASSIGN rRecord = ROWID(Pedidos).    
    END.
    
    OPEN QUERY q-pedidos
        FOR EACH Pedidos NO-LOCK,
            FIRST Clientes WHERE  Clientes.CodCliente = Pedidos.CodCliente NO-LOCK,
            FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK.
        
    REPOSITION q-pedidos TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE pi-validaCliente:
    DEFINE INPUT PARAMETER p-cliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER p-valid AS LOGICAL NO-UNDO INITIAL NO.
    
    FIND FIRST b-clientes NO-LOCK
        WHERE b-clientes.CodCliente = p-cliente NO-ERROR.
        
    IF NOT AVAILABLE b-clientes THEN
    DO:
        MESSAGE "Cliente nao existe!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN p-valid = NO.
    END.
    IF AVAILABLE b-clientes THEN
    DO:
        FIND FIRST b-cidades NO-LOCK
            WHERE b-cidades.CodCidade = b-clientes.CodCidade NO-ERROR.
            
        ASSIGN p-valid = YES.
    END.
END PROCEDURE.

PROCEDURE pi-mostra:
    IF AVAILABLE Pedidos THEN
    DO:
        DISPLAY Pedidos.CodPedido 
                Pedidos.CodCliente
                Clientes.NomCliente
                Clientes.CodEndereco
                Clientes.CodCidade
                Cidades.NomCidade
                Pedidos.DatPedido
                Pedidos.Observacao
                WITH FRAME f-pedidos.
    END.
    ELSE DO:
        DISPLAY "" @ Pedidos.CodPedido 
                "" @ Pedidos.CodCliente
                "" @ Clientes.NomCliente
                "" @ Clientes.CodEndereco
                "" @ Clientes.CodCidade
                "" @ Cidades.NomCidade
                "" @ Pedidos.DatPedido
                "" @ Pedidos.Observacao
                WITH FRAME f-pedidos.
        DO WITH FRAME f-pedidos:
            ASSIGN bt-primeiro:SENSITIVE      = FALSE
               bt-anterior:SENSITIVE     =FALSE
               bt-proximo:SENSITIVE      = FALSE
               bt-ultimo:SENSITIVE       = FALSE
               bt-adicionar:SENSITIVE    = TRUE
               bt-editar:SENSITIVE       = FALSE
               bt-deletar:SENSITIVE      = FALSE
               bt-salvar:SENSITIVE       = FALSE
               bt-cancelar:SENSITIVE     = FALSE
               bt-exportar:SENSITIVE     = FALSE
               bt-sair:SENSITIVE         = TRUE
               bw-itens:SENSITIVE        = FALSE
               bt-adicionarItem:SENSITIVE = FALSE
               bt-editarItem:SENSITIVE   = FALSE
               bt-eliminarItem:SENSITIVE = FALSE .
        END.    
    END.
END PROCEDURE.

PROCEDURE pi-habilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-pedidos:
        ASSIGN Pedidos.CodCliente:SENSITIVE = pEnable
               Pedidos.DatPedido:SENSITIVE  = pEnable
               Pedidos.Observacao:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-pedidos:
        ASSIGN bt-primeiro:SENSITIVE      = pEnable
               bt-anterior:SENSITIVE     = pEnable
               bt-proximo:SENSITIVE      = pEnable
               bt-ultimo:SENSITIVE       = pEnable
               bt-adicionar:SENSITIVE    = pEnable
               bt-editar:SENSITIVE       = pEnable
               bt-deletar:SENSITIVE      = pEnable
               bt-salvar:SENSITIVE       = NOT pEnable
               bt-cancelar:SENSITIVE     = NOT pEnable
               bt-exportar:SENSITIVE     = pEnable
               bt-sair:SENSITIVE         = pEnable
               bw-itens:SENSITIVE        = pEnable 
               bt-adicionarItem:SENSITIVE = pEnable 
               bt-editarItem:SENSITIVE   = pEnable 
               bt-eliminarItem:SENSITIVE = pEnable .
    END.
END PROCEDURE.


PROCEDURE pi-mostraItens:
    OPEN QUERY q-itens
        FOR EACH Itens NO-LOCK
            WHERE Itens.CodPedido = Pedidos.CodPedido,
        FIRST Produtos NO-LOCK
                WHERE Produtos.CodProduto = Itens.CodProduto.
END PROCEDURE.

/*---- PROCEDURES DE ITENS ----*/

PROCEDURE pi-mostraFrameItem:
    DEFINE BUTTON bt-salvarItem   LABEL "Salvar" AUTO-ENDKEY.
    DEFINE BUTTON bt-cancelarItem LABEL "Cancelar" AUTO-ENDKEY.

    DEFINE FRAME f-itens 
         Itens.CodProduto COLON 20
         Produtos.NomProduto NO-LABELS
         Itens.NumQuantidade COLON 20
         Itens.ValTotal COLON 20 SKIP(1)
         bt-salvarItem
         bt-cancelarItem
         WITH SIDE-LABELS THREE-D SIZE 90 BY 10
              VIEW-AS DIALOG-BOX TITLE "Item".

    IF c-actionItem = "add" THEN DO:
        /* Limpa os campos para novo item */
        DISPLAY "" @ Itens.CodProduto
                "" @ Produtos.NomProduto
                0  @ Itens.NumQuantidade
                0  @ Itens.ValTotal
            WITH FRAME f-itens.
    END.
    ELSE IF c-actionItem = "edit" THEN DO:
        FIND FIRST bf-itens NO-LOCK
            WHERE bf-itens.CodPedido = Pedidos.CodPedido
              AND bf-itens.CodItem = i-seqItem NO-ERROR.
        IF AVAILABLE bf-itens THEN DO:
            FIND FIRST bf-produtos NO-LOCK
                WHERE bf-produtos.CodProduto = bf-itens.CodProduto NO-ERROR.

            DISPLAY bf-itens.CodProduto @  Itens.CodProduto 
                    bf-produtos.NomProduto @ Produtos.NomProduto
                    bf-itens.NumQuantidade @ Itens.NumQuantidade
                    bf-itens.ValTotal @ Itens.ValTotal
                    WITH FRAME f-itens.  
        END.
    END.

    DO WITH FRAME f-itens:
        ASSIGN Itens.CodProduto:SENSITIVE = TRUE
               Produtos.NomProduto:SENSITIVE = FALSE
               Itens.NumQuantidade:SENSITIVE = TRUE
               Itens.ValTotal:SENSITIVE = FALSE
               bt-salvarItem:SENSITIVE = TRUE
               bt-cancelarItem:SENSITIVE = TRUE.
    END.

    ON 'choose' OF bt-salvarItem IN FRAME f-itens
    DO:
        DEFINE VARIABLE l-valido AS LOGICAL NO-UNDO.

        RUN pi-validaProduto(INPUT Itens.CodProduto:SCREEN-VALUE, OUTPUT l-valido).
        IF NOT l-valido THEN RETURN NO-APPLY.

        IF c-actionItem = "add" THEN DO:
            FIND LAST bf-itens NO-LOCK
                WHERE bf-itens.CodPedido = Pedidos.CodPedido NO-ERROR.
            IF AVAILABLE bf-itens THEN
                ASSIGN i-seqItem = bf-itens.CodItem + 1.
            ELSE
                ASSIGN i-seqItem = 1.

            CREATE bf-itens.
            ASSIGN bf-itens.CodItem = i-seqItem
                   bf-itens.CodPedido = Pedidos.CodPedido.
        END.
        ELSE IF c-actionItem = "edit" THEN DO:
            FIND FIRST bf-itens EXCLUSIVE-LOCK
                WHERE bf-itens.CodPedido = Pedidos.CodPedido
                  AND bf-itens.CodItem = i-seqItem NO-ERROR.
        END.

        /* Atribui os valores dos campos para o buffer exclusivo */
        ASSIGN bf-itens.CodProduto = INPUT Itens.CodProduto
               bf-itens.NumQuantidade = INPUT Itens.NumQuantidade.

        FIND FIRST bf-produtos NO-LOCK
            WHERE bf-produtos.CodProduto = bf-itens.CodProduto NO-ERROR.

        IF AVAILABLE bf-produtos THEN
            ASSIGN bf-itens.ValTotal = bf-produtos.ValProduto * bf-itens.NumQuantidade.

        RUN pi-abrirQuery.
        RUN pi-mostraItens.
        RUN pi-totalPedido.

    END.


    ON 'leave' OF Itens.CodProduto IN FRAME f-itens
    DO:
        DEFINE VARIABLE l-valido AS LOGICAL NO-UNDO.

        RUN pi-validaProduto(INPUT Itens.CodProduto:SCREEN-VALUE, OUTPUT l-valido).
        IF NOT l-valido THEN RETURN NO-APPLY.

        FIND FIRST bf-produtos NO-LOCK
            WHERE bf-produtos.CodProduto = INPUT Itens.CodProduto NO-ERROR.

        IF AVAILABLE bf-produtos THEN
            DISPLAY bf-produtos.NomProduto @ Produtos.NomProduto WITH FRAME f-itens.
    END.

    ON 'leave' OF Itens.NumQuantidade IN FRAME f-itens
    DO:
        FIND FIRST bf-produtos NO-LOCK
            WHERE bf-produtos.CodProduto = INPUT Itens.CodProduto NO-ERROR.
        IF AVAILABLE bf-produtos THEN
            ASSIGN Itens.ValTotal:SCREEN-VALUE = STRING(bf-produtos.ValProduto * INPUT Itens.NumQuantidade).
    END.

    WAIT-FOR ENDKEY OF FRAME f-itens.
END PROCEDURE.



PROCEDURE pi-validaProduto:
    DEFINE INPUT PARAMETER p-produto AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER p-valido AS LOGICAL NO-UNDO INITIAL NO.

    FIND FIRST bf-produtos NO-LOCK
        WHERE bf-produtos.CodProduto = p-produto NO-ERROR.

    IF NOT AVAILABLE bf-produtos THEN
    DO:
        MESSAGE "Produto nao existe!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN p-valido = NO.
    END.
    ELSE
        ASSIGN p-valido = YES.
END PROCEDURE.


PROCEDURE pi-totalPedido:
    DEFINE VARIABLE d-total AS DECIMAL NO-UNDO INITIAL 0.

    FOR EACH itens NO-LOCK
        WHERE itens.CodPedido = Pedidos.CodPedido:
        ASSIGN d-total = d-total + itens.ValTotal.
    END.
    
    FIND FIRST b-pedidos EXCLUSIVE-LOCK
        WHERE b-pedidos.CodPedido = Pedidos.CodPedido NO-ERROR.
    IF AVAILABLE b-pedidos THEN
    DO:
        ASSIGN b-pedidos.ValPedido = d-total.    
    END.
    ELSE 
        MESSAGE "Pedido nao encontrado" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
END PROCEDURE.


WAIT-FOR ENDKEY OF FRAME f-pedidos.
