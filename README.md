# TechXchange 2025 - Lab 3640 - Docling
Lab material for the Docling workshop at TechXchange 2025

> [!NOTE]
> Join us at IBM TechXchange: [Deep Dive into Docling with the Core Development Team [3640]](https://reg.tools.ibm.com/flow/ibm/techxchange25/sessioncatalog/page/sessioncatalog/session/1752897821138001SxCw)


## 1. (lab only) Setup the lab environment

> [!CAUTION]
> This step is designed to bootstrap the fresh lab VMs. It customizes some global system setting, so it is highly discouraged to run it outside of the lab environment.

```sh
curl -L ibm.biz/tx25-docling-setup | bash -
```

Steps included in the script

0. Clone this repo
1. Disk setup
2. System configuration (ssh, etc)
3. Install dependencies
4. Prepare the lab content

## 2. Launch the lab

This lab will use:

1. [Docling](https://github.com/docling-project/docling)
2. [LiteLLM](https://github.com/BerriAI/litellm) connecting to watsonx.ai
3. [Llama Stack](https://github.com/llamastack/llama-stack)
4. [Jupyter Lab](https://jupyter.org/)

The script below will make sure to launch all the required components with the correct setup:

```sh
bash start.sh
```
