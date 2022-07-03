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
 * kapi_tree structures table functions
 * Functions for basic tree structures
 * context: Tree Structure Table
 **/


-- @function kapi_tree_structure_table_new_nodes
-- @description 
-- Creates a new structure table
-- The tree_nodes table have the following structure:
-- tree_node_id uuid,                  -- Unique identifier for the node uuid.uuid_generate_v4()
-- tree_node_group_id uuid,            -- Group identifier for the node, could be used as tenant, 
                                       -- or similar to group the nodes with duplicate paths when needed.    
-- tree_node_data_id uuid,             -- The Foreign key id to reference the data that will be linked to the tree node
-- tree_node_path ltree,               -- The path of the node in the tree
-- tree_node_metadata jsonb,           -- The metadata of the node
-- tree_link_metadata jsonb,           -- The metadata of the link related to the predecessor node
-- tree_node_inserted_at bigint,       -- The epoch time when the node was inserted in milliseconds
-- tree_node_updated_at bigint         -- The epoch time when the node was updated in milliseconds

-- A One To One relation To the data table is enforced by the tree_node_data_id
-- Is highly recommended to use this table just for tree operations, not for data operations or biz logic

-- @param _schema The schema name
-- @param _table The table name
-- @param _suffix The suffix to add to the table name default _tree_nodes
-- @return create a new table in the schema and will sufix _tree_nodes [_schema].[_table][suffix]
-- @usage
-- SELECT kapi_tree_structure_table_new_nodes('categories','brands');
-- SELECT kapi_tree_structure_table_new_nodes('categories','brands','_mysuffix');

DROP FUNCTION IF EXISTS public.kapi_tree_structure_table_new_nodes;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_table_new_nodes(
    _schema varchar, 
    _table varchar,
    _suffix varchar DEFAULT '_tree_nodes'
    ) 
RETURNS VOID
AS
$$
DECLARE
    _table_name varchar default  _table || _suffix;
    _table_name_full varchar default _schema || '.' || _table || _suffix;
BEGIN
    -- Verify that the schema exists in the database
	EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || _schema || ';
    ';
	
	EXECUTE '
	CREATE TABLE IF NOT EXISTS ' || _table_name_full || '(
        tree_node_id uuid NOT NULL,
        tree_node_group_id uuid,
        tree_node_data_id uuid NOT NULL,
        tree_node_path ltree NOT NULL,
        tree_node_metadata jsonb NOT NULL DEFAULT ''{}''::jsonb,
        tree_link_metadata jsonb NOT NULL DEFAULT ''{}''::jsonb,
        tree_node_inserted_at bigint NOT NULL DEFAULT ((date_part(''epoch''::text, CURRENT_TIMESTAMP) * (1000)::double precision))::bigint,
        tree_node_updated_at bigint NOT NULL DEFAULT ((date_part(''epoch''::text, CURRENT_TIMESTAMP) * (1000)::double precision))::bigint,

        CONSTRAINT _pk PRIMARY KEY (tree_node_id),
        CONSTRAINT _uk_group_path UNIQUE (tree_node_group_id, tree_node_path),
        CONSTRAINT _uk_reference_id UNIQUE (tree_node_data_id)

    );        
	
	CREATE INDEX IF NOT EXISTS _idx_path  ON ' || _table_name_full || ' USING gist (tree_node_path);
	CREATE INDEX IF NOT EXISTS _idx_group ON ' || _table_name_full || ' (tree_node_group_id);
    CREATE INDEX IF NOT EXISTS _idx_group_path ON ' || _table_name_full || ' USING btree (tree_node_group_id, tree_node_path);
    CREATE INDEX IF NOT EXISTS _idx_inserted_at ON ' || _table_name_full || ' (tree_node_inserted_at);
    CREATE INDEX IF NOT EXISTS _idx_updated_at ON ' || _table_name_full || ' (tree_node_updated_at);
	
	';
END;
$$
LANGUAGE plpgsql;

-- @function kapi_tree_structure_table_new_data
-- @description
-- Creates a new default data table ( basic data table to be linked to the tree structure table )
-- The tree_data table have the following structure:
-- id uuid,                         -- Unique identifier for the data uuid.uuid_generate_v4()
                                    -- will be used as the tree_node_data_id One on One relation
-- group_id uuid,                   -- Group identifier for the data, could be used as tenant, 
                                    -- or similar to group_id the data with duplicate paths when needed.
                                    -- should be the same as the tree_node_group_id
-- metadata jsonb,                  -- The metadata ( biz logic sense)
-- data jsonb,                      -- Extra data beside de fields  
-- inserted_at bigint,              -- The epoch time when the data was inserted in milliseconds
-- updated_at bigint                -- The epoch time when the data was updated in milliseconds                                   
