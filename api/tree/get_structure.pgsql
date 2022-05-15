CREATE OR REPLACE FUNCTION public.kapi_tree_get(ctxName text) 
RETURNS TABLE (
    tree_owner_id uuid
	,tree_node_path ltree
	,tree_node_parent_path ltree
	,tree_node_key ltree
	,tree_node_type citext
	,tree_link_state citext
	,tree_node_level bigint
	,tree_node_descendants bigint
	,tree_node_id uuid
	,tree_node_parent_id uuid
	,tree_node_metadata jsonb
	,tree_link_metadata jsonb
	,tree_node_inserted_at timestamp
	,tree_node_updated_at timestamp
)
AS
$$
BEGIN

END;
$$
LANGUAGE plpgsql;