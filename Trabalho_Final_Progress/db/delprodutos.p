TRIGGER PROCEDURE FOR DELETE OF Produtos.

FIND FIRST Itens WHERE Itens.CodProduto = Produtos.CodProduto NO-ERROR.
IF NOT AVAILABLE Itens THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "N�o � possivel deletar o Produto " Produtos.CodProduto " Pois ele est� associado a um Pedido."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN ERROR.
END.
