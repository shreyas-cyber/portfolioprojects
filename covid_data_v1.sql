--select * from ['owid-covid-death$']
--order by 3,4

--select * from ['owid-covid-data$']
--order by 3,4

--Select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population from ['owid-covid-death$']
order by 1,2


--Total cases vs total deaths
--Shows likelihood of dying if you contract covid in our country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from ['owid-covid-death$']
where location like '%ndia%'
order by 1,2

--Total cases vs population
--shows what percentage of population got into covid
select location,date,total_cases,population, (total_cases/population)*100 as death_percentage 
from ['owid-covid-death$']
where location like '%ndia%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfection, max((total_cases/population))*100 as percentagePopulationInfected 
from ['owid-covid-death$']
--where location like '%ndia%'
group by location,population
order by 4 desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount 
from ['owid-covid-death$']
--where location like '%ndia%'
where continent is not null
group by location
order by 2 desc

--showing continents with the highest death counts per population
select continent,max(cast(total_deaths as int)) as totaldeathcount 
from ['owid-covid-death$']
--where location like '%ndia%'
where continent is not null
group by continent
order by 2 desc

--global numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from ['owid-covid-death$']
--where location like '%ndia%'
where continent is not null
--group by date
order by 1,2


--total population vs vaccination
with popvsvac (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,dat.new_vaccinations
, sum(CONVERT(int,dat.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from ['owid-covid-death$'] dea
join ['owid-covid-data$'] dat
on dea.location = dat.location
and dea.date = dat.date
where dea.continent is not null
--order by 2,3
)
select * ,(peoplevaccinated/population) * 100
from popvsvac

--Temp table

drop table if exists #percenttable
create table #percenttable
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)
insert into #percenttable
select dea.continent,dea.location,dea.date,dea.population,dat.new_vaccinations
, sum(cast(dat.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from ['owid-covid-death$'] dea
join ['owid-covid-data$'] dat
on dea.location = dat.location
and dea.date = dat.date
--where dea.continent is not null
--order by 2,3
select *, (peoplevaccinated/population)*100 
from #percenttable

--creating view

create view percenttable as
select dea.continent,dea.location,dea.date,dea.population,dat.new_vaccinations
, sum(cast(dat.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from ['owid-covid-death$'] dea
join ['owid-covid-data$'] dat
on dea.location = dat.location
and dea.date = dat.date
where dea.continent is not null