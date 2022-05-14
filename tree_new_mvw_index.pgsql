CREATE OR REPLACE FUNCTION public.kapi_tree_new_mvw_index(ctxName text) 
    RETURNS VOID
    AS
    $$
	BEGIN 
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree USING gist (tree_path);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_node_id);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_node_pod);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_node_parent_id);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_link_id);';
		EXECUTE 'CREATE UNIQUE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_path);';
		EXECUTE 'CREATE UNIQUE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_path, tree_node_pod);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_node_id);';
		EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_node_parent_id);';
		
       END;
    $$
LANGUAGE plpgsql;
