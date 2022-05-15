-- select public.kapi_tree_table_new('tree'); 
CREATE OR REPLACE FUNCTION public.kapi_tree_table_new(ctxName text) 
RETURNS VOID
AS
$$
BEGIN
	EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || ctxName || ';
    ';
	
    EXECUTE '
	CREATE TABLE IF NOT EXISTS ' || ctxName || '.tree_nodes( 
	tree_node_id uuid PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
	tree_node_path ltree NOT NULL,
	tree_owner_id uuid NOT NULL,
	tree_node_metadata jsonb DEFAULT ''{}''::jsonb,
	tree_link_metadata jsonb DEFAULT ''{}''::jsonb,
	tree_node_inserted_at timestamp(0) without time zone NOT NULL DEFAULT now(),
	tree_node_updated_at timestamp(0) without time zone NOT NULL DEFAULT now()
	);

	ALTER TABLE ' || ctxName || '.tree_nodes 
	ADD CONSTRAINT uk_owner_path UNIQUE (tree_owner_id, tree_node_path);
	CREATE INDEX idx_tree  ON ' || ctxName || '.tree_nodes USING gist (tree_node_path);
	CREATE INDEX idx_owner ON ' || ctxName || '.tree_nodes (tree_owner_id);
	';
	
END;
$$
LANGUAGE plpgsql;
