-- Q1) 

select BIDDER_ID, 
count(case when bid_status = "won" then 1 end)as Win,
count(case when bid_status <> "cancelled" then 1 end) as Total_bids ,
(count(case when bid_status = "won" then 1 end)/count(case when bid_status <> "cancelled" then 1 end))*100 as Percentage_Win
from ipl_bidding_details group by BIDDER_ID order by Percentage_Win DESC;

-- Other Answer 1: Here we are not ignoring Cancelled (using IF)  
select bidder_id,
sum(if(bid_status = 'won',1,0)) wins, 
count(bid_status) total_bid,
(sum(if(bid_status like 'won',1,0)))/count(bid_status) * 100 win_percentage
from ipl_Bidding_Details
group by bidder_id
order by win_percentage desc; 

-- Other Answer 2: Here we are not ignoring Cancelled (using IF) 
select bidder_id,
count(case when bid_status="won" then 1 end) as win,
count(*) as totalmatches,
(count(case when bid_status="won" then 1 end)/count(*))*100 as winpercent
from ipl_bidding_details 
group by bidder_id
order by winpercent desc;



-- Q2) 
select s.Stadium_id,s.Stadium_Name,s.City,count(m.match_id) as Total_Matches
from ipl_stadium s join ipl_match_schedule m
on s.stadium_id = m.stadium_id
where m.status<> "cancelled"
group by s.stadium_id,s.stadium_name,s.city;



-- Q3)
select  Stadium_ID, Stadium_Name, sum(if(toss_winner = match_winner, 1,0)) as Toss_Wins,
count(match_id) Total, 
sum(if(toss_winner = match_winner, 1,0)) / count(match_id) * 100 as Percentage_Win
from ipl_match join ipl_match_schedule using (match_id)
join ipl_stadium using (stadium_id)
group by STADIUM_ID, Stadium_Name;





-- Q4)
select count(ibd.bidder_id) as count_bids, it.team_name, ibd.bid_team
from ipl_bidding_details ibd join ipl_bidder_points ibp on ibd.bidder_id=ibp.bidder_id
join ipl_team it on ibd.bid_team=it.team_id
group by it.team_name,ibd.bid_team order by ibd.bid_team;



-- Q5)
select Win_details, SUBSTRING_INDEX(WIN_DETAILS,' ',2) Win_Team, 
case when MATCH_WINNER = 1 then TEAM_ID1 
when MATCH_WINNER = 2 then TEAM_ID2
 end as Win_Team_ID from ipl_match;

#note there are few values in match_winner column which is greater than 2 which is wrong as match_winner should have only 1 or 2 as values 
-- which indicates team 1 or team 2 has won 



-- Q6 
SELECT iplts.TEAM_ID, TEAM_NAME, 
sum(MATCHES_PLAYED) as Total_Matches_Played, 
sum(matches_won) as Total_Matches_Won,
sum(matches_lost) as Total_Matches_Lost
 FROM ipl_team_standings iplts inner join ipl_team iplt on iplts.TEAM_ID=iplt.TEAM_ID
  group by iplts.TEAM_ID ;

-- Q7) 
select t.team_name,p.player_name,tp.player_role
from ipl_team t join ipl_team_players tp
using (TEAM_ID)
join ipl_player p
using (PLAYER_ID)
where t.team_name like "%Mumbai indians%" and tp.player_role like "%bowler%";


-- Q8) 
select t.team_name,count(tp.player_role) as all_rounder_count from ipl_team t 
join ipl_team_players tp using (team_id)
join ipl_player p using (player_id)
where player_role like '%all-rounder%' group by team_name having all_rounder_count>4;




-- Q9)

select ibd.bid_status,year(ibd.bid_date) biddingyear,sum(ibp.total_points) totalbidderpoints
from ipl_bidding_details ibd join ipl_bidder_points ibp on ibd.bidder_id = ibp.bidder_id 
join ipl_team it on ibd.bid_team = it.team_id join ipl_match im on it.team_id = im.match_winner
join ipl_match_schedule ims on im.match_id = ims.match_id
join ipl_stadium ist on ims.stadium_id = ist.stadium_id
where it.remarks like "%csk%" and ist.stadium_name like  "%M. Chinnaswamy Stadium%" and im.win_details LIKE "%csk won%"
group by ibd.bid_status, biddingyear
order by totalbidderpoints desc, biddingyear;


-- Q10)
select Team_name as Team, Player_name as Player, Player_role as Role
from (select ipl_player.PLAYER_ID, PLAYER_NAME, 
dense_rank() over(order by cast(trim(both ' ' from substring_index(substring_index(PERFORMANCE_DTLS,'Dot',1),'Wkt-',-1))
as signed int) desc ) as WICKET_RANK,
PLAYER_ROLE, Team_name from ipl_player, ipl_team_players, ipl_team
where ipl_player.PLAYER_ID = ipl_team_players.PLAYER_ID  
and PLAYER_ROLE in ('bowler', 'all-rounder')
and ipl_team.TEAM_ID = ipl_team_players.TEAM_ID) as Temp
where WICKET_RANK <= 5;




-- Q11) 
select sum(if(bid_team = if(toss_winner = 1,team_id1,team_id2) ,1,0)) as no_of_wins, bidder_id, 
count(bid_team) count, 
round((sum(if(bid_team = if(toss_winner = 1,team_id1,team_id2) ,1,0)) / count(bid_team) ) *100,2) percentage
from ipl_match im join ipl_match_schedule ims using (match_id) 
join ipl_bidding_details ibd using(schedule_id)
group by bidder_id order by percentage desc;


-- Q12)
 with temp2 as 
(select * , rank() over (order by Total_Tournament_Duration ASC) Duration_rank from
(SELECT TOURNMT_ID, TOURNMT_NAME, datediff(To_date,from_date) as Total_Tournament_Duration
from  ipl_tournament) temp1)

select * from temp2 where Duration_rank= 1 or duration_rank = (select  max(duration_rank) from temp2);



-- Q13
select distinct bdr.BIDDER_ID,bdr.BIDDER_NAME,year(bds.BID_DATE) as Year,
month(bds.BID_DATE) as Month,pt.TOTAL_POINTS as Total_Points
from ipl_bidder_details bdr inner join ipl_bidder_points pt on bdr.BIDDER_ID=pt.BIDDER_ID 
inner join ipl_bidding_details bds
on pt.BIDDER_ID=bds.BIDDER_ID
where year(bds.BID_DATE)=2017
order by Total_Points desc,Month asc ;


-- Q14
-- using sub query

select bidder_id, (select bidder_name from ipl_bidder_details 
where ipl_bidder_details.bidder_id=ipl_bidding_details.bidder_id) as bidder_name,
year(bid_date) as `year`, monthname(bid_date) as `month`, 
(select total_points from ipl_bidder_points 
where ipl_bidder_points.bidder_id=ipl_bidding_details.bidder_id) as total_points from ipl_bidding_details
where year(bid_date)=2017
group by bidder_id,bidder_name,year,month,total_points
order by total_points desc, Month asc ;


-- Q15

with temp as(
SELECT *,
rank() over( order by TOTAL_POINTS Desc) Points_Rank, 
(select bidder_name from ipl_bidder_details ipl_bd where ipl_bd.bidder_id = ipl_bp.bidder_id) as Bidder_Name 
 FROM ipl.ipl_bidder_points ipl_bp where  TOURNMT_ID=2018)

  (select  Bidder_id, points_rank, total_points, bidder_name from temp order by points_rank ASC limit 3)
   union
  (select  Bidder_id, points_rank, total_points, bidder_name from temp order by points_rank DESC limit 3);


-- ____________________________________________________________________________________________________________________________________
-- Q16


/*
Step 1: Created Two tables as per question
Step 2: Created Two Triggers, one for Insert and one for Update
Step 3: Inserted values in Student_Details Table and made sure that the Backup table also has the details added automatically

Reconfirmation
Step 4: Updated the values of one of the student's mobile number and 
made sure that it also changed in the backup table when you update the student_details table

Step 5: Inserted a new student detail and confirmed that both the tables get these new details

Drop student_table (optional)
Step 6: To show that the backup data is not affected when student_details table is dropped

*/
-- ________________________________________________________
-- Step 1

-- Creating Database and also Tables
Create database GreatLearning;
Use Greatlearning;

CREATE TABLE Student_details (
    Student_id INT PRIMARY KEY,
    Student_name VARCHAR(250),
    Mail_id VARCHAR(200),
    Mobile_no VARCHAR(20)
);

-- Create the Student_details_backup table
CREATE TABLE Student_details_backup (
    Student_id INT PRIMARY KEY,
    Student_name VARCHAR(250),
    Mail_id VARCHAR(200),
    Mobile_no VARCHAR(20)
);
-- _______________________________________________________
-- Step 2


DROP TRIGGER IF EXISTS after_student_update;    #optional
-- Just to make sure that no triggers are created before

# We are Creating 2 Triggers one for insert and another for Update

-- Trigger for Insert
DELIMITER //
CREATE TRIGGER insert_student_details_trigger
AFTER INSERT ON Student_details
FOR EACH ROW
BEGIN
    INSERT INTO Student_details_backup (student_id, student_name, mail_id, mobile_no)
    VALUES (NEW.student_id, NEW.student_name, NEW.mail_id, NEW.mobile_no)
    ON DUPLICATE KEY UPDATE
    student_name = NEW.student_name,
    mail_id = NEW.mail_id,
    mobile_no = NEW.mobile_no;
END;
//
DELIMITER ;

-- Trigger for Update

DELIMITER //
CREATE TRIGGER update_student_details_trigger
AFTER UPDATE ON Student_details
FOR EACH ROW
BEGIN
    UPDATE Student_details_backup
    SET
        student_name = NEW.student_name,
        mail_id = NEW.mail_id,
        mobile_no = NEW.mobile_no
    WHERE student_id = NEW.student_id;
END;
//
DELIMITER ;

-- _______________________________________________
-- Step 3


-- Checking if values change upon updating or inserting 

-- Inserting values 
INSERT INTO Student_details (Student_id, Student_name, Mail_id, Mobile_no)
VALUES
    (1, 'Amit Mishra', 'amit.mishra@yahoo.com', '8991234567'),
    (2, 'Anush Malipatil', 'anush.malipatil@yahoo.com', '9882345678'),
    (3, 'Aishwarya N', 'aishwarya_n@outlook.com', '9993456789'),
    (4, 'Aishwarya K', 'aishwarya_k@outlook.com', '7894567890'),
    (5, 'Abhilash Jose', 'abhilash.jose@yahoo.com', '6905678901');
    
 
 -- Step 4
-- updating Amit's number to check if the backup is also updating 

UPDATE Student_details
SET Mobile_no = '9022221111'
WHERE Student_name = 'Aishwarya K';


-- Step 5
-- insert a new student to check to student_details (This create automatic update in backup table)
INSERT INTO Student_details 
VALUES (6, 'Amitha K', 'amitha.k@yahoo.com', '8990000561');

-- ________________________________________________________
-- Step 6
--  Now lets see if the data gets affected if our student details table is deleted 
drop table Student_details;

-- Summary:
/* The student_details_ backup table was not affected so we can say that when detials are inserted or updated 
it changes even in the backup table and assuming if student_details table is dropped then we can retrive the information
from the backup table*/

