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

DROP DOMAIN IF EXISTS public.kapi_dtd_epoch;
DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_seconds;
DROP DOMAIN IF EXISTS public.kapi_dtd_epoch_seconds_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp;
DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_seconds_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_timestamp_naive_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_uuid;
DROP DOMAIN IF EXISTS public.kapi_dtd_uuid_auto;
DROP DOMAIN IF EXISTS public.kapi_dtd_uuid_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_json;
DROP DOMAIN IF EXISTS public.kapi_dtd_json_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_ltree;
DROP DOMAIN IF EXISTS public.kapi_dtd_citext;
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_notempty;
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_notempty_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_citext_null_or_notempty;
DROP DOMAIN IF EXISTS public.kapi_dtd_int;
DROP DOMAIN IF EXISTS public.kapi_dtd_int_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_text;
DROP DOMAIN IF EXISTS public.kapi_dtd_text_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_text_notempty;
DROP DOMAIN IF EXISTS public.kapi_dtd_text_notempty_default;
DROP DOMAIN IF EXISTS public.kapi_dtd_text_null_or_notempty;
