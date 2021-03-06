Metior on Heroku
================

This web application provides a simple way to generate statistics for projects
hosted on GitHub. Just enter the user and project name and hit "Generate
stats!".

It is built using Rails, Metior and Heroku's application platform.

## Environment

The application is deployed on Heroku's Cedar stack. It is currently running
with only one web dyno and without any workers. That's why you may experience
long loading times when viewing large repositories like `ruby/ruby` or
`mxcl/homebrew`.

There's a simple caching mechanism that will reuse already generated reports if
they're not older than 60 minutes. It uses locally stored files so it wouldn't
work for an isolated worker. But I think that's fine for the beginning.

## Future plans

* Generate more reports
* Background processing and smarter caching
* Tighter integration into GitHub, e.g. for listing repositories or analyzing
  private repositories

## Contribute

Metior and this Rails app are open-source. Therefore you are free to help
improving them. There are several ways of contributing to Metior's development:

* Build apps using it and spread the word.
* Report problems and request features using the [issue tracker][2].
* Write patches yourself to fix bugs and implement new functionality.
* Create a Metior fork on [GitHub][1] and start hacking. Extra points for using
  feature branches and GitHub's pull requests.

## About the name

The latin word "metior" means "I measure". That's just what Metior does –
measuring source code histories.

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

* Sebastian Staudt – koraktor(at)gmail.com

## See Also

* [Metior's homepage][1]
* [Metior's GitHub project page][2]

Follow Metior on Twitter [@metiorstats](http://twitter.com/metiorstats).

 [1]: http://koraktor.de/metior
 [2]: http://github.com/koraktor/metior
