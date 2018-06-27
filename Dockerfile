FROM docker.io/centos:7
LABEL maintainer="Noah Heil <nceheil@gmail.com>"
ARG GRAFANA_VERSION=5.1.3

LABEL name="Grafana" \
      io.k8s.display-name="Grafana" \
      io.k8s.description="Grafana Dashboard for use with Prometheus." \
      io.openshift.expose-services="3000" \
      io.openshift.tags="grafana" \
      build-date="2018-05-22" \
      version=$GRAFANA_VERSION \
      release="1"

# User grafana gets added by RPM
ENV \
    GF_PLUGIN_DIR=/var/lib/grafana \
    USERNAME=grafana


RUN yum -y update && yum -y upgrade && \
    yum -y install epel-release && \
    yum -y install git jq unzip nss_wrapper && \
    curl -L -o /tmp/grafana.rpm https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-$GRAFANA_VERSION-1.x86_64.rpm && \
    yum -y localinstall /tmp/grafana.rpm && \
    yum -y clean all && \
    rm -rf /var/cache/yum \
    rm /tmp/grafana.rpm

RUN for plugin in $(curl -s https://grafana.net/api/plugins?orderBy=name | jq '.items[] | select(.internal=='false') | .slug' | tr -d '"'); do grafana-cli --pluginsDir "${GF_PLUGIN_DIR}" plugins install $plugin; done

COPY ./root /
RUN /usr/bin/fix-permissions /var/log/grafana && \
    /usr/bin/fix-permissions /etc/grafana && \
    /usr/bin/fix-permissions /usr/share/grafana && \
    /usr/bin/fix-permissions /usr/sbin/grafana-server

VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

ENTRYPOINT ["/usr/bin/rungrafana"]
