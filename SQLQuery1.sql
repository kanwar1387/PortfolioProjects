--select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Ind%'
ORDER BY 1,2;

-- Looking at Total Cases Vs Population
-- shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
--Where location = 'India'
Where continent is not null
group by location, population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per population

SELECT location, max(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
--Where location = 'India'
where continent is not null
group by location
ORDER BY HighestDeathCount desc;

-- LET's break things down by continents

-- showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
--Where location = 'India'
where continent is not null
group by continent
ORDER BY HighestDeathCount desc;


-- Global numbers

SELECT date, SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
group by date
ORDER BY 1,2;

SELECT SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- looking at total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3;

--use cte
with popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac

-- Creating view
CREATE VIEW PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(int, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null;
