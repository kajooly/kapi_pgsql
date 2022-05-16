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
