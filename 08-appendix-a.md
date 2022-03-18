# Appendix A: Non-security recommendations

During the investigation into securing the AAW environment, additional
non-security related recommendations have been identified. These
are not included as official recommendations as they are out of scope,
but they are included below for informational purposes:

## Profile automation

Today, the AAW environment performs a series of configuration upon
the creation of new user profiles. In continuing with these efforts,
and with the addition of tooling provided by this proposal,
that the AAW team:

> **Recommendation APNDXA-PROF-01**: Split the custom StatCan
> profile-configurator into multiple, small controllers. Each
> controller would be responsible for one configuration item.

> **Recommendation APNDXA-PROF-02**: The custom controllers
> additionally apply configuration that:
>
> 1. Create a local docker repository in Artifactory
> 2. Generate image pull credentials for Artifactory,
>    applicable only to the namespace
> 3. Configure the Gitea instances for each profile, while managing
>    keys for accessing Postgres.

## Azure Kubernetes Service (AKS)

> **APNDXA-AKS-01**: Longer term, as more heavy analytical-based workloads
> are run in the AAW environment, it is recommended that the DAaaS team investigate
> the use of [spot node pools](https://docs.microsoft.com/en-us/azure/aks/spot-node-pool).
>
> If determined to be a viable option, then the following node pools would be
> added to the AAW AKS cluster:
>
> | Pool                | VM Type            | Subnet              | Purpose                          |
> | ------------------- | ------------------ | ------------------- | -------------------------------- |
> | `spot-unclassified` | `Standard_D16s_v3` | `user-unclassified` | Unclassified user spot workloads |
> | `spot-protected-b`  | `Standard_D16s_v3` | `user-protected-b`  | Protected B user spot workloads  |
