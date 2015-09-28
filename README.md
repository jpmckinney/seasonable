# Seasonable

Displays fruits and vegetables in season in Quebec.

Data from [mangezquebec.com](http://www.mangezquebec.com/). Images from mangezquebec.com and the [Shutterstock API](https://developers.shutterstock.com/).

## Getting Started

    bundle
    createdb seasonable
    rake setup
    SHUTTERSTOCK_CLIENT_ID=... SHUTTERSTOCK_CLIENT_SECRET=... rake
    rackup

## Deployment

    heroku apps:create
    heroku config:set SHUTTERSTOCK_CLIENT_ID=...
    heroku config:set SHUTTERSTOCK_CLIENT_SECRET=...
    git push heroku master
    heroku run rake setup
    heroku run rake
    heroku open

Copyright (c) 2015 James McKinney, released under the MIT license
