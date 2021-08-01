
--Uvid u tabelu COVID_DEATHS
select * 
from COVID_DEATHS
order by 3,4;

--Uvid u tabelu COVID_VACCINATIONS
select * 
from COVID_VACCINATIONS
order by 3,4;

select location, dan, total_cases, new_cases, total_deaths, population
from covid_deaths where continent is not null
order by 1,2;

--Broj preminulih u odnosu na ukupan broj zaraženih (prikaz procenta smrtnosti u našoj državi) po danima (tj. do datog dana)
select location, dan, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%Bos%' and continent is not null
order by 1,2;

--Broj zaraženih u odnosu na broj stanovnika u našoj državi
select location, dan, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from covid_deaths
where location like '%Bos%'
order by 1,2;

--Države sa najvećim brojem zaraženih u odnosu na broj stanovnika
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
from covid_deaths
where total_cases is not NULL and continent is not null
group by location, population
order by 4 desc;

--Ukupan broj preminulih po kontinentima
select location,  MAX(total_deaths) as TotalDeathsCount
from covid_deaths
where total_deaths is not NULL and continent is  NULL
group by continent
order by 2 desc;

--Ukupan broj preminulih po državama
select location,  MAX(total_deaths) as TotalDeathsCount
from covid_deaths
where total_deaths is not NULL and continent is not NULL
group by location
order by 2 desc;

--Brojevi na globalnom nivou (ukupan broj slučajeva, ukupan broj preminulih i procenat smrtnosti po danima)
select dan, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid_deaths
where continent is not null
group by dan
order by 1,2;

--Ukupan broj zaraženih, ukupan broj preminulih  i procenat smrtnosti (krajnje vrijednost)
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from covid_deaths
where continent is not null
order by 1,2;

--Prikaz broja vakcinisanih za svaku državu po danima uz informacije na kom se kontinentu se država nalazi i koliko ima stanovnika
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null
order by 2,3;

--Ukupan broj vakcinisanih za svaku državu po danima (ukupan broj vakcinisanih datog dana i broj vakcinisanih do toga dana)
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null
order by 2,3;

--Kreiramo with na osnovu prethodnog upita da bismo odredili procenat vakcinisanih
with pop_vs_vac as(
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null)
select continent, location, dan, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100
from pop_vs_vac;

--Kreiramo tabelu pomoću koje se može odrediti procenat vakcinisanih za svaku lokaciju (državu, kontinent)
create table percent_population_vaccinated
(continent varchar2(26),
location varchar2(200),
dan date,
population number(38),
new_vaccinations number(38),
rolling_people_vaccinated number(38)
);

--Unos podataka u novu tabelu
insert into percent_population_vaccinated
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan;

--Uvid u tabelu percent_population_vaccinated
select continent, location, dan, population, new_vaccinations, rolling_people_vaccinated, (rolling_people_vaccinated/population)*100
from percent_population_vaccinated;

--Kreiranje pogleda za čuvanje podataka za kasniju vizualizaciju (procenat vakcinisanih po danima za svaku državu)
create view percent_population_vaccinated_v as
select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.dan) as rolling_people_vaccinated
from covid_deaths dea join covid_vaccinations vac 
on dea.location = vac.location and dea.dan = vac.dan
where dea.continent is not null;

SELECT * FROM percent_population_vaccinated_v;


