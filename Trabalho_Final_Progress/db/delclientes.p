TRIGGER PROCEDURE FOR DELETE OF Clientes.

FIND FIRST Pedidos WHERE Pedidos.CodCliente = Clientes.CodCliente NO-ERROR.
IF NOT AVAILABLE Pedidos THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "O Cliente " Clientes.CodCliente " n�o pode ser excluido pois h� pedidos asociados a ele"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN ERROR.
END.
