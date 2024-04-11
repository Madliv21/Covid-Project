--Likehood of dying if you contract Covid in Romania
--select *
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Project Covid]..CovidDeaths
where location= 'Romania'
order by 1,2

--Percentage of population with Covid
select location,date,population,total_cases, (total_cases/population)*100 as InfectionRate
from [Project Covid]..CovidDeaths
where location= 'Romania'
order by 1,2

--Highest InfectionRate/ DeathRate
select location,population,max(total_cases) as HighestInfection, max((total_cases/population))*100 as HighestInfectionRate, max((total_deaths/total_cases))*100 as HighestDeathPercentage
from [Project Covid]..CovidDeaths
--where location= 'Romania'
Group By location,population
order by HighestInfectionRate desc

--Highest DeathRate per Country
select location,population,max(cast(total_deaths as int)) as DeathCount
from [Project Covid]..CovidDeaths
where continent is not null
Group By location,population
order by DeathCount desc

--Highest DeathRate per Continent
select continent,max(cast(total_deaths as bigint)) as DeathCount
from [Project Covid]..CovidDeaths
where continent is not null
Group By continent
order by DeathCount desc

--Global Numbers

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as bigint)) as TotalDeaths,sum(cast(new_deaths as bigint))/sum(new_cases) as DeathRatio
from [Project Covid]..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases,sum(cast(new_deaths as bigint)) as TotalDeaths,sum(cast(new_deaths as bigint))/sum(new_cases) as DeathRatio
from [Project Covid]..CovidDeaths
where continent is not null
order by 1,2

--Total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location) as TotalVaccinations
from [Project Covid]..CovidDeaths dea
join [Project Covid]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--with CTE

with PopvsVac(Continent,Location,Date,Population,new_vaccinations,TotalVaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location) as TotalVaccinations
from [Project Covid]..CovidDeaths dea
join [Project Covid]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *,(TotalVaccinations/Population)*100 as VaccinationPercentage
from PopvsVac
order by 2,3

--Temp table

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
TotalVaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from [Project Covid]..CovidDeaths dea
join [Project Covid]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select *,(TotalVaccinations/Population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated
order by 2,3


--Creating View for Visualization
Create View TotalVaccinations as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from [Project Covid]..CovidDeaths dea
join [Project Covid]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select *
From TotalVaccinations


