-- SELECT kapi_tree_new_mvw_tgrs('portfolios_tree')
CREATE OR REPLACE FUNCTION public.kapi_tree_new_mvw_tgrs(ctxName text) 
RETURNS VOID
AS
$$
BEGIN 
	EXECUTE 'CREATE OR REPLACE FUNCTION  ' || ctxName || '.check_owners()
	RETURNS trigger AS $t1$
	DECLARE
	counter integer;
	child_owner uuid;
	parent_owner uuid;
	BEGIN
	  SELECT owner_id INTO child_owner FROM  ' || ctxName || '.nodes WHERE id = NEW.child_id;
	  SELECT owner_id INTO parent_owner FROM  ' || ctxName || '.nodes WHERE id = NEW.parent_id;
	  IF parent_owner != child_owner THEN
		RAISE EXCEPTION ''Owner Check failed''; 
	  END IF;
	  RETURN NEW;
	END;
	$t1$ LANGUAGE plpgsql;

	DROP TRIGGER IF EXISTS check_owners_trg ON  ' || ctxName || '.links;
	CREATE TRIGGER check_owners_trg
	BEFORE INSERT OR UPDATE
	ON  ' || ctxName || '.links
	FOR EACH ROW
	EXECUTE PROCEDURE  ' || ctxName || '.check_owners();';
	
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
