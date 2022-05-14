-- SELECT kapi_tree_new_mvw_tgrs('portfolios_tree')
CREATE OR REPLACE FUNCTION public.kapi_tree_new_mvw_tgrs(ctxName text) 
RETURNS VOID
AS
$$
BEGIN 
	
	EXECUTE 'CREATE OR REPLACE FUNCTION ' || ctxName || '.tree_refresh_mvw()
		RETURNS trigger 
		AS 
		$t$ 
		BEGIN
		  REFRESH MATERIALIZED VIEW ' || ctxName || '.tree;
		  RETURN NULL;
		END;
		$t$ LANGUAGE plpgsql;';
		
	EXECUTE	'
	DROP TRIGGER IF EXISTS tree_refresh_mvw_trg ON ' || ctxName || '.nodes;
	CREATE TRIGGER tree_refresh_mvw_trg
		AFTER INSERT OR UPDATE OR DELETE
		ON ' || ctxName || '.nodes
		FOR EACH STATEMENT
		EXECUTE PROCEDURE ' || ctxName || '.tree_refresh_mvw();';
	
	EXECUTE	'
	DROP TRIGGER IF EXISTS tree_refresh_mvw_trg ON ' || ctxName || '.links;
	CREATE TRIGGER tree_refresh_mvw_trg
		AFTER INSERT OR UPDATE OR DELETE
		ON ' || ctxName || '.links
		FOR EACH STATEMENT
		EXECUTE PROCEDURE ' || ctxName || '.tree_refresh_mvw();';
		
END;
$$
LANGUAGE plpgsql;
