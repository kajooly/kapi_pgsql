CREATE OR REPLACE FUNCTION public.kapi_tree_new_struct(ctxName text) 
RETURNS VOID
AS
$$
BEGIN
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
	CREATE EXTENSION IF NOT EXISTS citext;
	CREATE EXTENSION IF NOT EXISTS ltree;
	
	EXECUTE 'CREATE SCHEMA IF NOT EXISTS ' || ctxName || ' ;';

	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || ctxName || '.nodes
	(
		id uuid PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
		owner_id uuid NOT NULL,
		pod ltree NOT NULL,
		metadata jsonb DEFAULT ''{}''::jsonb,
		inserted_at timestamp(0) without time zone NOT NULL DEFAULT now(),
		updated_at timestamp(0) without time zone NOT NULL DEFAULT now()
	);';
	
	EXECUTE 'CREATE INDEX owner_idx ON ' || ctxName || '.nodes (owner_id);';

	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || ctxName || '.links
	(
		id uuid PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
		parent_id uuid,
		child_id uuid NOT NULL,
		behaviour citext NOT NULL DEFAULT ''link'',
		metadata jsonb DEFAULT ''{}''::jsonb,
		inserted_at timestamp(0) without time zone NOT NULL DEFAULT now(),
		updated_at timestamp(0) without time zone NOT NULL DEFAULT now()
	);';
	
	EXECUTE 'ALTER TABLE ' || ctxName || '.links ADD CONSTRAINT not_same_parent_child CHECK (parent_id <> child_id);';
	EXECUTE 'CREATE UNIQUE INDEX both_ways_uk ON ' || ctxName || '.links (greatest(parent_id,child_id), least(parent_id,child_id));';
	
	EXECUTE 'ALTER TABLE ' || ctxName || '.links
	ADD CONSTRAINT parent_fkey
	FOREIGN KEY (parent_id)
	REFERENCES ' || ctxName || '.nodes(id)
	ON DELETE NO ACTION;';
	
	EXECUTE 'ALTER TABLE ' || ctxName || '.links
	ADD CONSTRAINT child_fkey
	FOREIGN KEY (child_id)
	REFERENCES ' || ctxName || '.nodes(id)
	ON DELETE NO ACTION;';
	
END;
$$
LANGUAGE plpgsql;
