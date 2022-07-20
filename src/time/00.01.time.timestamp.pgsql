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
-- TimeStamp Functions get or format timestamp
-- ISO 8601 format
-- Default timestamp in milliseconds & UTC timezone
-- MAIN FUNCTION: public.kapi_time_timestamp
---------------------------------------------------------------

-- FUNCTION: public.kapi_time_timestamp_seconds
-- i.e: 2022-07-05 14:45:08
-- SELECT public.kapi_time_timestamp_seconds('2022-07-05 14:45:08.471898');
-- SELECT public.kapi_time_timestamp_seconds();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp_seconds;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp_seconds(
    _timestamp timestamp DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
AS $BODY$
DECLARE
	_result timestamp;
BEGIN
    _result = TO_CHAR((_timestamp AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS')::timestamp ;
    RETURN _result;
END;
$BODY$;

-- FUNCTION: public.kapi_time_timestamp_milliseconds
-- i.e: 2022-07-05 14:45:08.471
-- SELECT public.kapi_time_timestamp_milliseconds('2022-07-05 14:45:08.471898');
-- SELECT public.kapi_time_timestamp_milliseconds();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp_milliseconds;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp_milliseconds(
    _timestamp timestamp DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
AS $BODY$
DECLARE
	_result timestamp;
BEGIN
    _result = TO_CHAR((_timestamp AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS.MS')::timestamp;
    RETURN _result;
END;
$BODY$;

-- FUNCTION: public.kapi_time_timestamp_naive
-- i.e: 2022-07-05 14:45:08.471898
-- SELECT public.kapi_time_timestamp_naive('2022-07-05 14:45:08.471898');
-- SELECT public.kapi_time_timestamp_naive();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp_naive;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp_naive(
    _timestamp timestamp DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
AS $BODY$
DECLARE
	_result timestamp;
BEGIN
    _result = (_timestamp AT TIME ZONE 'UTC')::timestamp ;
    RETURN _result;
END;
$BODY$;

-- @description: Default timestamp in milliseconds & UTC timezone
-- FUNCTION: public.kapi_time_timestamp
-- SELECT public.kapi_time_timestamp('2022-07-05 14:45:08.471898');
-- SELECT public.kapi_time_timestamp();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp(
    _timestamp timestamp DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
AS $BODY$
DECLARE
	_result timestamp;
BEGIN
    _result = public.kapi_time_timestamp_milliseconds(_timestamp);
    RETURN _result;
END;
$BODY$;