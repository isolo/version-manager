# version-manager
versioning lib (with Git support) written in Ruby

## Information:
The gem purpose is to automate process of releasing a new version. It can be used with [semver](http://semver.org/).
There are three version components: major, minor and patch (MAJOR.MINOR.PATCH).
Major and minor versions should be updated from the master branch. Patch version should be updated from the release branch.
By default, release version has a format like: release-MAJOR.MINOR.
Also, a tag is being created alongside with a branch. It has a format like: MAJOR.MINOR.PATCH.

## Installation:
    gem install version-manager

## Usage:

### Bump a new version:
    manver make major
    manver make minor
    manver make patch

### Switch to the latest version:
    manver latest
