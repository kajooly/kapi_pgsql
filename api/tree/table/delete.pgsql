-- select public.kapi_tree_table_delete('tree'); 
CREATE OR REPLACE FUNCTION public.kapi_tree_table_delete(ctxName text) 
RETURNS VOID
AS
$$
BEGIN
	EXECUTE '
	DROP TABLE IF EXISTS ' || ctxName || '.tree_nodes;
	';
	
	EXECUTE '
	DROP SCHEMA IF EXISTS ' || ctxName || ';
	';
	
END;
$$
LANGUAGE plpgsql;

