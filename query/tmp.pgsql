WITH
tree_source AS (
	SELECT * FROM forest.tree_nodes
),
tree_base AS(
	SELECT
	this_node.tree_owner_id
	,this_node.tree_node_path
	,subltree(this_node.tree_node_path,0,nlevel(this_node.tree_node_path) -1 ) AS tree_node_parent_path
	,subpath(this_node.tree_node_path, -1 ) AS tree_node_key
	,nlevel(this_node.tree_node_path)::bigint AS tree_node_level
	,
	(
		SELECT  
		count(*)
		FROM tree_source descendants
		WHERE 
		descendants.tree_node_path <@ this_node.tree_node_path 
		AND descendants.tree_node_path != this_node.tree_node_path
		AND descendants.tree_owner_id = this_node.tree_owner_id
	)::bigint  AS tree_node_descendants
	,this_node.tree_node_id
	,parent_node.tree_node_id AS tree_node_parent_id
	,this_node.tree_node_metadata
	,this_node.tree_link_metadata
	,this_node.tree_node_inserted_at
	,this_node.tree_node_updated_at
	FROM tree_source this_node
	LEFT JOIN tree_source parent_node 
	ON (this_node.tree_owner_id = parent_node.tree_owner_id) 
	AND parent_node.tree_node_path = subltree(this_node.tree_node_path,0,nlevel(this_node.tree_node_path) -1 )
	ORDER BY (this_node.tree_owner_id, this_node.tree_node_path)
),
tree_structure AS (
	SELECT 
	(
		CASE WHEN tree_node_level = 1 THEN
			'root'
		ELSE
			CASE WHEN tree_node_descendants = 0 THEN
				'leaf'
			ELSE
				'node'
			END
		END
	) AS tree_node_type
	,
	(
		CASE WHEN tree_node_level = 1 THEN
			'root'
		ELSE
			CASE WHEN tree_node_parent_id IS NULL THEN
				'unlinked'
			ELSE
				'linked'
			END
		END
	) AS tree_link_state
	,* 
	FROM tree_base
)
SELECT 
tree_owner_id::uuid
,tree_node_path::ltree
,tree_node_parent_path::ltree
,tree_node_key::ltree
,tree_node_type::citext
,tree_link_state::citext
,tree_node_level::bigint
,tree_node_descendants::bigint
,tree_node_id::uuid
,tree_node_parent_id::uuid
,tree_node_metadata::jsonb
,tree_link_metadata::jsonb
,tree_node_inserted_at::timestamp
,tree_node_updated_at::timestamp
FROM tree_structure;


