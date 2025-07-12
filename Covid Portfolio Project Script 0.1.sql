SELECT * 
FROM dbo.CovidDeaths$
WHERE Continent is not null
ORDER BY 3, 4

--SELECT *
--FROM dbo.CovidVaccinations$
--ORDER BY 3, 4;

--Select data that we are going to be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
ORDER BY 1,2 

-- Looking at the total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE location like '%States%'
ORDER BY 1,2 

--Looking at the total cases vs population 
--Shows what percentage of population get covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 as
Percent_Population_infected 
FROM dbo.CovidDeaths$
ORDER BY 1,2

-- What country has the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as Highest_Infection_Count,
MAX(total_cases/population)*100 as Percent_Population_Infected
FROM dbo.CovidDeaths$
GROUP BY location, Population
ORDER BY Percent_Population_Infected desc

--Showing Countries with highest Death Count per Population

SELECT location,MAX(total_deaths) as Total_Death_Count 
FROM dbo.CovidDeaths$
GROUP BY location
ORDER BY Total_Death_Count desc

--Let Break Thing Down By Continents
-- Showing continents with highest death count 

SELECT Continent, MAX(Cast(Total_deaths as int)) as Total_Death_Count
FROM dbo.CovidDeaths$
WHERE Continent is not null
GROUP BY Continent 
ORDER BY Total_Death_Count desc


-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From dbo.CovidDeaths$
where continent is not null 
order by 1,2

--joining covid deaths and covid vaccinations tables together 

SELECT *
FROM [portfolio project].dbo.[CovidDeaths$] dea
JOIN [portfolio project].dbo.[CovidVaccinations$] vac
     ON dea.location = vac.location 
     AND dea.date = vac.date

     -- Looking at the Total population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [portfolio project].dbo.[CovidDeaths$] dea
JOIN [portfolio project].dbo.[CovidVaccinations$] vac
      ON dea.location = vac.location 
      AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3 ;

-- Using CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.Date) AS Rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
   FROM [portfolio project].dbo.[CovidDeaths$] dea
   JOIN [portfolio project].dbo.[CovidVaccinations$] vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
-- Order by 2,3
SELECT *, 
       (Rolling_people_vaccinated / population) * 100 
FROM PopvsVac

--Temp Table 

-- Using Temp table to perform calculation on the partition by in previous query 

DROP TABLE IF exists #Percent_population_vaccinated 
CREATE TABLE #Percent_population_vaccinated
( 
Continent nvarchar(225),
location nvarchar(225),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
Rolling_People_Vaccinated numeric 
)

INSERT INTO #Percent_population_vaccinated
SELECT  dea.continent, dea.location, dea.date,  dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.Date) AS Rolling_people_vaccinated
   FROM [portfolio project].dbo.[CovidDeaths$] dea
   JOIN [portfolio project].dbo.[CovidVaccinations$] vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
   -- WHERE dea.continent IS NOT NULL
   -- ORDER by 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #Percent_population_vaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW Percent_population_vaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM [portfolio project].dbo.[CovidDeaths$] dea
JOIN [portfolio project].dbo.[CovidVaccinations$] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


