// Run once against mongo1 after `docker compose up`:
rs.initiate({
  _id: 'rs0',
  members: [
    {_id:0, host:'mongo1:27017'},
    {_id:1, host:'mongo2:27017'},
    {_id:2, host:'mongo3:27017'}
  ]
});
// Failover test: `docker stop mongo1` -> rs.status() shows mongo2 elected PRIMARY
// in ~10s; writes resume automatically. Captured in evidence/rs_status.txt.
