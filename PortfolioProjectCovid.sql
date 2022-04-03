select*
from [portfolio project]..Deaths$
order by 4
select*
from [portfolio project]..vaccinations$	
order by 3

-- select data that we are going to be using   

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..Deaths$
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]..Deaths$
where location = 'Croatia'
and continent is not null
order by 1,2 

-- looking at total cases vs population
-- show what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
from [portfolio project]..Deaths$
where location = 'Croatia'
order by 1,2 
  

  -- looking at countries with highes infection rate compared to population

select location, population,max (total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectionPercentage
from [portfolio project]..Deaths$
--where location = 'Croatia'
group by population, location
order by PopulationInfectionPercentage desc

-- showing countries with highest death count per population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..Deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- let's break things down by continent
--showing the continent with highest death count

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project]..Deaths$
where continent is not null 
group by continent
order by TotalDeathCount desc


-- global numbers by date

select date, sum(new_cases) as TotalWorldCases, sum(cast(new_deaths as int)) as TotalWorldDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [portfolio project]..Deaths$
where continent is not null
group by date
order by 1

-- global numbers total

select sum(new_cases) as TotalWorldCases, sum(cast(new_deaths as int)) as TotalWorldDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [portfolio project]..Deaths$
where continent is not null


-- looking total population vs vaccination

select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVacc
-- partition by:
  --slično kao Group by ali umjesto da sve npr. Afghanistane srola u jedno, partition by za sve afghanistane napravi neku kalkulaciju
from [portfolio project]..Deaths$ dea
join [portfolio project]..vaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.location= 'Croatia'
 order by 2,3

 -- sad zelimo iskoristiti taj broj i saznati koliki postotak ljudi se cijepio svaki dan. Dakle RollingPeopleVacc/Population. Da bi to napravili moramo korisiti CET ili TEMP table
 -- ne mozemo korisiti stupac koji smo upravo kreirali kako bi kreirali sljedeci
 -- broj stupaca u CTE-u mora biti isti kao u selectu zato navodimo sve
 -- prvo kreiramo cte a onda idemo sa selectom i executamo sve
 --CTE

 With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVacc)
 as
 (
 select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVacc
from [portfolio project]..Deaths$ dea
join [portfolio project]..vaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.location= 'Croatia'
 --order by 2,3
 )
 select*, (RollingPeopleVacc/population) *100 as Vaccbydaypercentage
 from PopvsVac

 -- TEMP TABLE


 
 Drop table if exists #PercentPopulationVacc
 Create Table #PercentPopulationVacc
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVacc
  select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from [portfolio project]..Deaths$ dea
join [portfolio project]..vaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.location= 'Croatia'
 --order by 2,3
Select*, (RollingPeopleVaccinated/Population)*100 as postotak
 from  #PercentPopulationVacc

 --Creating View to store data for later visualisations

 Create View  PercentPopulationVacc as 
   select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from [portfolio project]..Deaths$ dea
join [portfolio project]..vaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.location= 'Croatia'



