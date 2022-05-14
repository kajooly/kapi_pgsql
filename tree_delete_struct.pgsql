-- select  public.kapi_tree_delete_struct('test_tree');
CREATE OR REPLACE FUNCTION public.kapi_tree_delete_struct(ctxName text)
RETURNS VOID
AS
$$
	BEGIN
		EXECUTE 'DROP TABLE ' || ctxName || '.links CASCADE;';
		EXECUTE 'DROP TABLE ' || ctxName || '.nodes CASCADE;';
	END;
$$
LANGUAGE plpgsql;
