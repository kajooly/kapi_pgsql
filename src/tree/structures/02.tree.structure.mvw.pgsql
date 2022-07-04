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

DROP FUNCTION IF EXISTS public.kapi_tree_structure_new_mvw;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_new_mvw(
    _source varchar,
    _schema varchar, 
    _table varchar,
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
            this_node.id
            ,this_node.group_id
            ,this_node.node_path
            ,this_node.node_metadata
                
            ,this_node.node_key
            ,this_node.value
            ,this_node.weight
            ,this_node.node_alias
            ,this_node.note
            ,this_node.details
            ,this_node.node_data
            
            ,parent_node.id AS node_parent_id
            ,this_node.node_path_to
            ,this_node.node_name
            ,this_node.node_depth
            ,
            (
                SELECT  
                count(*)
                FROM tree_source descendants
                WHERE 
                descendants.node_path <@ this_node.node_path 
                AND descendants.node_path != this_node.node_path
                AND descendants.group_id = this_node.group_id
            )::bigint AS node_descendants
            ,this_node.node_link_metadata
            ,this_node.node_link_data
                    
            ,this_node.inserted_at
            ,public.kapi_time_epoch_to_timestamp(this_node.inserted_at) AS inserted_at_ts
            ,this_node.updated_at
            ,public.kapi_time_epoch_to_timestamp(this_node.updated_at) AS updated_at_ts
            
            FROM tree_source this_node
            LEFT JOIN tree_source parent_node 
            ON (this_node.group_id = parent_node.group_id) 
            AND parent_node.node_path = this_node.node_path_to
            ORDER BY (this_node.group_id, this_node.node_path)
        ),
        tree_structure AS (
            SELECT 
            (
                CASE WHEN node_depth = 1 THEN
                    ''root''
                ELSE
                    CASE WHEN node_depth = 0 THEN
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
            FROM tree_base
        )
        SELECT 
        id::uuid
        ,group_id::uuid
        

        ,key::citext
        ,value::text
        ,weight::integer
        ,alias::citext
        ,note::text
        ,details::text
        
        ,node_metadata::jsonb
        ,node_data::jsonb
        
        ,node_path::ltree
        ,node_parent_id::uuid
        ,node_path_to::ltree 
        ,node_name::ltree
        ,node_depth::bigint
        ,node_descendants::bigint
        ,node_type::text
        
        ,node_link_state::text
        ,node_link_metadata::jsonb
        ,node_link_data::jsonb
        
        ,inserted_at::bigint
        ,inserted_at_ts::timestamp
        ,updated_at::bigint
        ,updated_at_ts::timestamp
        FROM tree_structure
    ;
    ';

END;
$$
LANGUAGE plpgsql;
