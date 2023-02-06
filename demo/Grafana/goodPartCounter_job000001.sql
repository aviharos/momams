SELECT
  cast(recvtimets as bigint) AS "time",
  cast(attrvalue as real) as attrvalue
FROM default_service.urn_ngsiv2_i40process_job_000001_i40process
WHERE
  attrname = 'goodPartCounter' and
  recvtimets = (select recvtimets from default_service.urn_ngsiv2_i40process_job_000001_i40process order by recvtimets desc limit 1)
ORDER BY 1
