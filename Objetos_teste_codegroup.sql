create or replace NONEDITIONABLE FUNCTION fctcalcpedido(p_pedido_id IN NUMBER) RETURN VARCHAR2
--
 IS
  --
  vretorno NUMBER := 0;

BEGIN
  
    SELECT nvl(total_pedido,0)
      INTO   vretorno
     FROM   pedidos p
    WHERE  p.pedido_id = p_pedido_id;

    IF vretorno = 0 THEN
    
     SELECT (p.preco * i.quantidade) total_pedido
       INTO vretorno
     FROM itens_pedido i,
          produtos p
     WHERE i.produto_id = p.produto_id
     AND i.pedido_id = p_pedido_id;
        RETURN vretorno;
    
    END IF;
  
  RETURN vretorno;

EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20001,
                             'Erro ao calcular  preço * quantidade compra do cliente, favor entrar com contato com time de TI!' ||
                              SQLERRM);

END fctcalcpedido;
/


CREATE OR REPLACE TRIGGER trg_a_itens_pedido
  AFTER INSERT OR UPDATE OR DELETE ON itens_pedido
  FOR EACH ROW
DECLARE
  l_valor_itens NUMBER;
BEGIN

  IF (inserting) THEN
  
    SELECT a.preco * :new.quantidade
    INTO   l_valor_itens
    FROM   produtos a
    WHERE  a.produto_id = :new.produto_id;
  
    UPDATE pedidos a
    SET    a.total_pedido = a.total_pedido + l_valor_itens
    WHERE  a.pedido_id = :new.pedido_id;
  
  ELSIF (updating) THEN
  
    IF (:old.quantidade > :new.quantidade) THEN
      SELECT a.preco * (:old.quantidade - :new.quantidade)
      INTO   l_valor_itens
      FROM   produtos a
      WHERE  a.produto_id = :new.produto_id;
    
      UPDATE pedidos a
      SET    a.total_pedido = a.total_pedido - l_valor_itens
      WHERE  a.pedido_id = :new.pedido_id;
    
    ELSE
    
      SELECT a.preco * (:new.quantidade - :old.quantidade)
      INTO   l_valor_itens
      FROM   produtos a
      WHERE  a.produto_id = :new.produto_id;
    
      UPDATE pedidos a
      SET    a.total_pedido = a.total_pedido + l_valor_itens
      WHERE  a.pedido_id = :new.pedido_id;
    
    END IF;
  
  ELSIF (deleting) THEN
  
    SELECT a.preco * :old.quantidade
    INTO   l_valor_itens
    FROM   produtos a
    WHERE  a.produto_id = :old.produto_id;
  
    UPDATE pedidos a
    SET    a.total_pedido = a.total_pedido - l_valor_itens
    WHERE  a.pedido_id = :old.pedido_id;
  
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20001,
                            'Erro na trigger "trg_a_itens_pedido", Favor entrar com contato com time de TI!' ||
                            SQLERRM);
  
END trg_a_itens_pedido;
/

CREATE OR REPLACE PROCEDURE prc_rel_comp_cli
(
  p_cliente_id IN NUMBER,
  p_produto_id IN NUMBER,
  p_quant      IN NUMBER
) IS
  v_pedido_id NUMBER := 0;

BEGIN

  SAVEPOINT salv_oper;

  -- inseri uma nova linha..
  INSERT INTO pedidos
    (pedido_id,
     cliente_id,
     data_pedido,
     total_pedido)
  VALUES
    (pedidos_seq.nextval,
     p_cliente_id,
     trunc(SYSDATE),
     0)
  RETURNING pedido_id INTO v_pedido_id;

  -- inseri itens do pedido
  INSERT INTO itens_pedido
    (item_id,
     pedido_id,
     produto_id,
     quantidade)
  VALUES
    (itens_pedido_seq.nextval,
     v_pedido_id,
     p_produto_id,
     p_quant);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO salv_oper;
    raise_application_error(-20001,
                            'Erro ao inserir compra do cliente, favor entrar com contato com time de TI!' ||
                            SQLERRM);
  
END prc_rel_comp_cli;
/
