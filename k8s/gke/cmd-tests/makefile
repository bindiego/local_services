deploy: cmd1.yaml cmd2.yaml
	@-kubectl apply -f ./cmd1.yaml
	@-kubectl apply -f ./cmd2.yaml

clean: 
	@-kubectl delete -f ./cmd1.yaml
	@-kubectl delete -f ./cmd2.yaml

status:
	@-kubectl get pods

logs:
	@-kubectl logs command-demo-never-restart
	@-kubectl logs command-demo-restart-on-failure

.PHONY: clean status logs
