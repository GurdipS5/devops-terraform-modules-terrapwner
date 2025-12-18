# devops-terraform-modules-terrapwner

# 🔐 CI/CD Agent Security Testing with Terrapwner

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Terrapwner](https://img.shields.io/badge/Terrapwner-v0.1.x-632CA6?style=for-the-badge&logo=datadog&logoColor=white)](https://github.com/DataDog/terraform-provider-terrapwner)
[![Buildkite](https://img.shields.io/badge/Buildkite-Supported-14CC80?style=for-the-badge&logo=buildkite&logoColor=white)](https://buildkite.com/)
[![TeamCity](https://img.shields.io/badge/TeamCity-Supported-000000?style=for-the-badge&logo=teamcity&logoColor=white)](https://www.jetbrains.com/teamcity/)
[![Lynx](https://img.shields.io/badge/Lynx_Backend-Supported-4A154B?style=for-the-badge)](https://github.com/Clivern/Lynx)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

> **Security testing suite for CI/CD pipelines using [Datadog's Terrapwner](https://github.com/DataDog/terraform-provider-terrapwner) provider. Test your Buildkite and TeamCity agents for common vulnerabilities, credential exposure, and network security issues.**

---

## ⚠️ Security Warning

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠️  WARNING: This tool is designed for SECURITY TESTING only              │
│                                                                             │
│  • Only use in controlled test environments                                 │
│  • NEVER run in production                                                  │
│  • Be aware of legal implications                                           │
│  • Follow responsible disclosure practices                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [What Gets Tested](#-what-gets-tested)
- [Pipeline Integration](#-pipeline-integration)
  - [Buildkite](#buildkite)
  - [TeamCity](#teamcity)
- [Lynx State Backend Testing](#-lynx-state-backend-testing)
- [Understanding Results](#-understanding-results)
- [Security Recommendations](#-security-recommendations)
- [Configuration](#%EF%B8%8F-configuration)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔍 **Command Execution Testing** | Test what commands can be executed on CI/CD agents |
| 🌐 **Network Security Probes** | Check internet access, internal services, and cloud metadata (SSRF) |
| 🔑 **Credential Exposure Detection** | Find secrets in environment variables and config files |
| 🐳 **Container Security** | Detect Docker socket access and Kubernetes token exposure |
| 📦 **Buildkite-Specific Tests** | Plugin directories, hooks, agent tokens |
| 🏗️ **TeamCity-Specific Tests** | Agent configuration, authorization tokens |
| 🐺 **Lynx Backend Testing** | State exfiltration risks, credential exposure |
| 📊 **Actionable Reports** | Clear security summaries with remediation guidance |

---

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- Access to your CI/CD agent environment

### Installation

```bash
# Clone this repository
git clone https://github.com/your-org/cicd-security-tests.git
cd cicd-security-tests

# Initialize Terraform
terraform init

# Run the security assessment
terraform apply -auto-approve

# View results
terraform output security_assessment_summary
```

### One-Liner

```bash
terraform init && terraform apply -auto-approve && terraform output -json > report.json
```

---

## 🔍 What Gets Tested

### Agent Security

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENT SECURITY TESTS                     │
├─────────────────────────────────────────────────────────────┤
│  ✓ User identity and privileges                             │
│  ✓ Available system tools (curl, wget, nc, python)          │
│  ✓ Sudo capabilities                                        │
│  ✓ Docker socket access (container escape risk)             │
│  ✓ SSH keys and cloud credentials                           │
│  ✓ Git credentials and tokens                               │
└─────────────────────────────────────────────────────────────┘
```

### Network Security

```
┌─────────────────────────────────────────────────────────────┐
│                   NETWORK SECURITY TESTS                    │
├─────────────────────────────────────────────────────────────┤
│  ✓ Internet connectivity (HTTP/HTTPS)                       │
│  ✓ DNS resolution                                           │
│  ✓ Cloud metadata services (169.254.169.254) - SSRF risk    │
│  ✓ Internal service reachability                            │
│  ✓ Common exfiltration ports (SSH, DNS)                     │
└─────────────────────────────────────────────────────────────┘
```

### Platform-Specific

```
┌─────────────────────────────────────────────────────────────┐
│                 BUILDKITE-SPECIFIC TESTS                    │
├─────────────────────────────────────────────────────────────┤
│  ✓ BUILDKITE_AGENT_ACCESS_TOKEN exposure                    │
│  ✓ Plugin directory write permissions                       │
│  ✓ Hooks directory access (persistence risk)                │
│  ✓ Build artifact security                                  │
│  ✓ Secrets in build logs                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 TEAMCITY-SPECIFIC TESTS                     │
├─────────────────────────────────────────────────────────────┤
│  ✓ buildAgent.properties file access                        │
│  ✓ Authorization token exposure                             │
│  ✓ Agent configuration write permissions                    │
│  ✓ Work directory security                                  │
│  ✓ Secrets in agent logs                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Pipeline Integration

### Buildkite

Add to your `.buildkite/pipeline.yml`:

```yaml
steps:
  - label: "🔐 Agent Security Assessment"
    key: "security-test"
    command: |
      # Install Terraform if not present
      if ! command -v terraform &> /dev/null; then
        curl -fsSL https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip -o terraform.zip
        unzip terraform.zip && chmod +x terraform
        export PATH=$PATH:$PWD
      fi
      
      # Run security tests
      cd security-tests/
      terraform init
      terraform apply -auto-approve
      terraform output -json > security-report.json
      
      # Upload artifact
      buildkite-agent artifact upload security-report.json
    
    agents:
      queue: "security-test-agents"
    
    soft_fail: true
    
    artifact_paths:
      - "security-tests/security-report.json"
```

### TeamCity

**Kotlin DSL:**

```kotlin
object SecurityAssessment : BuildType({
    name = "Agent Security Assessment"
    
    vcs {
        root(DslContext.settingsRoot)
    }
    
    steps {
        script {
            name = "Run Security Assessment"
            workingDir = "security-tests"
            scriptContent = """
                #!/bin/bash
                set -e
                
                # Install Terraform
                if ! command -v terraform &> /dev/null; then
                    curl -fsSL https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip -o terraform.zip
                    unzip terraform.zip && chmod +x terraform
                    export PATH=${'$'}PATH:${'$'}PWD
                fi
                
                # Run tests
                terraform init
                terraform apply -auto-approve
                terraform output -json > security-report.json
            """.trimIndent()
        }
    }
    
    artifactRules = "security-tests/security-report.json => security-artifacts"
    
    failureConditions {
        executionTimeoutMin = 30
    }
})
```

**Build Step (UI):**

```bash
#!/bin/bash
cd security-tests/
terraform init
terraform apply -auto-approve
terraform output -json > security-report.json
```

---

## 🐺 Lynx State Backend Testing

If you're using [Clivern's Lynx](https://github.com/Clivern/Lynx) as your Terraform backend, this suite includes specific tests for state security.

### Configuration

Update `variables.tf` with your Lynx server details:

```hcl
variable "lynx_host" {
  description = "Your Lynx server hostname"
  default     = "lynx.yourcompany.com"
}

variable "lynx_port" {
  description = "Lynx server port"
  default     = 4000
}
```

### What Gets Tested

| Test | Risk Level | Description |
|------|------------|-------------|
| `TF_HTTP_USERNAME` exposure | 🚨 Critical | Credentials in environment |
| `TF_HTTP_PASSWORD` exposure | 🚨 Critical | Credentials in environment |
| Network access to Lynx | ⚠️ Warning | Can agent reach backend? |
| `terraform state pull` | 🚨 Critical | Can state be exfiltrated? |
| Hardcoded credentials | 🚨 Critical | Secrets in `backend.tf` |
| Lynx API without auth | 🚨 Critical | Misconfigured backend |

### Example Output

```
=============================================
LYNX STATE BACKEND SECURITY ASSESSMENT
=============================================

CREDENTIAL EXPOSURE:
- TF_HTTP_USERNAME in env: 🚨 EXPOSED
- TF_HTTP_PASSWORD in env: 🚨 EXPOSED

NETWORK ACCESS:
- Can reach Lynx backend: ⚠️ YES

STATE ACCESS:
- Can pull state:         🚨 YES (EXFIL RISK)

RISKS IF CREDENTIALS + NETWORK ACCESS:
- Attacker can read ALL state (secrets, resources, outputs)
- Attacker can MODIFY state (corrupt infrastructure)
- Attacker can LOCK state (denial of service)
```

---

## 📊 Understanding Results

### Status Icons

| Icon | Meaning | Action Required |
|------|---------|-----------------|
| ✅ | Secure | Control is in place |
| ⚠️ | Warning | Evaluate business need |
| 🚨 | Critical | Immediate remediation |

### Example Summary Output

```
============================================
CI/CD AGENT SECURITY ASSESSMENT SUMMARY
============================================

Agent User: buildkite-agent

NETWORK SECURITY:
- Internet Access (HTTP):  ⚠️  ACCESSIBLE
- Internet Access (HTTPS): ⚠️  ACCESSIBLE
- AWS Metadata Service:    🚨 ACCESSIBLE (SSRF RISK)
- GCP Metadata Service:    ✅ BLOCKED

PRIVILEGE ESCALATION:
- Docker Socket Access:    🚨 ACCESSIBLE (ESCAPE RISK)

CREDENTIAL EXPOSURE:
- CI Platform Tokens:      🚨 FOUND IN ENV
- Cloud Credentials:       ⚠️  FOUND IN ENV
```

---

## 🛡️ Security Recommendations

### Critical Findings & Fixes

<details>
<summary><b>🚨 Cloud Metadata Service Accessible (SSRF Risk)</b></summary>

**Risk:** Attackers can steal cloud credentials via SSRF attacks.

**Fix:**
```bash
# Block metadata service at network level
iptables -A OUTPUT -d 169.254.169.254 -j DROP

# Or use IMDSv2 with hop limit (AWS)
aws ec2 modify-instance-metadata-options \
    --instance-id i-xxx \
    --http-tokens required \
    --http-put-response-hop-limit 1
```
</details>

<details>
<summary><b>🚨 Docker Socket Accessible (Container Escape)</b></summary>

**Risk:** Full host access via container escape.

**Fix:**
- Don't mount Docker socket to CI containers
- Use rootless Docker or Podman
- Use Kaniko for building images in CI
</details>

<details>
<summary><b>🚨 Lynx Credentials in Environment</b></summary>

**Risk:** State exfiltration, tampering, or DoS.

**Fix:**
- Use Lynx OAuth2/SSO (Azure AD, Keycloak, Okta)
- Use short-lived tokens instead of static credentials
- Create separate Lynx users per pipeline
</details>

<details>
<summary><b>⚠️ Internet Access Available</b></summary>

**Risk:** Data exfiltration possible.

**Fix:**
- Implement egress filtering
- Only allow required destinations
- Use a forward proxy with allowlist
</details>

---

## ⚙️ Configuration

### Customizing Tests

#### Add Custom Network Probes

```hcl
data "terrapwner_network_probe" "custom_service" {
  type    = "tcp"
  host    = "your-internal-service.local"
  port    = 8080
  timeout = 5
}
```

#### Add Custom Command Tests

```hcl
data "terrapwner_local_exec" "custom_check" {
  command = ["your", "command", "here"]
}
```

#### Skip Specific Tests

```hcl
# Set to false to skip
variable "test_docker_socket" {
  default = true
}

data "terrapwner_local_exec" "docker_socket" {
  count   = var.test_docker_socket ? 1 : 0
  command = ["ls", "-la", "/var/run/docker.sock"]
}
```

---

## 📁 Repository Structure

```
.
├── README.md                    # This file
├── main.tf                      # Core security tests
├── pipeline-specific-tests.tf   # Buildkite & TeamCity tests
├── lynx-backend-tests.tf        # Lynx state backend tests
├── variables.tf                 # Configuration variables
├── outputs.tf                   # Test result outputs
└── examples/
    ├── buildkite/
    │   └── pipeline.yml
    └── teamcity/
        └── settings.kts
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-test`)
3. Commit your changes (`git commit -m 'Add amazing security test'`)
4. Push to the branch (`git push origin feature/amazing-test`)
5. Open a Pull Request

---

## 📚 Resources

- [Terrapwner GitHub](https://github.com/DataDog/terraform-provider-terrapwner)
- [Terrapwner Terraform Registry](https://registry.terraform.io/providers/DataDog/terrapwner)
- [Lynx Terraform Backend](https://github.com/Clivern/Lynx)
- [Buildkite Security Best Practices](https://buildkite.com/docs/pipelines/security)
- [TeamCity Security Notes](https://www.jetbrains.com/help/teamcity/security-notes.html)
- [OWASP CI/CD Security](https://owasp.org/www-project-devsecops-guideline/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <sub>Built with ❤️ for securing CI/CD pipelines</sub>
</p>

<p align="center">
  <a href="https://github.com/DataDog/terraform-provider-terrapwner">
    <img src="https://img.shields.io/badge/Powered_by-Terrapwner-632CA6?style=flat-square&logo=datadog" alt="Powered by Terrapwner">
  </a>
</p>
