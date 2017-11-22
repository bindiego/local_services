# Demo of a DaemonSet deployment

A DaemonSet ensures that all (or some) Nodes run a copy of a Pod.

## Use cases

- running a cluster storage daemon, such as *glusterd*, *ceph*, on each node.
- running a logs collection daemon on every node, such as *fluentd* or *logstash*.
- running a node monitoring daemon on every node, such as Prometheus Node Exporter, *collectd*, Datadog agent, New Relic agent, or Ganglia *gmond*.
