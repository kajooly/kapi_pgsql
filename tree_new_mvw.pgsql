CREATE OR REPLACE FUNCTION public.kapi_tree_new_mvw(ctxName text)
RETURNS VOID
AS
$$
BEGIN 
	EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || ctxName || '.tree AS 
	SELECT * FROM public.kapi_tree_get(''' || ctxName || ''');';
END;
$$
LANGUAGE plpgsql;
