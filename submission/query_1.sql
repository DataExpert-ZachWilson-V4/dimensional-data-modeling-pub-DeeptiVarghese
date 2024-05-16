create table deeptianievarghese22866.actors(
actor varchar not null,
actor_id varchar not null,
films array(    --struct array for storing film variables for the actor
row(
year integer,  
film varchar,
votes integer,
rating double,
film_id varchar
)),
quality_class varchar,   --categorical variable for binning average ranges, hence varchar
is_active boolean,
current_year integer
)
with
  (
    format = 'PARQUET',
    partitioning = ARRAY['current_year']
  )
