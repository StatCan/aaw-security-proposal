---
title: Securing Advanced Analytics Workspaces
subtitle: Enabling Protected B Workloads
author:
- Zachary Seguin
fontsize: 10pt
mainfont: Arial
geometry: margin=0.75in
header-includes: |
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyhead[L]{Securing Advanced Analytics Workspaces}
    \fancyhead[R]{UNCLASSIFIED / NON-CLASSIFIÉ}
---

\begin{center}UNCLASSIFIED / NON-CLASSIFIÉ\end{center}

\begin{center}\textbf{THIS DOCUMENT IS A WORK IN PROGRESS}\end{center}

\newpage

# Introduction

## Background

The Advanced Analytics Workspaces (AAW) was launched in response to the
COVID-19 pandemic which caused a shift in work environment for
Statistics Canada employees. AAW was tasked with providing an unclassified
compute environment to allow for data scientists to perform analysis
work using a public cloud compute environment without requiring access
to Statistics Canada networks and  issued devices.

Statistics Canada is now interested in expanding the environment to
include Protected B data. This requires modification to the environment
to support the necessary isolation and exfiltration protections.

The platform was built as a collaboration between:

- Cloud Workload and Migration Division
- Data Analytics as a Service Division
- Data Science Division

## Technology

The Advanced Analytics Workspaces is constructed of many tools. Its base is
built on Kubernetes, Cloud Native Computing Foundation (CNCF) tooling, and Kubeflow.

The platform is made up of many different open- source software components.
In addition, some custom components have also been developed to provide desired
functionality.

Everything is running with an Azure Kubernetes Service (AKS) cluster.
Kubernetes is an extensible orchestration system and is a platform for
building platforms.

Components of the platform include, generally, components which either
provide functionality to end users or components which ensure the
security of the platform. This proposal will focus on the following
components of Kubernetes and platform components to provide an isolated
Protected B base compute environment:

- Kubernetes Network Policies
- Istio Service Mesh
- Gatekeeper policies
- Fluentd / Elasticsearch

Further, this proposal will discuss securing the Kubeflow component to provide
users with the appropriate environment for running Protected B data analysis:

- Jupyter Notebooks
- Remote Desktop
- Kubeflow Pipelines

> This proposal attempts to strike a balance between security requirements
> and user freedom.

This proposal was created by Zachary Seguin, with the assistance of
William Hearn, Justin Bertrand, Brendan Gadd, Andrew Scribner,
and Blair Drummond.

Any questions should be directed to [zachary.seguin@canada.ca](mailto:zachary.seguin@canada.ca).
