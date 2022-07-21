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
-- The table have the following structure:
-- id uuid,                     -- Unique identifier for the node uuid.uuid_generate_v4()
-- node_group_id uuid,               -- Group identifier for the node, could be used as tenant 
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

-- node_key citext,             -- REQUIERED: The key of the node in the tree may be used as your own
                                -- identifier. or replicated to the node_path as the node_name
-- node_weight integer,         -- The weight of the node, my be used to order the nodes

-- node_alias citext,           -- REQUIRED: The alias of the node, human readable name

-- node_inserted_at bigint,     -- The epoch time when the node was inserted in milliseconds
-- node_updated_at bigint       -- The epoch time when the node was updated in milliseconds


-- Is highly recommended to use this table just for tree operations, not for data operations or biz logic

-- @param _schema The schema name
-- @param _table The table name
-- @param _suffix The suffix to add to the table name default _tree_nodes
-- @return create a new table in the schema and will sufix _tree_nodes [_schema].[_table][suffix]
-- @usage
-- SELECT kapi_tree_structure_new_nodes('categories','brands');

DROP FUNCTION IF EXISTS public.kapi_tree_structure_new_nodes;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_new_nodes(
    _schema varchar, 
    _table varchar
    ) 
RETURNS VOID
AS
$$
DECLARE
    _suffix varchar DEFAULT '_nodes';
    _table_name varchar default  _table || _suffix;
    _table_name_full varchar default _schema || '.' || _table || _suffix;
BEGIN
    -- Verify that the schema exists in the database
	EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || _schema || ';
    ';
	
	EXECUTE '
	CREATE TABLE IF NOT EXISTS ' || _table_name_full || '(
        node_id kapi_dtd_uuid_auto,
        CONSTRAINT _pk_' || _table_name || ' PRIMARY KEY (node_id),

        node_group_id kapi_dtd_uuid_default,

        -- REQUIRED ----------------------------------------- 
        -- uniques one per level per group
        -- --------------------------------------------------
        -- TODO: change ltree to kapi when dls resolved
        -- node_path kapi_dtd_ltree,
        node_path ltree NOT NULL,
        node_key kapi_dtd_citext_notempty,
        node_alias kapi_dtd_citext_notempty,
        -- --------------------------------------------------
        -- --------------------------------------------------
       
        -- GENERATED ---------------------------------------
        -- This columns are generated on the fly, cant be updated or inserted
        -- --------------------------------------------------
        node_path_to ltree GENERATED ALWAYS AS (subltree(node_path,0,nlevel(node_path) -1 )) STORED,
        node_name ltree GENERATED ALWAYS AS (subpath(node_path, -1 )) STORED,
		node_depth bigint GENERATED ALWAYS AS (nlevel(node_path)::bigint) STORED,
       
        -- Base columns ------------------------------------
        node_weight kapi_dtd_int_default,
        node_metadata kapi_dtd_json_default,
        node_data kapi_dtd_json_default,

        node_link_weight kapi_dtd_int_default,
        node_link_metadata kapi_dtd_json_default,
        node_link_data kapi_dtd_json_default,


        -- Date and time ------------------------------------
        node_inserted_at kapi_dtd_epoch_auto,
        node_updated_at kapi_dtd_epoch_auto,

        -- CONSTRAINTS --------------------------------------
        CONSTRAINT _uk_group_node_path_' || _table_name || ' UNIQUE (node_group_id, node_path),
		CONSTRAINT _uk_group_parent_node_alias_' || _table_name || ' UNIQUE (node_group_id, node_path_to, node_alias),
		CONSTRAINT _uk_group_parent_key_' || _table_name || ' UNIQUE (node_group_id, node_path_to, node_key)

    );           
	
	CREATE INDEX IF NOT EXISTS _idx_path_' || _table_name || '  ON ' || _table_name_full || ' USING gist (node_path);
	CREATE INDEX IF NOT EXISTS _idx_group_' || _table_name || ' ON ' || _table_name_full || ' (node_group_id);
    CREATE INDEX IF NOT EXISTS _idx_group_path_' || _table_name || ' ON ' || _table_name_full || ' (node_group_id, node_path);
    CREATE INDEX IF NOT EXISTS _idx_node_inserted_at_' || _table_name || ' ON ' || _table_name_full || ' (node_inserted_at);
    CREATE INDEX IF NOT EXISTS _idx_node_updated_at_' || _table_name || ' ON ' || _table_name_full || ' (node_updated_at);
    CREATE INDEX IF NOT EXISTS _idx_group_node_key_' || _table_name || ' ON ' || _table_name_full || ' (node_group_id, node_key);
    CREATE INDEX IF NOT EXISTS _idx_group_node_alias_' || _table_name || ' ON ' || _table_name_full || ' (node_group_id, node_alias);
    CREATE INDEX IF NOT EXISTS _idx_node_key_node_alias_fst_' || _table_name || ' ON ' || _table_name_full || ' USING gist (node_key, node_alias);
    CREATE INDEX IF NOT EXISTS _idx_node_key_node_alias_path_fst_' || _table_name || ' ON ' || _table_name_full || ' USING gist (node_key, node_alias, node_path);
	
	';

    EXECUTE '
	SELECT public.kapi_tablefunc_updatedat(''' || _schema || ''', ''' || _table_name || ''' ,''node_updated_at'');
    ';
END;
$$
LANGUAGE plpgsql;


-- @function kapi_tree_structure_new_nodes
-- @description 
-- Creates a default data structure table
--
-- Is highly recommended to use this table just for data operations or biz logic
-- and Alter to your needs just link the table to the nodes table
-- 
-- data_:: if you need Unique values per level per group add them to the nodes table
-- 
-- The table have the following structure:
-- id uuid,                     -- Unique identifier for the One to One relationship with nodes

-- state citext                 -- State: the particular condition that someone or something is in at a specific time.
                                -- iex: Kanban use case, In Progress, Done, etc
-- state citext                 -- Status: the situation at a particular time during a process.
                                -- iex: Open, Closed, In Progress, etc
-- value text,                  -- The value of the node                                

-- data_ text,                   -- The note of the node ( might be used to store the concept or title)
-- details text,                -- The details of the node ( might be used to store the body or extra info)

-- inserted_at bigint,          -- The epoch time when the node was inserted in milliseconds
-- updated_at bigint            -- The epoch time when the node was updated in milliseconds

-- @TODO: Add support for One to One relationship via DEFERRABLE and Transaction commits 
-- When our common DSL(Ecto) and ORM supports it
-- ALTER TABLE nodes
--         ADD FOREIGN KEY (id) REFERENCES data(id)
--                 DEFERRABLE INITIALLY DEFERRED;
-- ALTER TABLE data
--         ADD FOREIGN KEY (id) REFERENCES nodes(id)
--                 DEFERRABLE INITIALLY DEFERRED;
-- BEGIN transaction;
-- INSERT INTO nodes VALUES (1, ...);
-- INSERT INTO data VALUES (1, ....);
-- COMMIT;

-- @param _schema The schema name
-- @param _table The table name
-- @param _suffix The suffix to add to the table name default _tree_nodes
-- @return create a new table in the schema and will sufix _tree_nodes [_schema].[_table][suffix]
-- @usage
-- SELECT kapi_tree_structure_new_data('categories.brands_nodes','categories','brands', 'citext NOT NULL','MATCH SIMPLE ON DELETE RESTRICT ON UPDATE CASCADE');
-- SELECT kapi_tree_structure_new_data('categories.brands_nodes','categories','brands', 'numeric');
-- SELECT kapi_tree_structure_new_data('categories.brands_nodes','categories','brands');
DROP FUNCTION IF EXISTS public.kapi_tree_structure_new_data;
CREATE OR REPLACE FUNCTION public.kapi_tree_structure_new_data(
    _nodes_table varchar,
    _schema varchar, 
    _table varchar,
    _value_declaration varchar DEFAULT 'kapi_dtd_citext_null_or_notempty',
    _reference_declaration varchar DEFAULT 'MATCH SIMPLE ON DELETE CASCADE ON UPDATE CASCADE'
    ) 
RETURNS VOID
AS
$$
DECLARE
    _suffix varchar DEFAULT '_data';
    _table_name varchar default  _table || _suffix;
    _table_name_full varchar default _schema || '.' || _table || _suffix;
BEGIN
    -- Verify that the schema exists in the database
	EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || _schema || ';
    ';
	
	EXECUTE '
	CREATE TABLE IF NOT EXISTS ' || _table_name_full || '(
        data_id kapi_dtd_uuid_auto,
        CONSTRAINT _pk_' || _table_name || ' PRIMARY KEY (data_id),           
		
        data_node_id kapi_dtd_uuid,
        CONSTRAINT _uk_one_to_one_' || _table_name || ' UNIQUE (data_node_id), 
        CONSTRAINT _fk_one_to_one_' || _table_name || ' FOREIGN KEY (data_node_id) REFERENCES ' || _nodes_table || ' (node_id) ' || _reference_declaration || ',

        data_value ' || _value_declaration || ',
       	
		data_note kapi_dtd_text_null_or_notempty,
        data_details kapi_dtd_text_null_or_notempty,
	
        data_inserted_at kapi_dtd_epoch_auto,
        data_updated_at kapi_dtd_epoch_auto
    );
    CREATE INDEX IF NOT EXISTS _idx_data_value_' || _table_name || ' ON ' || _table_name_full || ' (data_value);           
    CREATE INDEX IF NOT EXISTS _idx_inserted_at_' || _table_name || ' ON ' || _table_name_full || ' (data_inserted_at);
    CREATE INDEX IF NOT EXISTS _idx_updated_at_' || _table_name || ' ON ' || _table_name_full || ' (data_updated_at);
	';

    EXECUTE '
	SELECT public.kapi_tablefunc_updatedat(''' || _schema || ''', ''' || _table_name || ''' ,''data_updated_at'');
    ';

END;
$$
LANGUAGE plpgsql;
