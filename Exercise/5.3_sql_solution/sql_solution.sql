/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM `Facilities`where membercost > 0;

/*
name
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court
*/

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(1) FROM `Facilities`where membercost = 0;
/*
Count
4
*/

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid,name,membercost,monthlymaintenance
 FROM `Facilities` WHERE membercost > 0 and membercost < (monthlymaintenance * 0.20);
/*

facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0  	200
1	Tennis Court 2	5.0	    200
4	Massage Room 1	9.9	    3000
5	Massage Room 2	9.9	    3000
6	Squash Court	3.5	    80
*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
/*Solution 1 */
SELECT * FROM `Facilities` where facid =1
UNION
SELECT * FROM `Facilities` where facid =5;
/*Solution 2*/
SELECT * FROM `Facilities` where facid in (1,5);
/*

facid	name	 membercost	guestcost	initialoutlay	monthlymaintenance	
5	Massage Room 2	9.9	80.0	4000	3000
1	Tennis Court 2	5.0	25.0	8000	200
*/

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
Select name,monthlymaintenance, IF(monthlymaintenance < 100, "Cheap","Expensive") As label from Facilities;
/*	 
name	monthlymaintenance
Tennis Court 1	Expensive
Tennis Court 2	Expensive
Badminton Court	Cheap
Table Tennis	Cheap
Massage Room 1	Expensive
Massage Room 2	Expensive
Squash Court	Cheap
Snooker Table	Cheap
Pool Table	Cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname,Surname from Members where joindate= (select MAX(joindate) from Members);
/*
firstname	Surname	
Darren	Smith
*/
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT firstname || ' ' || surname AS member, name AS facility
FROM members
INNER JOIN bookings
ON members.memid = bookings.memid
INNER JOIN facilities
ON bookings.facid = facilities.facid
WHERE name LIKE '%Tennis Court%'
ORDER BY member;
/*
member	name
0	Tennis Court 1
0	Tennis Court 2
*/

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT
firstname || ' ' || surname AS member,
name AS facility,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM members
INNER JOIN bookings
ON members.memid = bookings.memid
INNER JOIN facilities
ON bookings.facid = facilities.facid
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
ORDER BY cost DESC;
/*

*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

;SELECT
firstname || ' ' || surname AS member,
name AS facility,
CASE WHEN firstname = 'GUEST' THEN guestcost  slots ELSE membercost  slots END AS cost
FROM members
INNER JOIN bookings
ON members.memid = bookings.memid
INNER JOIN facilities
ON bookings.facid = facilities.facid
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost  slots ELSE membercost  slots END > 30
ORDER BY cost DESC;
/* */
select firstname from Members where guestcost > 30 or membercost > 30 and memid in (Select memid from Bookings where starttime like '2012-09-14%' ) 
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
    ;SELECT fac.name,
       fac.facid,
       SUM(
           CASE WHEN mem.memid = 0 THEN fac.guestcost * book.slots
           ELSE fac.membercost * book.slots
           END
       ) AS revenue
FROM `Facilities` fac
JOIN `Bookings` book ON fac.facid = book.facid
JOIN `Members` mem ON book.memid = mem.memid
GROUP BY fac.name, fac.facid
HAVING revenue > 1000
ORDER BY revenue
/*

name	facid	revenue	
Badminton Court	2	1906.5
Squash Court	6	13468.0
Tennis Court 1	0	13860.0
Tennis Court 2	1	14310.0
Massage Room 2	5	14454.6
Massage Room 1	4	50351.6
*/