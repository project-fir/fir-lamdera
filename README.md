## Fir

Check out the [demo](https://fir-lamdera.lamdera.app/)

Ideas:
 * During development of the twitch_vod pipeline, I stumbled upon this. I'm starting to see an idea emerge where Lamdera can be used to manage metadata https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html

References:

 * Dashboard: https://fir-sandbox.ent.eastus2.azure.elastic-cloud.com/ent/select
 * Elastic cloud API (Dev-ops stuff): https://www.elastic.co/guide/en/cloud/current/ec-restful-api.html
 * Elastic App Search API (The variant of ES cloud this app is using): https://www.elastic.co/guide/en/app-search/current/index.html
 * Guide on document indexing: https://www.elastic.co/guide/en/app-search/7.14/indexing-documents-guide.html
  

Environment variables:
The Python scripts in this repo assume the environment variable `ELASTIC_CLOUD_API_KEY` is set


Radar:
 * Entity relation diagram in Elm: https://github.com/azimuttapp/azimutt


Features on the docket:
 * regex pre-validation of input data, UI based - ran into issues with ES cloud validator
 * simple nesting / un-nesting, UI based - ran into issues with Slides exporter not supporting row-indices, which would've solved this problem, see `presidential_approval_pipeline.py` for an example (the nested `for` loop)
