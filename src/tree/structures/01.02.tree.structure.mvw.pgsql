-- Copyright 2022 Rolando Lucio 

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     https://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

/*
 * kapi_tree structures materialized view
 * Functions for basic tree visualizations
 * context: Tree Structure Materialized View
 **/
-- SELECT kapi_tree_structure_new_tree('categories.brands_nodes', 'categories','brands')
DROP FUNCTION IF EXISTS public.kapi_tree_structure_new_tree;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_new_tree(
    _source varchar,
    _schema varchar, 
    _table varchar
    ) 
RETURNS VOID
AS
$$
DECLARE
    _suffix varchar DEFAULT '_tree'
    _table_name varchar default  _table || _suffix;
    _table_name_full varchar default _schema || '.' || _table || _suffix;
BEGIN

    EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || _schema || ';
    ';

    EXECUTE '
    CREATE MATERIALIZED VIEW IF NOT EXISTS' || _table_name_full || ' AS
        WITH
        tree_source AS (
           SELECT * FROM ' || _source || ' 
        ),
        tree_base AS(
            SELECT
            this_node.node_id 
            ,this_node.node_group_id
            ,this_node.node_path
            ,this_node.node_key
            ,this_node.node_alias

            ,this_node.node_path_to
            ,this_node.node_name
            ,this_node.node_depth


            ,this_node.node_weight
            ,this_node.node_metadata
            ,this_node.node_data
            ,this_node.node_link_weight
            ,this_node.node_link_metadata
            ,this_node.node_link_data

            ,this_node.node_inserted_at
            ,this_node.node_updated_at

            ,public.kapi_time_epoch_to_timestamp(this_node.node_inserted_at) AS node_inserted_at_ts
            ,public.kapi_time_epoch_to_timestamp(this_node.node_updated_at) AS node_updated_at_ts

            ,parent_node.node_id AS node_parent_id

            ,
            (
                SELECT  
                count(*)
                FROM tree_source descendants
                WHERE 
                descendants.node_path <@ this_node.node_path 
                AND descendants.node_path != this_node.node_path
                AND descendants.node_group_id = this_node.node_group_id
            )::bigint AS node_descendants

            FROM tree_source this_node
            LEFT JOIN tree_source parent_node 
            ON (this_node.node_group_id = parent_node.node_group_id) 
            AND parent_node.node_path = this_node.node_path_to
            ORDER BY (this_node.node_group_id, this_node.node_path)
        ),
        tree_structure AS (
            SELECT 
            (
                CASE WHEN node_depth = 1 THEN
                    ''root''
                ELSE
                    CASE WHEN node_descendants = 0 THEN
                        ''leaf''
                    ELSE
                        ''node''
                    END
                END
            ) AS node_type
            ,
            (
                CASE WHEN node_depth = 1 THEN
                    ''root''
                ELSE
                    CASE WHEN node_parent_id IS NULL THEN
                        ''unlinked''
                    ELSE
                        ''linked''
                    END
                END
            ) AS node_link_state
            ,*
            ,public.kapi_time_epoch_now()::bigint AS tree_refreshed_at
            FROM tree_base
        ),
        tree_datatype AS(
            SELECT 
            -- node fields
            node_id::uuid
            ,node_group_id::uuid
            ,node_path::ltree
            ,node_key::citext
            ,node_alias::citext	
            ,node_path_to::ltree 
            ,node_name::ltree
            ,node_depth::bigint
            ,node_weight::integer      
            ,node_metadata::jsonb
            ,node_data::jsonb
            ,node_link_weight::integer      
            ,node_link_metadata::jsonb
            ,node_link_data::jsonb        
            ,node_inserted_at::bigint
            ,node_updated_at::bigint      
            -- view fields    
            ,node_inserted_at_ts::timestamp
            ,node_updated_at_ts::timestamp
            ,node_parent_id::uuid     
            ,node_descendants::bigint		
            ,node_type::text      
            ,node_link_state::text
            -- tree gen
            ,tree_refreshed_at::bigint
            ,public.kapi_time_epoch_to_timestamp(tree_refreshed_at)::timestamp AS tree_refreshed_at_ts
            FROM tree_structure
        ),
        tree_counts AS (
            SELECT 
            -- node fields
            node_id::uuid
            ,node_group_id::uuid
            ,node_path::ltree
            ,node_key::citext
            ,node_alias::citext	
            ,node_path_to::ltree 
            ,node_name::ltree
            ,node_depth::bigint
            ,node_weight::integer      
            ,node_metadata::jsonb
            ,node_data::jsonb
            ,node_link_weight::integer      
            ,node_link_metadata::jsonb
            ,node_link_data::jsonb        
            ,node_inserted_at::bigint
            ,node_updated_at::bigint      
            -- view fields    
            ,node_inserted_at_ts::timestamp
            ,node_updated_at_ts::timestamp
            ,node_parent_id::uuid     
            ,node_descendants::bigint		
            ,node_type::text      
            ,node_link_state::text
            -- tree gen
            ,tree_refreshed_at::bigint
            ,tree_refreshed_at_ts::timestamp
            ,(count(*) OVER ())::bigint AS tree_nodes_total
            ,(row_number() OVER (ORDER BY node_updated_at DESC))::bigint AS tree_nodes_updated_rn
            ,(count(*) OVER (PARTITION BY node_group_id))::bigint AS tree_nodes_total_group
            ,(row_number() OVER (PARTITION BY node_group_id ORDER BY node_updated_at DESC))::bigint AS tree_nodes_updated_rn_group
            FROM tree_datatype
        )
        SELECT 
            node_id::uuid
            ,node_group_id::uuid
            ,node_path::ltree
            ,node_key::citext
            ,node_alias::citext	
            ,node_path_to::ltree 
            ,node_name::ltree
            ,node_depth::bigint
            ,node_weight::integer      
            ,node_metadata::jsonb
            ,node_data::jsonb
            ,node_link_weight::integer      
            ,node_link_metadata::jsonb
            ,node_link_data::jsonb        
            ,node_inserted_at::bigint
            ,node_updated_at::bigint      
            -- view fields    
            ,node_inserted_at_ts::timestamp
            ,node_updated_at_ts::timestamp
            ,node_parent_id::uuid     
            ,node_descendants::bigint		
            ,node_type::text      
            ,node_link_state::text
            -- tree gen
            ,tree_refreshed_at::bigint
            ,tree_refreshed_at_ts::timestamp
            ,tree_nodes_total::bigint
            ,tree_nodes_updated_rn::bigint
            ,tree_nodes_total_group::bigint
            ,tree_nodes_updated_rn_group ::bigint 
        FROM tree_counts
        ORDER BY node_group_id, node_path ASC
        ;
    ';

END;
$$
LANGUAGE plpgsql;
