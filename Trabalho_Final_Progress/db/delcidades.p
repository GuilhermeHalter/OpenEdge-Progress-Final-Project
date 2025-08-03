TRIGGER PROCEDURE FOR DELETE OF Cidades.
FIND FIRST Cliente WHERE Cliente.CodCidade = Cidade.CodCidade NO-ERROR.
IF NOT AVAILABLE Cliente THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "Essa Cidade esta associada a um Cliente " Cliente.codCliente ". Não é possivel excluir."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        RETURN ERROR.
END.
