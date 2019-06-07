/* Welcome to the SQL mini project. For this project, I used the "country_club" database, which contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.
*/

/* Connections between the Tables of the Relational Database:
1. bookings.facID = facilities.facID
2. bookings.memID = members.memID
3. bookings.
*/


/* Q1: Some of the facilities charge a fee to members, but some do not. List the names of the facilities that do. */

SELECT name, membercost
  FROM  `Facilities` 
WHERE membercost != 0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( * ) 
  FROM  `Facilities` 
WHERE membercost = 0

/* Q3: Produce a list of facilities that charge a fee to members, where the fee is less than 20% of the facility's monthly maintenance cost. Return the facid, facility name, member cost, and monthly maintenance of the facilities in question. */

SELECT facid, name AS facility_name, membercost, monthlymaintenance
  FROM  `Facilities` 
WHERE membercost < ( 0.2 * monthlymaintenance ) 
LIMIT 0 , 30

/* Q4: Retrieve the details of facilities with ID 1 and 5. Write the query without using the OR operator. */

SELECT * 
  FROM  `Facilities` 
WHERE facID
IN ( 1, 5 ) 
LIMIT 0 , 30

/* Q5: Produce a list of facilities, with each labelled as 'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities in question. */

SELECT name, monthlymaintenance, 
  CASE WHEN monthlymaintenance >100  THEN  'expensive'
       ELSE  'cheap' END AS label
 FROM  `Facilities` 
LIMIT 0 , 30

/* Q6: Get the first and last name of the last member(s) who signed up without using a LIMIT clause in the solution. */

SELECT firstname, surname
  FROM  `Members` 
                  /*Create a subqueery to only select the maximum / most recent date from joindate*/
WHERE joindate = (SELECT MAX(joindate) 
                    FROM  `Members` )

/* Q7: Poduce a list of all members who have used a tennis court, including the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by the member name. 

Answer: The solution involves the use of a subquery in order to return data that will be used in the main query as a condition to further restrict the data to be retrieved.
Step 1: Create an overarching SELECT for columns court (to be created in the subquery) and to put member first name and last name n same column */  
SELECT sub.court, CONCAT( sub.firstname,  ' ', sub.surname ) AS name
  /* Step 2: Begin subquery */
  FROM (
     /* Step 3: Define contents for columns in parent SELECT method */  
     SELECT Facilities.name AS court, Members.firstname AS firstname, Members.surname AS surname
       FROM Bookings
         /* Step 4: Create an INNER JOIN to only SELECT Facilities with 'Tennis Court' contained in the name */      
         INNER JOIN Facilities ON Bookings.facid = Facilities.facid
           AND Facilities.name LIKE  'Tennis Court%' 
         /* Step 5: Create an INNER JOIN to connect Facilities to Members through the common table, Bookings */     
         INNER JOIN Members ON Bookings.memid = Members.memid
        )sub
/* Step 6: Group returned values by desired columns */  
GROUP BY sub.court, sub.firstname, sub.surname
ORDER BY name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30. Note: Guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user's ID is always 0. The output should include the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries. */

SELECT CONCAT(Members.firstname, ' ', Members.surname) AS name, Facilities.name AS facility, 
       CASE WHEN Members.memid =0 THEN Bookings.slots * Facilities.guestcost
            ELSE Bookings.slots * Facilities.membercost END AS cost
 FROM  `Members` 
     INNER JOIN  `Bookings` ON Members.memid = Bookings.memid
     INNER JOIN  `Facilities` ON Bookings.facid = Facilities.facid
 WHERE ( Bookings.starttime >=  '2012-09-14' AND Bookings.starttime <  '2012-09-15' )
 AND ((Members.memid =0 AND Bookings.slots * Facilities.guestcost > 30)
 OR (Members.memid !=0 AND Bookings.slots * Facilities.membercost > 30))
ORDER BY cost DESC , name

/* Q9: Produce the same result as in Q8, but using a subquery. */

SELECT name, facility, cost 
 FROM (
    SELECT CONCAT (firstname, ' ',  surname) AS name,
           Facilities.name AS facility,
           CASE WHEN Members.memid = 0 THEN
                    Bookings.slots*Facilities.guestcost
                ELSE Bookings.slots*Facilities.membercost
           END AS cost 
    FROM `Members`
          INNER JOIN Bookings ON Members.memid = Bookings.memid
          INNER JOIN Facilities ON Bookings.facid = Facilities.facid
    WHERE (Bookings.starttime >= '2012-09-14') AND (Bookings.starttime < '2012-09-15')
     ) AS bookings
 WHERE cost > 30
 ORDER BY cost DESC;
 
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facility, revenue 
FROM (
  SELECT Facilities.name AS facility, 
    SUM( CASE WHEN Bookings.memid = 0 THEN Bookings.slots*Facilities.guestcost
              ELSE Bookings.slots*Facilities.membercost
    END) AS revenue
    FROM Bookings
      INNER JOIN Facilities ON Bookings.facid = Facilities.facid
    GROUP BY Facilities.name
     ) AS allrvn 
WHERE revenue < 1000
ORDER BY revenue;
