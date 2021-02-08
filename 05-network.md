# Network

The next largest attack surface is the network. Controlling network access
is fundamental to preventing the exfiltration of protected data.

Within the protected workloads running in AAW, all network activity
will be **deny-by-default**. Specific exemptions will be made
for accessing authorized storage environments and systems, with
each whitelisted service undergoing an assessment for its security
posture with regards to data exfiltration.

**Relation with Azure controls**: The AAW environment is relying
on defense-in-depth, so there are multiple levels of network
controls to restrict unauthorized network connectivity. Additionally,
the Azure controls cannot restrict access to specific services within
the cluster whereas the Kubernetes-level security controls can.

Finally, it is also important that all network activity be encrypted
using the Istio service mesh available in the Statistics Canada
Cloud Native Platform.

## Network policies

The primary mechanism for restricting network activity will be via Kubernetes
Network Policies. Network policies are implemented in the Azure Kubernetes
environment via the Linux iptables firewall on each node.

The default deny rule that will block all ingress and egress traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: pb-deny-by-default
  namespace: $NAMESPACE
spec:
  podSelector:
    matchLabels:
      data.statcan.gc.ca/classification: protected-b
  policyTypes:
  - Ingress
  - Egress
```

> **Recommendation NET-POL-01**: The above network policy strategy be approved.

## In-transit encryption

Any service which is made available to Protected B workloads must be placed
on the Istio Service Mesh, which provides automatic TLS encryption for all
connectivity. Istio's TLS implementation is mutual TLS, therefore
both the client and the server verify each other's identity.

> **Recommendation NET-TR-01**: Istio be used for inter-service traffic
> of Protected B workloads, providing mutual TLS encryption.

## External services

Protected B workloads should not connect directly to any external service.

> **Recommendation NET-ES-01**: Requests should be mediated
> through a service running in the AAW Kubernetes cluster, where possible.
> If not possible, then the service is to allow-listed on the firewall,
> since the firewall is deny-by-default. For protected workloads,
> these exceptions should be limited.

### Packages

Artifactory provides a package-proxy, which will provide the necessary
mediation between Protected B workloads and the remote repositories.
Artifactory is already utilized within the Statistics Canada main
cloud environment, so there is operational knowledge of the system.

Package sources should be limited due to the potential risk they can introduce.

> *NOTE*: This will require a paid Artifactory license.

Alternatively, installation of packages is not permitted. Only packages
available in the compiled Docker images would be made available in
the environment.

> **Recommendation NET-ES-02**: Packages be provided through an Artifactory
> instance running in the AAW environment.

> **Recommendation NET-ES-03**: X-Ray should be installed alongside Artifactory
> to provide for CVE scanning of packages being imported into the environment.

### Source code

Access to a source code system was identified during discussions
of the AAW environment.

A source code system available to both unclassified and Protected B
workloads introduces some complications from a security posture,
and in particular how to prevent data exfiltration from the environment.

Therefore, there are three proposals on how to implement a source
code system in AAW:

> **Recommendation NET-ES-03**: For source code,
>
> 1. Continue to use external source code systems for unclassified workloads.
>    This is permitted via TBS policy:
>
>    > 6.1: Departments are to enable open access to the Internet for GC
>    > electronic networks and devices, including GC and external Web 2.0
>    > tools and services, to authorized individuals, as per Section 6.1.3
>    > of the Policy on Acceptable Network and Device Use (PANDU).
>    >
>    > — https://www.tbs-sct.gc.ca/pol/doc-eng.aspx?id=32588#cha5
>
>    and launch an internal-only GitLab instance accessible
>    only to Protected B workloads.
>
> 2. Launch a GitLab instance in the AAW environment which is
>    available to all workloads. Workloads running at the
>    Protected B level are granted only HEAD / GET requests
>    to the GitLab instance (to prevent data exfiltration).
>    POST requests to specificly authorized endpoints,
>    such as for authorization, will be allowed.
>
> 3. Two seperate GitLab instances be launched in the AAW
>    environment, 1 for unclassified and 1 for Protected B.
>    This is the least recommended solution due to the
>    maintenance overhead.
>
> **DAaaS should identify the best solution based on the
> needs of its users, and therefore this proposal
> does not specify a specific solution.**
