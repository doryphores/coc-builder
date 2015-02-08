Clash of Clans base builder
===========

A web app for experimenting with Clash of Clans base layouts.

## Warning

This app only runs in a browser with support for the new [GeometryUtils API](http://dev.w3.org/csswg/cssom-view/#the-geometryutils-interface). Currently this means Firefox 36+.

## To run locally

This app uses the [Jekyll](http://jekyllrb.com/) site generator.

You will need `ruby` and the `bundler` gem installed. Then clone this repo and run `bundle install` to install the required gems.

## To deploy to Github pages

Checkout the branch you wish to deploy (**not** `gh-pages`) and run `bundle exec rake`. The task will generate the site, commit the changes to the `gh-pages` branch and push to Github.
