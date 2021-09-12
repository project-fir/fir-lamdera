import os
import requests

import json
import typing as t
from pathlib import Path
from pydantic import BaseModel
from urllib.parse import urljoin


"""
Goal here is to populate ES with BS data that is:
 * simple to fetch more of
 * isn't too messy but not too clean either
 * fun

Also, experimenting with style. I'm using closures in Python where I'd use classes / methods in the past
Hypothesis: Python is cool if paired with type-hints & only using classes for nouns
"""


class ChatLog(BaseModel):
    """
Example of one record, obtained with this (saved locally, JSON format): https://www.youtube.com/watch?v=6g9erT2-tGE
  {
    "channel_id": "451874858",
    "content_id": "1139565287",
    "content_offset_seconds": 840.892,
    "content_type": "video",
    "created_at": "2021-09-05T06:22:57.592Z",
    "updated_at": "2021-09-05T06:22:57.592Z",
    "video_offset_link": "https://www.twitch.tv/videos/1139565287?t=00h14m00s",
    "commenter_display_name": "CarpePax",
    "commenter_id": "451874858",
    "commenter_name": "carpepax",
    "commenter_type": "user",
    "commenter_bio": null,
    "commenter_created_at": "2019-08-01T00:23:22.404651Z",
    "commenter_updated_at": "2021-09-08T06:10:19.082984Z",
    "commenter_logo": "https://static-cdn.jtvnw.net/jtv_user_pictures/1be80f26-d470-4123-b0eb-a65f9a170b9c-profile_image-300x300.png",
    "message_body": "I want one of those guitars.",
    "message_fragments": [
      {
        "text": "I want one of those guitars."
      }
    ],
    "message_is_action": false,
    "message_user_badges": [
      {
        "_id": "broadcaster",
        "version": "1"
      },
      {
        "_id": "subscriber",
        "version": "12"
      },
      {
        "_id": "sub-gifter",
        "version": "50"
      }
    ],
    "message_user_color": "#FF0E6C",
    "message_user_notice_params": {}
  }
    """
    channel_id: str
    content_id: str
    content_offset_seconds: float
    content_type: str

    # TODO: this is the original format: "2021-09-05T06:14:12.79Z"
    #       what's the elm-friendliest way, I really think breaking into POSIX parts is powerful
    created_at: str
    updated_at: str
    # TODO: pydantic url validation?? example
    video_offset_link: str
    commenter_display_name: str
    commenter_id: str
    commenter_name: str
    commenter_type: str
    commenter_bio: t.Optional[str]
    commenter_created_at: str
    commenter_updated_at: str
    message_body: str

    message_is_action: bool
    message_user_badges: t.Optional[t.List[t.Dict[str, str]]]
    # omitted fields (not sure what they do / if I'd have use for them)
    # commenter_logo": "https://static-cdn.jtvnw.net/jtv_user_pictures/2f565a97-fa34-4a9a-8b7c-444f7d604196-profile_image-300x300.jpg",
    # message_user_color": "#8A2BE2",
    # message_user_notice_param: {}

    # it appears message_fragments isn't always present, going with message_body
    # message_fragments: t.Optional[t.List[t.Dict[str, str]]]


def validate_file(path: str) -> t.Tuple[bool, t.Optional[t.List[ChatLog]]]:
    """
    Given a file pointing to twitch_vod logs, validate each record against Pydantic validation

    Returns:
        If every record in the file is valid, we return (True, <validated_data>)

        If there is one invalid record, we return (False, None). This means we're not tolerating
        partial reads, I don't want to bring in that complexity

    """
    data: t.List[ChatLog] = []

    try:
        with open(path, 'r',  encoding="utf8") as fp:
            raw = json.load(fp)

        for blob in raw:
            log = ChatLog(**blob)
            data.append(log)
    except Exception as ex:
        print(ex)
        return False, None

    return True, data


def publish_to_es(validated_data: t.List[ChatLog], es_host: str, api_key: str, index="twitch_vod_logs"):
    """
    Given validated chat logs, create an index for them to go in, and place


    Note: feeling lazy, going with dynamic mappings, might be worth looking into static mappings
    """
    def create_index():
        url = urljoin(es_host, index)
        r = requests.put(url)
        print(r.text)

    def post_data():
        # TODO: Not sure what the limit is for payload size (or if there is one), batching logic probably belongs here..
        index_industruction: t.Dict = {
            "index": {
                "_index": index,
            },
        }

        index_instructions = [json.dumps(index_industruction)
                              for _ in range(0, len(validated_data))]
        zipped = [j for i in zip(
            index_instructions, validated_data) for j in i]

        print(zipped)
        payload = '\n'.join(zipped)

        print("payload:")
        print(payload)

        url = urljoin(es_host, "_bulk")
        r = requests.post(
            url,
            data=payload,
            headers={
                "Content-Type": "application/x-ndjson"
                "Authorization: ApiKey $ECE_API_KEY"
            },
        )
        print("Response:")
        print(r.text)

    create_index()
    post_data()


if __name__ == "__main__":
    DATA_DIR: Path = Path(Path.home(), "data/twitch_vod_scraper")
    # ES_HOST = "http://elastic-search:9200"  # container name, depcrecated - experimenting with hosted solution.
    API_KEY = os.getenv("EC_API_KEY")
    ES_HOST = "https://api.elastic-cloud.com/api/v1/"
    DRY_RUN = True

    print(f"""
  Starting Twitch VOD pipeline into Elastic Search:
      source: valid files in {DATA_DIR}
      dest: Elastic Search index at {ES_HOST}
  """)

    json_files = [f for f in os.listdir(DATA_DIR)]
    for f in json_files:
        path = Path(DATA_DIR, f)
        is_valid, validated_data = validate_file(path=path)

        if not DRY_RUN:
            print(F"publishing to {ES_HOST}")
            publish_to_es(validated_data=validated_data,
                          es_host=ES_HOST, api_key=API_KEY)
        else:
            print("This is a dry run, not actually doing anything.")
            print(f"api_key={API_KEY}")
