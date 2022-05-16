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


/**
 * 
 * Basic Kapi Elements 
 * 
 **/
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS ltree;
	
DROP TYPE IF EXISTS kapi_tree;
CREATE TYPE kapi_tree AS(
    tree_owner_id uuid,
    tree_node_path ltree,
    tree_node_parent_path ltree,
    tree_node_key ltree,
    tree_node_type citext,
    tree_link_state citext,
    tree_node_level bigint,
    tree_node_descendants bigint,
    tree_node_id uuid,
    tree_node_parent_id uuid,
    tree_node_metadata jsonb,
    tree_link_metadata jsonb,
    tree_node_inserted_at timestamp,
    tree_node_updated_at timestamp
);

DROP DOMAIN IF EXISTS kapi_timestamp;
CREATE DOMAIN kapi_timestamp timestamp(0) without time zone NOT NULL DEFAULT now();

DROP DOMAIN IF EXISTS kapi_uuid_auto;
CREATE DOMAIN kapi_uuid_auto uuid NOT NULL DEFAULT uuid_generate_v4();

DROP DOMAIN IF EXISTS kapi_uuid;
CREATE DOMAIN kapi_uuid uuid NOT NULL;

DROP DOMAIN IF EXISTS kapi_ltree;
CREATE DOMAIN kapi_ltree ltree NOT NULL;

DROP DOMAIN IF EXISTS kapi_json;
CREATE DOMAIN kapi_json jsonb NOT NULL DEFAULT '{}'::jsonb;

DROP TYPE IF EXISTS kapi_tree_table;
CREATE TYPE kapi_tree_table AS(
    tree_node_id kapi_uuid_auto,
    tree_node_path kapi_ltree,
    tree_owner_id kapi_uuid,
    tree_node_metadata kapi_json,
    tree_link_metadata kapi_json,
    tree_node_inserted_at kapi_timestamp,
    tree_node_updated_at kapi_timestamp
);

/**
 * 
 * Kapi API functions
 * 
 **/


-- This function returns a list of all the nodes in the tree.
-- in a kapi_tree type structure for a given 
-- treeSource Location of type kapi_tree_table.

-- Example:
-- SELECT * FROM kapi_tree_get('forest.tree_nodes');

DROP FUNCTION IF EXISTS kapi_tree_get;
CREATE OR REPLACE FUNCTION kapi_tree_get(treeSource text) 
RETURNS SETOF kapi_tree
AS
$$
BEGIN
    RETURN QUERY EXECUTE '
    WITH
    tree_source AS (
       SELECT * FROM ' || treeSource || ' 
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
                ''root''
            ELSE
                CASE WHEN tree_node_descendants = 0 THEN
                    ''leaf''
                ELSE
                    ''node''
                END
            END
        ) AS tree_node_type
        ,
        (
            CASE WHEN tree_node_level = 1 THEN
                ''root''
            ELSE
                CASE WHEN tree_node_parent_id IS NULL THEN
                    ''unlinked''
                ELSE
                    ''linked''
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
	';

END;
$$
LANGUAGE plpgsql;


-- This function creates a new schema and a kapi_tree table
-- at ctxName with table name tree_nodes

-- Example:
-- SELECT kapi_tree_struct_new('trees');
DROP FUNCTION IF EXISTS kapi_tree_struct_new;
CREATE OR REPLACE FUNCTION public.kapi_tree_struct_new(ctxName text) 
RETURNS VOID
AS
$$
BEGIN
	EXECUTE '
	CREATE SCHEMA IF NOT EXISTS ' || ctxName || ';
    ';
	
	EXECUTE '
	CREATE TABLE IF NOT EXISTS ' || ctxName || '.tree_nodes OF kapi_tree_table (
	PRIMARY KEY (tree_node_id)
	);
	
	ALTER TABLE ' || ctxName || '.tree_nodes 
	ADD CONSTRAINT uk_owner_path UNIQUE (tree_owner_id, tree_node_path);
	CREATE INDEX idx_tree  ON ' || ctxName || '.tree_nodes USING gist (tree_node_path);
	CREATE INDEX idx_owner ON ' || ctxName || '.tree_nodes (tree_owner_id);
	
	';
END;
$$
LANGUAGE plpgsql;



-- this function Delete the structure of the tree

-- Example:
-- SELECT kapi_tree_struct_delete('trees');
DROP FUNCTION IF EXISTS kapi_tree_struct_delete;
CREATE OR REPLACE FUNCTION kapi_tree_struct_delete(ctxName text) 
RETURNS VOID
AS
$$
BEGIN
	EXECUTE '
	DROP TABLE IF EXISTS ' || ctxName || '.tree_nodes;
	';
	
	EXECUTE '
	DROP SCHEMA IF EXISTS ' || ctxName || ';
	';
	
END;
$$
LANGUAGE plpgsql;

-- Create a MATERIALIZED where to hit the queries

-- Example:
-- SELECT kapi_tree_mvw_new('trees');
DROP FUNCTION IF EXISTS kapi_tree_mvw_new;
CREATE OR REPLACE FUNCTION kapi_tree_mvw_new(ctxName text)
RETURNS VOID
AS
$$
BEGIN 
	EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || ctxName || '.tree AS 
	SELECT * FROM kapi_tree_get(''' || ctxName || '.tree_nodes'');';
	
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id);';
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree USING gist (tree_node_path);';
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_node_id);';
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_node_parent_id);';
	EXECUTE 'CREATE UNIQUE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_node_path);';
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_node_id);';
	EXECUTE 'CREATE INDEX ON '|| ctxName ||'.tree (tree_owner_id, tree_node_parent_id);';
	
END;
$$
LANGUAGE plpgsql;

-- Delete the MATERIALIZED tree view

-- Example:
-- SELECT kapi_tree_mvw_delete('trees');
DROP FUNCTION IF EXISTS kapi_tree_mvw_delete;
CREATE OR REPLACE FUNCTION kapi_tree_mvw_delete(ctxName text)
RETURNS VOID
AS
$$
BEGIN 
	EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS '|| ctxName ||'.tree ;';
    EXECUTE 'DROP FUNCTION IF EXISTS ' || ctxName || '.tree_mvw_refresh();';
END;
$$
LANGUAGE plpgsql;