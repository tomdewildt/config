---
name: generate-infra-diagram
description: Generate an infrastructure topology diagram from Terraform files.
argument-hint: <path>
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(npx *)
---

## Your Task

Read all Terraform files from a given path, analyze the infrastructure resources and their relationships, and generate a Mermaid topology diagram. Render the diagram to SVG using mermaid-cli and output a textual explanation of the infrastructure. Do NOT output the Mermaid diagram code in the response — refer the user to the generated files instead.

## Arguments

```
${ARGUMENTS}
```

## Steps

1. Use the Glob tool to find all `**/*.tf` files in the provided path. If no `.tf` files are found, inform the user and stop.

2. Read all discovered `.tf` files to understand the full infrastructure definition. Pay special attention to:
   - `outputs.tf` and `variables.tf` in each module — these reveal how modules connect to each other
   - Module references in the root `main.tf` — trace variable flows between root and module definitions to understand the actual resource relationships

3. Analyze the infrastructure by identifying all resources, data sources, modules, and their relationships:
   - Network resources (VPCs, subnets, firewalls, security groups, routers, route tables, NAT gateways, internet gateways)
   - Compute resources (VM instances, container services, serverless functions)
   - Storage resources (object storage buckets, persistent disks, artifact/container registries)
   - Database resources (managed SQL instances, NoSQL databases, in-memory caches)
   - Load balancing (load balancers, target groups, network endpoint groups, proxies, listeners, SSL certificates)
   - DNS & CDN (DNS records, CDN distributions)
   - Security & IAM (service accounts, IAM roles, secrets managers, workload identity/OIDC federation, IDS/threat detection)
   - Monitoring & alerting (alert policies, notification channels, log-based metrics)
   - Connections between resources (e.g., subnet belongs to VPC, service uses service account, container service connects to database)

4. Generate a Mermaid `graph TD` diagram following the styling standards defined in the additional resources section below.

5. Render the diagram:
   - Write the Mermaid code to `<path>/infrastructure.mmd`
   - Run: `npx -p @mermaid-js/mermaid-cli@latest mmdc -i <path>/infrastructure.mmd -o <path>/infrastructure.svg --quiet`
   - If the render fails, still output the Mermaid source path so the user can debug

6. Output a textual explanation of the infrastructure topology covering:
   - Architecture pattern (e.g., serverless, hybrid VM+serverless, microservices)
   - Networking model (e.g., private-only database, NAT for egress, VPC peering)
   - Deployment model (e.g., container services, VM instances, serverless functions)
   - Security posture (e.g., IDS, bastion/tunnel access, workload identity federation, secrets management)
   - CI/CD flow (e.g., GitHub Actions with OIDC, artifact registry)
   - Confirm the file paths for the generated `.mmd` and `.svg` files

## Additional Resources

### Styling Standards

#### Color Scheme

Always apply these `classDef` styles and assign every node to the appropriate class:

```
classDef compute fill:#4285F4,stroke:#1a73e8,color:#fff
classDef storage fill:#0F9D58,stroke:#0d8c4e,color:#fff
classDef network fill:#DB4437,stroke:#c33a2e,color:#fff
classDef security fill:#AB47BC,stroke:#8E24AA,color:#fff
classDef monitoring fill:#FF7043,stroke:#E64A19,color:#fff
classDef external fill:#607D8B,stroke:#455A64,color:#fff
```

- `compute` (Blue) — VM instances, container services, serverless functions
- `storage` (Green) — Databases, storage buckets, artifact registries, persistent disks
- `network` (Red) — Load balancer IPs, proxies, SSL certs, routers, NAT, firewalls
- `security` (Purple) — Secrets, service accounts, workload identity, IAM roles
- `monitoring` (Orange) — Alert policies, notification channels, dashboards
- `external` (Grey) — Internet entry point, third-party services (GitHub, CI/CD providers)

#### Node Shapes

- `(("name"))` double circle — External entry points (Internet, users)
- `["name"]` rectangle — Compute resources
- `[("name")]` cylinder — Databases and storage
- `{"name"}` rhombus — Routing, proxies, load balancing components

#### Label Formats

Use `<br/>` for multi-line labels. Include key specs so the diagram is self-documenting:

- **VM / Instance** — `Name<br/>Machine Type | Disk<br/>Port XXXX`
  - Example: `API Server<br/>t3.large | 500GB SSD<br/>Port 8080`
- **Container service** — `Name<br/>Port XXXX | CPU | Memory<br/>(image name)`
  - Example: `Backend Service<br/>Port 8000 | 4 CPU | 8Gi<br/>(my-app-backend)`
- **Database** — `Type Version<br/>Instance Tier<br/>Disk Size + Type`
  - Example: `PostgreSQL 15<br/>db.r6g.large<br/>100GB SSD`
- **Storage bucket** — Bucket name or purpose
  - Example: `Files Bucket`
- **Firewall rule** — `Firewall: Purpose<br/>(Source Range → :Port)`
  - Example: `Firewall: SSH<br/>(10.0.0.0/8 → :22)`
- **Service account** — `Name SA<br/>(key roles)`
  - Example: `Backend SA<br/>(secrets.read, storage.admin)`

#### Edge Styles

- `-->` solid arrow — Primary data/traffic flow
- `-.->` dotted arrow — Secondary relationships (IAM bindings, monitoring, firewall rules)
- `---` solid line (no arrow) — Associations without direction (SSL cert attached to proxy)
- `-->|"label"|` labeled edge — Add context to routing (e.g., `|"backend domain"|`)

#### Subgraph Nesting

Organize subgraphs in this hierarchy for consistent layout:

- **Top level** — Cloud provider + region (e.g., `GCP (europe-west4)`)
- **Mid level** — Logical groups (Load Balancer, VPC, Storage, IAM, Monitoring, etc.)
- **Inner level** — Network topology within VPC (Subnet > service groupings like container services, compute, database)
- **External** — Third-party services outside the cloud provider (GitHub, SaaS integrations)
