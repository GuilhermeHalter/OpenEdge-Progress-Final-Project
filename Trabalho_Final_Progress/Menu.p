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
    WITH SIZE 120 BY 20
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

