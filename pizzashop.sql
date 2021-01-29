-- Database: pizzashop

-- DROP DATABASE pizzashop;

CREATE DATABASE pizzashop
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
	
	

-- Table: public.tblingredients

-- DROP TABLE public.tblingredients;

CREATE TABLE public.tblingredients
(
    id integer NOT NULL DEFAULT nextval('tblingredients_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    isvisible boolean NOT NULL,
    isdeleted boolean NOT NULL,
    price integer NOT NULL,
    region text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tblingredients_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.tblingredients
    OWNER to postgres;
	
	
-- Table: public.tblsupplier

-- DROP TABLE public.tblsupplier;

CREATE TABLE public.tblsupplier
(
    id integer NOT NULL DEFAULT nextval('tblsupplier_id_seq'::regclass),
    name text COLLATE pg_catalog."default" NOT NULL,
    isvisible boolean NOT NULL,
    isdeleted boolean NOT NULL,
    CONSTRAINT tblsupplier_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.tblsupplier
    OWNER to postgres;
	
	
-- Table: public.tblstock

-- DROP TABLE public.tblstock;

CREATE TABLE public.tblstock
(
    id integer NOT NULL DEFAULT nextval('tblstock_id_seq'::regclass),
    supplierid integer NOT NULL,
    ingredientid integer NOT NULL,
    stock integer NOT NULL,
    CONSTRAINT tblstock_pkey PRIMARY KEY (id),
    CONSTRAINT "tblIngredientsFK" FOREIGN KEY (ingredientid)
        REFERENCES public.tblingredients (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "tblSupplierFK" FOREIGN KEY (supplierid)
        REFERENCES public.tblsupplier (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.tblstock
    OWNER to postgres;
	
	
-- Table: public.tblbasepizza

-- DROP TABLE public.tblbasepizza;

CREATE TABLE public.tblbasepizza
(
    id integer NOT NULL DEFAULT nextval('pizzaflavour_id_seq'::regclass),
    flavour text COLLATE pg_catalog."default" NOT NULL,
    price integer NOT NULL,
    CONSTRAINT pizzaflavour_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.tblbasepizza
    OWNER to postgres;
	
	
-- Table: public.tblpizzasize

-- DROP TABLE public.tblpizzasize;

CREATE TABLE public.tblpizzasize
(
    id integer NOT NULL DEFAULT nextval('pizzasize_id_seq'::regclass),
    size integer NOT NULL,
    price integer NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pizzasize_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.tblpizzasize
    OWNER to postgres;
	
-- Table: public.tblcomposedpizzaingredients

-- DROP TABLE public.tblcomposedpizzaingredients;

CREATE TABLE public.tblcomposedpizzaingredients
(
    composedpizzaid integer NOT NULL,
    ingredientid integer NOT NULL,
    id integer NOT NULL DEFAULT nextval('tblorderedpizzaingredients_id_seq'::regclass),
    CONSTRAINT tblorderedpizzaingredients_pkey PRIMARY KEY (id),
    CONSTRAINT "tblorderedpizzaingredientsFK" FOREIGN KEY (ingredientid)
        REFERENCES public.tblingredients (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.tblcomposedpizzaingredients
    OWNER to postgres;
	

-- Table: public.tblcomposedpizza

-- DROP TABLE public.tblcomposedpizza;

CREATE TABLE public.tblcomposedpizza
(
    basepizzaid integer NOT NULL,
    pizzasizeid integer NOT NULL,
    ingredientid integer NOT NULL,
    price integer NOT NULL,
    id integer NOT NULL DEFAULT nextval('tblcomposedpizza_id_seq'::regclass),
    CONSTRAINT tblcomposedpizza_pkey PRIMARY KEY (id),
    CONSTRAINT "tblcomposedpizzaBasePizzaFK" FOREIGN KEY (basepizzaid)
        REFERENCES public.tblbasepizza (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "tblcomposedpizzaPizzaSizeFK" FOREIGN KEY (pizzasizeid)
        REFERENCES public.tblpizzasize (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.tblcomposedpizza
    OWNER to postgres;
	

-- Table: public.tblorderedpizza

-- DROP TABLE public.tblorderedpizza;

CREATE TABLE public.tblorderedpizza
(
    id integer NOT NULL DEFAULT nextval('tblorderedpizza_id_seq'::regclass),
    composedpizzaid integer NOT NULL,
    datetime timestamp without time zone NOT NULL,
    CONSTRAINT tblorderedpizza_pkey PRIMARY KEY (id),
    CONSTRAINT "tblcomposedpizzaidFK" FOREIGN KEY (composedpizzaid)
        REFERENCES public.tblcomposedpizza (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.tblorderedpizza
    OWNER to postgres;
	
	
-- Type: ingredients_stock

-- DROP TYPE public.ingredients_stock;

CREATE TYPE public.ingredients_stock AS
(
	id integer,
	name text,
	isvisible boolean,
	isdeleted boolean,
	price integer,
	region text,
	"Stock" integer
);

ALTER TYPE public.ingredients_stock
    OWNER TO postgres;



-- Type: composed_pizza

-- DROP TYPE public.composed_pizza;

CREATE TYPE public.composed_pizza AS
(
	id integer,
	price integer,
	flavour text,
	pizzasize integer,
	ingredients text
);

ALTER TYPE public.composed_pizza
    OWNER TO postgres;


-- Type: ordered_pizza

-- DROP TYPE public.ordered_pizza;

CREATE TYPE public.ordered_pizza AS
(
	flavour text,
	size integer,
	price integer,
	datetime timestamp without time zone,
	ingredients text
);

ALTER TYPE public.ordered_pizza
    OWNER TO postgres;



-- FUNCTION: public.funcgetcomposedpizza()

-- DROP FUNCTION public.funcgetcomposedpizza();

CREATE OR REPLACE FUNCTION public.funcgetcomposedpizza(
	)
    RETURNS SETOF composed_pizza 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  result_record composed_pizza;
BEGIN
for result_record in select tblcomposedpizza.id as id, tblcomposedpizza.price as price, tblbasepizza.flavour as flavour, tblpizzasize.size as pizzasize, public.funcgetingredientsofcomposedpizza(tblcomposedpizza.ingredientid) as ingredients 
from tblcomposedpizza
INNER JOIN tblbasepizza ON tblbasepizza.id = tblcomposedpizza.basepizzaid
INNER JOIN tblpizzasize ON tblpizzasize.id = tblcomposedpizza.pizzasizeid loop
RETURN next result_record;
end loop;
return;
END
$BODY$;

ALTER FUNCTION public.funcgetcomposedpizza()
    OWNER TO postgres;



-- FUNCTION: public.funcgetingredientsofcomposedpizza(integer)

-- DROP FUNCTION public.funcgetingredientsofcomposedpizza(integer);

CREATE OR REPLACE FUNCTION public.funcgetingredientsofcomposedpizza(
	paramingredientid integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
RETURN (select STRING_AGG(tblingredients.name, ',') as Ingredients
from tblingredients
inner join tblcomposedpizzaingredients 
on tblcomposedpizzaingredients.ingredientid = tblingredients.id
where tblcomposedpizzaingredients.composedpizzaid = paramingredientid);
END
$BODY$;

ALTER FUNCTION public.funcgetingredientsofcomposedpizza(integer)
    OWNER TO postgres;


-- FUNCTION: public.funcgetingredientswithstockbaker()

-- DROP FUNCTION public.funcgetingredientswithstockbaker();

CREATE OR REPLACE FUNCTION public.funcgetingredientswithstockbaker(
	)
    RETURNS SETOF ingredients_stock 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  result_record ingredients_stock;
BEGIN
for result_record in select tblingredients.id as id, tblingredients.name as name, tblingredients.isvisible as isvisible, tblingredients.isdeleted as indeleted,tblingredients.price as price,
tblingredients.region as region, CASE WHEN SUM(tblstock.stock) IS NULL THEN 0 ELSE SUM(tblstock.stock)  END as Stock from tblingredients
LEFT JOIN tblstock
ON tblingredients.id = tblstock.ingredientid
GROUP BY tblingredients.id
having tblingredients.isdeleted = false loop
RETURN next result_record;
end loop;
return;
END
$BODY$;

ALTER FUNCTION public.funcgetingredientswithstockbaker()
    OWNER TO postgres;


-- FUNCTION: public.funcgetingredientswithstockcustomer()

-- DROP FUNCTION public.funcgetingredientswithstockcustomer();

CREATE OR REPLACE FUNCTION public.funcgetingredientswithstockcustomer(
	)
    RETURNS SETOF ingredients_stock 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  result_record ingredients_stock;
BEGIN
for result_record in select tblingredients.id as id, tblingredients.name as name, tblingredients.isvisible as isvisible, tblingredients.isdeleted as indeleted,tblingredients.price as price,
tblingredients.region as region, SUM(tblstock.stock) as Stock from tblingredients
inner join tblstock
ON tblingredients.id = tblstock.ingredientid
GROUP BY tblingredients.id
having tblingredients.isvisible = true and tblingredients.isdeleted = false and SUM(tblstock.stock) > 0 loop
RETURN next result_record;
end loop;
return;
END
$BODY$;

ALTER FUNCTION public.funcgetingredientswithstockcustomer()
    OWNER TO postgres;


-- FUNCTION: public.funcgetorderedpizza()

-- DROP FUNCTION public.funcgetorderedpizza();

CREATE OR REPLACE FUNCTION public.funcgetorderedpizza(
	)
    RETURNS SETOF ordered_pizza 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  result_record Ordered_Pizza;
BEGIN
for result_record in select tblbasepizza.flavour as flavour, tblpizzasize.size as size, tblcomposedpizza.price as price, tblorderedpizza.datetime as datetime,
public.funcgetingredientsofcomposedpizza(tblcomposedpizza.ingredientid) as ingredients
from tblcomposedpizza
INNER JOIN tblbasepizza on tblbasepizza.id = tblcomposedpizza.basepizzaid
INNER JOIN tblpizzasize on tblpizzasize.id = tblcomposedpizza.pizzasizeid
INNER JOIN tblorderedpizza on tblorderedpizza.composedpizzaid = tblcomposedpizza.id loop
RETURN next result_record;
end loop;
return;
END
$BODY$;

ALTER FUNCTION public.funcgetorderedpizza()
    OWNER TO postgres;


-- FUNCTION: public.funcgetorderedpizza(integer)

-- DROP FUNCTION public.funcgetorderedpizza(integer);

CREATE OR REPLACE FUNCTION public.funcgetorderedpizza(
	paramingredientid integer)
    RETURNS SETOF ordered_pizza 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
  result_record Ordered_Pizza;
BEGIN
for result_record in select tblbasepizza.flavour as flavour, tblpizzasize.size as size, tblcomposedpizza.price as price, tblorderedpizza.datetime as datetime,
public.funcgetingredientsofcomposedpizza(tblcomposedpizza.ingredientid) as ingredients
from tblcomposedpizza
INNER JOIN tblbasepizza on tblbasepizza.id = tblcomposedpizza.basepizzaid
INNER JOIN tblpizzasize on tblpizzasize.id = tblcomposedpizza.pizzasizeid
INNER JOIN tblorderedpizza on tblorderedpizza.composedpizzaid = tblcomposedpizza.id
where tblcomposedpizza.id = paramingredientid loop
RETURN next result_record;
end loop;
return;
END
$BODY$;

ALTER FUNCTION public.funcgetorderedpizza(integer)
    OWNER TO postgres;


-- PROCEDURE: public.procaddbasepizza(text, integer)

-- DROP PROCEDURE public.procaddbasepizza(text, integer);

CREATE OR REPLACE PROCEDURE public.procaddbasepizza(
	basepizzaname text,
	basepizzaprice integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblbasepizza (flavour, price) values (basepizzaname,basepizzaprice);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddcomposedpizza(integer, integer, integer, integer[])

-- DROP PROCEDURE public.procaddcomposedpizza(integer, integer, integer, integer[]);

CREATE OR REPLACE PROCEDURE public.procaddcomposedpizza(
	basepizzaid integer,
	pizzasizeid integer,
	ingreidentid integer,
	ingredientidsforprice integer[])
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
finalsum integer;
baseprice integer;
sizeprice integer;
ingredientprice integer;
begin
   baseprice :=(select price from tblbasepizza where id = basePizzaid);
sizeprice :=(select price from tblpizzasize where id = pizzasizeid);
ingredientprice := (select SUM(price) from tblingredients where id =  ANY (ingredientidsforprice));
finalsum := (baseprice + sizeprice + ingredientprice);
--finalsum := 10;
INSERT INTO tblcomposedpizza (basepizzaid, pizzasizeid, ingredientid, price) values (basePizzaid,pizzasizeid,ingreidentid,finalsum);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddcomposedpizzaingredients(integer, integer)

-- DROP PROCEDURE public.procaddcomposedpizzaingredients(integer, integer);

CREATE OR REPLACE PROCEDURE public.procaddcomposedpizzaingredients(
	composedpizzaid integer,
	ingredientid integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblcomposedpizzaingredients (composedpizzaid, ingredientid) values (composedpizzaid,ingredientid);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddflavour(text, integer)

-- DROP PROCEDURE public.procaddflavour(text, integer);

CREATE OR REPLACE PROCEDURE public.procaddflavour(
	flavourname text,
	price integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblpizzaflavour (flavour, price) values (flavourname,price);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddingredient(text, integer, text)

-- DROP PROCEDURE public.procaddingredient(text, integer, text);

CREATE OR REPLACE PROCEDURE public.procaddingredient(
	ingredientname text,
	ingredientprice integer,
	ingredientregion text)
LANGUAGE 'plpgsql'
AS $BODY$
begin
   INSERT INTO tblingredients (name,price,region, isvisible,isdeleted) values (ingredientname,ingredientprice,ingredientregion,true,false);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddsize(integer, integer)

-- DROP PROCEDURE public.procaddsize(integer, integer);

CREATE OR REPLACE PROCEDURE public.procaddsize(
	size integer,
	price integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblpizzasize (size, price) values (size,price);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procaddstock(integer, integer, integer)

-- DROP PROCEDURE public.procaddstock(integer, integer, integer);

CREATE OR REPLACE PROCEDURE public.procaddstock(
	supplierid integer,
	ingredientid integer,
	stockid integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
	INSERT INTO tblstock (supplierid, ingredientid,stock) values (supplierId,ingredientId,stockId);
    commit;
end;
$BODY$;

-- PROCEDURE: public.procaddsupplier(text)

-- DROP PROCEDURE public.procaddsupplier(text);

CREATE OR REPLACE PROCEDURE public.procaddsupplier(
	suppliername text)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblsupplier (name, isvisible,isdeleted) values (suppliername,true,false);
    commit;
end;
$BODY$;

-- PROCEDURE: public.procdeleteingredient(integer)

-- DROP PROCEDURE public.procdeleteingredient(integer);

CREATE OR REPLACE PROCEDURE public.procdeleteingredient(
	ingredientid integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
	UPDATE tblingredients
	SET isdeleted = true
	WHERE id = ingredientid;
    commit;
end;
$BODY$;


-- PROCEDURE: public.procdeletesupplier(integer)

-- DROP PROCEDURE public.procdeletesupplier(integer);

CREATE OR REPLACE PROCEDURE public.procdeletesupplier(
	supplierid integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
	UPDATE tblsupplier
	SET isdeleted = true
	WHERE id = supplierid;
    commit;
end;
$BODY$;


-- PROCEDURE: public.procorderpizza(integer)

-- DROP PROCEDURE public.procorderpizza(integer);

CREATE OR REPLACE PROCEDURE public.procorderpizza(
	composedid integer)
LANGUAGE 'plpgsql'
AS $BODY$
begin
    -- subtracting the amount from the sender's account 
   INSERT INTO tblorderedpizza (composedpizzaid, datetime)
	VALUES (composedid,current_timestamp);
    commit;
end;
$BODY$;


-- PROCEDURE: public.procsetingredientvisibility(integer, boolean)

-- DROP PROCEDURE public.procsetingredientvisibility(integer, boolean);

CREATE OR REPLACE PROCEDURE public.procsetingredientvisibility(
	ingredientid integer,
	ingredientvisibility boolean)
LANGUAGE 'plpgsql'
AS $BODY$
begin
	UPDATE tblingredients
	SET isvisible = ingredientvisibility
	WHERE id = ingredientid;
    commit;
end;
$BODY$;


-- PROCEDURE: public.procsetsuppliervisibility(integer, boolean)

-- DROP PROCEDURE public.procsetsuppliervisibility(integer, boolean);

CREATE OR REPLACE PROCEDURE public.procsetsuppliervisibility(
	supplierid integer,
	suppliervisibility boolean)
LANGUAGE 'plpgsql'
AS $BODY$
begin
	UPDATE tblsupplier
	SET isvisible = suppliervisibility
	WHERE id = supplierid;
    commit;
end;
$BODY$;
