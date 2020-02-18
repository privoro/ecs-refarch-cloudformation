docker run \
    --network=host \
    -p 9090:9091 \
    -v prometheus.yml:/etc/prometheus \
    prom/prometheus
