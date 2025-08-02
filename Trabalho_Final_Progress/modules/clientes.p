/*Clientes.p*/

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
    WITH SIZE 120 BY 20
        VIEW-AS DIALOG-BOX TITLE "Clientes".
 
 
RUN pi-habilitaBotoes (INPUT TRUE).
DISPLAY WITH FRAME f-clientes.
WAIT-FOR ENDKEY OF FRAME f-clientes.
        
PROCEDURE pi-habilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    
    DO WITH FRAME f-clientes:
        ASSIGN bt-primeiro:SENSITIVE = pEnable
            bt-anterior:SENSITIVE = pEnable
            bt-proximo:SENSITIVE = pEnable
            bt-ultimo:SENSITIVE = pEnable
            bt-adicionar:SENSITIVE = pEnable
            bt-editar:SENSITIVE = pEnable
            bt-deletar:SENSITIVE = pEnable
            bt-salvar:SENSITIVE = pEnable
            bt-cancelar:SENSITIVE = pEnable
            bt-exportar:SENSITIVE = pEnable
            bt-sair:SENSITIVE = pEnable.
    END.
END PROCEDURE.
