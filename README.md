# What's in Season

Data from [mangezquebec.com](http://www.mangezquebec.com/). Images from mangezquebec.com and the [Shutterstock API](https://developers.shutterstock.com/).

## Getting Started

    bundle
    createdb whatsinseason
    rake setup
    rake
    rackup

## Deployment

    heroku create
    heroku config:set SHUTTERSTOCK_CLIENT_ID=
    heroku config:set SHUTTERSTOCK_CLIENT_SECRET=
    git push heroku master

Copyright (c) 2015 James McKinney, released under the MIT license
