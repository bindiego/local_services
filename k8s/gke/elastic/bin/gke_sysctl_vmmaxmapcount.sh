#!/bin/bash -eu

# Increase Virtual Memory for Elasticsearch on GKE
# https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
# Dependencies: kubectl, gcloud, jq

# Run this every time you scaled your gke cluster

__nodes() {
	kubectl get nodes -o custom-columns=n:.metadata.name --no-headers
}

__zone_by_node() {
	local node=$1
	kubectl get node $node -o json \
		 | jq -r '.metadata.labels["failure-domain.beta.kubernetes.io/zone"]'
}

# Option 1: recommended
__gcloud_ssh() {
	local node=$1 && shift
	echo ">> ssh $node"
	gcloud compute ssh --zone $(__zone_by_node $node) $node -- sudo bash -c "'"$@"'"
}

# Option 2: you will need to add your public key to GCE meta
__ssh() {
	local node=$1 && shift
	echo ">> ssh $node"
	ssh -oStrictHostKeyChecking=no $node -- sudo bash -c "'"$@"'"
}

		#__gcloud_ssh $node \
# use either __gcloud_ssh or _ssh @line:37
__main() {
	for node in $(__nodes); do
		__ssh $node \
			"echo -n before: && sysctl -n vm.max_map_count && sysctl -w vm.max_map_count=262144 && echo -n after: && sysctl -n vm.max_map_count"
	done
}

__main
