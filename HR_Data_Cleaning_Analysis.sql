use projects;
SELECT * FROM projects.hr;
alter table hr change column ï»¿id emp_id varchar(20);
set sql_safe_updates=0;
update hr 
set birthdate= case when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;
update hr 
set hire_date= case when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
else null
end;

update hr
set termdate=date(str_to_date(termdate,'%Y-%m-%d %H%i%s UTC'));
select birthdate,termdate from hr where termdate is not null ;
select birthdate,termdate from hr where termdate !='';
select birthdate,termdate from hr where termdate is not null and termdate!='';
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;
SELECT termdate from hr;
ALTER TABLE hr MODIFY COLUMN birthdate DATE;
ALTER TABLE hr MODIFY COLUMN hire_date DATE;
SET sql_mode = 'ALLOW_INVALID_DATES';
ALTER TABLE hr MODIFY COLUMN termdate DATE;

alter table hr add column age int;
update hr set age= timestampdiff(year,birthdate,curdate());
select birthdate,age from hr;
select min(age) youngest,max(age) oldest from hr;
select birthdate,age from hr where age < 18;

/* selet gender breakdown of all the employees in the table */
select gender, count(*) from hr where age >=18 and termdate = 0000-00-00 group by gender;

/* what is race, ethnicity breakdown of employees */

select race, count(*) from hr where age >=18 and termdate =0000-00-00 group by race;

/* what is age distribuiton of employees in hr*/
select min(age) youngest , max(age) oldest from hr where age >=18 and termdate =0000-00-00;

select case when age between 18 and 24 then '18-24'
            when age between 25 and 34 then '25-34'
            when age between 35 and 44 then '35-44'
            when age between 45 and 54 then '46-54'
            when age between 55 and 64 then '55-64'
            else '65+'
		end as age_group,gender, count(*) as no_of_employee from hr where age >=18 and termdate =0000-00-00
        group by age_group,gender order by age_group;
        
/* how many employees work at headquarters vs remote loaction */
select location , count(*) count from hr where age>18 and termdate=0000-00-00 group by location;

/* what is average length of employment for employees who have been terminated */
select round(avg(timestampdiff(year,hire_date,termdate)),0) avg_length_employment from hr 
where termdate <= curdate() and termdate <> 0000-00-00 and age>18;\

/* how does gender distribution varies acorss deparments and job titles */
select department,gender, count(*) count from  hr where age>=18 and termdate=0000-00-00 group by 
department,gender order by department;

/* what is distribution of jobtitles across the company */
select jobtitle , count(*) count from hr where age>18 and termdate=0000-00-00 group by jobtitle order by
jobtitle desc;

/* 8 which department has highest turnover rate */
-- select department,turnover from (select department, timestampdiff(year,hire_date,termdate) as turnover from hr 
-- where termdate<=curdate() and termdate <> 0000-00-00 and age<18) derived_table order by turnover desc limit 1;
select department,total_count,terminated_count, terminated_count/total_count as termination_rate from(
select department,count(*) as total_count, sum(case when termdate<>0000-00-00 and termdate<curdate() then 1 else 0 end) as terminated_count
from hr where age<=18 group by department) subquerry order by termination_rate desc;

/* 9 what is distribution of employees acorss city and state */
select location_state , count(*) count from hr where age>18 and termdate=0000-00-00 
group by location_state order by count desc;

/* how has the companys employee count changed over time based on hire_date and termdate */
select year, hires,terminations, hires-terminations as net_change, 
round((hires-terminations)/hires*100,2) as net_change_percent
from ( select year(hire_date) as year, count(*) as hires, sum(case when termdate<>0000-00-00 and termdate < curdate() then 1 else 0 end) as terminations
from hr where age <=18 group by year) as subquerry order by year;

/* what is tenure distribution for each year */
select department , round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure from hr 
where termdate<>0000-00-00 and termdate < curdate() and age < 18 group by department;

