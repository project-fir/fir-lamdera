import os
import requests

import json
import typing as t
from pathlib import Path
from pydantic import BaseModel
from urllib.parse import urljoin


class _Config(BaseModel):
    es_cloud_hostname: str
    api_key: str
    destination_engine: str
    source_dir: Path
    # default to side-effect free, opt-out by setting value to False
    dry_run: bool = True
    # max chunk_size is 100, there are also data size limitations but not applicable to us here
    chunk_size: int = 100


class ApprovalRatingDoc(BaseModel):
    """
Example of one record, obtained with this (saved locally, JSON format): see `procedure.md` for details

  "Barack Obama": {
    "Mon Jan 16 2017 03:00:00 GMT-0500 (Eastern Standard Time)": {
      "Start Date": "2017-01-16T08:00:00.000Z",
      "End Date": "2017-01-19T08:00:00.000Z",
      "Approving": 59,
      "Disapproving": 37,
      "Unsure/NoData": 4
    },
    """
    president_name: str
    start_date: str  # which timestamp format?
    end_date: str  # which timestamp?
    approving: float
    disapproving: float
    unsure_no_data: float


def chunker(seq, size):
    return (seq[pos:pos + size] for pos in range(0, len(seq), size))


def validate_file(path: str) -> t.Tuple[bool, t.Optional[t.List[ApprovalRatingDoc]]]:
    """
    Given a file pointing to presidential_approvals, scan for validation issues

    Returns:
        If every record in the file is valid, we return (True, <validated_data>)

        If there is one invalid record, we return (False, None). This means we're not tolerating
        partial reads, I don't want to bring in that complexity
    """
    data: t.List[ApprovalRatingDoc] = []

    print("attempting validation..")
    try:
        with open(path, 'r',  encoding="utf8") as fp:
            raw = json.load(fp)

        for pres_name, data_blob in raw.items():
            for _, blob in data_blob.items():
                # NB: We're doing some re-shaping here, another case we'd like to include in our import UI
                #    If we had the ability to add a row index to all the sheets, this would be a straight forward ** operator
                d = ApprovalRatingDoc(
                    president_name=pres_name,
                    start_date=blob["Start Date"],
                    end_date=blob["End Date"],
                    approving=blob["Approving"],
                    disapproving=blob["Disapproving"],
                    unsure_no_data=blob["Unsure/NoData"],
                )
                data.append(d)
    except Exception as ex:
        print(ex)
        return False, None

    print("validation succeeded")
    return True, data


def publish_to_es(validated_data: t.List[ApprovalRatingDoc], config: _Config):
    """
    Given validated data, publish document (in chunks) to the already created engine

    Note: For the time being, I'm doing schema checking with the ES-Cloud UI. I think that's a bit
    more practical while I develop the Elm UI for the same thing.

    Important limitations:
      Documents are sent via an array and are independently accepted and indexed, or rejected.
      A 200 response and an empty errors array denotes a successful index.
      If no id is provided, a unique id will be generated.
      A document is created each time content is received without an id - beware duplicates!
      A document will be updated - not created - if its id already exists within a document.
      If the Engine has not seen the field before, then it will create a new field of type text.
      Fields cannot be named: external_id, engine_id, highlight, or, and, not, any, all, none.
      There is a 100 document per request limit; each document must be less than 100kb.
      An indexing request may not exceed 10mb.

    Source: https://www.elastic.co/guide/en/app-search/7.14/documents.html
    """
    endpoint = f"/api/as/v1/engines/{config.destination_engine}/documents"
    url = urljoin(config.es_cloud_hostname, endpoint)

    for i, chunk in enumerate(chunker(validated_data, config.chunk_size)):
        print(
            f"processing chunk {i} of {len(validated_data) / config.chunk_size}...")
        payload = [c.dict() for c in chunk]
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {config.api_key}",
        }

        r = requests.post(
            url=url,
            json=payload,
            headers=headers,
        )

    print("Response:")
    print(r.text)


if __name__ == "__main__":
    config = _Config(
        es_cloud_hostname="https://fir-sandbox.ent.eastus2.azure.elastic-cloud.com",
        api_key=os.getenv("ELASTIC_CLOUD_API_KEY"),
        destination_engine="presidential-approval-ratings",
        source_dir=Path(Path.home(), "data/presidential_approval"),
        dry_run=False,
    )

    print(f"""
  Starting presidential approval rating pipeline into Elastic Search:
      {config.dict()}
  """)

    json_files = [f for f in os.listdir(config.source_dir)]
    for f in json_files:
        path = Path(config.source_dir, f)
        is_valid, validated_data = validate_file(path=path)

        if not config.dry_run:
            print(F"publishing to: {config.destination_engine}")
            publish_to_es(validated_data=validated_data, config=config)
        else:
            print(
                "This is a dry run, not actually doing anything")
