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


-- FUNCION: public.kapi_tablefunc_updatedat
-- DESCRIPTION: This Trigger Function is used to update the date of the last update of the table.
-- USAGE: 
-- SELECT public.kapi_tablefunc_updatedat('categories','brands_data','node_updated_at');
-- SELECT public.kapi_tablefunc_updatedat('categories','brands_data');
DROP FUNCTION IF EXISTS public.kapi_tablefunc_updatedat;
CREATE OR REPLACE FUNCTION public.kapi_tablefunc_updatedat(
    _schema varchar, 
    _table varchar,
    _updatedat_column varchar DEFAULT 'updated_at'
)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
COST 100
AS
$$
DECLARE
    _table_name varchar default  _table;
    _table_name_full varchar default _schema || '.' || _table;
BEGIN
    EXECUTE '
	CREATE OR REPLACE FUNCTION ' || _schema || '.' || _table_name || '_trg_fn_b4_update_updatedat()
	RETURNS trigger 
	AS 
	$BODY$ 
	BEGIN
      -- Now epoch time in milliseconds or default to current time
	  NEW.' || _updatedat_column || ' =  public.kapi_time_epoch_now();
	  RETURN NEW;
	END;
	$BODY$ 
    LANGUAGE plpgsql
	;
	';

    EXECUTE	'
	DROP TRIGGER IF EXISTS trg_updatedat ON ' || _table_name_full || ';
	CREATE TRIGGER trg_updatedat
	BEFORE UPDATE 
	ON ' || _table_name_full || '
	FOR EACH ROW
	EXECUTE PROCEDURE ' || _schema || '.' || _table || '_trg_fn_b4_update_updatedat();
	';
END;
$$;


-- FUNCION: public.kapi_tablefunc_mvw_refresh
-- DESCRIPTION: This Trigger Function is used to refresh the materialized view.
-- USAGE: 
-- SELECT public.kapi_tablefunc_mvw_refresh('categories.brands_nodes','categories','brands_tree');
DROP FUNCTION IF EXISTS public.kapi_tablefunc_mvw_refresh;
CREATE OR REPLACE FUNCTION public.kapi_tablefunc_mvw_refresh(
    _source varchar,
    _view_schema varchar,
    _view varchar
)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
COST 100
AS
$$
DECLARE
    _table_name_full varchar default _source;
    _view_name varchar default  _view;
    _view_name_full varchar default _view_schema || '.' || _view;
    _func_name_full varchar default  _table_name_full || '_trg_mvw_refresh_' || _view_name || '()';
BEGIN
    EXECUTE '
	CREATE OR REPLACE FUNCTION ' || _func_name_full || ' 
	RETURNS trigger 
	AS 
	$t$ 
	BEGIN
	  REFRESH MATERIALIZED VIEW ' || _view_name_full || ';
	  RETURN NULL;
	END;
	$t$ LANGUAGE plpgsql
    ;
	';
		
	EXECUTE	'
	DROP TRIGGER IF EXISTS refresh_mvw_trg_' || _view_name || ' ON ' || _table_name_full || ';
	CREATE TRIGGER tree_refresh_mvw_trg
	AFTER INSERT OR UPDATE OR DELETE
	ON ' || _table_name_full || '
	FOR EACH STATEMENT
	EXECUTE PROCEDURE ' || _func_name_full || ';
	';
END;
$$;

