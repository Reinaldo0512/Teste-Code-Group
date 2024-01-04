-- ----------------------------------------------------- 
-- Table Produtos
-- ----------------------------------------------------- 
CREATE TABLE produtos (
    produto_id NUMBER PRIMARY KEY,
    nome VARCHAR2(50),
    preco NUMBER
);
-- ----------------------------------------------------- 
-- Table Clientes 
-- ----------------------------------------------------- 
CREATE TABLE clientes (
    cliente_id NUMBER PRIMARY KEY,
    nome VARCHAR2(50),
    email VARCHAR2(50)
);
-- ----------------------------------------------------- 
-- Table Pedidos 
-- ----------------------------------------------------- 
CREATE TABLE pedidos (
    pedido_id NUMBER PRIMARY KEY,
    cliente_id NUMBER,
    data_pedido DATE,
    total_pedido NUMBER,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);
-- ----------------------------------------------------- 
-- Table Itens Pedido
-- ----------------------------------------------------- 
CREATE TABLE itens_pedido (
    item_id NUMBER PRIMARY KEY,
    pedido_id NUMBER,
    produto_id NUMBER,
    quantidade NUMBER,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
    FOREIGN KEY (produto_id) REFERENCES produtos(produto_id)
);


-- sequence..
create sequence pedidos_seq
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
/

create sequence itens_pedido_seq
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
/

create sequence clientes_seq
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
/

create sequence produtos_seq
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
nocache;
/

-- insert..

insert into produtos (produto_id,
                      nome,
                      preco)
valeus (produtos.seq.nextval,
        'pasta de dente oral B',
		10);
commit;

insert into produtos (produto_id,
                      nome,
                      preco)
valeus (produtos.seq.nextval,
        'fio dental c/ hortelã',
		5);
commit;

insert into produtos (produto_id,
                      nome,
                      preco)
valeus (produtos.seq.nextval,
        'escova dental oral B',
		15);
commit;
--

insert into clientes (cliente_id, 
                      nome,  
                      email  
        valeus (clientes_seq.nextval,
		        'João Gilherme da silva',
				'jfs@codegroup.com.br');
commit;

insert into clientes (cliente_id, 
                      nome,  
                      email  
        valeus (clientes_seq.nextval,
		        'Fernando miranda',
				'Fermiranda@codegroup.com.br');
commit;				

insert into clientes (cliente_id, 
                      nome,  
                      email  
        valeus (clientes_seq.nextval,
		        'Jessica miranda',
				'jessica@codegroup.com.br');
commit;

/*  Programa - Codigo */


CREATE OR REPLACE FUNCTION fctcalcpedido(p_pedido_id IN NUMBER) RETURN VARCHAR2
--
 IS
  --
  vretorno NUMBER := 0;

BEGIN

  SELECT total_pedido
  INTO   vretorno
  FROM   pedidos p
  WHERE  p.pedido_id = p_pedido_id;
  
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


-- teste de mesa..
SELECT * FROM produtos;
SELECT * FROM clientes;
SELECT * FROM pedidos; --FOR UPDATE;
SELECT * FROM itens_pedido;

DELETE FROM pedidos;
DELETE FROM itens_pedido;

INSERT INTO itens_pedido VALUES ( 1, 1, 1, 10 ); -- total 100
INSERT INTO itens_pedido VALUES ( 2, 1, 2, 5 ); -- total 125

UPDATE itens_pedido a SET a.quantidade = 100 WHERE a.pedido_id = 33 AND a.item_id = 43; -- total 150
UPDATE itens_pedido a SET a.quantidade = 1  WHERE a.pedido_id = 34 AND a.item_id = 44; -- total 100

DELETE FROM itens_pedido a WHERE a.item_id = 43; -- total 50
DELETE FROM itens_pedido a WHERE a.item_id = 44; 


BEGIN
  prc_rel_comp_cli (p_cliente_id => 1 ,
                    p_produto_id => 2 ,
                    p_quant   =>    5);
END;
/

