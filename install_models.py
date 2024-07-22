import urllib.request
import os
import json

redownload = False

with open("models.json", "r") as f:
    downloads = json.load(f)

for destination, url in downloads.items():
    if redownload or not os.path.exists(destination):
        print(f"Downloading {destination}")
        directory = "/".join(destination.split("/")[:-1])
        os.makedirs(directory, exist_ok=True)
        urllib.request.urlretrieve(url, destination)
