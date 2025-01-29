--------------------------------------------------------------------------------------------------------------------------------
--Path and Search/delete commands
--------------------------------------------------------------------------------------------------------------------------------
SET SEARCH_PATH TO coursework, PUBLIC;

--Select commands
SELECT * FROM ticket;
SELECT * FROM spectator;
SELECT * FROM event;

--------------------------------------------------------------------------------------------------------------------------------
--Event insert
--------------------------------------------------------------------------------------------------------------------------------

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
