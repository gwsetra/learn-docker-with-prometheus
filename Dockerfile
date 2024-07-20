# Use the latest Python 3.11 runtime as a parent image
FROM grafana/alloy:latest

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ARG DEBIAN_FRONTEND=noninteractive



# Install Prometheus
RUN apt-get update && \
    apt-get install -y wget gpg && \
    wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz && \
    tar -xzf prometheus-2.46.0.linux-amd64.tar.gz && \
    mv prometheus-2.46.0.linux-amd64 /etc/prometheus && \
    ln -s /etc/prometheus/prometheus /usr/local/bin/prometheus && \
    rm prometheus-2.46.0.linux-amd64.tar.gz

# Install Node Exporter
RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz && \
    tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz && \
    mv node_exporter-1.6.1.linux-amd64 /etc/node_exporter && \
    ln -s /etc/node_exporter/node_exporter /usr/local/bin/node_exporter && \
    rm node_exporter-1.6.1.linux-amd64.tar.gz

# Create a directory for Prometheus configuration
RUN mkdir -p /etc/prometheus

# Add Prometheus configuration file
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY alloy.hcl /etc/alloy/config.alloy

RUN mkdir -p /etc/apt/keyrings/ &&  mkdir -p /etc/apt/keyrings/ &&  \
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor |  tee /etc/apt/keyrings/grafana.gpg > /dev/null &&  \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" |  tee /etc/apt/sources.list.d/grafana.list

RUN  apt-get update
#RUN  #apt-get install -y alloy

#CMD ["run", "--server.http.listen-addr=0.0.0.0:12345", "--storage.path=/var/lib/alloy/data", "/etc/alloy/config.alloy"]

#RUN grafana/alloy:latest &&  \
#    run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data  \
#    /etc/alloy/config.alloy

# Expose port 80
EXPOSE 80
EXPOSE 12345

# Command to run both Prometheus and Node Exporter
ENTRYPOINT ["/bin/alloy"]

CMD ["sh", "-c", "prometheus --config.file=/etc/prometheus/prometheus.yml & node_exporter"]
