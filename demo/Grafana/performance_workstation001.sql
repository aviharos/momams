SELECT
  cast(recvtimets as bigint) AS "time",
  cast(attrvalue as real) as attrvalue
FROM default_service.urn_ngsiv2_i40asset_workstation_001_i40asset
WHERE
  attrname = 'oeePerformance' and
  recvtimets = (select recvtimets from default_service.urn_ngsiv2_i40asset_workstation_001_i40asset order by recvtimets desc limit 1)
ORDER BY 1
