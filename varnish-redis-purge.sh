varnishadm "ban req.url ~ /" &&
redis-cli -h redis-fpc.openebs.svc.cluster.local flushall &&
redis-cli -h redis-session.openebs.svc.cluster.local -p 6380 flushall &&
redis-cli -h redis-config-cache.openebs.svc.cluster.local -p 6381 flushall
