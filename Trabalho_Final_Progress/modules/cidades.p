/*Cidades.p*/
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

{c:/Trabalho_Final_Progress/includes/navbar.i}

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY q-cidades FOR Cidades SCROLLING.

DEFINE BUFFER b-cidades FOR Cidades.

DEFINE FRAME f-cidades
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
    Cidades.CodCidade COLON 20
    Cidades.NomCidade COLON 20
    Cidades.CodUF COLON 20
    WITH SIDE-LABELS THREE-D SIZE 120 BY 20
        VIEW-AS DIALOG-BOX TITLE "Cidades".

        
ON 'choose' OF bt-primeiro 
DO:
    GET FIRST q-cidades.
    RUN pi-mostra.
END.

ON 'choose' OF bt-anterior 
DO:
    GET PREV q-cidades.
    IF NOT AVAILABLE Cidades THEN
    DO:
        GET LAST q-cidades.    
    END.
    RUN pi-mostra.
END.

ON 'choose' OF bt-proximo 
DO:
    GET NEXT q-cidades.
    IF NOT AVAILABLE cidades THEN
    DO:
        GET FIRST q-cidades.        
    END.
    RUN pi-mostra.
END.

ON 'choose' OF bt-ultimo 
DO:
    GET LAST q-cidades.
    RUN pi-mostra.
END.


/*Adicionar*/
ON 'choose' OF bt-adicionar 
DO:
    ASSIGN cAction = "add".
    RUN pi-habilitaBotoes (INPUT FALSE).
    RUN pi-habilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-cidades.
    DISPLAY NEXT-VALUE(seqCidade) @ Cidades.CodCidade WITH FRAME f-cidades.
    
END. /*FIM Adicionar*/

/*Editar*/
ON 'choose' OF bt-editar 
DO:
   ASSIGN cAction = "edit".
   RUN pi-habilitaBotoes (INPUT FALSE).
   RUN Pi-habilitaCampos (INPUT TRUE).
   
   DISPLAY Cidades.CodCidade WITH FRAME f-cidades.
   RUN pi-mostra.
END. /*FIM Editar*/

/*Deletar*/
ON 'choose' OF bt-deletar 
DO:
    DEFINE VARIABLE lConfirm AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER b-city FOR Cidades.
    
    MESSAGE "Deseja realmente eliminar a Cidade" Cidade.CodCidade "?" UPDATE lConfirm
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminar Cidade".
    IF lConfirm THEN
    DO:
        FIND b-city 
            WHERE b-city.CodCidade = Cidades.CodCidade
            EXCLUSIVE-LOCK NO-ERROR.
        DELETE b-city.
        RUN pi-AbrirQuery.
        APPLY "choose" TO bt-proximo IN FRAME f-cidades.
    END.
END. /*FIM Deletar*/

/*Exportar*/
ON 'choose' OF bt-exportar 
DO:
    /*CSV*/
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "cidades.csv".
    OUTPUT TO VALUE(cArq).
    FOR EACH cidades NO-LOCK:
        PUT UNFORMATTED Cidades.CodCidade ";"
                        Cidades.NomCidade ";"
                        Cidade.CodUF      ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
    
    /*JSON*/
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oObj AS JsonObject NO-UNDO.
    DEFINE VARIABLE aCidades AS JsonArray NO-UNDO.
    
    ASSIGN cArquivo = SESSION:TEMP-DIRECTORY + "cidades.json".
    aCidades = NEW JsonArray().
    FOR EACH Cidades NO-LOCK:
        oObj = NEW JsonObject().
        oObj:ADD("CodCidade", Cidades.CodCidade).
        oObj:ADD("NomCidade", Cidades.NomCidade).
        oObj:ADD("CodUF", Cidades.CodUF).
        aCidades:ADD(oObj).
    END.
    aCidades:WriteFile(INPUT cArquivo, INPUT YES, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivo).
END. /*FIM Exportar*/
        
ON 'choose' OF bt-salvar 
DO:
    IF cAction = "add" THEN
    DO:
        CREATE b-cidades.
        ASSIGN b-cidades.CodCidade = INPUT Cidades.CodCidade.
    END.
    IF cAction = "edit" THEN
    DO:
        FIND FIRST b-cidades
            WHERE b-cidades.CodCidade = Cidades.CodCidade
            EXCLUSIVE-LOCK NO-ERROR.
    END.

    ASSIGN b-cidades.NomCidade = INPUT Cidades.NomCidade
           b-cidades.CodUF = INPUT Cidades.CodUF.
           
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
DISPLAY WITH FRAME f-cidades.
APPLY "CHOOSE" TO bt-primeiro.

WAIT-FOR ENDKEY OF FRAME f-cidades.


PROCEDURE pi-abrirQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Cidades THEN
    DO:
        ASSIGN rRecord = ROWID(Cidades).    
    END.
    
    OPEN QUERY q-cidades
        FOR EACH cidades.
        
    REPOSITION q-cidades TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE pi-mostra:
    IF AVAILABLE Cidades THEN
    DO:
        DISPLAY Cidades.CodCidade 
                Cidades.NomCidade 
                Cidades.CodUF
                WITH FRAME f-cidades.
    END.
    ELSE DO:
        DISPLAY "" @ Cidades.CodCidade 
                "" @ Cidades.NomCidade 
                "" @ Cidades.CodUF
                WITH FRAME f-cidades.
        DO WITH FRAME f-cidades:
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
    END.
END PROCEDURE.

PROCEDURE pi-habilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-cidades:
        ASSIGN Cidades.NomCidade:SENSITIVE = pEnable
               Cidades.CodUF:SENSITIVE      = pEnable.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-cidades:
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
