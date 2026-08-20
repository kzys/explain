# Mojo before Mojo

Swift's [first commit](https://github.com/swiftlang/swift/commit/afc81c1855b) was iconic:

> initial checkin, nothing much to see here.

The commit contained an empty `main()` function. Parser.cpp and Lexer.cpp were there, but both contained literally just `int X;`.

So, when I read that [Mojo is finally open-source](https://www.modular.com/blog/mojo-open-source), I dug into its commit history. Unfortunately, [the very first commit](https://github.com/modular/modular/commit/4e56b08b5c) we can see in the open-source repository is not dramatic. I believe some bits (such as GraphRT?) were filtered out here:

> [GraphRT] Plumb through a new -export-bef flag into graphrt-translate.
>
> The translation itself always errors out at the moment.  This patch is
> all the plumbing to allow it to build etc, and also sets up an LLVM.h
> for the Modular repository (largely adapted from CIRCT).

"CIRCT" is [Circuit IR Compilers and Tools](https://circt.llvm.org/), another LLVM project.

## LLCL

The next core component was [LLCL](https://github.com/modular/modular/commit/55c333f949):

> [LLCL/bef-executor] Start building out these two components.
>
> LLCL currently just has its Runtime god object and an allocator
> interface with a trivial implementation.  bef-executor just creates
> an instance of it.

The commit message mentions `bef-executor`, but it seems to have been redacted from the open-source repository.

What does "LLCL" stand for? A later commit explained that LLCL stood for [Low-level Concurrency Library](https://github.com/modular/modular/commit/a0f45ee89d). The commit also spelled out its design goals:

> LLCL/Runtime is designed as a low-level concurrency library for managing system
> resources on modern CPU systems.  It has many peers with similar functionality,
> e.g. Intel Thread Building Blocks, Apple Grand Central Dispatch and many others.

LLCL reminds me of Go's runtime, Rust's tokio and java.util.concurrent. Even if you don't write compilers (I don't), you've seen these problems before.

## KGEN

The next was [KGEN](https://github.com/modular/modular/commit/33cf822a03). Note that the PR number doesn't point to a PR in `modular/modular`. It probably points to their private repository:

> [KGEN] Add an initial cut at a kgen-opt tool with a simple kgen dialect. (#934)

Unlike LLCL, KGEN was tackling a code generation problem that was very specific to compilers:

> KGEN is very different than a typical machine learning "operator graph"
> interpreters.  Those frameworks typically have an opinionated set of operators
> for math, control flow, and often have an implicit "tensor" type that is passed
> between operators.  That level of representation is often (but not always)
> target/hardware independent.  While these abstractions can support "graph level
> optimizations", they doesn't typically expose buffers, accelerator details, and
> other minutiae that is required to get high performance from heterogenous
> accelerators.

I don't fully grasp the idea, to be honest.

Later commits added [TaskList.md](https://github.com/modular/modular/commit/38d18f9be3) and [DesignOverview.md](https://github.com/modular/modular/commit/fa745505cd) from Google Docs. The latter discussed whether to invent a new language:

> In the immediate term, we can start by building an embedded DSL in C++ (e.g. like Halide has) or Python - this provides a convenient way to get things off the ground, allowing us to develop other parts of the stack.  If/when we get to the point where this isn’t working well for us, we can decide what to do about it. Lazily evaluating this allows us to make the decision with more information and experience, particularly knowledge of the primary programming models we need to enable and what pain points need to be solved.
>
> If the negatives of inventing a new language are overwhelmed by the benefits (thus having proper business justification), then it will be no problem to bring up something simple quickly, and enable demos.  If the language is a big usability win, it could be useful to help us scale our team and allow us to move more quickly.  A language could be useful to engender excitement about what we’re doing (differentiating our work from other designs), as nothing causes more furor in the programming community and tech press than programming languages. :-)

## Lightning

Then that proposed new language became [Lightning](https://github.com/modular/modular/commit/cc6c476313), which was also called "Lit" in commit messages:

> [Lit] add some notes on Lightning language divergences from Python. (#3439)
>
> Still very much a WIP, but seems good to have.

It was described as a Python-ish language:

> Lightning is intended to evolve into a superset of Python, which adds
> first-class support for static types, "structs" with zero-cost abstraction
> features, and support for kgen-parameters and search.

## Mojo

Lightning (or Lit) was eventually renamed to [Mojo](https://github.com/modular/modular/commit/742d85258c):

> [Lit] [Mojo] Initial set of renames from lit to mojo (#10028)
>
> Just a first pass at renaming lit to mojo. This is not a complete set
> of changes, but it is a good start. I have not yet renamed the lit
> directory, but I will do that in a follow up commit. I also tried to
> ensure that the changes I made will work with both .lit and .mojo
> directories.

There must be more after the renaming, and of course after it went open source. Mojo's first commit was not really dramatic, likely because it was redacted. Still, I'm glad they kept the whole history intact -- the language had a past before it had a name.
