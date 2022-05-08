-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT max(era) 
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear 
  from people 
  where weight>300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear 
  FROM people 
  WHERE namefirst LIKE '% %' 
  ORDER BY namefirst,nameLast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) 
  FROM people 
  GROUP BY birthyear 
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) 
  FROM people 
  GROUP BY birthyear 
  HAVING avg(height)>70 
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst,namelast,h.playerid,yearid 
  FROM people as p 
  INNER JOIN halloffame as h 
  ON h.playerID =p.playerID 
  AND h.inducted='Y' 
  ORDER BY yearid DESC,h.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst,namelast,h.playerid,s.schoolid,yearid 
  FROM people as p 
  INNER JOIN halloffame as h,collegeplaying as c, schools as s 
  ON h.playerID =p.playerID 
  AND h.playerID = c.playerID 
  AND c.schoolID = s.schoolID 
  AND h.inducted='Y' 
  AND s.schoolState='CA' 
  ORDER BY yearid DESC,s.schoolID,h.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid,namefirst,namelast,schoolID 
  FROM q2i as q 
  LEFT OUTER JOIN
  collegeplaying as c
  on q.playerID = c.playerID
  ORDER BY q.playerID DESC,c.schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerID,namefirst,namelast,yearid,round((H+H2B+2*H3B+3*HR+0.0)/(AB+0.0),4) as slg
  FROM people p,batting b
  WHERE AB>50
  AND p.playerID = b.playerID
  ORDER BY slg DESC,b.yearid,b.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT b.playerID,namefirst,namelast,lslg
  FROM people p,
    (SELECT playerid,round((sum(H)+sum(H2B)+2*sum(H3B)+3*sum(HR)+0.0)/(sum(AB)+0.0),4) as lslg
    FROM batting
    GROUP BY playerid
    HAVING sum(AB)>50)
  as b
  WHERE p.playerID = b.playerID
  ORDER BY lslg DESC,b.playerid
  LIMIT 10

;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst,namelast,lslg
  FROM people p,
    (SELECT playerid,round((sum(H)+sum(H2B)+2*sum(H3B)+3*sum(HR)+0.0)/(sum(AB)+0.0),4) as lslg
    FROM batting
    GROUP BY playerid
    HAVING sum(AB)>50)
  as b
  WHERE p.playerID = b.playerID
  AND b.lslg>(
    SELECT round((sum(H)+sum(H2B)+2*sum(H3B)+3*sum(HR)+0.0)/(sum(AB)+0.0),4) as lslg
    FROM batting
    WHERE playerid = 'mayswi01'
  )
  ORDER BY lslg DESC,b.playerid
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid,min(salary),max(salary),avg(salary)
  FROM salaries
  GROUP BY yearid
;

-- Question 4ii

-- Helper TABLE
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid INT);
INSERT INTO binids VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

DROP VIEW IF EXISTS LD;
CREATE VIEW LD(low,delta,mx)
AS
  SELECT min(salary),CAST((max(salary)-min(salary))/10 as int),max(salary)
  FROM salaries
  WHERE yearid=2016
;

DROP VIEW IF EXISTS LH;
CREATE VIEW LH(binid,low,high,mx)
AS
  SELECT binid,low+binid*delta,low+(1+binid)*delta,mx
  FROM binids,LD
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid,low,high,count(*)
  FROM LH
  INNER JOIN (SELECT * FROM salaries WHERE yearid=2016)
  ON salary>=low AND salary<high or binid = 9 AND salary=mx
  GROUP BY binid
;

-- Question 4iii
DROP VIEW IF EXISTS helper3;
CREATE VIEW helper3(yearid, low, high, aveage)
AS
  SELECT yearid,min(salary),max(salary),avg(salary)
  FROM salaries
  GROUP BY yearid
;

DROP VIEW IF EXISTS q4iii;
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT h2.yearid,h2.low-h1.low,h2.high - h1.high,round(h2.aveage - h1.aveage,4)
  FROM helper3 as h1
  INNER JOIN helper3 as h2
  ON h1.yearid = h2.yearid-1
  ORDER BY h2.yearid
;

-- Question 4iv
DROP VIEW IF EXISTS helper4;
CREATE VIEW helper4(yearid,salary)
AS 
  SELECT yearid,max(salary)
  FROM salaries
  WHERE yearid = '2000' or yearid = '2001'
  GROUP BY yearid
;

CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, namefirst, namelast, s.salary, s.yearid
  FROM helper4 h,people p
  INNER JOIN salaries s
  ON p.playerid = s.playerid
  WHERE h.yearid = s.yearid and h.salary = s.salary
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID,max(s.salary)-min(s.salary)
  FROM allstarfull a
  INNER JOIN salaries s
  ON a.playerID = s.playerID AND a.yearid = s.yearid
  WHERE a.yearid = '2016'
  GROUP BY a.teamID
;

