import os
import requests

import json
import typing as t

from pathlib import Path
from pydantic import BaseModel
from urllib.parse import urljoin


class _Config(BaseModel):
    es_host: str
    # api_key: str
    destination_index: str
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

    """
    endpoint = f"/{config.destination_index}"
    url = urljoin(config.es_host, endpoint)

    # step 1: create index
    r = requests.put(url)
    if not r.ok:
        raise Exception(f"error: {r.text}")

    # step 2: iterate through 1-1
    #         Eventually this will get slow, the _bulk API looks straight forward but will take some dev work to get going
    #         A bigger problem here is we don't have id's for this sort of dataset. i think this will bite us in the form of accidental duplication, eventually.
    for i, vd in enumerate(validated_data, config.chunk_size):
        print(
            f"processing datum {i} of {len(validated_data)}")

        endpoint = f"/{config.destination_index}/doc"
        url = urljoin(config.es_host, endpoint)

        r = requests.post(
            url=url,
            json=vd.dict(),
        )

        if not r.ok:
            raise Exception(f"error: {r.text}")


if __name__ == "__main__":
    config = _Config(
        es_host="http://34.121.52.200:9200/",
        destination_index="presidential-approval-ratings-dev",
        # destination_index="presidential-approval-ratings",
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
            print(F"publishing to: {config.destination_index}")
            publish_to_es(validated_data=validated_data, config=config)
        else:
            print(
                "This is a dry run, not actually doing anything")
