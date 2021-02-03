# Kubeflow

## Jupyter Notebooks

Jupyter Notebooks are the main component of the AAW environment that
is relied upon by users to perform their analysis processes. These
notebooks, while powerful, contain functionality that are directly
in violation of Protected B controls.

Therefore, for Jupyter Notebooks to be used with Protected B data:

> **Recommendation KF-NB-01**: The download functionality be disabled
> in the Jupyter Notebooks environment. If this functionality cannot
> be disabled, then Jupyter Notebooks must not be used with
> Protected B workloads.

> **Recommendation KF-NB-02**: The copy/paste functionality be disabled
> in the Jupyter Notebooks environment. If this functionality cannot
> be disabled, then Jupyter Notebooks must not be used with
> Protected B workloads.

To make a notebook Protected B capable, a "Configuration" option will
be added that applies the appropriate configuration for Protected B
workloads. This includes:

- Adding `data.statcan.gc.ca/classification` labels to PVCs and Pods

This may require some modification to the Jupyter Web app or Notebook
controller.

## Pipelines

Pipelines is a powerful component of Kubeflow for "building and
deploying portable, scalable, machine learning (ML) workflows based
on Docker Containers".

Unfortunately, due to the current design of pipelines, there is
no possibility to seperate Unclassified and Protected B pipelines,
even with the appropriate labelling in place on resources because
the final output and artifacts are stored in an uncontrolled
MinIO object store.

> **Recommendation KF-PL-01**: Kubeflow Pipelines be disabled
> for Protected B workloads, enforced by Gatekeeper.
