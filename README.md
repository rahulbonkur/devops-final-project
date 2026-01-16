# DevOps Final Project – Cloud Architecture & Deployment Flows

## 1. Project Overview
This project demonstrates two distinct, real-world deployment strategies on AWS using modern DevOps tooling and best practices.

- **App-1 (AI Chatbot)**: Containerized, serverless deployment using **AWS ECS Fargate**, built and deployed via **AWS CodeBuild**.
- **App-2 (Recipe App)**: VM-based deployment using **Jenkins + Ansible** on **Amazon Linux 2023**.

All infrastructure is provisioned using **Terraform (Infrastructure as Code)**.

---

## 2. Infrastructure (Terraform)
**Region**: `ap-south-1` (Mumbai)

| Component | Description |
|--------|------------|
| **VPC** | Custom VPC with public subnets and internet gateway |
| **Security Groups** | App-specific access (ALB/ECS + EC2 SSH/HTTP) |
| **IAM Roles** | Least-privilege roles for CodeBuild, ECS Tasks, EC2 |
| **Key Pair** | `mykey` (private key stored securely on Jenkins Master) |
| **State** | Remote Terraform state stored in **Amazon S3** |

---

## 3. Application 1: AI Chatbot (Containerized)
**Stack**: Python (Flask) + **Groq API (Llama-3-70b)**  
**Architecture**: Serverless Containers (ECS Fargate)

### Deployment Flow (GitOps)
1. Developer pushes code to GitHub (`app1-ai-chatbot/`)
2. **AWS CodeBuild** is triggered:
   - Builds Docker image
   - Tags image with commit hash and `latest`
   - Pushes image to **Amazon ECR**
3. CodeBuild triggers **ECS Service update**
4. **ECS Fargate** pulls image and runs the task behind an **Application Load Balancer**

### Runtime
- Stateless containers
- Load balanced via ALB
- Auto-managed compute via Fargate

**Key Files**
- `app1-ai-chatbot/Dockerfile`
- `app1-ai-chatbot/buildspec.yml`
- `terraform/ecr.tf`, `terraform/ecs.tf`, `terraform/codebuild.tf`

---

## 4. Application 2: Recipe App (VM-Based)
**Stack**: Python (Flask) + SQLite  
**Architecture**: Traditional VM deployment with configuration management

### Deployment Flow (Jenkins + Ansible)
1. Code pushed to GitHub (`app2-recipe-app/`)
2. Jenkins pipeline is triggered
3. Terraform provisions **Recipe Slave EC2** (Amazon Linux 2023)
4. Jenkins fetches Slave IP from Terraform outputs
5. Jenkins runs **Ansible Playbook**:
   - Installs system packages
   - Creates application user
   - Deploys code
   - Configures Gunicorn + systemd
   - Configures Nginx reverse proxy

### Runtime
- Nginx (Port 80) → Gunicorn (Port 5000) → Flask
- App runs as non-root user
- Mutable VM deployment

**Key Files**
- `jenkins/Jenkinsfile`
- `ansible/playbooks/deploy-recipe-app.yml`
- `terraform/ec2-slave.tf`

---

## 5. Secrets & Configuration
### App-1 (ECS)
- **GROQ_API_KEY**
- **GROQ_MODEL**

> Note: API key is temporarily hardcoded for demo purposes.  
> In production, secrets should be injected via ECS Task Definitions or AWS Secrets Manager.

### App-2 (VM)
- SSH key stored securely on Jenkins Master
- App runs as `appuser`
- Gunicorn managed via systemd

---

## 6. Verification
- **AI Chatbot**: Access via ALB DNS Name
- **Recipe App**: Access via EC2 Public IP

---

## 7. Key DevOps Concepts Demonstrated
- Infrastructure as Code (Terraform)
- CI/CD Pipelines (CodeBuild + Jenkins)
- Containerization & Serverless Compute (ECS Fargate)
- Configuration Management (Ansible)
- IAM Least Privilege
- Production-grade service management (systemd, Nginx, Gunicorn)

---

## 8. Architecture Summary
This project intentionally demonstrates **both modern container-based deployments and traditional VM-based deployments**, showcasing a strong understanding of real-world DevOps trade-offs.
