
-- CREATE OR REPLACE DIRECTORY MYDIR as 'G:\STUDENT';

DECLARE
    v_fisier UTL_FILE.FILE_TYPE;
    v_output_drop VARCHAR2(10000);
    v_output VARCHAR2(10000);

    v_cursor_id NUMBER;
    v_rec_tab   DBMS_SQL.DESC_TAB;
    v_nr_col    NUMBER;
    v_total_coloane NUMBER;
    v_columns VARCHAR2(10000);
    
BEGIN
    
    v_fisier := UTL_FILE.FOPEN('MYDIR', 'rez.sql', 'W');

    -- !!! Tabele

    FOR i IN (SELECT table_name FROM user_tables) LOOP

        v_output_drop := '-- DROP TABLE ' || i.table_name || ' CASCADE CONSTRAINTS ' || CHR(10) ;
        
        v_output := 'CREATE TABLE ' || i.table_name || ' ( ' || CHR(10);

        v_cursor_id := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_cursor_id, 'SELECT * FROM ' || i.table_name, DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_total_coloane, v_rec_tab);

        v_nr_col := v_rec_tab.FIRST;
        IF (v_nr_col IS NOT NULL) THEN
            LOOP
                v_output := v_output || v_rec_tab(v_nr_col).col_name || ' ';
                v_output := v_output || GETTYPE(v_rec_tab, v_nr_col);
                IF (v_rec_tab(v_nr_col).col_null_ok) THEN
                    v_output := v_output || ',';
                ELSE
                    v_output := v_output || ' NOT NULL,';
                END IF;

                v_nr_col := v_rec_tab.NEXT(v_nr_col);
                EXIT WHEN (v_nr_col IS NULL);
                v_output := v_output || CHR(10);
            END LOOP;
        END IF;

        FOR pk IN (SELECT col.column_name
                   FROM user_cons_columns col
                   JOIN user_constraints cons ON col.constraint_name = cons.constraint_name
                   WHERE cons.table_name = i.table_name AND cons.constraint_type = 'P') LOOP
            v_output := v_output || CHR(10) || 'CONSTRAINT PK_' || i.table_name || '_' || pk.column_name ||' PRIMARY KEY (' || pk.column_name || '),';
        END LOOP;

    
        FOR fk IN (SELECT col.column_name, fk.table_name, fk.column_name AS ref_column
                   FROM user_cons_columns col
                   JOIN user_constraints cons ON col.constraint_name = cons.constraint_name
                   JOIN user_cons_columns fk ON cons.r_constraint_name = fk.constraint_name
                   WHERE cons.table_name = i.table_name AND cons.constraint_type = 'R') LOOP
            v_output := v_output || CHR(10) || 'CONSTRAINT FK_' || i.table_name || '_'|| fk.column_name || ' FOREIGN KEY (' || fk.column_name || ') REFERENCES ' || fk.table_name || '(' || fk.ref_column || '),';
        END LOOP;

        
        FOR uniq IN (SELECT col.column_name
                     FROM user_cons_columns col
                     JOIN user_constraints cons ON col.constraint_name = cons.constraint_name
                     WHERE cons.table_name = i.table_name AND cons.constraint_type = 'U') LOOP
            v_output := v_output || CHR(10) || 'CONSTRAINT UNIQ_' || i.table_name || '_' ||  uniq.column_name || ' UNIQUE (' || uniq.column_name || '),';
        END LOOP;

        v_output := RTRIM(v_output, ',') || ') ' || CHR(10) || '/' || CHR(10);

        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

        UTL_FILE.PUT_LINE(v_fisier, v_output_drop);
        UTL_FILE.PUT_LINE(v_fisier, v_output);

    END LOOP;

    -- !!! Indecsi

        -- FOR i in (SELECT INDEX_NAME, TABLE_NAME FROM USER_INDEXES) LOOP
        --     v_output := 'CREATE INDEX ' || i.index_name || CHR(10) || 'ON ' || i.table_name 
        -- END LOOP;

    FOR i IN (SELECT INDEX_NAME, TABLE_NAME FROM USER_INDEXES) LOOP

        v_columns := '';

        FOR c IN (SELECT COLUMN_NAME
                  FROM USER_IND_COLUMNS
                  WHERE INDEX_NAME = i.INDEX_NAME
                  ORDER BY COLUMN_POSITION) LOOP
            
            IF v_columns IS NOT NULL THEN
                v_columns := v_columns || ', ' || c.COLUMN_NAME;
            ELSE
                v_columns := c.COLUMN_NAME;
            END IF;
        END LOOP;
        
        v_output := 'CREATE INDEX ' || i.INDEX_NAME || ' ON ' || i.TABLE_NAME || ' (' || v_columns || ');';

        v_output := v_output || chr(10);
        UTL_FILE.PUT_LINE(v_fisier, v_output);

    END LOOP;
    

    -- !!! Functii/Proceduri
    -- obs: in user_procdures se afla si triggerele si pachetele dar tratez cazurile separat

    FOR i in (SELECT OBJECT_NAME, OBJECT_type FROM USER_PROCEDURES where OBJECT_TYPE IN ('FUNCTION', 'PROCEDURE')) LOOP 

        v_output := 'CREATE OR REPLACE ';
        FOR l in (select text from USER_SOURCE where name = i.OBJECT_NAME and TYPE = i.OBJECT_type) LOOP
            v_output := v_output || l.text; -- avem deja tipul, numele, param, return type in prima linie
        end loop; 
        v_output := v_output || CHR(10) ||'/' || chr(10);
        
        UTL_FILE.PUT_LINE(v_fisier, v_output);
    END LOOP;

    -- !!! Pachete
    -- select * from user_procedures where object_type='PACKAGE';

    FOR i in (SELECT distinct OBJECT_NAME FROM USER_PROCEDURES where OBJECT_TYPE ='PACKAGE') LOOP 

        v_output := 'CREATE OR REPLACE ';
        FOR l in (select text from USER_SOURCE where name = i.OBJECT_NAME AND TYPE = 'PACKAGE') LOOP
            v_output := v_output || l.text; -- avem deja tipul, numele, param, return type in prima linie
        end loop; 
        v_output := v_output || CHR(10) || '/' ||  chr(10);
        
        UTL_FILE.PUT_LINE(v_fisier, v_output);
    END LOOP;


    -- !!! Triggere
    -- select * from user_triggers;

    FOR i IN (SELECT  trigger_name FROM USER_TRIGGERS) LOOP
        v_output := 'CREATE OR REPLACE ';
        FOR l in (select text from USER_SOURCE where name = i.trigger_name) LOOP
            v_output := v_output || l.text; 
        end loop;
        v_output := v_output ||  CHR(10) || '/' || chr(10);
        
        UTL_FILE.PUT_LINE(v_fisier, v_output);
    end loop;

    -- !!! Types
    -- select * from user_types;

    FOR i IN (SELECT DISTINCT TYPE_NAME FROM USER_TYPES) LOOP
        v_output := 'CREATE OR REPLACE ';
        FOR l IN (SELECT text FROM USER_SOURCE WHERE name = i.TYPE_NAME AND TYPE = 'TYPE') LOOP
            v_output := v_output || l.text;
        END LOOP;
        
        v_output := v_output || CHR(10) || '/' || CHR(10);
        UTL_FILE.PUT_LINE(v_fisier, v_output); 

        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_count FROM USER_SOURCE WHERE name = i.TYPE_NAME AND TYPE = 'TYPE BODY';
            
            IF v_count > 0 THEN
                v_output := 'CREATE OR REPLACE ';
                FOR l IN ( SELECT text FROM USER_SOURCE WHERE name = i.TYPE_NAME AND TYPE = 'TYPE BODY' ) LOOP
                    v_output := v_output || l.text;
                END LOOP;

                v_output := v_output || CHR(10) || '/' || CHR(10);
                UTL_FILE.PUT_LINE(v_fisier, v_output); 
            END IF;
        END;
    END LOOP;

    -- !!! Secvente
    -- SELECT * FROM USER_SEQUENCES;

    FOR i in (select sequence_name, min_value, INCREMENT_BY from USER_SEQUENCES) LOOP
        v_output := 'CREATE SEQUENCE ' || i.sequence_name;
        v_output := v_output || chr(10) || 'START WITH ' || i.min_value || chr(10) || 'INCREMENT BY ' || i.increment_by;
        v_output := v_output ||';' || chr(10);

        utl_file.PUT_LINE(v_fisier, v_output);
    end loop;
    UTL_FILE.FCLOSE(v_fisier);
END;

-- select * from user_types;
-- select * from user_procedures;
-- select text from USER_SOURCE where name = i.OBJECT_NAME
-- select * from user_source where type 
-- SELECT * FROM USER_SEQUENCES;
