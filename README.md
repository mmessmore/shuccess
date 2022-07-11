# Shuccess

I made a dumb unit/functional testing framework for shell.

## How to use

### Hooks

There are 4 hook functions you can add to:

1. **pre_run**: this is run before all testing begins
2. **post_run**: this is run after all testing is over
3. **pre_test**: this is run before every test
4. **post_test**: this is run after every test

`pre_test` and `post_test` are passed the name of the test function as the
first positional argument.  You can do stuff based off of that if you want.

### Writing tests

After the "ADD TESTS HERE" command, you can add the test functions you want.

Every function needs to be immediately preceded by a comment like
```bash
# test [number] [description]
```

For example:
```bash
# test 4 Ensure entity name in response
test_entity_name_positive() {
  res=$(curl http://example.com/api/foo | jq -r '.name')
  [ "$res" = "foo" ] && return 0
  return 1
}
```

The number indicates the order that the test functions are run in.
You can add additional comments above the "special" comment, but that
"special" comment is used to discover tests.

Test functions exiting 0 are considered success and you'll get a pretty green
message.  If they exit non-0, then they are considered a failure and you'll get
a mean red message.  Both include the function name and description.


### Verbosity Helper
There is a `verbose` convenience function that takes an integer as the first
argument and a message as the subsequent arguments.

If the number of `-v` arguments to the command is greater or equal to the
integer argument, then the message will be printed.  This can be useful for
debugging, etc.

### How it works

This abuses the crap out of `awk` to do the shell equivalent of reflection.
That allows it to discover metadata from the comments and the function names.

***DO NOT*** add a comment that matches `^# *test *[0-9]` anywhere other than
preceding a test function or super weird stuff will happen.

## Running

You can run `shuccess.sh -P` to print the list of tests with their numbers.

You can run `shuccess.sh 4` to just run test 4.

If you just run `shuccess.sh`, then all tests will be run.

### Usage

```
shuccess.sh
  A unit testing framework for shell.

USAGE
  shuccess.sh [-v] [TEST_NUM]
  shuccess.sh -P
  shuccess.sh -h

ARGUMENTS
  TEST_NUM    Optionally specify a specific test by number

OPTIONS
  -h           This friendly help message
  -P           Print all tests
  -v           Verbose, set more than once to be more verbose
```

## Why did I make this?

I was writing functional tests for a script as a script.  It was very
procedural.  I kinda missed testing frameworks like you would have with a real
programming language where you just define functions or whatever and it does
what it needs to.

I had some free time to make a thing that probably already exists better
somewhere else, just because it was an interesting problem to solve.

## TODO

I may or may not get around to doing these.

- [ ] Make this thing output a JUnit compatible report.
- [ ] Support having arbitrary `test*.sh` scripts in addition to functions

