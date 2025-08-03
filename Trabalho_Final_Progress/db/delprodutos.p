TRIGGER PROCEDURE FOR DELETE OF Produtos.

FIND FIRST Itens WHERE Itens.CodProduto = Produtos.CodProduto NO-ERROR.
IF NOT AVAILABLE Itens THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "Não é possivel deletar o Produto " Produtos.CodProduto " Pois ele está associado a um Pedido."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN ERROR.
END.
