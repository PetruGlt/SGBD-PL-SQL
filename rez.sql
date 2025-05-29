-- DROP TABLE STUDENTI CASCADE CONSTRAINTS 

CREATE TABLE STUDENTI ( 
ID NUMBER(38,0) NOT NULL,
NR_MATRICOL VARCHAR2(6) NOT NULL,
NUME VARCHAR2(15) NOT NULL,
PRENUME VARCHAR2(30) NOT NULL,
AN NUMBER(1,0),
GRUPA CHAR(2),
BURSA NUMBER(6,2),
DATA_NASTERE DATE,
EMAIL VARCHAR2(40),
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_STUDENTI_ID PRIMARY KEY (ID)) 
/

-- DROP TABLE CURSURI CASCADE CONSTRAINTS 

CREATE TABLE CURSURI ( 
ID NUMBER(38,0) NOT NULL,
TITLU_CURS VARCHAR2(52) NOT NULL,
AN NUMBER(1,0),
SEMESTRU NUMBER(1,0),
CREDITE NUMBER(2,0),
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_CURSURI_ID PRIMARY KEY (ID)) 
/

-- DROP TABLE NOTE CASCADE CONSTRAINTS 

CREATE TABLE NOTE ( 
ID NUMBER(38,0) NOT NULL,
ID_STUDENT NUMBER(38,0) NOT NULL,
ID_CURS NUMBER(38,0) NOT NULL,
VALOARE NUMBER(2,0),
DATA_NOTARE DATE,
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_NOTE_ID PRIMARY KEY (ID),
CONSTRAINT FK_NOTE_ID_STUDENT FOREIGN KEY (ID_STUDENT) REFERENCES STUDENTI(ID),
CONSTRAINT FK_NOTE_ID_CURS FOREIGN KEY (ID_CURS) REFERENCES CURSURI(ID)) 
/

-- DROP TABLE PROFESORI CASCADE CONSTRAINTS 

CREATE TABLE PROFESORI ( 
ID NUMBER(38,0) NOT NULL,
NUME VARCHAR2(15) NOT NULL,
PRENUME VARCHAR2(30) NOT NULL,
GRAD_DIDACTIC VARCHAR2(20),
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_PROFESORI_ID PRIMARY KEY (ID)) 
/

-- DROP TABLE DIDACTIC CASCADE CONSTRAINTS 

CREATE TABLE DIDACTIC ( 
ID NUMBER(38,0) NOT NULL,
ID_PROFESOR NUMBER(38,0) NOT NULL,
ID_CURS NUMBER(38,0) NOT NULL,
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_DIDACTIC_ID PRIMARY KEY (ID),
CONSTRAINT FK_DIDACTIC_ID_PROFESOR FOREIGN KEY (ID_PROFESOR) REFERENCES PROFESORI(ID),
CONSTRAINT FK_DIDACTIC_ID_CURS FOREIGN KEY (ID_CURS) REFERENCES CURSURI(ID)) 
/

-- DROP TABLE PRIETENI CASCADE CONSTRAINTS 

CREATE TABLE PRIETENI ( 
ID NUMBER(38,0) NOT NULL,
ID_STUDENT1 NUMBER(38,0) NOT NULL,
ID_STUDENT2 NUMBER(38,0) NOT NULL,
CREATED_AT DATE,
UPDATED_AT DATE,
CONSTRAINT PK_PRIETENI_ID PRIMARY KEY (ID),
CONSTRAINT FK_PRIETENI_ID_STUDENT1 FOREIGN KEY (ID_STUDENT1) REFERENCES STUDENTI(ID),
CONSTRAINT FK_PRIETENI_ID_STUDENT2 FOREIGN KEY (ID_STUDENT2) REFERENCES STUDENTI(ID),
CONSTRAINT UNIQ_PRIETENI_ID_STUDENT1 UNIQUE (ID_STUDENT1),
CONSTRAINT UNIQ_PRIETENI_ID_STUDENT2 UNIQUE (ID_STUDENT2)) 
/

CREATE INDEX SYS_C007398 ON STUDENTI (ID);

CREATE INDEX SYS_C007411 ON PROFESORI (ID);

CREATE INDEX IDX_NUME_PROFESOR ON PROFESORI (NUME);

CREATE INDEX SYS_C007420 ON PRIETENI (ID);

CREATE INDEX NO_DUPLICATES ON PRIETENI (ID_STUDENT1, ID_STUDENT2);

CREATE INDEX SYS_C007405 ON NOTE (ID);

CREATE INDEX SYS_C007415 ON DIDACTIC (ID);

CREATE INDEX SYS_C007401 ON CURSURI (ID);

CREATE OR REPLACE FUNCTION getType(v_rec_tab DBMS_SQL.DESC_TAB, v_nr_col int) RETURN VARCHAR2 AS
  v_tip_coloana VARCHAR2(200);
  v_precizie VARCHAR2(40);
BEGIN
     CASE (v_rec_tab(v_nr_col).col_type)
        WHEN 1 THEN v_tip_coloana := 'VARCHAR2'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 2 THEN v_tip_coloana := 'NUMBER'; v_precizie := '(' || v_rec_tab(v_nr_col).col_precision || ',' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 12 THEN v_tip_coloana := 'DATE'; v_precizie := '';
        WHEN 96 THEN v_tip_coloana := 'CHAR'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 112 THEN v_tip_coloana := 'CLOB'; v_precizie := '';
        WHEN 113 THEN v_tip_coloana := 'BLOB'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'XMLTYPE'; v_precizie := '';
        WHEN 101 THEN v_tip_coloana := 'BINARY_DOUBLE'; v_precizie := '';
        WHEN 100 THEN v_tip_coloana := 'BINARY_FLOAT'; v_precizie := '';
        WHEN 8 THEN v_tip_coloana := 'LONG'; v_precizie := '';
        WHEN 180 THEN v_tip_coloana := 'TIMESTAMP'; v_precizie :='(' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 181 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH TIME ZONE'; v_precizie := '';
        WHEN 231 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH LOCAL TIME ZONE'; v_precizie := '';
        WHEN 114 THEN v_tip_coloana := 'BFILE'; v_precizie := '';
        WHEN 23 THEN v_tip_coloana := 'RAW'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 11 THEN v_tip_coloana := 'ROWID'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'URITYPE'; v_precizie := '';
      END CASE; 
      RETURN v_tip_coloana||v_precizie;
END;

/

CREATE OR REPLACE FUNCTION getTsasdype(v_rec_tab DBMS_SQL.DESC_TAB, v_nr_col int) RETURN VARCHAR2 AS
  v_tip_coloana VARCHAR2(200);
  v_precizie VARCHAR2(40);
BEGIN
     CASE (v_rec_tab(v_nr_col).col_type)
        WHEN 1 THEN v_tip_coloana := 'VARCHAR2'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 2 THEN v_tip_coloana := 'NUMBER'; v_precizie := '(' || v_rec_tab(v_nr_col).col_precision || ',' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 12 THEN v_tip_coloana := 'DATE'; v_precizie := '';
        WHEN 96 THEN v_tip_coloana := 'CHAR'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 112 THEN v_tip_coloana := 'CLOB'; v_precizie := '';
        WHEN 113 THEN v_tip_coloana := 'BLOB'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'XMLTYPE'; v_precizie := '';
        WHEN 101 THEN v_tip_coloana := 'BINARY_DOUBLE'; v_precizie := '';
        WHEN 100 THEN v_tip_coloana := 'BINARY_FLOAT'; v_precizie := '';
        WHEN 8 THEN v_tip_coloana := 'LONG'; v_precizie := '';
        WHEN 180 THEN v_tip_coloana := 'TIMESTAMP'; v_precizie :='(' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 181 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH TIME ZONE'; v_precizie := '';
        WHEN 231 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH LOCAL TIME ZONE'; v_precizie := '';
        WHEN 114 THEN v_tip_coloana := 'BFILE'; v_precizie := '';
        WHEN 23 THEN v_tip_coloana := 'RAW'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 11 THEN v_tip_coloana := 'ROWID'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'URITYPE'; v_precizie := '';
      END CASE; 
      RETURN v_tip_coloana||v_precizie;
END;

/

CREATE OR REPLACE procedure afiseaza_profesori(camp IN varchar2) as
   v_cursor_id INTEGER;
   v_ok INTEGER;

   v_id_prof number(2);
   v_nume_prof varchar2(15);
   v_prenume_prof varchar2(30);
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'SELECT id, nume, prenume FROM profesori ORDER BY '||camp, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_id_prof); 
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_nume_prof,51); 
  -- ATENTIE!! la coloanele de tip varchar2 sau char trebuie specificata si dimensiunea
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_prenume_prof,30);   
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);

  LOOP 
     IF DBMS_SQL.FETCH_ROWS(v_cursor_id)>0 THEN 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_id_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_nume_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_prenume_prof); 

         DBMS_OUTPUT.PUT_LINE(v_id_prof || '   ' || v_nume_prof || '    ' || v_prenume_prof);
      ELSE 
        EXIT; 
      END IF; 
  END LOOP;   
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;

/

CREATE OR REPLACE procedure afiseazasda_profesori(camp IN varchar2) as
   v_cursor_id INTEGER;
   v_ok INTEGER;

   v_id_prof number(2);
   v_nume_prof varchar2(15);
   v_prenume_prof varchar2(30);
begin
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor_id, 'SELECT id, nume, prenume FROM profesori ORDER BY '||camp, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_id_prof); 
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_nume_prof,51); 
  -- ATENTIE!! la coloanele de tip varchar2 sau char trebuie specificata si dimensiunea
  DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_prenume_prof,30);   
  v_ok := DBMS_SQL.EXECUTE(v_cursor_id);

  LOOP 
     IF DBMS_SQL.FETCH_ROWS(v_cursor_id)>0 THEN 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_id_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_nume_prof); 
         DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_prenume_prof); 

         DBMS_OUTPUT.PUT_LINE(v_id_prof || '   ' || v_nume_prof || '    ' || v_prenume_prof);
      ELSE 
        EXIT; 
      END IF; 
  END LOOP;   
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;

/

CREATE OR REPLACE PACKAGE manager_facultate IS
      g_today_date   DATE:= SYSDATE;
      CURSOR lista_studenti IS SELECT nr_matricol, nume, prenume, grupa, an FROM studenti ORDER BY nume;
     PROCEDURE adauga_student (nume studenti.nume%type, prenume studenti.prenume%type);
     PROCEDURE sterge_student (nr_matr studenti.nr_matricol%type);
END manager_facultate;

/

CREATE OR REPLACE TRIGGER dml_stud
   BEFORE INSERT OR UPDATE OR DELETE ON studenti
BEGIN
  dbms_output.put_line('Operatie DML in tabela studenti !');
  -- puteti sa vedeti cine a declansat triggerul:
  CASE
     WHEN INSERTING THEN DBMS_OUTPUT.PUT_LINE('INSERT');
     WHEN DELETING THEN DBMS_OUTPUT.PUT_LINE('DELETE');
     WHEN UPDATING THEN DBMS_OUTPUT.PUT_LINE('UPDATE');
     -- WHEN UPDATING('NUME') THEN .... // vedeti mai jos trigere ce se executa doar la modificarea unui camp
  END CASE;
END;

/

CREATE OR REPLACE TYPE student AS OBJECT
(nume varchar2(10),
 prenume varchar2(10),
 grupa varchar2(4),
 an number(1), 
 data_nastere date,
 member procedure afiseaza_foaie_matricola
);

/

CREATE OR REPLACE TYPE BODY student AS
   MEMBER PROCEDURE afiseaza_foaie_matricola IS
   BEGIN
       DBMS_OUTPUT.PUT_LINE('Aceasta procedura calculeaza si afiseaza foaia matricola');
   END afiseaza_foaie_matricola;
END;

/

CREATE OR REPLACE TYPE profesori_t AS OBJECT (
    id_profesor NUMBER,
    nume VARCHAR2(50),
    prenume VARCHAR2(50)
);

/

CREATE SEQUENCE PROFESORI_SEQ
START WITH 1
INCREMENT BY 1;

