#!/usr/bin/python

# Author: Ryan Ivis -- Ping Identity
# Pull Down Tor Nodes / AlienVault Feeds and convert to YAML for Logstash Enrichment
# This simple py Script downloads enrichment files and converts them to a Logstash format for enriching logs.

import urllib2, re
import requests

def writeYAML_TOR(url, enrichmentFilePath):
        torNodes = requests.get(url)
        rawContent = torNodes.text
        lineContent = rawContent.splitlines()

        if lineContent:
                yamlFile = open(enrichmentFilePath, 'w+')
                for line in lineContent:
                        if line.startswith("ExitAddress"):
                                splitLine = line.split(" ")
                                yamlFile.write("\"" + splitLine[1] + "\": \"YES\"" + "\n")
                yamlFile.close()

def writeYAML_AV(url, enrichmentFilePath):
        yamlFile = open(enrichmentFilePath, 'w')
        html = urllib2.urlopen(url)
        for line in html.readlines():
                line = re.sub('\\r|\\n','',line)
                newLine=line.split(' ', 1)[0]
                yamlFile.write("\"" + newLine + "\": \"YES\"" + "\n")
        yamlFile.close()


#Start Script #GRAB 2 FEEDS AND CONVERT TO YAML FOR LOGSTASH
torFeedURL = "https://check.torproject.org/exit-addresses"
alienvaultFeedURL = "https://reputation.alienvault.com/reputation.generic"

enrichmentFilePath_TOR = "/usr/share/elasticsearch/enrichment/TorNodes.yml"
enrichmentFilePath_AV = "/usr/share/elasticsearch/enrichment/AlienVaultIP.yml"

writeYAML_TOR(torFeedURL, enrichmentFilePath_TOR)
writeYAML_AV(alienvaultFeedURL, enrichmentFilePath_AV)

print("Enrichment pull complete.")