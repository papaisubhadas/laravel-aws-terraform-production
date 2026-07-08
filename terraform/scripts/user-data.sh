#!/bin/bash
set -e

# ============================================
# EC2 USER DATA SCRIPT
# Automated setup for Laravel application server
# ============================================

# Redirect all output to log file
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "Laravel EC2 Setup Starting"
echo "Time: $(date)"
echo "Instance ID: $(ec2-metadata --instance-id | cut -d ' ' -f 2)"
echo "Availability Zone: $(ec2-metadata --availability-zone | cut -d ' ' -f 2)"
echo "========================================="

# ============================================
# System Update
# ============================================

echo "Step 1/8: Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# ============================================
# Install Dependencies
# ============================================

echo "Step 2/8: Installing web server and PHP..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  nginx \
  php8.3-fpm \
  php8.3-cli \
  php8.3-mysql \
  php8.3-mbstring \
  php8.3-xml \
  php8.3-curl \
  php8.3-zip \
  php8.3-gd \
  php8.3-bcmath \
  php8.3-intl \
  unzip \
  git \
  curl \
  wget \
  ec2-instance-connect

# ============================================
# Install Composer
# ============================================

echo "Step 3/8: Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Verify installation
composer --version

# ============================================
# Create Application Directory
# ============================================

echo "Step 4/8: Setting up application directory..."
mkdir -p /var/www/laravel
chown -R www-data:www-data /var/www/laravel

# ============================================
# Create Test HTML Page
# ============================================

echo "Step 5/8: Creating test page..."

# For now, we'll create a beautiful test page
# In Week 4, we'll replace this with actual Laravel deployment
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laravel AWS Terraform - Production Ready</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
        }
        
        .container {
            text-align: center;
            padding: 60px 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
            max-width: 800px;
            margin: 20px;
        }
        
        h1 {
            font-size: 3.5em;
            margin-bottom: 20px;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            font-size: 1.5em;
            margin-bottom: 30px;
            opacity: 0.9;
        }
        
        .status {
            display: inline-block;
            padding: 15px 30px;
            background: #10b981;
            border-radius: 30px;
            margin: 20px 0;
            font-size: 1.2em;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }
        
        .info-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 25px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .info-card h3 {
            font-size: 1em;
            margin-bottom: 10px;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .info-card p {
            font-size: 1.3em;
            font-weight: 600;
            word-break: break-all;
        }
        
        .tech-stack {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .tech-stack h2 {
            margin-bottom: 20px;
            font-size: 1.5em;
        }
        
        .tech-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            justify-content: center;
        }
        
        .badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        .footer {
            margin-top: 40px;
            opacity: 0.7;
            font-size: 0.9em;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        .status {
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Laravel AWS Terraform</h1>
        <p class="subtitle">Production Infrastructure - Multi-AZ Deployment</p>
        
        <div class="status">✅ EC2 Instance Running</div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>Instance ID</h3>
                <p id="instance-id">Loading...</p>
            </div>
            
            <div class="info-card">
                <h3>Availability Zone</h3>
                <p id="az">Loading...</p>
            </div>
            
            <div class="info-card">
                <h3>Instance Type</h3>
                <p id="instance-type">Loading...</p>
            </div>
            
            <div class="info-card">
                <h3>Region</h3>
                <p id="region">Loading...</p>
            </div>
        </div>
        
        <div class="tech-stack">
            <h2>Technology Stack</h2>
            <div class="tech-badges">
                <span class="badge">AWS EC2</span>
                <span class="badge">Terraform</span>
                <span class="badge">Auto Scaling</span>
                <span class="badge">Application Load Balancer</span>
                <span class="badge">RDS MariaDB</span>
                <span class="badge">VPC Multi-AZ</span>
                <span class="badge">Nginx</span>
                <span class="badge">PHP 8.3</span>
                <span class="badge">Laravel 11</span>
            </div>
        </div>
        
        <div class="footer">
            <p>Deployed by Subha Sankar Das</p>
            <p>Infrastructure as Code with Terraform</p>
        </div>
    </div>
    
    <script>
        // Fetch instance metadata from AWS metadata service
        const metadataBase = 'http://169.254.169.254/latest/meta-data/';
        
        async function fetchMetadata(endpoint, elementId) {
            try {
                const response = await fetch(metadataBase + endpoint);
                const data = await response.text();
                document.getElementById(elementId).textContent = data;
            } catch (error) {
                document.getElementById(elementId).textContent = 'N/A';
            }
        }
        
        // Fetch all metadata
        fetchMetadata('instance-id', 'instance-id');
        fetchMetadata('placement/availability-zone', 'az');
        fetchMetadata('instance-type', 'instance-type');
        
        // Derive region from availability zone
        fetchMetadata('placement/availability-zone', 'region').then(() => {
            const az = document.getElementById('az').textContent;
            if (az && az !== 'N/A') {
                document.getElementById('region').textContent = az.slice(0, -1);
            }
        });
    </script>
</body>
</html>
HTML

# ============================================
# Configure Nginx
# ============================================

echo "Step 6/8: Configuring Nginx..."

cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.php;

    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Health check endpoint for ALB
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
NGINX

# Test Nginx configuration
nginx -t

# ============================================
# Start Services
# ============================================

echo "Step 7/8: Starting services..."

# Enable and start PHP-FPM
systemctl enable php8.3-fpm
systemctl start php8.3-fpm

# Enable and start Nginx
systemctl enable nginx
systemctl restart nginx

# ============================================
# Final Verification
# ============================================

echo "Step 8/8: Verifying installation..."

# Check service status
systemctl is-active --quiet nginx && echo "✅ Nginx is running" || echo "❌ Nginx failed"
systemctl is-active --quiet php8.3-fpm && echo "✅ PHP-FPM is running" || echo "❌ PHP-FPM failed"

# Test web server locally
curl -f http://localhost/ > /dev/null 2>&1 && echo "✅ Web server responding" || echo "❌ Web server not responding"

echo "========================================="
echo "Setup Complete!"
echo "Time: $(date)"
echo "Total duration: $SECONDS seconds"
echo "========================================="

# Signal completion (for debugging)
touch /var/log/user-data-complete
EOF