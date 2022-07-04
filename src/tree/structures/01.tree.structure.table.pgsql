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


-- @function kapi_tree_structure_new_nodes
-- @description 
-- Creates a new structure table
-- The tree_nodes table have the following structure:
-- id uuid,                     -- Unique identifier for the node uuid.uuid_generate_v4()
-- group_id uuid,               -- Group identifier for the node, could be used as tenant 
                                -- or similar. to group the nodes with duplicate paths when needed.    

-- node_path ltree,             -- REQUIERED: The path of the node in the tree  [node_path_to].[node_name]
-- node_path_to ltree,          -- The path of the parent node in the Auto Gen cant be inserted or updated
-- node_name ltree,             -- The name of the node in the tree  Auto Gen cant be or updated
                                -- CHECK (name ~ ''^[a-zA-Z0-9_]*$'')
-- node_depth integer,          -- The depth of the node in the tree  Auto Gen cant be or updated

-- node_link_metadata jsonb,    -- The metadata of the link related to the predecessor node
-- node_link_data jsonb,        -- The data of the link related to the predecessor node
-- node_metadata jsonb,         -- The metadata of the node
-- node_data jsonb,             -- The data of the node extra to the base columns
                                -- Recomendation: extend data to external table and link OneToOne

-- key citext,                  -- REQUIERED: The key of the node in the tree may be used as your own
                                -- identifier. or replicated to the node_path as the node_name
-- value text,                  -- The value of the node                                
-- weight integer,              -- The weight of the node, my be used to order the nodes

-- alias citext,                -- REQUIRED: The alias of the node, human readable name

-- note text,                   -- The note of the node ( might be used to store the concept or title)
-- details text,                -- The details of the node ( might be used to store the body or extra info)

-- inserted_at bigint,          -- The epoch time when the node was inserted in milliseconds
-- updated_at bigint            -- The epoch time when the node was updated in milliseconds


-- Is highly recommended to use this table just for tree operations, not for data operations or biz logic

-- @param _schema The schema name
-- @param _table The table name
-- @param _suffix The suffix to add to the table name default _tree_nodes
-- @return create a new table in the schema and will sufix _tree_nodes [_schema].[_table][suffix]
-- @usage
-- SELECT kapi_tree_structure_new_nodes('categories','brands','_mysuffix');
-- SELECT kapi_tree_structure_new_nodes('categories','brands');

DROP FUNCTION IF EXISTS public.kapi_tree_structure_new_nodes;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_new_nodes(
    _schema varchar, 
    _table varchar,
    _suffix varchar DEFAULT '_nodes'
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
        id uuid NOT NULL DEFAULT uuid_generate_v4(),
        group_id uuid,
         
        node_path ltree NOT NULL,
        node_path_to ltree GENERATED ALWAYS AS (subltree(node_path,0,nlevel(node_path) -1 )) STORED,
        node_name ltree GENERATED ALWAYS AS (subpath(node_path, -1 )) STORED,
		node_depth bigint GENERATED ALWAYS AS (nlevel(node_path)::bigint) STORED,
        node_link_metadata jsonb NOT NULL DEFAULT ''{"behaviour": "link"}''::jsonb,
        node_link_data jsonb NOT NULL DEFAULT ''{ }''::jsonb,
        node_metadata jsonb NOT NULL DEFAULT ''{"behaviour": "hierarchy.down"}''::jsonb,
        node_data jsonb NOT NULL DEFAULT ''{ }''::jsonb,
        
		key citext NOT NULL,
        CONSTRAINT _chk_trim_key_' || _table_name || ' CHECK (LENGTH(TRIM(key)) = LENGTH(key)),
		value text,
	    weight integer NOT NULL DEFAULT 0,

        alias citext NOT NULL,
		CONSTRAINT _chk_trim_alias_' || _table_name || ' CHECK (LENGTH(TRIM(alias)) = LENGTH(alias)),
		
		note text,
        CONSTRAINT _chk_nullornotempty_note_' || _table_name || ' CHECK ((LENGTH(TRIM(note)) > 0) OR note IS NULL),
        details text,
		CONSTRAINT _chk_nullornotempty_details_' || _table_name || ' CHECK ((LENGTH(TRIM(details)) > 0) OR details IS NULL),
	
        inserted_at bigint NOT NULL DEFAULT ((date_part(''epoch''::text, CURRENT_TIMESTAMP) * (1000)::double precision))::bigint,
        updated_at bigint NOT NULL DEFAULT ((date_part(''epoch''::text, CURRENT_TIMESTAMP) * (1000)::double precision))::bigint,

        CONSTRAINT _pk_' || _table_name || ' PRIMARY KEY (id),
        CONSTRAINT _uk_group_node_path_' || _table_name || ' UNIQUE (group_id, node_path),
		CONSTRAINT _uk_group_parent_alias_' || _table_name || ' UNIQUE (group_id, node_path_to, alias),
		CONSTRAINT _uk_group_parent_key_' || _table_name || ' UNIQUE (group_id, node_path_to, key)

    );           
	
	CREATE INDEX IF NOT EXISTS _idx_path_' || _table_name || '  ON ' || _table_name_full || ' USING gist (node_path);
	CREATE INDEX IF NOT EXISTS _idx_group_' || _table_name || ' ON ' || _table_name_full || ' (group_id);
    CREATE INDEX IF NOT EXISTS _idx_group_path_' || _table_name || ' ON ' || _table_name_full || ' (group_id, node_path);
    CREATE INDEX IF NOT EXISTS _idx_inserted_at_' || _table_name || ' ON ' || _table_name_full || ' (inserted_at);
    CREATE INDEX IF NOT EXISTS _idx_updated_at_' || _table_name || ' ON ' || _table_name_full || ' (updated_at);
    CREATE INDEX IF NOT EXISTS _idx_group_key_' || _table_name || ' ON ' || _table_name_full || ' (group_id, key);
    CREATE INDEX IF NOT EXISTS _idx_group_alias_' || _table_name || ' ON ' || _table_name_full || ' (group_id, alias);
    CREATE INDEX IF NOT EXISTS _idx_key_alias_fst_' || _table_name || ' ON ' || _table_name_full || ' USING gist (key, alias);
    CREATE INDEX IF NOT EXISTS _idx_key_alias_path_fst_' || _table_name || ' ON ' || _table_name_full || ' USING gist (key, alias, node_path);
	
	';
END;
$$
LANGUAGE plpgsql;

