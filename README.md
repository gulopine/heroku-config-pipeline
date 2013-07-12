# Heroku Config Pipeline

Heroku's [pipelines](https://devcenter.heroku.com/articles/labs-pipelines) offer
a convenient way to manage multiple environments, but by design, they only
manage your code slugs, not your add-ons or configuration environment. This
plugin allows you to use those same pipelines for your config values as well.

## Installation

First, install [heroku-pipeline](https://github.com/heroku/heroku-pipeline) and
activate a pipeline.

``` bash
$ heroku pipeline
Pipeline: example-stage ---> example-prod
```

Then, install this plugin:

``` bash
$ heroku plugins:install git@github.com:gulopine/heroku-config-pipeline.git
```

## Comparing environments

Like `pipeline:diff`, you can compare the configuration environments using
`config:diff`:

``` bash
$ heroku config:diff
Comparing example-stage to example-prod...4 config vars are different
+AWS_ACCESS_KEY_ID:     0123456789abcdef
+AWS_SECRET_ACCESS_KEY: fedcba9876543210
+DEBUG:                 True
-SECRET_KEY:            0123456789abcdef
+SECRET_KEY:            fedcba9876543210
```

Like `git diff`, each line with a plus sign is something that's present in your
current environment, while the minus sign is an entry that's present in the
one you're comparing against. This way, you can easily identify which entries
have been added, removed or changed at this stage in the pipeline.

## Promoting config values

You can also promote individual values from one app to the next in the pipeline
by using `config:promote`. Because you'll almost always have some values that
are truly unique to that environment, this won't promote your entire environment
by default. Instead, you can specify each config entry individually.

``` bash
$ heroku config:promote AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
Setting config vars and restarting example-prod... done, v123
AWS_ACCESS_KEY_ID:     0123456789abcdef
AWS_SECRET_ACCESS_KEY: fedcba9876543210
```
