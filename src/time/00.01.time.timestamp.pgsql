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


--------------------------------------------------------------

-- SELECT public.kapi_time_timestamp_now();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp_now;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp_now()
    RETURNS timestamp
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
AS $BODY$
    DECLARE
        _result timestamp;
    BEGIN
        _result = TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC'), 'YYYY-MM-DD HH24:MI:SS.MS')::timestamp;
        RETURN _result;
    END;
$BODY$;


---------------------------------------------------------------
-- TimeStamp Functions get or format timestamp
-- ISO 8601 format
-- Default timestamp in milliseconds & UTC timezone
-- MAIN FUNCTION: public.kapi_time_timestamp
-- Refer to timezones: select * from pg_timezone_names;
-- some examples
-- SELECT (now()::TIMESTAMP WITH TIME ZONE at time zone 'America/mexico_city')::TIMESTAMP WITH TIME ZONE ;
-- SELECT now()::timestamp at time zone 'UTC' at time zone 'America/mexico_city';
-- SELECT timezone('America/mexico_city',now()::timestamptz);
---------------------------------------------------------------

-- FUNCTION: public.kapi_time_timestamp_seconds
-- i.e: 2022-07-05 14:45:08
-- SELECT public.kapi_time_timestamp_seconds('2022-07-23 11:57:07.115713 America/mexico_city');
-- SELECT public.kapi_time_timestamp_seconds('2022-07-23 11:41:23.113887+00');
-- SELECT public.kapi_time_timestamp_seconds('Wed 17 Dec 07:37:16 1997 PST');
-- SELECT public.kapi_time_timestamp_seconds('2004-10-19 10:23:54+02');
-- SELECT public.kapi_time_timestamp_seconds('1999-01-08 04:05:06 -8:00');
-- SELECT public.kapi_time_timestamp_seconds('2022-07-05 14:45:08.471898');
-- SELECT public.kapi_time_timestamp_seconds();
DROP FUNCTION IF EXISTS public.kapi_time_timestamp_seconds;
CREATE OR REPLACE FUNCTION public.kapi_time_timestamp_seconds(
    _timestamp timestamptz DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
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
    _timestamp timestamptz DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
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
    _timestamp timestamptz DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
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
    _timestamp timestamptz DEFAULT CURRENT_TIMESTAMP
    )
    RETURNS timestamp
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
AS $BODY$
DECLARE
	_result timestamp;
BEGIN
    _result = public.kapi_time_timestamp_milliseconds(_timestamp);
    RETURN _result;
END;
$BODY$;

---------------------------------------------------------------
-- End OF TimeStamp FORMAT Functions
---------------------------------------------------------------