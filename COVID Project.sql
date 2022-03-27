select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



--Looking at total cases vs total deaths in the US (%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total cases versus population in the US (%)
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
	from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate relative to population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectionPercentage
	from PortfolioProject..CovidDeaths
group by location, population
order by InfectionPercentage desc

--Showing Countries with Highest Death Count 
select location, max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	where continent is not null
group by location
order by TotalDeathCount desc

--Death Count by Continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	where continent is null and location not like '%income%'
group by location
order by TotalDeathCount desc

--Looking at Total Population vs Vaccinations
with PopvsVac (Continent, location, date, population, New_Vaccinations, TotalVaccinationsRunningTotal) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRunningTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (TotalVaccinationsRunningTotal/population)*100 as PercentagePopulationVaccinated
from PopvsVac

--temp table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
TotalVaccinationsRunningTotal numeric
)


insert into #PercentPopulationVaccinated 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRunningTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (TotalVaccinationsRunningTotal/population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated


--Creating view for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinationsRunningTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null