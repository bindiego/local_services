# [Vega](http://vega.github.io/) on [Kibana](https://www.elastic.co/products/kibana)

在Kibana里使用vega，这里比如把我个人出行记录通过一个vega支持的图表展示出来

Ok, let's see what it looks like first :)

![](https://raw.githubusercontent.com/bindiego/local_services/develop/elastic/kibana_vega_sample/kibana_vega_travels.png)

We use composite aggregation to get the results

首先就是我们使用的是Elasticsearch的composite aggregation查询来获取数据。

```
GET activity/_search
{
  "profile": "true", 
	"size": 0,
	"aggs": {
  	"table": {
    	"composite": {
      	"size": 100,
      	"sources": [
        	{
          	"stk1": {
            	"terms": {"field": "travelled_from.keyword"}
          	}
        	},
        	{
          	"stk2": {
            	"terms": {"field": "travelled_to.keyword"}
          	}
        	}
      	]
    	}
  	}
	}
}
```

Here is sample data you add to the index

这里是一个数据案例

```
POST activity/_doc/
{
  "@timestamp": "2020-01-17T12:40:00Z+0800",
  "duration": 11,
  "type" : "travel",
  "travel" : "yes",
  "transportation" : "air",
  "travelled_from": "Vancouver",
  "travelled_to": "Beijing",
  "comments": "Retreat"
}
```

At the Kibana Visualization UI, we use [this](https://raw.githubusercontent.com/bindiego/local_services/develop/elastic/kibana_vega_sample/vega.json) configuration.

上面提供的连接，就是Kibana UI中vega这个可视化图的全部配置了，核心就是用到了上面的composite聚合查询。
