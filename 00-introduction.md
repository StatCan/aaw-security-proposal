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

The Advanced Analytics Workspaces is constructed of many tools. Its base
is built on Kubernetes, Cloud Native Computing Foundation (CNCF) tooling,
and Kubeflow.

More details of the platform available on Statistics Canada DAaaS
GitHub page (https://github.com/StatCan/daaas).
