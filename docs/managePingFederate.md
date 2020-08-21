# PingFederate Deployment Strategies

_This document aims to describe different approaches and considerations when deploying PingFederate containers in general devops environments._ 

PingFederate deployments typically require the _most_ consideration amonst Ping Identity products because the nature of a federation service is neither truly stateful or stateless. As such, we will discuss multiple strategies that organizations use based on their environment, goals and available resources. When determining which pattern aligns best for your team, consider the path to "devops best practices" an evolution that looks similar to:

<!-- graph of complexity vs devops alignment -->