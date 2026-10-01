output "mahe_frontend_alb_dns" {
  description = "Frontend Application Load Balancer DNS"
  value       = aws_lb.mahe_frontend_alb.dns_name
}