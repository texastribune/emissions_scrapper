# Emissions Scrapper

This software will scrap "Air Emission Event Report Database" [link](http://www11.tceq.texas.gov/oce/eer/index.cfm)

## Installation
To use it you will need **ruby 2.1.0** and **mongodb**.
    git clone [link]
    cd emissions_scrapper
    cp config/mongoid.yml.example config/mongoid.yml
    mkdir tmp
    bundle install

And you are good to go!

## Usage

To retrieve emission events just run:

    bin/scrapper download [from] [to]

**from** is the initial tracking number and YES! you guessed, **to** is the final one!

To scrap the info and stored into the database just:

    bin/scrapper scrap

And finally if you need a CSV file:

    bin/scrapper export [short|full]

## Development

Just add cool stuff.