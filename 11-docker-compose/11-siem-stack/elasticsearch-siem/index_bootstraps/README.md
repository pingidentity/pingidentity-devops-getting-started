# Index Bootstraps

When you utilize ILM (INDEX LIFE CYCLE MANAGEMENT) within elastic search the indexes need to be bootstraped for the alias to be set. This is done for routing purposes. Without bootstraping the indexes, they are not set correctly and will not rollover, and will have other issues. You must bootstrap them for auto rollover.

