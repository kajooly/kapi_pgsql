CREATE OR REPLACE FUNCTION public.kapi_tree_delete_mvw(ctxName text)
 RETURNS VOID
    AS
    $$
	BEGIN
		EXECUTE 'DROP MATERIALIZED VIEW '|| ctxName ||'.tree CASCADE;';	
	END;
    $$
LANGUAGE plpgsql
