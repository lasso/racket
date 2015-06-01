# Racket - The noisy Rack MVC framework

[![Build Status](https://travis-ci.org/lasso/racket.svg?branch=master)](https://travis-ci.org/lasso/racket)&nbsp;&nbsp;&nbsp;&nbsp;[![codecov.io](https://codecov.io/github/lasso/racket/coverage.svg?branch=master)](https://codecov.io/github/lasso/racket?branch=master)


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
Probably not. At the moment it is good _enough_ for my needs, but I plan to add more features/make stuff faster
as I start porting more of my old apps from Ramaze.

## Where are the tests?
I am still working on them. At the moment the tests cover about 97 per cent of the code base, but that's just because I have been a bit lazy. A cool 100 per cent is the goal.

I am using [bacon](https://github.com/chneukirchen/bacon) and [rack-test](https://github.com/brynary/rack-test) for testing. Run the tests by typing `bacon spec/racket.rb`in the root directory. Code coverage reports are provided by [simplecov](https://rubygems.org/gems/simplecov). After the tests have run the an HTML report can be found in the `coverage` directory. Or you can just trust [Travis CI](https://travis-ci.org/lasso/racket) and [Codecov](https://codecov.io/github/lasso/racket) who run the tests automatically on each commit.

## Alright, I want to try using this stuff. Where are the docs?
Unfortunately there aren't any docs yet. The main reason is that most things are not finished yet, I am still
moving stuff around like crazy. There **will** be a wiki later and I also plan on documenting the code itself heavily
(using [Yard](http://yardoc.org/)).

## Why is the code licenced under the GNU Affero General Public License? I want a more liberal licence!
Because I think it is a Good Thing&trade; to share code. The
[GNU Affero General Public License licence](https://www.gnu.org/licenses/agpl.html) is very liberal unless you plan
on beeing egotistical. I you feel you cannot work with that, please choose
[something else](https://en.wikipedia.org/wiki/Comparison_of_web_application_frameworks#Ruby).
