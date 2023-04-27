Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVacccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Totl Cases vs Total Deaths


Select Location, date, Cast(total_cases as float),Cast(total_deaths as float), (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Saudi%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, Cast(population as float) as Population, Cast(total_cases as float) as Total_cases,(Cast(total_cases as float)/Cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Cast(population as float) as Population, MAX(Cast(total_cases as float)) as HighestInfectionCases,MAX((Cast(total_cases as float)/Cast(population as float)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Break by Continent

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per popluation
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Number
Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/sum(cast(total_deaths as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Saudi%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent,location,date,population,New_Vaccincations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creat View for Vis

Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
