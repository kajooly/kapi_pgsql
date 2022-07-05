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


---------------------------------------------------------------
-- epoch
-- Base epoch in milliseconds since the UNIX epoch.
---------------------------------------------------------------

DROP DOMAIN IF EXISTS public.kapi_dtc_epoch;
CREATE DOMAIN public.kapi_dtc_epoch bigint 
NOT NULL 
CHECK (char_length(VALUE::text) = 13)
;

DROP DOMAIN IF EXISTS public.kapi_dtc_epoch_auto;
CREATE DOMAIN public.kapi_dtc_epoch_auto bigint 
NOT NULL 
DEFAULT ((date_part('epoch'::text, CURRENT_TIMESTAMP AT TIME ZONE 'UTC') * (1000)::double precision))::bigint
CHECK (char_length(VALUE::text) = 13)
;

DROP DOMAIN IF EXISTS public.kapi_dtc_epoch_seconds;
CREATE DOMAIN public.kapi_dtc_epoch_seconds bigint 
NOT NULL 
CHECK (char_length(VALUE::text) = 10)
;

DROP DOMAIN IF EXISTS public.kapi_dtc_epoch_seconds_auto;
CREATE DOMAIN public.kapi_dtc_epoch_seconds_auto bigint 
NOT NULL 
DEFAULT ((date_part('epoch'::text, CURRENT_TIMESTAMP AT TIME ZONE 'UTC')))::bigint
CHECK (char_length(VALUE::text) = 10)
;

---------------------------------------------------------------
-- timestamp
-- Base timestamp in milliseconds AT TIME ZONE 'UTC'
-- Format 
-- SELECT 
-- CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
-- TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS')::timestamp,
-- TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS.MS')::timestamp
---------------------------------------------------------------


DROP DOMAIN IF EXISTS public.kapi_dtc_timestamp;
CREATE DOMAIN public.kapi_dtc_timestamp timestamp NOT NULL
;

DROP DOMAIN IF EXISTS public.kapi_dtc_timestamp_auto;
CREATE DOMAIN public.kapi_dtc_timestamp_auto timestamp 
NOT NULL 
DEFAULT TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS.MS')::timestamp 
;

DROP DOMAIN IF EXISTS public.kapi_dtc_timestamp_seconds_auto;
CREATE DOMAIN public.kapi_dtc_timestamp_seconds_auto timestamp 
NOT NULL 
DEFAULT TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS')::timestamp 
--CHECK (char_length(VALUE::text) = 19)
;

DROP DOMAIN IF EXISTS public.kapi_dtc_timestamp_naive_auto;
CREATE DOMAIN public.kapi_dtc_timestamp_naive_auto timestamp 
NOT NULL 
DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::timestamp
;
COMMENT ON DOMAIN public.kapi_dtc_timestamp_naive_auto IS 'length > 23, match full timestamp precision  i.e: 2022-07-05 11:08:04.826507';
---------------------------------------------------------------
-- uuid v4
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtc_uuid;
CREATE DOMAIN public.kapi_dtc_uuid uuid NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtc_uuid_auto;
CREATE DOMAIN public.kapi_dtc_uuid_auto uuid NOT NULL DEFAULT uuid_generate_v4();

DROP DOMAIN IF EXISTS public.kapi_dtc_uuid_default;
CREATE DOMAIN public.kapi_dtc_default uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000';

---------------------------------------------------------------
-- jsonb
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtc_json;
CREATE DOMAIN public.kapi_dtc_json jsonb NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtc_json_default;
CREATE DOMAIN public.kapi_dtc_json_default jsonb NOT NULL DEFAULT '{}'::jsonb;

---------------------------------------------------------------
-- ltree
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtc_ltree;
CREATE DOMAIN public.kapi_dtc_ltree ltree NOT NULL;