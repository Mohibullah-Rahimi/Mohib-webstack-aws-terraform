#!/bin/bash
# scripts/user_data.sh
# Simple cloud-init for web instances.
# This runs at first boot. Replace or extend to deploy your application.

# Update and install nginx
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

# Simple index page identifying this instance and author
cat <<'EOF' > /var/www/html/index.html
<html>
  <head><title>Mohibullah-Rahimi - Terraform Web Stack</title></head>
  <body>
    <h1>Hello from Terraform-provisioned EC2</h1>
    <p>Provisioned by: Mohibullah Rahimi</p>
    <p>Instance launched by Terraform user-data script.</p>
  </body>
</html>
EOF

systemctl enable nginx
systemctl start nginx