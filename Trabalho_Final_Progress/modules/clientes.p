/*Clientes.p*/

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-primeiro LABEL "<<".
DEFINE BUTTON bt-anterior LABEL "<".
DEFINE BUTTON bt-proximo LABEL ">".
DEFINE BUTTON bt-ultimo LABEL ">>".
DEFINE BUTTON bt-adicionar LABEL "Adicionar".
DEFINE BUTTON bt-editar LABEL "Modificar".
DEFINE BUTTON bt-deletar LABEL "Eliminar".
DEFINE BUTTON bt-salvar LABEL "Salvar".
DEFINE BUTTON bt-cancelar LABEL "Cancelar".
DEFINE BUTTON bt-exportar LABEL "Exportar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY q-clientes FOR Clientes, Cidades SCROLLING.

DEFINE BUFFER b-clientes FOR Clientes.
DEFINE BUFFER b-cidades FOR Cidades.

DEFINE FRAME f-clientes
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
    Clientes.CodCliente  COLON 20
    Clientes.NomCliente  COLON 20
    Clientes.CodEndereco  COLON 20
    Clientes.CodCidade    COLON 20 Cidades.NomCidade NO-LABELS
    Clientes.Observacao   COLON 20
    WITH SIDE-LABELS SIZE 120 BY 10
        VIEW-AS DIALOG-BOX TITLE "Clientes".
 
ON 'choose' OF bt-primeiro 
DO:
    GET FIRST q-clientes.
    RUN pi-mostra.
END.

ON 'choose' OF bt-anterior 
DO:
    GET PREV q-clientes.
    RUN pi-mostra.
END.

ON 'choose' OF bt-proximo 
DO:
    GET NEXT q-clientes.
    RUN pi-mostra.
END.

ON 'choose' OF bt-ultimo 
DO:
    GET LAST q-clientes.
    RUN pi-mostra.
END.

/*Adicionar*/
ON 'choose' OF bt-adicionar 
DO:
    ASSIGN cAction = "add".
    RUN pi-habilitaBotoes (INPUT FALSE).
    RUN pi-habilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-clientes.
    DISPLAY NEXT-VALUE(seqCliente) @ Clientes.CodCliente WITH FRAME f-clientes. 

END. /*FIM Adicionar*/

/*Editar*/
ON 'choose' OF bt-editar 
DO:
   ASSIGN cAction = "edit".
   RUN pi-habilitaBotoes (INPUT FALSE).
   RUN Pi-habilitaCampos (INPUT TRUE).
   
   DISPLAY Clientes.CodCliente WITH FRAME f-clientes.
   RUN pi-mostra.
END. /*FIM Editar*/

/*Deletar*/
ON 'choose' OF bt-deletar 
DO:
    DEFINE VARIABLE lConfirm AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER b-clie FOR Clientes.
    
    MESSAGE "Deseja realmente eliminar o Cliente" Clientes.CodCliente "?" UPDATE lConfirm
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminar Cliente".
    IF lConfirm THEN
    DO:
        FIND b-clie 
            WHERE b-clie.CodCliente = Clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
        DELETE b-clie.
        RUN pi-AbrirQuery.
        APPLY "choose" TO bt-proximo IN FRAME f-clientes.
    END.
END. /*FIM Deletar*/

/*Exportar*/
ON 'choose' OF bt-exportar 
DO:
    /*CSV*/
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.csv".
    OUTPUT TO VALUE(cArq).
    FOR EACH clientes NO-LOCK,
        EACH cidades WHERE Cidade.CodCidade = Clientes.CodCidade NO-LOCK:
            PUT UNFORMATTED Clientes.CodCliente  ";"
                            Clientes.NomCliente  ";"
                            Clientes.CodEndereco ";"
                            Clientes.CodCidade   ";"
                            Cidades.NomCidade    ";"
                            Clientes.Observacao  ";".
            PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
    
    /*JSON*/
    DEFINE VARIABLE cArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE oObj AS JsonObject NO-UNDO.
    DEFINE VARIABLE aClientes AS JsonArray NO-UNDO.
    
    ASSIGN cArquivo = SESSION:TEMP-DIRECTORY + "clientes.json".
    aClientes = NEW JsonArray().
    FOR EACH Clientes NO-LOCK,
        EACH cidades WHERE Cidade.CodCidade = Clientes.CodCidade NO-LOCK:
            oObj = NEW JsonObject().
            oObj:ADD("CodCliente", Cliente.CodCliente).
            oObj:ADD("NomCliente", Cliente.NomCliente).
            oObj:ADD("CodEndereco", Cliente.CodEndereco).
            oObj:ADD("CodCidade", Cliente.CodCidade).
            oObj:ADD("NomCidade", Cidade.NomCidade).
            oObj:ADD("Observacao", Cliente.Observacao).
            aClientes:ADD(oObj).
    END.
    aClientes:WriteFile(INPUT cArquivo, INPUT YES, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArquivo).
END. /*FIM Exportar*/

ON 'leave' OF clientes.CodCidade
DO:
    DEFINE VARIABLE cNomeCidade AS CHARACTER NO-UNDO.

    FIND FIRST Cidades WHERE Cidades.CodCidade = INTEGER(Clientes.CodCidade:SCREEN-VALUE) NO-LOCK NO-ERROR.
    
    IF AVAILABLE Cidades THEN
        cNomeCidade = Cidades.NomCidade.
    ELSE
        cNomeCidade = "".

    DISPLAY cNomeCidade @ Cidades.NomCidade WITH FRAME f-clientes.
END.


ON 'choose' OF bt-salvar 
DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    
    RUN pi-validaCidade(INPUT Clientes.CodCidade:SCREEN-VALUE,
                        OUTPUT lValid).
    IF lValid = NO THEN
    DO:
        RETURN NO-APPLY.    
    END.
    
    IF cAction = "add" THEN
    DO:
        CREATE b-clientes.
        ASSIGN b-clientes.CodCliente = INPUT Clientes.CodCliente.
    END.
    IF cAction = "edit" THEN
    DO:
        FIND FIRST b-clientes
            WHERE b-clientes.CodCliente = Clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
    END.
    
    ASSIGN b-clientes.NomCliente = INPUT Clientes.NomCliente
           b-clientes.CodEndereco = INPUT Clientes.CodEndereco
           b-clientes.CodCidade = INPUT Clientes.CodCidade
           b-clientes.Observacao = INPUT Clientes.Observacao.
    
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
DISPLAY WITH FRAME f-clientes.
WAIT-FOR ENDKEY OF FRAME f-clientes.
                  
PROCEDURE pi-abrirQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Clientes THEN
    DO:
        ASSIGN rRecord = ROWID(Clientes).    
    END.
    
    OPEN QUERY q-clientes
        FOR EACH clientes,
            FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade.
        
    REPOSITION q-clientes TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE pi-mostra:
    IF AVAILABLE Clientes THEN
    DO:
        DISPLAY Clientes.CodCliente
                Clientes.NomCliente
                Clientes.CodEndereco
                Clientes.CodCidade
                Cidade.NomCidade
                Clientes.Observacao
                WITH FRAME f-clientes.
    END.
    ELSE DO:
        CLEAR FRAME f-clientes.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-clientes:
        ASSIGN Clientes.NomCliente:SENSITIVE  = pEnable
               Clientes.CodEndereco:SENSITIVE = pEnable
               Clientes.CodCidade:SENSITIVE   = pEnable
               Clientes.Observacao:SENSITIVE  = pEnable.
    END.
END PROCEDURE.

PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-clientes:
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

PROCEDURE pi-validaCidade:
    DEFINE INPUT PARAMETER pCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValido AS LOGICAL NO-UNDO INITIAL NO.
    
    FIND FIRST b-cidades
        WHERE b-cidades.CodCidade = pCidade
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-cidades THEN
    DO:
        MESSAGE "Cidade" pCidade "nao existe!!!"
            VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValido = NO.
    END.
    ELSE
        ASSIGN pValido = YES.
END PROCEDURE.
