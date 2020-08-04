# how to use the pingidentity/apache-jmeter image. 

The reason we build a jmeter image rather than use one provided by someone else is so we can include the tool scripts and flows that are common across all PingIdentity images.. namely, this means being able to provide the `.jmx` file to the image via remote server profile (i.e. stored on github). 