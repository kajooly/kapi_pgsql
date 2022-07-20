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
-- Epoch time functions
-- MAIN FUNCTION: public.kapi_time_epoch
---------------------------------------------------------------

-- FUNCTION: public.kapi_time_epoch_now
-- DESCRIPTION: Returns the current epoch time in milliseconds, TZ UTC
-- RETURNS: 
-- bigint, 13 digits epoch time in milliseconds ie: 1658327306754
-- SELECT public.kapi_time_epoch_now();
DROP FUNCTION IF EXISTS public.kapi_time_epoch_now;
CREATE OR REPLACE FUNCTION public.kapi_time_epoch_now()
    RETURNS bigint
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE
    COST 1
AS $BODY$
    DECLARE
        _result bigint;
    BEGIN
        _result = ((date_part('epoch'::text, CURRENT_TIMESTAMP AT TIME ZONE 'UTC') * (1000)::double precision))::bigint;
        RETURN _result;
    END;
$BODY$;