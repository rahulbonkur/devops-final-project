# DevOps Final Project - Cloud Architecture & Deployment Flows

## 1. Project Overview
This project demonstrates two distinct modern deployment strategies for microservices applications on AWS.

- **App-1 (AI Chatbot)**: Containerized deployment using **AWS ECS Fargate**, built via **AWS CodeBuild**.
- **App-2 (Recipe App)**: VM-based deployment using **Jenkins + Ansible** on **Amazon Linux 2023**.

The entire infrastructure is provisioned as code using **Terraform**.

---

## 2. Infrastructure (Terraform)
**Region**: `ap-south-1` (Mumbai)

| Component | Description |
|-----------|-------------|
| **VPC** | Custom VPC with Public Subnets for internet access. |
| **Security Groups** | Locked down. App-1 (ALB/ECS), App-2 (Port 80/22 restricted). |
| **IAM Roles** | Least-privilege roles for CodeBuild, ECS Tasks, and Jenkins. |
| **Key Pair** | `mykey` (Private key: `~/.ssh/mykey.pem`) for SSH access. |
| **State** | Local Terraform state (for this demo). |

---

## 3. Application 1: AI Chatbot (Containerized)
**Stack**: Python (Flask) + **Groq API** (Llama-3-70b)
**Architecture**: Serverless Containers

### deployment Pipeline (GitOps)
1.  **Code**: Pushed to GitHub (`app1-ai-chatbot/`).
2.  **Build**: **AWS CodeBuild** triggers on commit.
    *   Builds Docker Image (`Dockerfile` optimized for ECS).
    *   Tags image with Commit Hash & `latest`.
    *   Pushes to **Amazon ECR**.
3.  **Deploy**: CodeBuild triggers **ECS Service Update**.
    *   Service: `ai-chatbot-service`
    *   Platform: **AWS Fargate** (Serverless)
    *   Load Balancer: Application Load Balancer (ALB)
4.  **Runtime**:
    *   ECS Task pulls image from ECR.
    *   Secret Management: `GROQ_API_KEY` injected via ECS Task Definition.

**Key Files**:
- `app1-ai-chatbot/buildspec.yml`
- `app1-ai-chatbot/Dockerfile`
- `terraform/ecs.tf`, `terraform/codebuild.tf`

---

## 4. Application 2: Recipe App (VM-Based)
**Stack**: Python (Flask) + SQLite
**Architecture**: Traditional VM Deployment (Mutable)

### Deployment Pipeline (Jenkins + Ansible)
1.  **Code**: Pushed to GitHub (`app2-recipe-app/`).
2.  **Trigger**: **Jenkins Master** (running on EC2).
3.  **Provisioning**:
    *   Terraform provisions **Slave EC2** (Amazon Linux 2023).
    *   Outputs Slave IP (`recipe_slave_public_ip`).
4.  **Config Management (Ansible)**:
    *   Jenkins generates dynamic inventory with Slave IP + `mykey.pem`.
    *   **Ansible Playbook** runs against Slave.
    *   Installs: `python3`, `pip`, `nginx`, `git`.
    *   Deploys: App code, virtualenv, Gunicorn, Systemd service.
5.  **Runtime**:
    *   Nginx (Port 80) -> Gunicorn (Port 5000) -> Flask.
    *   OS User: `ec2-user`.

**Key Files**:
- `jenkins/Jenkinsfile`
- `ansible/playbooks/deploy-recipe-app.yml`
- `terraform/ec2-slave.tf`

---

## 5. Secrets & Configuration
### App-1 (ECS)
- **Environment Variables**: Managed in ECS Task Definition.
    - `GROQ_API_KEY`: API Key for LLM.
    - `GROQ_MODEL`: `llama3-70b-8192`.

### App-2 (VM)
- **SSH Key**: `~/.ssh/mykey.pem` on Jenkins Master.
- **App User**: `appuser` (Application runs as this user, not root).
- **Service Port**: `5000` (Internal), exposed via Nginx on `80`.

---

## 6. Verification
- **App-1**: Access via ALB DNS Name.
- **App-2**: Access via Slave Public IP.
