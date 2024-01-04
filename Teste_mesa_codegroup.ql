SELECT * FROM produtos;
SELECT * FROM clientes;
SELECT * FROM pedidos;
SELECT * FROM itens_pedido;


-- TESTA A FUNÇAO
SELECT fctcalcpedido(1) FROM DUAL;


-- CHAMA O PROCESSO
BEGIN
  prc_rel_comp_cli (p_cliente_id => 3 ,
                    p_produto_id => 3 ,
                    p_quant   =>    2);
END;
/

-- VALOR .. PRODUTO 1 =>  10
-- VALOR .. PRODUTO 2 =>  20
-- VALOR .. PRODUTO 3 =>  30


DELETE pedidos;
DELETE itens_pedido;

SELECT * FROM pedidos;
-- WHERE PEDIDO_ID = 1;
SELECT * FROM itens_pedido
WHERE item_id = 1;

UPDATE itens_pedido a SET a.quantidade = 1 
 WHERE a.pedido_id = 9
AND a.item_id = 9; 
COMMIT;

DELETE itens_pedido 
 WHERE pedido_id = 9
AND item_id = 9; 
COMMIT;










