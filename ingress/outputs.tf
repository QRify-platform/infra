output "controller_role_arn" {
  value = aws_iam_role.lb_controller.arn
}


# curl -o modules/ingress/aws_lb_controller_policy.json \
#   https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
