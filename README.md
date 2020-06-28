# Dog API example

A simple script for downloading lists of images for specified dog breeds from [Dog API](https://dog.ceo/dog-api/documentation).

## Usage

Specific dog breeds are passed to the script as an array of arguments. Mispelled or nonexisting breed names will get ignored. The input is case insensitive.

    $ ./doggos.rb dachshund retriever

This will result in two CSV files (dachshund.csv and retriever.csv) plus a JSON file (updated_at.json) with each of the CSV files' creation timestamps.

The download and CSV-dump of each specified breed is run asynchronously, each breed spawning a new thread. The default thread pool size is 5 and can be changed by setting `POOL_SIZE` environment variable.

    $ POOL_SIZE=3 ./doggos.rb hound labrador maltese shiba samoyed
