--------------------------------------------------------------------------------------------------------------------------------
--Path and ultility commands
--------------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA Coursework;
DROP SCHEMA Coursework CASCADE;

SET SEARCH_PATH TO Coursework, PUBLIC;

--Select commands
SELECT * FROM cancel;
SELECT * FROM ticket;
SELECT * FROM spectator;
SELECT * FROM event;

SELECT * FROM Table_count;
SELECT * FROM Event_tickets_issued;

--Drop all tables
DROP TABLE cancel;
DROP TABLE ticket;
DROP TABLE spectator;
DROP TABLE event;

--Fill the tables with my data
CALL fill_tables();

--Empty all tables
CALL empty_tables();

--Remove all views
CALL drop_select_views();

--Testing commands
BEGIN;
ROLLBACK;
COMMIT;

--------------------------------------------------------------------------------------------------------------------------------
--Table creation, and constraints
--------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE event (
    ecode        CHAR(4)		PRIMARY KEY,
    edesc        VARCHAR(20)	NOT NULL,
    elocation    VARCHAR(20)	NOT NULL,
    edate        DATE			NOT NULL		CHECK(edate >='2024-07-01' AND edate <='2024-07-31'),
    etime        TIME			NOT NULL		CHECK(etime >='9:00'),
    emax         SMALLINT		NOT NULL		CHECK(emax >= 1 AND emax <= 1000  )
);

CREATE TABLE spectator (
    sno          INTEGER		PRIMARY KEY,
    sname        VARCHAR(20)	NOT NULL,
    semail       VARCHAR(20) 	NOT NULL		UNIQUE
);

CREATE TABLE ticket (
    tno          INTEGER		PRIMARY KEY,
    ecode        CHAR(4)		NOT NULL,		FOREIGN KEY (ecode) REFERENCES event ON DELETE RESTRICT,
    sno          INTEGER 		NOT NULL,		FOREIGN KEY (sno) REFERENCES spectator ON DELETE RESTRICT,
	UNIQUE(ecode, sno)

);

CREATE TABLE cancel (
    tno          INTEGER		NOT NULL,
    ecode        CHAR(4)		NOT NULL,
    sno          INTEGER		NOT NULL,
    cdate        TIMESTAMP		NOT NULL		DEFAULT CURRENT_TIMESTAMP,
    cuser        VARCHAR(128)	NOT NULL		DEFAULT CURRENT_USER,
	PRIMARY KEY(tno, cdate)
);

--------------------------------------------------------------------------------------------------------------------------------
--Views
--------------------------------------------------------------------------------------------------------------------------------

--|Creates a view of the number of spectatorts liable to travel to a location and the date of travel|---------------------------
CREATE VIEW Travel_number("Number of Spectators", elocation, edate)
AS 
SELECT DISTINCT ON (e.ecode, edate) COUNT(sno), elocation, edate
FROM event AS e
LEFT JOIN ticket AS t ON t.ecode = e.ecode 
GROUP BY elocation, edate, e.ecode

DROP VIEW Travel_number;

---|Creates a view that lists the number of tickets currently valid and event descriptions for those events|--------------------
CREATE VIEW Event_tickets("Number of Tickets", edesc, ecode)
AS 
SELECT COUNT(t.ecode), edesc, e.ecode
FROM event AS e
LEFT JOIN ticket AS t ON t.ecode = e.ecode
GROUP BY edesc, e.ecode

DROP VIEW Event_tickets;


---|Create a schedule for a spectator|------------------------------------------------------------------------------------------
CREATE VIEW Schedule("Spectator name", sno, edate, elocation, etime, edesc)
AS 
SELECT sname, s.sno, edate, elocation, etime, edesc
FROM event AS e
LEFT JOIN ticket AS t ON t.ecode = e.ecode 
INNER JOIN spectator AS s ON  s.sno = t.sno

DROP VIEW Schedule;

---|Creates a view that tells you the status of a ticket and id info|-----------------------------------------------------------
CREATE OR REPLACE VIEW particular_ticket 
AS
SELECT tno, sname, ecode, ticket_status(t.tno)
FROM spectator AS s
LEFT JOIN ticket AS t ON s.sno = t.sno
UNION
SELECT c.tno, s.sname, c.ecode, ticket_status(c.tno) AS status
FROM spectator AS s
RIGHT JOIN cancel AS c ON s.sno = c.sno;

DROP VIEW particular_ticket;

---|Create a view to combine event,spectator and cancel for the details of cancelled tickets|-----------------------------------
CREATE OR REPLACE VIEW cancel_details
AS
SELECT c.ecode, tno, c.sno, edesc, elocation, edate, etime, sname, semail 
FROM cancel AS c
LEFT JOIN event AS e ON e.ecode = c.ecode
LEFT JOIN spectator AS s ON s.sno = c.sno

DROP VIEW cancel_details;

--|Check we have the expected amount of rows in our tables|---------------------------------------------------------------------
CREATE VIEW Table_count("Table name","Row count")
AS 
SELECT 'event', count(*) FROM event
UNION
SELECT 'spectator', count(*) FROM spectator
UNION
SELECT 'ticket', count(*) FROM ticket
UNION
SELECT 'cancel', count(*) FROM cancel

DROP VIEW Table_count;

--------------------------------------------------------------------------------------------------------------------------------
--Trigger functions
--------------------------------------------------------------------------------------------------------------------------------

--Logs A DELETE
CREATE TRIGGER log_delete
BEFORE DELETE ON ticket
FOR EACH ROW
EXECUTE PROCEDURE Log_deleted_tickets();

--Removes tickets for event deletetion
CREATE TRIGGER remove_event
BEFORE DELETE ON event
FOR EACH ROW
EXECUTE PROCEDURE Delete_ticket_edelete();

--Removes tickets for event updates
CREATE TRIGGER remove_tickets
AFTER UPDATE ON event
FOR EACH ROW
EXECUTE PROCEDURE Delete_tickets_eupdate();

--------------------------------------------------------------------------------------------------------------------------------
--Non-trigger Functions
--------------------------------------------------------------------------------------------------------------------------------

--Testing commands
BEGIN;
ROLLBACK;
COMMIT;

---|Keeps track of deleted tickets|---------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Log_deleted_tickets()
RETURNS trigger 
AS $log_delete$
BEGIN
	INSERT INTO cancel (tno, ecode, sno, cdate, cuser) 
	VALUES (OLD.tno, OLD.ecode, OLD.sno, CURRENT_TIMESTAMP, CURRENT_USER);
	RETURN OLD;
END;
$log_delete$
LANGUAGE PLPGSQL;

DROP FUNCTION Log_deleted_tickets CASCADE;

--DELETE TEST--
--Delete the ticket
DELETE FROM ticket WHERE tno = 1;

--Reverse the cancel, if forgot begin
insert into ticket values (1, 	'K003', 61);
DELETE FROM cancel WHERE tno = 1;

--Selects for checking
SELECT * FROM cancel;
SELECT * FROM ticket;

---|Deletes tickets when events change|-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Delete_tickets_eupdate()
RETURNS trigger 
AS $remove_tickets$
BEGIN
	IF NEW.elocation != OLD.elocation OR NEW.edate != OLD.edate OR NEW.etime != OLD.etime THEN
		DELETE FROM ticket WHERE ecode = NEW.ecode;
	END IF;
	RETURN NEW;
END;
$remove_tickets$
LANGUAGE PLPGSQL;

DROP FUNCTION Delete_tickets_eupdate CASCADE;

--UPDATE TEST--
--No meaningful change
UPDATE event
SET elocation = 'London' WHERE ecode = 'K003'

--A meaningful change
UPDATE event
SET elocation = 'Cambridge' WHERE ecode = 'K003'

--Selects for checking
SELECT * FROM ticket WHERE ecode = 'K003';
SELECT * FROM event WHERE ecode = 'K003';
SELECT * FROM cancel;
SELECT * FROM ticket;

---|Deletes events when event is deleted|-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Delete_ticket_edelete()
RETURNS trigger 
AS $remove_event$
BEGIN
	IF TG_OP = 'DELETE' THEN
		DELETE FROM ticket WHERE ecode = OLD.ecode;
	END IF;
	RETURN OLD;
END;
$remove_event$
LANGUAGE PLPGSQL;

DROP FUNCTION Delete_ticket_edelete CASCADE;

--DELETE TEST--
--An event with at least one ticket
DELETE FROM event WHERE ecode='K003'

--Selects for checking
SELECT * FROM ticket WHERE ecode = 'K003';
SELECT * FROM event WHERE ecode = 'K003';
SELECT * FROM cancel WHERE ecode= 'K003';
SELECT * FROM ticket;

---|Check ticket status|--------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ticket_status(INTEGER)
RETURNS VARCHAR
AS $ticket_status$
BEGIN
	IF EXISTS (SELECT tno FROM ticket WHERE tno = $1) THEN
		RETURN 'Valid';
	ELSIF EXISTS (SELECT tno FROM cancel WHERE tno = $1) THEN
		RETURN 'Cancelled';
	ELSE
		RETURN 'No ticket';
	END IF;
END;
$ticket_status$
LANGUAGE PLPGSQL;

DROP FUNCTION ticket_status CASCADE;

--Check if it works for tickets
--cancelled
SELECT * FROM ticket_status(1)
--valid
SELECT * FROM ticket_status(2)
--doesn't exist
SELECT * FROM ticket_status(100)

---|Finds the largest tno and adds 1 to it|-------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION new_tno()
RETURNS INTEGER
AS $new_tno$
BEGIN
	RETURN(
	SELECT MAX(tno) + 1 AS max_tno FROM(
		SELECT MAX(tno) AS tno FROM ticket
		UNION
		SELECT MAX(tno) AS tno FROM cancel
		)
	AS SUBQUERY);
END $new_tno$
LANGUAGE PLPGSQL;

--TEST--
SELECT * FROM new_tno()
--------------------------------------------------------------------------------------------------------------------------------
--Procedures
--------------------------------------------------------------------------------------------------------------------------------

---|Empty all the tables|-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE empty_tables()
AS $empty_tables$
BEGIN
	DELETE FROM event;
	DELETE FROM spectator;
	DELETE FROM cancel;
END $empty_tables$
LANGUAGE PLPGSQL;

DROP PROCEDURE empty_tables;

---|Remove a spectator and their tickets|---------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE remove_spectator(INTEGER)
AS $remove_spectator$
BEGIN
	DELETE FROM ticket WHERE sno = $1;
	DELETE FROM spectator WHERE sno = $1;
END $remove_spectator$
LANGUAGE PLPGSQL;

DROP PROCEDURE remove_spectator;

--------------------------------------------------------------------------------------------------------------------------------
--Other possible ideas & Extras stuff that I did for fun/utility. And some redundant things. 
--------------------------------------------------------------------------------------------------------------------------------

---|Removes all the views|------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE drop_select_views()
AS $drop_select_views$
BEGIN
	DROP VIEW cancel_details;
    DROP VIEW event_tickets;
    DROP VIEW event_tickets_issued;
    DROP VIEW particular_ticket;
    DROP VIEW schedule;
	DROP VIEW table_count;
    DROP VIEW ticket_info_view;
    DROP VIEW travel_number;
END $drop_select_views$
LANGUAGE PLPGSQL;

---|Creates a view that lists the number of tickets ever made for an event and descriptions for those events|-------------------
CREATE VIEW Event_tickets_issued("Number of Tickets","edesc", ecode)
AS
SELECT SUM(count), edesc, ecode FROM(
	SELECT count(t.ecode), e.edesc, e.ecode
	FROM event AS e
	LEFT JOIN ticket AS t ON t.ecode = e.ecode
	GROUP BY edesc, e.ecode
	UNION ALL
	SELECT count(c.ecode), e.edesc, e.ecode
	FROM event AS e
	LEFT JOIN cancel AS c ON c.ecode = e.ecode
	GROUP BY edesc, e.ecode
) 
AS SUBQUERY
GROUP BY edesc, ecode;

DROP VIEW Event_tickets_issued;

---|REDUNDANT|--|Remove an event and the associated tickets|--------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE remove_event(CHAR(4))
AS $remove_event$
BEGIN
	DELETE FROM ticket WHERE ecode = $1;
	DELETE FROM event WHERE ecode = $1;
END $remove_event$
LANGUAGE PLPGSQL;

DROP PROCEDURE remove_event;



--CREATE VIEW FOR TICKET BARRIER OPERATORS & SPECTATORS
--THAT PROVIDES A SNO AND ECODE GIVES A TNO FROM TABLE TICKET

--CREATE A VIEW FOR SPECTATORS
--THAT PROVIDED A ELOCATION GIVES EDESC,ELOCATION,ETIME,EDATE FROM TABLE EVENT

--CREATE A VIEW FOR SPECTATORS
--THAT PROVIDED SNO GIVES ECODE,TNO FROM TABLE TICKET 

--|CREATE A VIEW FOR LOCAL ORGANISERS, THAT PROVIDED ELOCATION,EDATE GIVES EVERYTHING ELSE FROM THE TABLE EVENT|----------------

CREATE OR REPLACE FUNCTION local_schedule(DATE,VARCHAR(20))
RETURNS TABLE (ecode		CHAR(4),
    		   edesc		VARCHAR(20),
    		   elocation	VARCHAR(20),
    		   edate		DATE,			
    		   etime		TIME,			
    		   emax			SMALLINT		
)
AS $local_schedule$
BEGIN
	RETURN QUERY
	SELECT e.*  FROM EVENT AS e
	WHERE e.edate = $1
	AND e.elocation = $2;
END $local_schedule$
LANGUAGE PLPGSQL;

SELECT * FROM local_schedule('2024-07-26','London')

--CREATE A VIEW FOR EVENT ORGANISERS
--ONE FOR EACH TABLE THAT GIVES THE WHOLE TABLE
--THAT PROVIDED EDATE GIVES ELOCATION FROM TABLE EVENT

--------------------------------------------------------------------------------------------------------------------------------
--Event insert
--------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE fill_tables()
AS $fill_tables$
BEGIN
--Check non-problematic data,
insert into event values ('F795', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '9:43',  52);
insert into event values ('F794', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '12:00',  5);
insert into event values ('F793', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '17:24', 44);
insert into event values ('K003', 'iuzedwdijrcdzvrrcudo', 'London', 		'2024-07-18', '19:52', 72);
insert into event values ('K831', 'arpvzlfpyojxeolacguj', 'London', 		'2024-07-30', '10:13', 49);
insert into event values ('B274', 'edtnximrvmxrdhgytyys', 'Manchester', 	'2024-07-18', '21:38', 22);
insert into event values ('F135', 'ngcpzbimorplkoqlogys', 'Manchester', 	'2024-07-19', '18:27', 35);
insert into event values ('Q588', 'trwnzzqdcnleljgqikla', 'Cambridge', 		'2024-07-21', '19:28',  8);
insert into event values ('A916', 'afiosiiczibavijwunoz', 'Coventry', 		'2024-07-22', '22:42', 41);
insert into event values ('A843', 'jueeyjeonntlulayomtm', 'Cambridge', 		'2024-07-12', '15:52', 79);
insert into event values ('G916', 'ztfrlsyrgzgvacrflgsg', 'Derby', 			'2024-07-02', '17:51', 98);
insert into event values ('M008', 'aohdqcmouhovabkznuxm', 'Portsmouth', 	'2024-07-01', '19:10', 80);
insert into event values ('H796', 'oztmlezxmlowxpfqljzm', 'Bristol',		'2024-07-10', '14:58', 49);
insert into event values ('C727', 'aebtakizpmaqiulcbddh', 'Norwich',		'2024-07-02', '23:12', 41);
--insert into event values ('C733', 'aebtakizpmaqiulcbddh', 'Norwich',		'2024-07-02', '9:10',  41);

--------------------------------------------------------------------------------------------------------------------------------
--Spectator insert
--------------------------------------------------------------------------------------------------------------------------------

--Check non-problematic data,
insert into spectator values (61, 	 'Shaw',	 	'spawlaczyk0@typepad');
insert into spectator values (91, 	 'Thorin', 		'tbeamiss1@businessi');
insert into spectator values (59, 	 'Torre', 		    'tmoens2@nba.com');
insert into spectator values (13, 	 'Aleece', 		'adecristoforo3@live');
insert into spectator values (23, 	 'Anthiathia', 	'awainscoat4@usda.go');
insert into spectator values (62,  	 'Wendeline', 	'whaggleton5@woothem');
insert into spectator values (54, 	 'Sapphire', 	'spimbley6@taobao.co');
insert into spectator values (44, 	 'Orion', 		       'oback7@de.vu');
insert into spectator values (52, 	 'Ruthie', 		 'rratledge8@free.fr');
insert into spectator values (51, 	 'Natassia', 	'nmandeville9@printf');
insert into spectator values (6, 	 'Andromache', 	'aateggarta@example.');
insert into spectator values (7, 	 'Max', 		     'bigmaxs@logger');
--insert into spectator values (8, 	 'Matt', 		     'bigmatt@logger');


--------------------------------------------------------------------------------------------------------------------------------
--Ticket insert 
--------------------------------------------------------------------------------------------------------------------------------

--Check non-problematic data,
insert into ticket values (1, 	'K003', 61);
insert into ticket values (2, 	'G916', 91);
insert into ticket values (3, 	'K003', 59);
insert into ticket values (4, 	'F135', 13);
insert into ticket values (5, 	'A843', 52);
insert into ticket values (6, 	'K003', 23);
insert into ticket values (7, 	'K831', 62);
insert into ticket values (8, 	'H796', 54);
insert into ticket values (9, 	'A916', 44);
insert into ticket values (10, 	'K003', 52);
insert into ticket values (11, 	'F135', 52);
insert into ticket values (12, 	'C727', 51);
insert into ticket values (13, 	'H796', 6);
insert into ticket values (14, 	'B274', 61);
insert into ticket values (15, 	'M008', 91);
insert into ticket values (16, 	'A843', 59);
insert into ticket values (17, 	'Q588', 13);
insert into ticket values (18, 	'A843', 23);
insert into ticket values (19, 	'K003', 62);
insert into ticket values (20, 	'G916', 54);
insert into ticket values (21, 	'H796', 44);
insert into ticket values (22, 	'K831', 54);
insert into ticket values (23, 	'K831', 52);
insert into ticket values (24, 	'K831', 51);
insert into ticket values (25, 	'Q588',  6);
--insert into ticket values (26, 	'K831',  6);
END $fill_tables$
LANGUAGE PLPGSQL;