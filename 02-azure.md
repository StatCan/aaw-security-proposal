# Azure Resources

The Advanced Analytics Workspaces (AAW) runs within the Azure Cloud
environment. Thus, it's critical that the Azure resources be correctly
configured to provide a secure context for the AAW and its associated
Protected B workloads. This section discusses the proposed
implementation of these Azure resources. Simply put,
the following diagram depicts the overall layout of the Azure
resources (based on network configuration):

![Network layout diagram](assets/images/network.svg)

Let's deep dive down to the difference resources and how they are
proposed to be configured.

## Subscription

Currently, the AAW environment lives in the `vdl` subscription. As it stands,
there are many person and non-person entities who have full access to resources
within the subscription (`Owner` or `Contributor` at the subscription level),
many of whom are not related to or associated with the AAW project.
This provides a high level of risk of many accidental or unauthorized
activities within the environment, including:

- Accidental or malicious removal of resources
- Accidental or malicious removal of security policies
- Malicious access to unauthorized resources

While generally users with access to the environment are trusted by the
organization, most users do not have a need to have this access within
the AAW environment. Therefore, this is directly in violation of
the principle of least privilege.

> **Recommendation AZ-SUB-01**: The AAW be moved to its own subscription with
> limited person and non-person entities who have `Owner` or `Contributor`
> at the subscription level.

## Resource groups

> **Recommendation AZ-RG-01**: The following resource groups be created with
> the defined purpose:
>
> - `aaw-$env-$region-$num-rg-network`: Network resources (VNET, Firewall)
> - `aaw-$env-$region-$num-rg-aks`: AKS resources (AKS, Container Registry)
> - `aaw-$env-$region-$num-rg-aks-managed`: AKS managed resources for each cluster
> - `aaw-$env-$region-$num-rg-backup`: Backup resources (Velero)
> - `aaw-$env-$region-$num-rg-security`: Security resources (e.g.
>    Vault KeyVault, Storage Account)
> - `aaw-$env-$region-$num-rg-data`: Data resources (e.g. Databases)
>
> (see below for variable values)

## Resource naming

> **Recommendation AZ-RN-01**: The naming convention of Azure resources be:
>
> `aaw-$env-$region-$num-$type-$purpose`, where:
>
> | Field      | Value                                                                                                                              |
> |------------|------------------------------------------------------------------------------------------------------------------------------------|
> | `$type`    | The resource type, usually abbreviated                                                                                             |
> | `$region`  | The region of the resource, if region-specific. Usually `cc`, for Canada Central                                                   |
> | `$num`     | The instance number of AAW in that env/region, starting at `00`                                                                    |
> | `$env`     | The environment of the resource, usually `prod` or `dev`                                                                           |
> | `$purpose` | If multiple resources of this type are deployed in this env/region/num, then the purpose of the resource should be appended at end |
>
> Common Azure resources and their abbreviations:
>
> | Abbreviation | Resource                            |
> |--------------|-------------------------------------|
> | `rg`         | Resource group                      |
> | `vnet`       | Virtual network                     |
> | `snet`       | Subnet                              |
> | `rt`         | Route table                         |
> | `fw`         | Firewall                            |
> | `aks`        | Azure Kubernetes Service            |
> | `cr`         | Container Registry                  |
> | `sa`         | Storage account                     |
> | `msi`        | User assigned managed self identity |
> | `kv`         | Azure Key Vault                     |
>
> Example resource names:
>
> - `aaw-prod-cc-00-vnet-hub`: the hub vnet in the aaw-prod-cc-00 environment
> - `aaw-prod-cc-00-aks`: the AKS cluster in Canada Central in the aaw-prod-cc-00 environment
>
> *Where resources do not support `-` in the name, then
> the `-` should be omitted from the resource name.*

## Networking

A proper network layout will enable the AAW environment to apply appropriate
rules and restrictions to workloads based on the source and destination
of each connection.

> **Recommendation AZ-NW-01**: Each region and environment will be assigned
> a network space of /14, broken down into the following Virtual Networks:
>
> - Hub VNET (/16)
> - AKS VNET (/16)
> - Data VNET (/16)
> - Reserved for future use (/16)
>
> A VNET is best given a /16 (65536) of IP space as this is
> the maximum number of private IPs permitted in a virtual network: [https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#networking-limits](https://docs.microsoft.com/en-us/azure/firewall/firewall-faq#why-does-azure-firewall-need-a--26-subnet-size).

This recommendation is referred to as a Hub & Spoke model. This allows us to
maximize the available IP space for the AKS cluster within the AKS VNET. While
this incurrs additional peering costs between the VNETs it is offset but
the increased security posture - in particular if the AAW environment
is peered with other enviroments in the future, as traffic can be forced
through the Azure firewall first.

> Note: The Data VNET / subnets are generally not needed as we can
> use Service Endpoints for managed databases and storage accounts.

> **Recommendation AZ-NW-02**: Each virtual network be broken down
> into the following subnets:
>
> *HUB VNET*
>
> | Network             | Subnet           | Start IP      | End IP        | Number of IPs |
> |---------------------|------------------|---------------|---------------|---------------|
> | `firewall`          | `x.y.255.192/26` | `x.y.255.192` | `x.y.255.255` | 64            |
>
> *AKS VNET*
>
> | Network             | Subnet           | Start IP      | End IP        | Number of IPs |
> |---------------------|------------------|---------------|---------------|---------------|
> | `load-balancers`    | `x.y.254.0/23`   | `x.y.254.0`   | `x.y.255.255` | 512           |
> | `system`            | `x.y.0.0/18`     | `x.y.0.0`     | `x.y.63.255`  | 16384         |
> | `user-unclassified` | `x.y.64.0/18`    | `x.y.64.0`    | `x.y.127.255` | 16384         |
> | `user-protected-b`  | `x.y.128.0/18`   | `x.y.128.0`   | `x.y.191.255` | 16384         |
>
> *DATA VNET*
>
> | Network             | Subnet           | Start IP      | End IP        | Number of IPs |
> |---------------------|------------------|---------------|---------------|---------------|
> | `data-unclassified` | `x.y.0.0/22`     | `x.y.0.0`     | `x.y.3.255`   | 1024          |
> | `data-protected-b`  | `x.y.4.0/22`     | `x.y.4.0`     | `x.y.7.255`   | 1024          |

### Firewall

#### Azure Firewall

The Azure Firewall sits at the edge of the AAW environment and
serves as the last defence between the internal networks
and the general internet.

> **Recommendation AZ-FW-01**: The Azure Firewall be used at the edge
> of the AAW networks.

> **Recommendation AZ-FW-02**: The Azure Firewall be configured
> with the following rules:
>
> 1. Inbound traffic destined for an internal subnet
>    shall be permitted to a Load Balancer located in
>    the `load-balancers` subnet.
> 2. Outbound traffic from the `system`, `user-protected-b`,
>    `data-unclassified` and `data-protected-b` subnets
>    be restricted to essential traffic only, with policies
>    unique to each subnet.
> 3. Outbound traffic to ports 80/443, and others as needed,
>    be permitted from the `user-unclassified` subnet.
> 4. Traffic from `user-unclassified` be permitted to `data-unclassified`,
>    and the same be applied for `protected-b`.

#### Network Security Groups (NSGs)

The Azure Firewall provides protection between external networks
and the Advanced Analytics Environment, but does not provide
protection for traffic flows within the environment.

Azure provides a Network Security Group (NSG) feature that allows
the control of traffic between subnets in a Virtual Network.

> **Recommendation AZ-FW-03**: Network Security Groups (NSGs) be
> used to control inter-subnet traffic flows within the same VNET.

> **Recommendation AZ-FW-04**: Network Security Groups (NSGs) be
> configured as:
>
> 1. `load-balancers` may accept traffic from any subnet. Restricting
>    access to load balancers is done on a per-subnet outbound restriction.
> 2. `system` subnet can accept any traffic to and from the `user-*` subnets.
> 3. `user-*` subnets can accept any traffic to/from the system subnet,
>    but not between user subnets. These subnets may also access the
>    matching `data-*` subnet.

## Disk storage

Disk encryption at rest is provided by Microsoft out of the box. By default,
however, these encryption keys come from Microsoft. For increased security
of protected data, it is recommended that
[Customer Managed Keys](https://docs.microsoft.com/en-us/azure/storage/common/customer-managed-keys-overview)
be utilized. *Note, however, that not all Azure services support customer
managed keys.*

The use of Customer Managed Keys is recommended by the Center
for Internet Security (CIS) for storing sensitive data, as well
as the ITSG-33 controls SC-28 (PROTECTION OF INFORMATION AT REST)
and SC-12 (CRYPTOGRAPHIC KEY ESTABLISHMENT AND MANAGEMENT).

> **Recommendation AZ-STR-01**: Customer Managed Keys be utlized where possible
> within the Azure environment.

> **Recommendation AZ-STR-02**: The Azure Key Vault key for storage encryption
> be backed by a Hardware Security Module (HSM).
>
> There are two options:
>
> - Shared HSM: $1.28/key/month + $0.039/10000 transactions
> - Single-tenant HSM: $6.208/hour (~$4,600/month)
>
> Automatic key rotation should be configured for storage encryption keys,
> assuming this is available for all services. If it is not, then manual
> rotation should occur every 90 days (3 months).

## Azure Kubernetes Service (AKS)

With the foundational Azure configuration and network configuration,
we can now build the Azure Kubernetes Service (AKS) cluster for the
Advanced Analytics Workspaces environment.

All the functionality discussed above was designed with the understand
of what features are supported and not supported by the Azure Kubernetes
Service. Therefore, the following recommendations are based on the base
Azure concepts presented above.

> **Recommendation AZ-AKS-01**: The AAW Kubernetes cluster would be constructed
> with the following node pools:
>
> | Pool                    | VM Type            | Subnet              | Purpose                                                  |
> |-------------------------|--------------------|---------------------|----------------------------------------------------------|
> | `system`                | `Standard_D16s_v3` | `system`            | Running system components of the AAW environment         |
> | `monitoring`            | `Standard_E16s_v3` | `system`            | Logging and monitoring components of the AAW environment |
> | `storage`               | `Standard_D32s_v3` | `system`            | Storage components of the AAW environment                |
> | `user-unclassified`     | `Standard_D16s_v3` | `user-unclassified` | Unclassified user workloads                              |
> | `user-gpu-unclassified` | `Standard_NC6s_v3` | `user-unclassified` | Unclassified user GPU workloads                          |
> | `user-protected-b`      | `Standard_D16s_v3` | `user-protected-b`  | Protected B user workloads                               |
> | `user-gpu-protected-b`  | `Standard_NC6s_v3` | `user-protected-b`  | Protected B user GPU workloads                           |

> The cluster be constructed with the following features enabled:
>
> * [User defined routing](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype)
> * [Azure Active Directory authentication](https://docs.microsoft.com/en-us/azure/aks/managed-aad)
> * [Control Plane Managed Identity](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity#bring-your-own-control-plane-mi)
> * [Customer Managed Keys for disk encryption](https://docs.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys)

The best practices in protecting the AKS cluster is to secure access to the
control plane of Kubernetes. The best way to do this is by running a fully
private AKS cluster (using Private Link). Unfortunately, due to reliance
on external tooling such as GitHub Actions, this is not possible. Therefore,
the next best option is to apply firewalls protecting the control plane.

> **Recommendation AZ-AKS-02**: Apply control plane firewall which
> restricts access to Statistics Canada networks only.

> **Recommendation AZ-AKS-03**: To manage the Kubernetes cluster from
> GitHub Actions, a self-hosted runner should be deployed and utilized
> so that access to the API server can be kept limited.

## Infrastructure as Code

> **Recommendation KUBE-CAC-01**: All Azure resources deployed to the
> Advanced Analytics Workspaces environment be managed via
> Terraform, a Infrastructure as Code tool.
>
> The only resource exempt from this requirement is the Subscription.
