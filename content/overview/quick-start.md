---
layout: overview
header: dark
footer: dark
title: Get Started
description: Get started with Deepstack pipelines. Build your first RAG application! 
weight: 2
toc: true
aliases: [get-started]
---

Deepstack is an open-source Python framework that helps developers build LLM-powered custom applications. In March 2024, we released Deepstack 2.0, a significant update. For more information on Deepstack 2.0, you can also read the [announcement post](https://deepstack.khulnasoft.com/blog/deepstack-2-release).

## Installation

Use [pip](https://github.com/pypa/pip) to install Deepstack:

```bash
pip install deepstack-ai
```

For more details, refer to our documentation.

{{< button url="https://docs.deepstack.khulnasoft.com/docs/installation" text="Docs: Installation" color="green">}}

## Ask Questions to a Webpage

This is a very simple pipeline that can answer questions about the contents of a webpage. It uses GPT-3.5-Turbo with the `OpenAIGenerator`.

Run the following **Quickstart** or the equivalent **Corresponding Pipeline** below. See the pipeline visualized in **Pipeline Graph**.

{{< tabs totalTabs="3">}}

{{< tab tabName="Quickstart: Ready-Made Template" >}}
First, install Deepstack:
```bash
pip install deepstack-ai
```

```python
import os
from deepstack import Pipeline, PredefinedPipeline

os.environ["OPENAI_API_KEY"] = "Your OpenAI API Key"

pipeline = Pipeline.from_template(PredefinedPipeline.CHAT_WITH_WEBSITE)
result = pipeline.run({
    "fetcher": {"urls": ["https://deepstack.khulnasoft.com/overview/quick-start"]},
    "prompt": {"query": "Which components do I need for a RAG pipeline?"}}
)
print(result["llm"]["replies"][0])
```
{{< /tab  >}}

{{< tab tabName="Corresponding Pipeline"  >}}
First, install Deepstack:
```bash
pip install deepstack-ai
```

```python
import os

from deepstack import Pipeline
from deepstack.components.fetchers import LinkContentFetcher
from deepstack.components.converters import HTMLToDocument
from deepstack.components.builders import PromptBuilder
from deepstack.components.generators import OpenAIGenerator

os.environ["OPENAI_API_KEY"] = "Your OpenAI API Key"

fetcher = LinkContentFetcher()
converter = HTMLToDocument()
prompt_template = """
According to the contents of this website:
{% for document in documents %}
  {{document.content}}
{% endfor %}
Answer the given question: {{query}}
Answer:
"""
prompt_builder = PromptBuilder(template=prompt_template)
llm = OpenAIGenerator()

pipeline = Pipeline()
pipeline.add_component("fetcher", fetcher)
pipeline.add_component("converter", converter)
pipeline.add_component("prompt", prompt_builder)
pipeline.add_component("llm", llm)

pipeline.connect("fetcher.streams", "converter.sources")
pipeline.connect("converter.documents", "prompt.documents")
pipeline.connect("prompt.prompt", "llm.prompt")

result = pipeline.run({"fetcher": {"urls": ["https://deepstack.khulnasoft.com/overview/quick-start"]},
              "prompt": {"query": "Which components do I need for a RAG pipeline?"}})

print(result["llm"]["replies"][0])
```
{{< /tab  >}}

{{< tab tabName="Pipeline Graph"  >}}
<div class="row" style="display:flex">
  <div class="column" style="margin:15px auto" >
    <img src="/images/chat_with_web.png" width="300" quality="70"/>
  </div>
</div>
{{< /tab  >}}

{{< /tabs >}}

## Build Your First RAG Pipeline

To build modern search pipelines with LLMs, you need two things: powerful components and an easy way to put them together. The Deepstack pipeline is built for this purpose and enables you to design and scale your interactions with LLMs. Learn how to create pipelines [here](https://docs.deepstack.khulnasoft.com/docs/creating-pipelines).

By connecting three components, a [Retriever](https://docs.deepstack.khulnasoft.com/docs/retrievers), a [PromptBuilder](https://docs.deepstack.khulnasoft.com/docs/promptbuilder) and a [Generator](https://docs.deepstack.khulnasoft.com/docs/generators), you can build your first Retrieval Augmented Generation (RAG) pipeline with Deepstack.

Try out how Deepstack answers questions about the given documents using the **RAG** approach 👇

{{< tabs totalTabs="3">}}

{{< tab tabName="Quickstart: Ready-Made Template"  >}}
First, install Deepstack and the [Chroma integration](https://deepstack.khulnasoft.com/integrations/chroma-documentstore) (we will use it as our document store):
```bash
pip install deepstack-ai chroma-deepstack
```

```python
import os

from deepstack import Pipeline, PredefinedPipeline
import urllib.request

os.environ["OPENAI_API_KEY"] = "Your OpenAI API Key"
urllib.request.urlretrieve("https://www.gutenberg.org/cache/epub/7785/pg7785.txt", "davinci.txt")  

indexing_pipeline =  Pipeline.from_template(PredefinedPipeline.INDEXING)
indexing_pipeline.run(data={"sources": ["davinci.txt"]})

rag_pipeline =  Pipeline.from_template(PredefinedPipeline.RAG)

query = "How old was he when he died?"
result = rag_pipeline.run(data={"prompt_builder": {"query":query}, "text_embedder": {"text": query}})
print(result["llm"]["replies"][0])
```
{{< /tab  >}}

{{< tab tabName="Corresponding Pipeline"  >}}
First, install Deepstack and the [Chroma integration](https://deepstack.khulnasoft.com/integrations/chroma-documentstore) (we will use it as our document store):
```bash
pip install deepstack-ai chroma-deepstack
```
```python
import os

from deepstack import Pipeline
from deepstack_integrations.document_stores.chroma import ChromaDocumentStore
from deepstack.components.converters import TextFileToDocument
from deepstack.components.preprocessors import DocumentCleaner, DocumentSplitter
from deepstack.components.embedders import OpenAIDocumentEmbedder, OpenAITextEmbedder
from deepstack.components.writers import DocumentWriter

from deepstack_integrations.components.retrievers.chroma import ChromaEmbeddingRetriever
from deepstack.components.builders import PromptBuilder
from deepstack.components.generators import OpenAIGenerator
import urllib.request

os.environ["OPENAI_API_KEY"] = "Your OpenAI API Key"
urllib.request.urlretrieve("https://www.gutenberg.org/cache/epub/7785/pg7785.txt", "davinci.txt")  

document_store = ChromaDocumentStore(persist_path=".")

text_file_converter = TextFileToDocument()
cleaner = DocumentCleaner()
splitter = DocumentSplitter()
embedder = OpenAIDocumentEmbedder()
writer = DocumentWriter(document_store)

indexing_pipeline = Pipeline()
indexing_pipeline.add_component("converter", text_file_converter)
indexing_pipeline.add_component("cleaner", cleaner)
indexing_pipeline.add_component("splitter", splitter)
indexing_pipeline.add_component("embedder", embedder)
indexing_pipeline.add_component("writer", writer)

indexing_pipeline.connect("converter.documents", "cleaner.documents")
indexing_pipeline.connect("cleaner.documents", "splitter.documents")
indexing_pipeline.connect("splitter.documents", "embedder.documents")
indexing_pipeline.connect("embedder.documents", "writer.documents")
indexing_pipeline.run(data={"sources": ["davinci.txt"]})

text_embedder = OpenAITextEmbedder()
retriever = ChromaEmbeddingRetriever(document_store)
template = """Given these documents, answer the question.
              Documents:
              {% for doc in documents %}
                  {{ doc.content }}
              {% endfor %}
              Question: {{query}}
              Answer:"""
prompt_builder = PromptBuilder(template=template)
llm = OpenAIGenerator()

rag_pipeline = Pipeline()
rag_pipeline.add_component("text_embedder", text_embedder)
rag_pipeline.add_component("retriever", retriever)
rag_pipeline.add_component("prompt_builder", prompt_builder)
rag_pipeline.add_component("llm", llm)

rag_pipeline.connect("text_embedder.embedding", "retriever.query_embedding")
rag_pipeline.connect("retriever.documents", "prompt_builder.documents")
rag_pipeline.connect("prompt_builder", "llm")

query = "How old was he when he died?"
result = rag_pipeline.run(data={"prompt_builder": {"query":query}, "text_embedder": {"text": query}})
print(result["llm"]["replies"][0])
```
{{< /tab  >}}

{{< tab tabName="Pipeline Graph"  >}}
<div class="row" style="display:flex">
  <div class="column" style="margin:15px auto" >
    <p>Indexing Pipeline</p>
    <img src="/images/indexing.png" width="300" quality="70"/>
  </div>
  <div class="column" style="margin:15px auto" >
    <p>RAG Pipeline</p>
    <img src="/images/rag.png" width="300" quality="70"/>
  </div>
</div>
{{< /tab  >}}

{{< /tabs >}}

For a hands-on guide on how to build your first RAG Pipeline with Deepstack 2.0, see our tutorial.

{{< button url="https://deepstack.khulnasoft.com/tutorials/27_first_rag_pipeline" text="Tutorial: Creating a RAG Pipeline" color="green">}}