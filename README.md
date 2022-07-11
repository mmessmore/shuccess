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

### Tests as scripts
You can also write separate scripts in the same directory if you would prefer.
They need to be executable (`chmod +x [file]`) and have a filename of `test_*`.
The second line (after the shebang) should have a comment in the same format as
before the functions.

You only need the `libexec` directory if you're writing your tests as separate
scripts and want the `verbose` command to have variable verbosity.  It's in
your path if the `libexec` directory exists.

Here's an example:

```bash
#!/bin/bash
# test 5 Positive dummy: this should always succeed

echo "Intentional script success"
verbose 1 "This will show with one or more -v options passed"

exit 0
```

### How it works

This abuses the crap out of `awk` to do the shell equivalent of reflection.
That allows it to discover metadata from the comments and the function names.

***DO NOT*** add a comment that matches `^# *test *[0-9]` anywhere other than
preceding a test function or super weird stuff will happen.

### Usage

```
shuccess
  A self-contained unit testing framework for shell.

  Tests may be added inline or as scripts in this directory. See examples for
  formatting requirements.

USAGE
  shuccess [-v] [-t NAME] [-r PATH] [-x PATH] [TEST_NUM]
  shuccess -P
  shuccess -h

ARGUMENTS
  TEST_NUM    Optionally specify a specific test by number

OPTIONS
  -c PATH      Output CSV report file to PATH
  -h           This friendly help message
  -j PATH      Output JUnit formatted output to PATH
  -P           Print all tests
  -t NAME      Testsuite (and "class") name for reporting (Default: Shuccess)
  -v           Verbose, set more than once to be more verbose

EXAMPLES
  # Show all tests that would be run and their number
  ./shuccess -P

  # Run with a testsuite name of "Camaro" and output CSV and JUnit XML
  ./shuccess -t "myapp" -c report.csv -j ./build/test-results/junit.xml

  # Run only test number 10 (handy for testing tests)
  ./shuccess 10
```

## Output

This will always display output per-test as it runs with pretty colors, and a
summary at the end.

You can specify the `-c` option for a CSV summary file.  It's specific to this
script, so maybe of limited use.

You can specify the `-j` option for a JUnit formatted XML report that could be
used by your CICD tooling, etc.  It contains all the required fields, but isn't
fully featured.

Both are gross, because they're hand-crafted output vs serialized data.  But I
can't do "proper" serialization without requiring a bunch of dependencies and I
wanted this to only require `bash`.

## Why did I make this?

I was writing functional tests for a script as a script.  It was very
procedural.  I kinda missed testing frameworks like you would have with a real
programming language where you just define functions or whatever and it does
what it needs to.

I had some free time to make a thing that probably already exists better
somewhere else, just because it was an interesting problem to solve.

## Probably Better Options

While I was in the middle of this I found out there are some options because I
was originally going to call it "shunit" and, well, yeah.

It's a lot more of a framework and I wanted something that *could* be just 1
script. I'm probably a little more opinionated on comments and such to do my
fake shell reflection, but yeah.

### Shunit2

[shunit2](https://github.com/akesterson/shunit) seems to be pretty active and
has a lot of features like assertions.  I'm just using return values for
success/failure, and assume 1 test per "assertion."  It's pretty heavy, but
kinda needs to be to do all that it does.

### Shunit

[shunit](https://github.com/akesterson/shunit) is closer to what this is, but
doesn't seem to be as popular as Shunit2.  It looks to be more in between what
Shunit2 is and what I'm doing.
