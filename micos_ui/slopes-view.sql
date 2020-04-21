create view slopes as SELECT samples.id AS sample_id,
    studies.name AS study_name,
    plots.name AS plot,
    samples.started_at,
    samples.finished_at,
    timezone('America/Detroit'::text, samples.started_at) AS local_start_time,
    timezone('America/Detroit'::text, samples.finished_at) AS local_finish_time,
    samples.height1,
    samples.height2,
    samples.height3,
    (samples.height1 + samples.height2 + samples.height3) / 3::double precision AS average_height,
    samples.n2o_slope,
    samples.n2o_r2,
    samples.co2_slope,
    samples.co2_r2,
    samples.ch4_slope,
    samples.ch4_r2,
    samples.air_temperature,
    samples.soil_temperature,
    samples.moisture,
    samples.deleted
   FROM samples
     JOIN plots ON plots.id = samples.plot_id
     JOIN studies ON plots.study_id = studies.id
  ORDER BY samples.id DESC;
