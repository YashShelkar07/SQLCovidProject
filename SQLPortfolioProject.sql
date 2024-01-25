select * from [PortfolioProject]..coviddeaths
where continent is not null
order by 3,4;

--select * from [PortfolioProject]..CovidVacination
--order by 3,4;

--Select Data that we going to use:

select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject].dbo.coviddeaths
order by 1,2


-- Looking at total Cases VS total Deaths 
-- DeathPercentage In INDIA :
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercantage
from [PortfolioProject].dbo.coviddeaths
where location = 'India'
order by 1,2;


ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_cases FLOAT;
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_deaths FLOAT;


--Looking at Total Case VS Population :
-- Shows that how many Population got Covid:
select location, date, population,total_cases, (total_cases/population)*100 as DeathsPercantage
from [PortfolioProject].dbo.coviddeaths
where location = 'India'
order by 1,2;

 --Looking at countries with highest Infected rate compaired to Population:
 select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPer
from [PortfolioProject].dbo.coviddeaths
--where location like 'I%'
group by location, population
order by PopulationInfectedPer desc


-- Showing Countries with Highest Death per Population :
 select location, max(total_deaths) as HighestDeathCount
from [PortfolioProject].dbo.coviddeaths
--where location like 'I%'
where continent is not null
group by location
order by HighestDeathCount desc

 --Now Break things down to Continent:
 select continent, max(total_deaths) as HighestDeathCount
 from [PortfolioProject].dbo.coviddeaths
 where continent is not null
 group by continent
 order by HighestDeathCount desc

 --Global Records :
 select sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths , sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
 from [PortfolioProject].dbo.coviddeaths
 where continent is not null
 --group by date
 order by DeathPercentage


 --Here we join 2 Tables Death and Vacination 
 select * 
 from [dbo].[CovidDeaths] dea 
 join [dbo].[CovidVacination] vac
 on dea.location = vac.location
 and dea.date = vac.date

 --Looking at Total Population vs Total Vacination :
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVacinated
 --( RollingPeopleVacinated / population)*100
 from [dbo].[CovidDeaths] dea 
 join [dbo].[CovidVacination] vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --Use CTE(Comman Table Expression)

 with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVacinated
-- ( RollingPeopleVacinated / population)*100
 from [dbo].[CovidDeaths] dea 
 join [dbo].[CovidVacination] vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
 select *, ( RollingPeopleVaccinated / population)*100
from popvsvac


-- Temp Table:
create table #PercentPopulationVaccinated
(
continent varchar(225),
location varchar(225),
date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVacinated
-- ( RollingPeopleVacinated / population)*100
 from [dbo].[CovidDeaths] dea 
 join [dbo].[CovidVacination] vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, ( RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated


-- Creating a View:

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVacinated
-- ( RollingPeopleVacinated / population)*100
 from [dbo].[CovidDeaths] dea 
 join [dbo].[CovidVacination] vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated