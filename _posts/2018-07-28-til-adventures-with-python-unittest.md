---
title: Adventures with Python unittest
tags: [ til, infra, intern ]
category: Work
---

Some good, some bad, some ugly, as with all tests.

## Today I Learned

Since this is a summary of a week's worth of learning, I've left it 'til now to
write and publish.

1. About test-running scripts
1. The difference between `tearDown` and `cleanup`
1. How to use `tempfile` to create entire mock projects
1. How to use `pdb`

There's quite a bit, so let's dive in. First, we'll talk shop, then tests, then
tools.

### Run, tests, run !

I've written a fair few `run_tests` scripts over the course of my projects, but
I'm mentioning this one today because it nicely complements the overall theme of
python's `unittest` module.

I've been using it as my TDD impetus whilst working on `cake`, a neat
build-artifact cache I'm developing at my internship. `unittest` has it's
quirks, but it gets the job done (mostly) and avoids external dependencies.
Normally, they aren't such a bad thing, but for ease of integration I wanted
this code to run without any extra setup. So, `python2.7` and `unittest` it was.

Over the course of writing tests, the need quickly arises for a 'run tests
NOW' button. In `vim`, of course, we can take care of this with macros or
mappings, but what about in the shell? _Entrez_: scripts.

I'll even give you the entirety of it.

```python
#! /usr/bin/env python
import unittest
import sys

import tests


def main():
    args = sys.argv
    verbosity = 1
    if '-v' in args or '--verbose' in args:
        verbosity = 2
    elif '-q' in args or '--quiet' in args:
        verbosity = 0

    suite = tests.suite()

    runner = unittest.TextTestRunner(verbosity=verbosity)
    runner.run(suite)


if __name__ == '__main__':
    main()
```

Yep, that simple. Sure, the verbosity checks are a little redundant looking, and
could possibly be solved with proper data structures. But this is a little
script, and that feature is (a) completely inconsequential and (b) fits neatly
across a few lines. I'm not worried about it.

Literally the entire script could fit in 4 lines if I felt like it, minus the
argument handling.

The one piece of magic is the line `suite = tests.suite()`. And I'm going to
show you how it works.

```python
# tests/__init__.py
def suite():
    import unittest
    import tests.recipe
    import tests.meta
    import tests.pantry
    import tests.chefs_make
    import tests.oven

    loader = unittest.TestLoader()
    loadmodule = loader.loadTestsFromModule
    suite = unittest.TestSuite()

    suite.addTests(loadmodule(tests.recipe))
    suite.addTests(loadmodule(tests.meta))
    suite.addTests(loadmodule(tests.pantry))
    suite.addTests(loadmodule(tests.chefs_make))
    suite.addTests(loadmodule(tests.oven))
    return suite
```

Simply import all the modules you need, and load 'em in a suite. It's
done in my `__init__.py` to make it *very* easy: at the interpreter, one
`import` and `unittest` can run the suite. In my eventual `setup.py`, it will be
just as easy.

So there, auto-test button.

## Clean Up, Clean Up, Everybody Do Your Share

Thought you were never going to hear that again, didn't you?

`cake` works with files and directories across several locations. The cache has
to live somewhere, there's a project and build location, things get copied
around, the whole works. Not unlike `git`, which inspired it's model (more on
that later if I get permission to open-source the project--otherwise, tough
luck).

So you can imagine, then, that I might be doing some setup and cleanup during my
testing. The precise mechanism I'm using is the `tempfile` module, which does
exactly what you think it does. I'll get to how in a moment, but note that it
doesn't clean up after itself in the case of temporary _directories_. That
burden is on me, which is fine. `tempfile` will never remove something I'm in
the middle of using (even if I accidentally might).

Ok, so, setup and cleanup are a pretty standard part of test suites, right?
Well, not exactly. They come from the JUnit-style tests, upon which `unittest`
is based. Other frameworks use things like fixtures and function annotations,
but we don't get the yummy goodness of that here. Hell, I can't even mock the
filesystem easily, so I am forced to use disk operations extensively in testing.
Which makes me think about efficiency in my code to avoid the disk. Which is
good.

... I'm getting a little off track. Setup. Right. In python's `unittest`, you
can define `setUp` and `tearDown` methods on a `TestCase`. Setup is run before
each test, tear down afterwards.

Mostly.

See, if `setUp` fails for any reason, `tearDown` won't run. You can yell at me
about poor tests later, but my `setUp` method needed to invoked methods on the
unit under test in order to pre-populate the cache. I didn't have to do it that
way, but I did, and I'm not arguing about it now since it works.

Anyways, that fails sometimes. So I ended up with temporary directories getting
created and not removed; the deletion code was in the `tearDown` method.

A google search and help doc later, I knew the answer. Turns out, 'cleanups' run
no matter what. Perfect.

I present the trimmed down solution.

```python
class TestCache(unittest.TestCase):

    def __init__(self, methodname='runTest'):
        super(TestCache, self).__init__(methodname)
        # this is a clean up, since it must run even if setUp fails
        self.addCleanup(self.remove_temp)

    def setUp(self):
        # create a 'project' with files in it
        self.project = tempfile.mkdtemp()
        out_dir = join(self.project, 'output')
        os.mkdir(out_dir)
        for fname in ['art1', 'art2a', 'art2b', art_tree]:
            fullname = join(out_dir, fname)
            dirname = os.path.dirname(fullname)
            if dirname and not exists(dirname):
                os.mkdir(dirname)
            open(fullname, 'a').close()
        # configure the cache
        self.cache_dir = tempfile.mkdtemp()
        self.conf = Configuration(self.cache_dir, out_dir, 'make all', [
                    Target('one', ['src1'], ['art1']),
                    Target('two', ['src2a', 'src2b'], ['art2a', 'art2b']),
                    Target('tree', ['tree'], [art_tree])
                    ])
        self.cache = cake.pantry.Cache(self.conf)
        # we do this here because we it's common setup between all the tests,
        # even though it also assumes add is working correctly
        self.cache.add(artifact='art1', commit='123')
        self.cache.add(artifact=art_tree, commit='123')
        self.cache.add(artifact='art2b', commit='123')
        self.cache.add(artifact='art1', commit='456', ancestor='123')
        self.cache.add(artifact=art_tree, commit='456', ancestor='123')
        self.cache.add(artifact='art2a', commit='789', ancestor='456')

    def remove_temp(self):
        for tmp in [self.project, self.cache_dir]:
            if tmp:
                shutil.rmtree(tmp)

    def test_things(self):
        # .... blah blah blah
```

### Tempfile

Ok, I was going to write about it, but it's listed up there in the code and I'm
about at 1000 words here, so forgive my laziness.

### PDB, or, Debugging Python

`import pdb ; pdb.set_trace()`

That's all.

Or, well, not all. But that is the only line you need to place in python code to
start the debugger. It has all the usual commands, which you can read about
using help (`?` in the provided debugger REPL). You can also evaluate python
code, just be careful; if the debugger thinks it's a debug command, you'll need
the `!` prefix.

Finally, a piece of advice. `pdb` can be customized with a `pdbrc` file. Google
it. There's examples everywhere, and some of them are quite helpful. But the one
you really need to know is `n;;l`, which is "execute next command, then list the
surrounding code."

That way you don't get lost.
