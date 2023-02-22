\prompt 'Enter table name: ' table_name
SET val.name = :'table_name';
do
$$
    declare
        columns record;
        id_table oid;
        name text;
        number text;
        type text;
        id_type oid;
        constr_name text;
	  constr_check text;
	  constr text;
        result text;
    begin
        select oid into id_table from pg_class where relname = current_setting('val.name');
	  if id_table is NULL then
	      raise notice 'This table does not exist';
	  else
	      raise notice 'Таблица: %', current_setting('val.name');
            raise notice 'No.  Имя столбца         Атрибуты';
            raise notice '--- ------------ ------------------------------------------------------';
            for columns in select * from pg_attribute where attrelid = id_table
            loop
	          if columns.attnum < 0 then
	              continue;
	          end if;
                number = columns.attnum;
                name = columns.attname;
                id_type = columns.atttypid;
	   
                select typname into type from pg_catalog.pg_type where oid = id_type;
	          select conname into constr_name from pg_constraint where oid = id_table;
	          select * into constr_check from pg_get_constraintdef(id_table);
	          constr = constr_name || ' ' || constr_check;

                select format('%-3s %-16s %-6s %s', number, name, 'Type   :', type) into result;
                raise notice '%', result;
	          select format('%-20s %-8s %s', '|', 'Constr :', constr) into result;
	          raise notice '%', result;
            end loop;
	    end if;
        end;
$$ LANGUAGE plpgsql;