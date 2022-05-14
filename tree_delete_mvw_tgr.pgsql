-- SELECT kapi_tree_delete_mvw_tgrs('portfolios_tree')
CREATE OR REPLACE FUNCTION public.kapi_tree_delete_mvw_tgrs(ctxName text) 
RETURNS VOID
AS
$$
BEGIN 
	
	
		
	EXECUTE	'DROP TRIGGER IF EXISTS tree_refresh_mvw_trg ON ' || ctxName || '.nodes;';
	
	EXECUTE	'DROP TRIGGER IF EXISTS tree_refresh_mvw_trg ON ' || ctxName || '.links;';
	
	EXECUTE 'DROP FUNCTION IF EXISTS ' || ctxName || '.tree_refresh_mvw()';

		
END;
$$
LANGUAGE plpgsql;
