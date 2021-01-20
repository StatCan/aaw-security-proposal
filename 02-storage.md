# Storage

Data is the largest asset and attack surface of the storing Protected B data
within the Advanced Analytics Workspaces. The AAW environment consists
currently of two main types of storage:

*	Disk storage (attached to one pod at a time)
*	MinIO object storage
	* Private bucket (accessible only to the project)
	*	Shared bucket (readable by all users)

Additionally, data is obtained from the following sources:

* MinIO object storage
* External data source available from the Internet

Access to data will be more restricted from protected workloads.

## Disk storage

Access to disk storage will be restricted based on the classification of the
disk and the classification of the pod it is being connected to. The following
table describes the disk classification, disk mode and pod classification, and
whether the combination is permitted or denied:

| Disk Classification | Disk Mode  | Pod Classification | Result    |
|---------------------|------------|--------------------|-----------|
| Unclassified        | Read only  | Unclassified       | Permitted |
| Unclassified        | Read/write | Unclassified       | Permitted |
| Unclassified        | Read only  | Protected B        | Permitted |
| Unclassified        | Read/write | Protected B        | Denied    |
| Protected B         | Read only  | Unclassified       | Denied    |
| Protected B         | Read/write | Unclassified       | Denied    |
| Protected B         | Read only  | Protected B        | Permitted |
| Protected B         | Read/write | Protected B        | Permitted |

Disk policies will be enforced by policy in Gatekeeper and the
Open Policy Agent.

## Object storage

A separate Protected B MinIO instance will be created for protected workloads.
This MinIO instance will operate similar to the existing MinIO instances,
except it will not be available outside of protected workloads
(no web interface).

Restricted access to MinIO storage will be implemented
using *Network Policies*.

### One-way synchronization with unclassified MinIO instance

To facilitate fetching data from the internet, a one-way synchronization from
the unclassified Standard MinIO instance will be performed. A write-only bucket
on the Standard MinIO instance will be mirrored to a read-only bucket on
the protected B MinIO instance.
