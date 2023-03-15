--select *
--from CovidDeaths
--order by 3,4

--select *
--from CovidVaccinations
--order by 3,4


--Select data to be used
select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from CovidProject.dbo.CovidDeaths
order by location, date



--delete rows with '%income%' in location column
delete from CovidProject.dbo.CovidDeaths
where location like '%income%'



--delete rows where continent column is null
delete from CovidProject.dbo.CovidDeaths
where continent is null



--death percentage of covid in US
select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as death_percentage
from CovidProject.dbo.CovidDeaths
where location like '%states'
order by location, date



--shows infection rate (total cases vs population) in US
select
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as infection_rate
from CovidProject.dbo.CovidDeaths
where location like '%states'
order by location, date



--countries with highest infection count vs population
select
	location,  
	population, 
	max(total_cases) as highest_infection_count, 
	max((total_cases/population))*100 as infection_rate
from CovidProject.dbo.CovidDeaths
group by location, population 
order by infection_rate desc



--countries with highest death count
select 
	location, 
	max(total_deaths) as total_death_count
from CovidProject.dbo.CovidDeaths
group by location
order by total_death_count desc



--continents with highest death count
--north america does not include canada
select 
	continent, 
	max(total_deaths) as total_death_count
from CovidProject.dbo.CovidDeaths
group by continent
order by total_death_count desc



--global death rate
select 
	sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
	sum(new_deaths)/sum(new_cases)*100 as death_rate
from CovidProject.dbo.CovidDeaths



--joining with CovidVaccinations table
--total population vs daily vaccinations
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(v.new_vaccinations) over (partition by d.location 
		Order by d.location, d.date) as rolling_total_vaccinations
from CovidProject.dbo.CovidDeaths d 
join CovidProject.dbo.CovidVaccinations v
	on d.location=v.location and d.date=v.date
order by continent, location, date



--temp table
Drop table if exists #pop_vacc_percent					--allows for multiple executions without overlapping temp tables
Create table #pop_vacc_percent (
	continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	rolling_total_vaccinations numeric)

Insert into #pop_vacc_percent
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(v.new_vaccinations) over (partition by d.location 
		Order by d.location, d.date) as rolling_total_vaccinations
from CovidProject.dbo.CovidDeaths d 
join CovidProject.dbo.CovidVaccinations v
	on d.location=v.location and d.date=v.date

select *,
	(rolling_total_vaccinations/population)*100 as percent_vaccinated
from #pop_vacc_percent
order by continent, location, date

--lists any active temp tables
SELECT name
FROM tempdb.sys.tables
WHERE name LIKE '%';



--create view
Create view pop_vacc_percent as
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(v.new_vaccinations) over (partition by d.location 
		Order by d.location, d.date) as rolling_total_vaccinations
from CovidProject.dbo.CovidDeaths d 
join CovidProject.dbo.CovidVaccinations v
	on d.location=v.location and d.date=v.date