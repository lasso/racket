# Racket - The noisy Rack MVC framework

[![Build Status](https://travis-ci.org/lasso/racket.svg?branch=master)](https://travis-ci.org/lasso/racket)&nbsp;&nbsp;&nbsp;&nbsp;[![Code Climate](https://codeclimate.com/github/lasso/racket/badges/gpa.svg)](https://codeclimate.com/github/lasso/racket)&nbsp;&nbsp;&nbsp;&nbsp;[![codecov.io](https://codecov.io/github/lasso/racket/coverage.svg?branch=master)](https://codecov.io/github/lasso/racket?branch=master)&nbsp;&nbsp;&nbsp;&nbsp;[![Gem Version](https://badge.fury.io/rb/racket-mvc.svg)](http://badge.fury.io/rb/racket-mvc)

## Say what?
Yes. It is yet another framework built on rack. Using MVC. Doing silly stuff while you look the other way.

## Why? I though there were a gazillion frameworks that did the same thing already...
You are correct. There are _lots_ of Rack frameworks out there. This one does not pretend to do anything special
that you could not get from any of them.

## So, I have to ask again. Why did you create this monstrosity?
Well, when my web host suddenly started insisting on using Phusion Passenger on all of their servers
I needed to replace my old [Ramaze](http://ramaze.net/) setup without to much hassle. I tried several
other Rack framework, but none of them seemed capable of replacing my apps without some major rewrites.

## So you just though writing a whole new framework would be easier than using Rails?
Yes. Writing Rack frameworks is easy! And since I am able to decide exactly what features I want I don't
need to adopt to a large ecosystem of concepts I do not like.

## So, is it any good?
Let us just say it is good _enough_ for my needs at the moment. I plan to add more features/make stuff faster
whenever I am finished porting most of my old apps from Ramaze.

## Where are the tests?
Have a look in the `spec` directory. The code base have tests covering 100 per cent of the code and I am planning on keeping it that way. At the moment the code is tested on the following platforms (using [Travis CI](https://travis-ci.org/)):

- 1.9.3
- 2.0.0
- 2.1.7
- 2.2.3
- jruby-19mode
- jruby-head
- rbx-2

I am using [bacon](https://github.com/chneukirchen/bacon) and [rack-test](https://github.com/brynary/rack-test) for testing. Run the tests by typing `rake test`in the root directory. Code coverage reports are provided by [simplecov](https://rubygems.org/gems/simplecov). After the tests have run the an HTML report can be found in the `coverage` directory.

If you are not interested in running the tests yourself you could have a look at the test status at [Travis CI](https://travis-ci.org/lasso/racket) and the code coverage at [Codecov](https://codecov.io/github/lasso/racket). Their stats get updated on every commit.

## Alright, I want to try using this stuff. Where are the docs?
At the moment there is not much documentation available, but I have started working on the [wiki](https://github.com/lasso/racket/wiki).

The code itself is documented using [Yard](http://yardoc.org/). The docs are not generated automatically, you need to run `rake doc` in the root directory to generate them. After running the rake task the documentation will be available in the `doc` directory.

## Why is the code licenced under the GNU Affero General Public License? I want a more liberal licence!
Because I think it is a Good Thing&trade; to share code. The
[GNU Affero General Public License licence](https://www.gnu.org/licenses/agpl.html) is very liberal unless you plan
on beeing egotistical. I you feel you cannot work with that, please choose
[something else](https://en.wikipedia.org/wiki/Comparison_of_web_application_frameworks#Ruby).
