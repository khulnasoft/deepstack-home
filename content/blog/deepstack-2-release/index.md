---
layout: blog-post
title: 'Deepstack 2.0:  The Composable Open-Source LLM Framework'
description: Meet Deepstack 2.0, a more flexible, customizable LLM framework
featured_image: thumbnail.png
images: ["blog/deepstack-2-release/thumbnail.png"]
toc: True
date: 2024-03-11
last_updated: 2024-03-11
authors:
  - Massimiliano Pippi
  - Tuana Celik
tags: ["Deepstack 2.0", "Open Source"]
---


Today we are happy to announce [the stable release of Deepstack 2.0](/release-notes/2.0.0) - we’ve been working on this for a while, and some of you have already been [testing the beta since its first release in December 2023](/blog/introducing-deepstack-2-beta-and-advent).

Deepstack is an open-source Python framework for building production-ready LLM applications, with integrations to almost all major model providers and databases.

At its core, Deepstack 2.0 is a major rework of the previous version with a very clear goal in mind: making it possible to implement composable AI systems that are easy to use, customize, extend, optimise, evaluate and ultimately deploy to production.

We encourage you to start using Deepstack 2.0 as of today, whether you’ve been a Deepstack user before or not. You can get started by installing `deepstack-ai`, our new package for Deepstack 2.0

> ⭐️ **To get started:**
> 
> `pip install deepstack-ai` and follow the [get started](/overview/quick-start) instructions to build your first LLM app with just a few lines of code.

If you’re already using Deepstack 1.0 in production, don’t worry! If your applications depend on `farm-deepstack` and you’re not ready to migrate just yet, you don’t have to take any action: we will keep supporting Deepstack 1.0, releasing security updates and critical bug fixes, giving everybody enough time to migrate. In the coming weeks, we will also start sharing some migration guides to help you along the way.

## Why Deepstack 2.0?

[Deepstack was first officially released in 2020](https://github.com/khulnasoft/deepstack/releases/tag/0.2.1), in the good old days when the forefront of NLP was semantic search, retrieval, and extractive question-answering. During this time, we established the core of what makes Deepstack _Deepstack_: [Components](https://docs.deepstack.khulnasoft.com/docs/nodes_overview) and [Pipelines](https://docs.deepstack.khulnasoft.com/docs/pipelines). These allowed users to build end-to-end applications by combining their desired language models (embedding, extractive QA, ranking) with their database of choice.

The boom of LLMs in 2023 made two things clear:

1.  👍 The pipeline-component structure is a great abstraction for building composable LLM applications with many moving parts.
2.  👎 Deepstack 1.0 often assumed that you would be doing retrieval and extractive QA over a set of documents, imposing limitations and providing a developer experience far from ideal when building LLM applications.

So, we decided that the best thing we could do for Deepstack and our community was to rewrite the component and pipeline architecture to keep up with the fast-paced AI industry. While Deepstack 2.0 is a complete rewrite, the underlying principle of composing components into flexible pipelines remains the same.

With that, let’s take a look at the pillars of Deepstack 2.0:

-   Composable and customizable pipelines
-   A common interface for storing data
-   A clear path to production
-   Optimization and Evaluation for Retrieval Augmentation

## Composable and customizable Pipelines

Modern LLM applications [comprise many moving parts](https://bair.berkeley.edu/blog/2024/02/18/compound-ai-systems/): retrievers, rankers, LLMs, and many more such as entity extractors, summarizers, format converters and data cleaners. Each one of these ‘subtasks’ is a _component_ in Deepstack.

With the first version of Deepstack we proved that pipelines are a good abstraction for connecting all those moving parts, but some of the assumptions we made in Deepstack 1.0 dated back to a pre-LLM era and needed rethinking.

One important limitation in Deepstack 1.0 is that loops are not allowed, and the pipeline graph has to be acyclic. This makes it difficult to implement, for example, agents, which are often designed with a reasoning flow that loops until a task is resolved.

In Deepstack 2.0 the pipeline graph can have cycles. Combined with decision components (think about if-then-else clauses in the execution flow) and routers (components that direct the execution flow towards a specific subgraph depending on the input) this can be used to build sophisticated loops that model agentic behavior.

### Customizable Components

We believe that the design of an AI framework should meet the following requirements:

-   **Be technology agnostic:** Allow users the flexibility to decide what vendor or technology they want for _each_ of these components and make it easy to switch out any component for another.
-   **Be explicit:** Make it transparent as to how these components can “talk” to each other.
-   **Be flexible:** Make it possible to create custom components whenever custom behavior is desirable.
-   **Be extensible:** Provide a uniform and easy way for the community and third parties to build their own components and foster an open ecosystem around Deepstack.

All components in Deepstack 2.0 (including [Deepstack Integrations](https://docs.deepstack.khulnasoft.com/v2.0/docs/integrations)) are built with a common “component” interface. The principle is simple:

-   A component implements some logic in a method called `run`
-   The `run` method receives one or more input values
-   The `run` method returns one or more output values

Take [embedders](https://docs.deepstack.khulnasoft.com/v2.0/docs/embedders) as an example: these components expect text as input and create vector representations (embeddings) that they return as output. On the other hand, [retrievers](https://docs.deepstack.khulnasoft.com/v2.0/docs/retrievers) may need embeddings as input and return documents as output. When creating a new component, to decide what inputs and outputs it should have is part of the ideation process.

While there are many ready-made components built into Deepstack, we want to highlight that [building your own custom components](https://docs.deepstack.khulnasoft.com/v2.0/docs/custom-components) is also a core functionality of Deepstack 2.0.

> In fact, we’ve taken advantage of this ourselves. For example, you can [read about how to use the latest optimization techniques](https://deepstack.khulnasoft.com/blog/optimizing-retrieval-with-hyde) (like HyDE) in Deepstack pipelines with custom components.

### Sharing Custom Components

Since the release of Deepstack 2.0-Beta, we’ve seen the benefits of having a well-defined simple interface for components. We, our community, and third parties have already created many components, available as additional packages for you to install.

We share these on the [Deepstack Integrations](https://deepstack.khulnasoft.com/integrations) page, which has expanded to include all sorts of components over the last few months (with contributions from [Assembly AI](https://deepstack.khulnasoft.com/integrations/assemblyai), [Jina AI](https://deepstack.khulnasoft.com/integrations/jina), [mixedbread ai](https://deepstack.khulnasoft.com/integrations/mixedbread-ai) and more). We will continue to expand this page with new integrations and you can help us by creating a PR on [deepstack-integrations](https://github.com/khulnasoft/deepstack-integrations) if you’d like to share a component with the community. To learn more about integrations and how to share them, you can check out our [“Introduction to Integrations” documentation](https://docs.deepstack.khulnasoft.com/v2.0/docs/integrations).

## A common interface for storing data

Most NLP applications work on large amounts of data. A common design pattern is to connect your internal knowledge base to a Large Language Model (LLM) so that it can answer questions, summarize or translate documents, and extract specific information. For example, in retrieval-augment generative pipelines (RAG), you often use an LLM to answer questions about some data that was previously retrieved.

This data has to come from somewhere, and Deepstack 2.0 provides a common interface to access it in a consistent way, independently from where data comes from. This interface is called “Document Store”, and it’s implemented for many different storage services, to make data easily available from within Deepstack pipelines.

Today, we are releasing Deepstack 2.0 with a [large selection of database and vector store integrations](https://deepstack.khulnasoft.com/integrations?type=Document+Store). These include [Chroma](https://deepstack.khulnasoft.com/integrations/chroma-documentstore), [Weaviate](https://deepstack.khulnasoft.com/integrations/weaviate-document-store), [Pinecone](https://deepstack.khulnasoft.com/integrations/pinecone-document-store), [Qdrant](https://deepstack.khulnasoft.com/integrations/qdrant-document-store), [Elasticsearch](https://deepstack.khulnasoft.com/integrations/elasticsearch-document-store), [Open Search](https://deepstack.khulnasoft.com/integrations/opensearch-document-store), [pgvector](https://deepstack.khulnasoft.com/integrations/pgvector-documentstore), [MongoDB](https://deepstack.khulnasoft.com/integrations/mongodb), [AstraDB](https://deepstack.khulnasoft.com/integrations/astradb), [Neo4j](https://deepstack.khulnasoft.com/integrations/neo4j-document-store), [Marqo DB](https://deepstack.khulnasoft.com/integrations/marqo-document-store), and the list will keep growing. And if your storage service is not supported yet, or should you need a high degree of customization on top of an existing one, by following our [guide to creating custom document stores](https://docs.deepstack.khulnasoft.com/v2.0/docs/creating-custom-document-stores), you can connect your Deepstack pipelines to your data from pretty much any storage service.

## A clear path to production

The experience we got over the last couple of years, working on Deepstack 1.0 and interacting with its community, taught us two things:

1.  It’s essential for any AI application framework to be feature-complete and developer-friendly.
2.  It's only after the deployment phase that AI-based applications can truly make an impact.

While rewriting the framework from scratch, we took the opportunity to incorporate specific features that would simplify the deployment of Deepstack-based AI applications in a production-grade environment:

-   A customizable [logging system](https://docs.deepstack.khulnasoft.com/v2.0/docs/logging) that supports structured logging and tracing correlation out of the box.
-   [Code instrumentation collecting spans and traces](https://docs.deepstack.khulnasoft.com/v2.0/docs/tracing) in strategic points of the execution path, with support for Open Telemetry and Datadog already in place.

In addition, we decided to start a dedicated project to simplify deploying Deepstack pipelines behind a RESTful API: [Deephooks](https://docs.deepstack.khulnasoft.com/v2.0/docs/deephooks).

Deephooks is a client-server application that allows you to deploy Deepstack pipelines, serving them through HTTP endpoints dynamically spawned. Two foundational features of Deepstack 2.0 made this possible:

1.  [The ability to introspect a pipeline](https://docs.deepstack.khulnasoft.com/v2.0/reference/pipeline-api#pipelineinputs), determining its inputs and outputs at runtime. This means that every REST endpoint has well-defined, dynamically generated schemas for the request and response body, all depending on the specific pipeline structure.
2.  [A robust serialization mechanism](https://docs.deepstack.khulnasoft.com/v2.0/docs/serialization). This allows for the conversion of Deepstack pipelines from Python to a preferred data serialization format, and vice versa. The default format is YAML but Deepstack is designed to easily extend support for additional serialization formats.

## Optimization and Evaluation of Retrieval Augmentation

We’ve already been seeing the benefits of the new Deepstack design, with pipeline optimization and evaluation being good examples of how we’ve been leveraging Deepstack 2.0. How?:

-   It’s easier to extend the capabilities of Deepstack
-   It’s easy to implement new integrations

### Implementing the latest retrieval optimizations

Retrieval is a crucial step for successful RAG pipelines. And there’s been a lot of work to optimize this step. With Deepstack 2.0, we’ve been able to:

-   Implement Hypothetical Document Embeddings (HyDE) easily, and we’ve already published [a guide to HyDE](https://docs.deepstack.khulnasoft.com/v2.0/docs/hypothetical-document-embeddings-hyde) along with [an example walkthrough](https://deepstack.khulnasoft.com/blog/optimizing-retrieval-with-hyde)
-   Added an integration for [Optimum](https://deepstack.khulnasoft.com/integrations/optimum) embedders by Hugging Face

And we will be able to add more optimization techniques along the way!

### Evaluation

Deepstack 2.0 is being released with a few evaluation framework integrations in place:

-   [Ragas](https://deepstack.khulnasoft.com/integrations/ragas)
-   [DeepEval](https://deepstack.khulnasoft.com/integrations/deepeval)
-   [UpTrain](https://deepstack.khulnasoft.com/integrations/uptrain)

Along with a [guide to model-based evaluation](https://docs.deepstack.khulnasoft.com/v2.0/docs/model-based-evaluation).

## Start using Deepstack 2.0

Alongside Deepstack 2.0, today we are also releasing a whole set of new tutorials, documentation, resources and more to help you get started:

-   [Documentation](https://docs.deepstack.khulnasoft.com/docs): full technical documentation on all Deepstack concepts and components
-   [Tutorials](https://deepstack.khulnasoft.com/tutorials): step-by-step, runnable Colab notebooks. Start with our first 2.0 tutorial [“Creating Your First QA Pipeline with Retrieval-Augmentation”](https://deepstack.khulnasoft.com/tutorials/27_first_rag_pipeline)
-   [Cookbooks](https://github.com/khulnasoft/deepstack-cookbook): A collection of useful notebooks that showcase Deepstack in various scenarios, using a number of our integrations.

And, as always, keep an eye out on our [blog](https://deepstack.khulnasoft.com/blog) and [integrations](https://deepstack.khulnasoft.com/integrations) for updates and new content.

## Join the Community

Stay up-to-date with Deepstack:

-   [Discord](https://discord.com/invite/VBpFzsgRVF)
-   [Subscribe to our newsletter](https://landing.khulnasoft.com/deepstack-community-updates)
-   [Twitter](https://twitter.com/Deepstack_AI)
-   [GitHub](https://github.com/khulnasoft/deepstack)