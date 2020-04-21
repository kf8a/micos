 create view data as SELECT samples.id AS sample_id,
    points.id AS point_id,
    studies.name AS study,
    plots.name AS plot,
    points.co2,
    points.n2o,
    points.ch4,
    points.datetime,
    points.minute
   FROM points
     JOIN samples ON samples.id = points.sample_id
     JOIN plots ON plots.id = samples.plot_id
     JOIN studies ON plots.study_id = studies.id;
