CREATE OR REPLACE FUNCTION public.kapi_tree_get(ctxName text) 
RETURNS TABLE (tree_owner_id uuid,
			  tree_path ltree,
			  tree_deep bigint,
			  tree_node_id uuid,
			  tree_node_pod ltree,
			  tree_node_parent_id uuid,
			  tree_node_metadata jsonb,
			  tree_node_inserted_at timestamp,
			  tree_node_updated_at timestamp,
			  tree_link_id uuid,
			  tree_link_behaviour citext,
			  tree_link_metadata jsonb,
			  tree_link_inserted_at timestamp,
			  tree_link_updated_at timestamp)
AS
$$
BEGIN

	RETURN QUERY EXECUTE 'WITH RECURSIVE 
	base_struct AS(
		SELECT 
		parents.id
		,parents.owner_id
		,parents.metadata
		,parents.pod
		,parents.inserted_at
		,parents.updated_at
		,children.parent_id
		,children.child_id
		,children.id AS tree_id
		,children.behaviour AS tree_behaviour
		,children.metadata AS tree_metadata
		,children.inserted_at AS children_inserted_at 
		,children.updated_at AS children_updated_at 
		
		,(parents.pod)::ltree AS path
		, 1 AS tree_deep
		,children.parent_id as pod_prev_id
		
		FROM ' || ctxName || '.nodes parents 
		LEFT JOIN ' || ctxName || '.links children
		
		ON children.child_id = parents.id
	),
	tree_struct AS(
		-- NO RECURSIVE (ROOTS)
		SELECT 
		id
		,parent_id
		,child_id
		 --,null::uuid as pod_prev_id 
		,pod_prev_id
		,path
		,tree_deep::bigint
		,tree_id
		,tree_behaviour
		,tree_metadata
		,owner_id
		,metadata
		,pod
		,inserted_at
		,updated_at
		,children_inserted_at 
		,children_updated_at 
		FROM base_struct 
		-- WHERE parent_id is NULL
		-- 
		UNION ALL
		SELECT 
		this_tree.id
		,bs.parent_id
		,bs.child_id
		, this_tree.pod_prev_id		
		,( bs.path::text || ''.'' || this_tree.path::text )::ltree AS path
		,( this_tree.tree_deep + 1 )::bigint AS tree_deep
		,this_tree.tree_id
		,this_tree.tree_behaviour
		,this_tree.tree_metadata
		,this_tree.owner_id
		,this_tree.metadata
		,this_tree.pod
		,this_tree.inserted_at
		,this_tree.updated_at
		,this_tree.children_inserted_at 
		,this_tree.children_updated_at 
		FROM base_struct bs
		INNER JOIN tree_struct this_tree
		ON bs.id = this_tree.parent_id
		--RECURSIVE
	),
	pod_links AS (
		SELECT
		owner_id AS tree_owner_id
		,path AS tree_path
		,tree_deep

		,id AS tree_node_id
		,pod AS tree_node_pod
		,pod_prev_id AS tree_node_parent_id
		,metadata AS tree_node_metadata
		,inserted_at AS tree_node_inserted_at
		,updated_at AS tree_node_updated_at

		,tree_id AS tree_link_id
		,coalesce(tree_behaviour, ''root'') AS tree_link_behaviour
		,coalesce(tree_metadata,  ''{}'') AS tree_link_metadata
		,children_inserted_at AS tree_link_inserted_at
		,children_updated_at AS tree_link_updated_at

		FROM tree_struct 
		WHERE parent_id is NULL 
		order by path 
	)
	SELECT * FROM pod_links pl;'
	;
	
END;
$$
LANGUAGE plpgsql;
