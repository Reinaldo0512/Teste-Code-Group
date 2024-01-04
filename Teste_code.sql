--DROP TABLE CLIENTES;
--DROP TABLE PRODUTOS;
--DROP TABLE ITENS_PEDIDO;
--DROP TABLE PEDIDOS;

--DROP SEQUENCE pedidos_seq; 
--DROP SEQUENCE itens_pedido_seq; 
--DROP SEQUENCE clientes_seq;
--DROP SEQUENCE produtos_seq; 


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


-- INSERT..
insert into produtos (produto_id,
                      nome,
                      preco)
VALUES (produtos_seq.nextval,
        'pasta de dente oral B',
		10);
commit;

insert into produtos (produto_id,
                      nome,
                      preco)
VALUES (produtos_seq.nextval,
        'fio dental c/ hortelã',
		20);
commit;

insert into produtos (produto_id,
                      nome,
                      preco)
VALUES (produtos_seq.nextval,
        'escova dental oral B',
		30);
commit;

insert into clientes (cliente_id, 
                      nome,  
                      email) 
        VALUES (clientes_seq.nextval,
		        'João Gilherme da silva',
				'jfs@codegroup.com.br');
commit;

insert into clientes (cliente_id, 
                      nome,  
                      email) 
        VALUES (clientes_seq.nextval,
		        'Fernando miranda',
				'Fermiranda@codegroup.com.br');
commit;				

insert into clientes (cliente_id, 
                      nome,  
                      email )
        VALUES (clientes_seq.nextval,
		        'Jessica miranda',
				'jessica@codegroup.com.br');
commit;
