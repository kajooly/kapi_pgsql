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

DROP DOMAIN IF EXISTS public.kapi_dtd_epoch;
CREATE DOMAIN public.kapi_dtd_epoch bigint 
NOT NULL 
CHECK (char_length(VALUE::text) = 13)
;

DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_auto;
CREATE DOMAIN public.kapi_dtd_epoch_auto bigint 
NOT NULL 
DEFAULT ((date_part('epoch'::text, CURRENT_TIMESTAMP AT TIME ZONE 'UTC') * (1000)::double precision))::bigint
CHECK (char_length(VALUE::text) = 13)
;

DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_seconds;
CREATE DOMAIN public.kapi_dtd_epoch_seconds bigint 
NOT NULL 
CHECK (char_length(VALUE::text) = 10)
;

DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_seconds_auto;
CREATE DOMAIN public.kapi_dtd_epoch_seconds_auto bigint 
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


DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp;
CREATE DOMAIN public.kapi_dtd_timestamp timestamp NOT NULL
;

DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_auto;
CREATE DOMAIN public.kapi_dtd_timestamp_auto timestamp 
NOT NULL 
DEFAULT TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS.MS')::timestamp 
;

DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_seconds_auto;
CREATE DOMAIN public.kapi_dtd_timestamp_seconds_auto timestamp 
NOT NULL 
DEFAULT TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS')::timestamp 
-- CHECK (char_length(VALUE::text) = 19)
;

DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_naive_auto;
CREATE DOMAIN public.kapi_dtd_timestamp_naive_auto timestamp 
NOT NULL 
DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')::timestamp
;
COMMENT ON DOMAIN public.kapi_dtd_timestamp_naive_auto IS 'length > 23, match full timestamp precision  i.e: 2022-07-05 11:08:04.826507';

---------------------------------------------------------------
-- uuid v4
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_uuid;
CREATE DOMAIN public.kapi_dtd_uuid uuid NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtd_uuid_auto;
CREATE DOMAIN public.kapi_dtd_uuid_auto uuid NOT NULL DEFAULT uuid_generate_v4();

DROP DOMAIN IF EXISTS public.kapi_dtd_uuid_default;
CREATE DOMAIN public.kapi_dtd_uuid_default uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000';

---------------------------------------------------------------
-- jsonb
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_json;
CREATE DOMAIN public.kapi_dtd_json jsonb NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtd_json_default;
CREATE DOMAIN public.kapi_dtd_json_default jsonb NOT NULL DEFAULT '{}'::jsonb;

---------------------------------------------------------------
-- ltree
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_ltree;
CREATE DOMAIN public.kapi_dtd_ltree ltree NOT NULL;

---------------------------------------------------------------
-- citext
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_citext;
CREATE DOMAIN public.kapi_dtd_citext citext NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtd_citext_default;
CREATE DOMAIN public.kapi_dtd_citext_default citext 
NOT NULL
DEFAULT 'undefined'::citext
;

-- 'a a'  OK
-- '             a a          '  Error
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_notempty;
CREATE DOMAIN public.kapi_dtd_citext_notempty citext
NOT NULL
CHECK (LENGTH(TRIM(VALUE)) = LENGTH(VALUE))
;

-- 'a a'  OK
-- '             a a          '  Error
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_notempty_default;
CREATE DOMAIN public.kapi_dtd_citext_notempty_default citext
NOT NULL
DEFAULT 'undefined'::citext
CHECK (LENGTH(TRIM(VALUE)) = LENGTH(VALUE))
;

-- 'a a'  OK
-- '             a a           '  OK
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_null_or_notempty;
CREATE DOMAIN public.kapi_dtd_citext_null_or_notempty citext
CHECK ((LENGTH(TRIM(VALUE)) > 0) OR VALUE IS NULL)
;

---------------------------------------------------------------
-- integer
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_int;
CREATE DOMAIN public.kapi_dtd_int integer NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtd_int_default;
CREATE DOMAIN public.kapi_dtd_int_default integer NOT NULL DEFAULT 0;

---------------------------------------------------------------
-- text
---------------------------------------------------------------
DROP DOMAIN IF EXISTS public.kapi_dtd_text;
CREATE DOMAIN public.kapi_dtd_text text NOT NULL;

DROP DOMAIN IF EXISTS public.kapi_dtd_text_default;
CREATE DOMAIN public.kapi_dtd_text_default text 
NOT NULL
DEFAULT 'undefined'::text
;

-- 'a a'  OK
-- '             a a          '  Error
DROP DOMAIN IF EXISTS public.kapi_dtd_text_notempty;
CREATE DOMAIN public.kapi_dtd_text_notempty text
NOT NULL
CHECK (LENGTH(TRIM(VALUE)) = LENGTH(VALUE))
;

-- 'a a'  OK
-- '             a a          '  Error
DROP DOMAIN IF EXISTS public.kapi_dtd_text_notempty_default;
CREATE DOMAIN public.kapi_dtd_text_notempty_default text
NOT NULL
DEFAULT 'undefined'::text
CHECK (LENGTH(TRIM(VALUE)) = LENGTH(VALUE))
;

-- 'a a'  OK
-- '             a a           '  OK
DROP DOMAIN IF EXISTS public.kapi_dtd_text_null_or_notempty;
CREATE DOMAIN public.kapi_dtd_text_null_or_notempty text
CHECK ((LENGTH(TRIM(VALUE)) > 0) OR VALUE IS NULL)
;