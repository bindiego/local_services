deploy: cmd1.yaml cmd2.yaml job1.yaml job2.yaml
	@-kubectl apply -f ./cmd1.yaml
	@-kubectl apply -f ./cmd2.yaml
	@-kubectl apply -f ./job1.yaml
	@-kubectl apply -f ./job2.yaml

clean: 
	@-kubectl delete -f ./cmd1.yaml
	@-kubectl delete -f ./cmd2.yaml
	@-kubectl delete -f ./job1.yaml
	@-kubectl delete -f ./job2.yaml

status:
	@-kubectl get pods

logs:
	@-kubectl logs command-demo-never-restart
	@-kubectl logs command-demo-restart-on-failure
	@-kubectl logs command-demo-never-restart-job
	@-kubectl logs command-demo-restart-on-failure-job

.PHONY: clean status logs
