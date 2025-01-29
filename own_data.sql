--------------------------------------------------------------------------------------------------------------------------------
--Path and Search/delete commands
--------------------------------------------------------------------------------------------------------------------------------
SET SEARCH_PATH TO coursework, PUBLIC

SELECT * FROM event
DELETE FROM EVENT

SELECT * FROM spectator
DELETE FROM spectator

SELECT * FROM ticket
DELETE FROM ticket

--------------------------------------------------------------------------------------------------------------------------------
--Transaction A
--------------------------------------------------------------------------------------------------------------------------------

--Check primary key,
insert into spectator values (61, 	 'Shaw', 		'spawlaczyk0@typepad');
insert into spectator values (61, 	 'Sean', 		 'asdasdzyk0@typepad');

--Check email uniqueness,
insert into spectator values (91, 	 'Thorin', 		'tbeamiss1@businessi');
insert into spectator values (59, 	 'Torre', 		'tbeamiss1@businessi');

--Check non-problematic data,
insert into spectator values (61, 	 'Shaw', 		'spawlaczyk0@typepad');
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
insert into spectator values (6, 	 'Andromache', 	'aateggarta@example.');


--------------------------------------------------------------------------------------------------------------------------------
--Transaction B
--------------------------------------------------------------------------------------------------------------------------------

--Check primary key
insert into event values ('F795', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '9:43',  52);
insert into event values ('F795', 'iuzedwdijrcdzvrrcudo', 'London', 		'2024-07-18', '19:52', 72);

--Check etime constraint
insert into event values ('F795', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '8:43',  52);

--Check edate constraint
--left (<)
insert into event values ('B274', 'edtnximrvmxrdhgytyys', 'Manchester', 	'2024-06-18', '21:38', 22);
--right (>)
insert into event values ('F135', 'ngcpzbimorplkoqlogys', 'Manchester', 	'2024-08-19', '18:27', 35);


--Check emax constraint
--left (<)
insert into event values ('A916', 'afiosiiczibavijwunoz', 'Coventry', 		'2024-07-22', '22:42', 0);
--right (>)
insert into event values ('A916', 'afiosiiczibavijwunoz', 'Coventry', 		'2024-07-22', '22:42', 1001);

--Check uniqueness
insert into event values ('K003', 'iuzedwdijrcdzvrrcudo', 'London', 		'2024-07-18', '19:52', 72);
insert into event values ('K831', 'arpvzlfpyojxeolacguj', 'London', 		'2024-07-18', '19:52', 49);

--Check non-problematic data,
insert into event values ('F795', 'ynltilnfnpydicwptwfd', 'London', 		'2024-07-26', '9:43',  52);
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

--------------------------------------------------------------------------------------------------------------------------------
--Transaction C(i)
--------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM spectator WHERE sno='300';

--With ticket
DELETE FROM spectator where sno='300';

--------------------------------------------------------------------------------------------------------------------------------
--Transaction D
--------------------------------------------------------------------------------------------------------------------------------

--An event without any tickets
DELETE FROM event WHERE ecode='F795';
	--To check
	SELECT * FROM event WHERE ecode='F795';
	

--An event with at least one ticket
DELETE FROM event WHERE ecode='K003';
	--To check
	SELECT * FROM ticket WHERE ecode='K003'
	SELECT * FROM event WHERE ecode='K003';
	
--------------------------------------------------------------------------------------------------------------------------------
--Transaction E
--------------------------------------------------------------------------------------------------------------------------------

--Giving a spectator more than one ticket for one event
insert into ticket values (58, 'A916', 91);
insert into ticket values (59, 'A916', 91);

--------------------------------------------------------------------------------------------------------------------------------
--Transaction F
--------------------------------------------------------------------------------------------------------------------------------

--Using view travel_number
SELECT * FROM Travel_number ORDER BY edate;
SELECT * FROM Travel_number ORDER BY "Number of Spectators" DESC;

--------------------------------------------------------------------------------------------------------------------------------
--Transaction G
--------------------------------------------------------------------------------------------------------------------------------

--Whole table
SELECT * FROM Event_tickets ORDER BY edesc;
SELECT * FROM Event_tickets ORDER BY "Number of Tickets" DESC;

--Using view Event_tickets
SELECT "Number of Tickets", event_tickets.edesc FROM Event_tickets ORDER BY edesc;
SELECT "Number of Tickets", event_tickets.edesc FROM Event_tickets ORDER BY "Number of Tickets" DESC;

--------------------------------------------------------------------------------------------------------------------------------
--Transaction H
--------------------------------------------------------------------------------------------------------------------------------

SELECT "Number of Tickets", event_tickets.edesc FROM Event_tickets WHERE ecode='K003';

--------------------------------------------------------------------------------------------------------------------------------
--Transaction I
--------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM Schedule ORDER BY SNO;
SELECT "Spectator name", edate, elocation, etime, edesc FROM Schedule WHERE sno = '44' ORDER BY edate;

--------------------------------------------------------------------------------------------------------------------------------
--Transaction J
--------------------------------------------------------------------------------------------------------------------------------

--Whole table
SELECT sname, ecode, ticket_status FROM particular_ticket ORDER BY tno;

--Check particular tno's
SELECT sname, ecode, ticket_status
FROM particular_ticket
WHERE tno IN (1,2);
--WHERE tno = 1;

--------------------------------------------------------------------------------------------------------------------------------
--Transaction K 
--------------------------------------------------------------------------------------------------------------------------------

--Fill the cancel table to make it easier to check
DELETE FROM ticket;
DELETE FROM ticket WHERE tno IN (1,2,3,4,5,6,7,8,9);

--Simple solution
SELECT tno,sno FROM cancel WHERE ecode = 'K003';

--Complex solution
SELECT * FROM canceL_details WHERE ecode = 'K003'

--------------------------------------------------------------------------------------------------------------------------------
--Transaction L
--------------------------------------------------------------------------------------------------------------------------------

--Simple solution
DELETE FROM event;
DELETE FROM spectator;
DELETE FROM cancel;

--Complex solution
CALL empty_tables()