# Using this project


## Contents
1.  [Architectural Recommendations](#architectural-recommendations)
2.  [Managing Persistence](#managing-persistence)
3.  [Making Configuration Updates](#making-configuration-updates)
4.  [Performance](performance)

## Architectural Recommendations

### Use an Orchestration tool
As with any containerized deployment, it is recommended to use a container orchestration engine. These tools relieve complexities of pushing configuration updates. 

## Managing Persistence
Persisting Data is one of the most common questions to arise when working with infrastructure that is meant to be ephemeral. To handle this within the Ping portfolio, certain features are built in to the product and guidelines are recommended to maintain flexibility for containers. These recommendations are dependent on the environment you deploy in to. 

## Making Configuration Updates
Pushing new configurations, or configuration changes should be seamless. To do this with PingDirectory instances: 


## Performance

Performance is highly dependent on a number of factors, so the goal of performance testing is to isola