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

-- kapi_tree datatypes

DROP TYPE IF EXISTS kapi_tree_tree;
CREATE TYPE kapi_tree_tree AS(
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
    tree_node_inserted_at bigint,
    tree_node_updated_at bigint
);

DROP TYPE IF EXISTS kapi_tree_nodes;
CREATE TYPE kapi_tree_node AS(
    id uuid,
    node_group_id uuid,
    node_path ltree,
);
