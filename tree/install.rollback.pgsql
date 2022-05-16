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

DROP FUNCTION IF EXISTS kapi_tree_mvw_delete;
DROP FUNCTION IF EXISTS kapi_tree_mvw_new;
DROP FUNCTION IF EXISTS kapi_tree_struct_delete;
DROP FUNCTION IF EXISTS kapi_tree_struct_new;
DROP FUNCTION IF EXISTS kapi_tree_get;
DROP TYPE IF EXISTS kapi_tree_table;
DROP DOMAIN IF EXISTS kapi_json;
DROP DOMAIN IF EXISTS kapi_ltree;
DROP DOMAIN IF EXISTS kapi_uuid;
DROP DOMAIN IF EXISTS kapi_uuid_auto;
DROP DOMAIN IF EXISTS kapi_timestamp;
DROP TYPE IF EXISTS kapi_tree;
