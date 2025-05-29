package main
import future.keywords.if
import future.keywords.in
import future.keywords.contains

deny contains msg if {
  input.kind == "Service"
  input.spec.type != "NodePort"
  msg = "Service type should be NodePort"
}

deny contains msg if {
  input.kind == "Deployment"
  some i
  input.spec.template.spec.containers[i].securityContext.runAsNonRoot != true
  msg = "Containers must not run as root - use runAsNonRoot within container security context"
}