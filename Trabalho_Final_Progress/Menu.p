/*Menu.p*/
CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-cidades LABEL "Cidades".
DEFINE BUTTON bt-produtos LABEL "Produtos".
DEFINE BUTTON bt-clientes LABEL "Clientes".
DEFINE BUTTON bt-pedidos LABEL "Pedidos".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.
DEFINE BUTTON bt-relatClientes LABEL "Relatorio de Clientes".
DEFINE BUTTON bt-relatPedidos LABEL "Relatorio de Pedidos".

DEFINE FRAME f-Menu
    bt-cidades AT 10
    bt-produtos
    bt-clientes
    bt-pedidos SKIP(1)
    bt-sair
    bt-relatClientes
    bt-relatPedidos
    WITH SIZE 120 BY 20
        VIEW-AS DIALOG-BOX TITLE "Hamburgueria Xtudo".
        

ON 'choose' OF bt-clientes
DO:
    RUN c:/Trabalho_Final_Progress/modules/clientes.p.
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

