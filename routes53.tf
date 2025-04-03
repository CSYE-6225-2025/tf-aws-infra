# Fetch the existing Route 53 hosted zone for the subdomain (dev.hardishah.me)
data "aws_route53_zone" "subdomain_zone" {
  name         = "${var.environment}.hardishah.me"
  private_zone = false
}

# A Record for Subdomain pointing to Application Load Balancer (ALB)
resource "aws_route53_record" "subdomain_a" {
  zone_id = var.subdomain_zone_id
  name    = "${var.environment}.hardishah.me" # Modify for "demo.hardishah.me" if needed
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name # ALB DNS name
    zone_id                = aws_lb.webapp_alb.zone_id  # ALB Zone ID
    evaluate_target_health = true
  }
}

# Output for verification (Optional)
output "subdomain_name_servers" {
  description = "Name servers for the subdomain hosted zone"
  value       = data.aws_route53_zone.subdomain_zone.name_servers
}
