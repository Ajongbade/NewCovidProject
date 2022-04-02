-- Covid death data (Worldwide)

select location, date, total_cases, new_cases, total_deaths, population from covidproject.dbo.coviddeaths
where continent is not null

order by 1, 2



-- Total Cases Vs Total Deaths (Nigeria)

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as death_percentage from covidproject.dbo.coviddeaths
where location like '%nigeria%'

order by  2



-- Total cases Vs Population (Nigeria)

select location, date, total_cases, population, (total_cases/population * 100) as population_percentage from covidproject.dbo.coviddeaths
where location like '%nigeria%'

order by 2



-- Highest infection rate Vs population (Worldwide)

select location, population,  max(total_cases) as total_infection, max((total_cases/population) * 100) as infection_rate from covidproject.dbo.coviddeaths
where continent is not null
group by location, population
order by infection_rate desc



-- Highest deaths  (Worldwide)

select location, population,  max(cast(total_deaths as int)) as total_deaths, max((total_deaths/population) * 100) as death_rate from covidproject.dbo.coviddeaths

where continent is not null
group by location, population
order by total_deaths desc


-- Continents with highest death count 
 
 select continent, max(cast(total_deaths as int)) as total_deaths from covidproject.dbo.coviddeaths

where continent is not null
group by continent

order by total_deaths desc


 
 -- total cases worldwide 1

 select sum(new_cases), location from covidproject.dbo.coviddeaths

 where location like '%world%'

 group by  location

  -- total cases worldwide 2

 select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage from covidproject.dbo.coviddeaths
where continent is not null
order by  2


-- Total population vs vaccination * using CTE

with popvscvv (continent, location, date, population, new_vaccinations, rollingvac) 

as( 

select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by cvd.location order by cvd.location, cvd.date) as rollingvac

from covidproject.dbo.coviddeaths  cvd
join covidproject.dbo.covidVaccinations cvv

on cvd.location = cvv.location and cvd.date = cvv.date

where cvd.continent is not null
)

select *, (rollingvac/population)*100 as percentage_vaccinated  from popvscvv


-- Total population vs vaccination * using TEMP TABLES

drop table #percentvac

create table #percentvac (
continent nvarchar (50), 
location nvarchar (50), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rollingvac numeric

)
insert into #percentvac
select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by cvd.location order by cvd.location, cvd.date) as rollingvac

from covidproject.dbo.coviddeaths  cvd
join covidproject.dbo.covidVaccinations cvv

on cvd.location = cvv.location and cvd.date = cvv.date

where cvd.continent is not null

select *, (rollingvac/population)*100 as percentage_vaccinated  from  #percentvac


-- create view for tableau (population v vaccinated) 

create view popvscvv as 
select cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by cvd.location order by cvd.location, cvd.date) as rollingvac

from covidproject.dbo.coviddeaths  cvd
join covidproject.dbo.covidVaccinations cvv

on cvd.location = cvv.location and cvd.date = cvv.date

where cvd.continent is not null

select * from popvscvv