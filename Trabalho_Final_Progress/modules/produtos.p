/*Produtos.p*/
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

{c:/Trabalho_Final_Progress/includes/navbar.i}

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.
   
DEFINE QUERY q-produtos FOR Produtos SCROLLING.

DEFINE BUFFER b-produtos FOR Produtos.

DEFINE FRAME f-produtos
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
    Produtos.CodProduto COLON 20
    Produtos.NomProduto COLON 20
    Produtos.ValProduto COLON 20
    WITH SIDE-LABELS THREE-D SIZE 120 BY 20
        VIEW-AS DIALOG-BOX TITLE "Produtos".

        
ON 'choose' OF bt-primeiro 
DO:
    GET FIRST q-produtos.
    RUN pi-mostra.
END.

ON 'choose' OF bt-anterior 
DO:
    GET PREV q-produtos.
    IF NOT AVAIL Produtos THEN
    DO:
        GET LAST q-produtos.        
    END.
    RUN pi-mostra.
END.

ON 'choose' OF bt-proximo 
DO:
    GET NEXT q-produtos.
    IF NOT AVAIL Produtos THEN
    DO:
        GET FIRST q-produtos.        
    END.
    RUN pi-mostra.
END.

ON 'choose' OF bt-ultimo 
DO:
    GET LAST q-produtos.
    RUN pi-mostra.
END.


/*Adicionar*/
ON 'choose' OF bt-adicionar 
DO:
    ASSIGN cAction = "add".
    RUN pi-habilitaBotoes (INPUT FALSE).
    RUN pi-habilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-produtos.
    DISPLAY NEXT-VALUE(seqProduto) @ Produtos.CodProduto WITH FRAME f-produtos.
    
END. /*FIM Adicionar*/

/*Editar*/
ON 'choose' OF bt-editar 
DO:
   ASSIGN cAction = "edit".
   RUN pi-habilitaBotoes (INPUT FALSE).
   RUN Pi-habilitaCampos (INPUT TRUE).
   
   DISPLAY Produtos.CodProduto WITH FRAME f-produtos.
   RUN pi-mostra.
END. /*FIM Editar*/

/*Deletar*/
ON 'choose' OF bt-deletar 
DO:
    DEFINE VARIABLE lConfirm AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER b-prod FOR Produtos.
    
    MESSAGE "Deseja realmente eliminar o Produto" Produtos.CodProduto "?" UPDATE lConfirm
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminar Cidade".
    IF lConfirm THEN
    DO:
        FIND b-prod 
            WHERE b-prod.CodProduto = Produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
        DELETE b-prod.
        RUN pi-AbrirQuery.
        APPLY "choose" TO bt-proximo IN FRAME f-produtos.
    END.
END. /*FIM Deletar*/

/*Exportar*/
ON 'choose' OF bt-exportar 
DO:
    /*CSV*/
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "produtos.csv".
    OUTPUT TO VALUE(cArq).
    FOR EACH Produtos NO-LOCK:
        PUT UNFORMATTED Produtos.CodProduto  ";"
                        Produtos.NomProduto ";"
                        Produtos.ValProduto  ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
    
    /*JSON*/
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oObj AS JsonObject NO-UNDO.
    DEFINE VARIABLE aProdutos AS JsonArray NO-UNDO.
    
    ASSIGN cArquivo = SESSION:TEMP-DIRECTORY + "produtos.json".
    aProdutos = NEW JsonArray().
    FOR EACH Produtos NO-LOCK:
        oObj = NEW JsonObject().
        oObj:ADD("CodProduto", Produtos.CodProduto).
        oObj:ADD("NomProduto", Produtos.NomProduto).
        oObj:ADD("ValProduto", Produtos.ValProduto).
        aProdutos:ADD(oObj).
    END.
    aProdutos:WriteFile(INPUT cArquivo, INPUT YES, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivo).
END. /*FIM Exportar*/
        
ON 'choose' OF bt-salvar 
DO:
    IF cAction = "add" THEN
    DO:
        CREATE b-produtos.
        ASSIGN b-produtos.CodProduto= INPUT Produtos.CodProduto.
    END.
    IF cAction = "edit" THEN
    DO:
        FIND FIRST b-produtos
            WHERE b-produtos.CodProduto = Produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
    END.

    ASSIGN b-produtos.NomProduto = INPUT Produtos.NomProduto
           b-produtos.ValProduto = INPUT Produtos.ValProduto.
           
    RUN pi-habilitaBotoes (INPUT TRUE).
    RUN pi-habilitaCampos (INPUT FALSE).
    RUN pi-abrirQuery.
END.

ON 'choose' OF bt-cancelar 
DO:
    RUN pi-habilitaBotoes (INPUT TRUE).
    RUN pi-habilitaCampos (INPUT FALSE).
    RUN pi-mostra.
END.
 
RUN pi-abrirQuery. 
RUN pi-habilitaBotoes (INPUT TRUE).
DISPLAY WITH FRAME f-produtos.
APPLY "choose" TO bt-primeiro.
WAIT-FOR ENDKEY OF FRAME f-produtos.


PROCEDURE pi-abrirQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Produtos THEN
    DO:
        ASSIGN rRecord = ROWID(Produtos).    
    END.
    
    OPEN QUERY q-produtos
        FOR EACH Produtos.
        
    REPOSITION q-produtos TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE pi-mostra:
    IF AVAILABLE Produtos THEN
    DO:
        DISPLAY Produtos.CodProduto 
                Produtos.NomProduto
                Produtos.ValProduto
                WITH FRAME f-produtos.
    END.
    ELSE DO:
        DISPLAY "" @ Produtos.CodProduto 
                "" @ Produtos.NomProduto
                "" @ Produtos.ValProduto
                WITH FRAME f-produtos.
        ASSIGN bt-primeiro:SENSITIVE = FALSE
            bt-anterior:SENSITIVE    = FALSE
            bt-proximo:SENSITIVE     = FALSE
            bt-ultimo:SENSITIVE      = FALSE
            bt-adicionar:SENSITIVE   = TRUE
            bt-editar:SENSITIVE      = FALSE
            bt-deletar:SENSITIVE     = FALSE
            bt-salvar:SENSITIVE      = FALSE
            bt-cancelar:SENSITIVE    = FALSE
            bt-exportar:SENSITIVE    = FALSE
            bt-sair:SENSITIVE        = TRUE.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-produtos:
        ASSIGN Produtos.NomProduto:SENSITIVE = pEnable
               Produtos.ValProduto:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-produtos:
        ASSIGN bt-primeiro:SENSITIVE = pEnable
            bt-anterior:SENSITIVE    = pEnable
            bt-proximo:SENSITIVE     = pEnable
            bt-ultimo:SENSITIVE      = pEnable
            bt-adicionar:SENSITIVE   = pEnable
            bt-editar:SENSITIVE      = pEnable
            bt-deletar:SENSITIVE     = pEnable
            bt-salvar:SENSITIVE      = NOT pEnable
            bt-cancelar:SENSITIVE    = NOT pEnable
            bt-exportar:SENSITIVE    = pEnable
            bt-sair:SENSITIVE        = pEnable.
    END.
END PROCEDURE.
