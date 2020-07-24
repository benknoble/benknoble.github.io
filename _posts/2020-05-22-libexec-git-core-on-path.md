---
title: 'Programs invoked by git have libexec/git-core on $PATH'
tags: [ dotfiles, git, shell, vim, ]
category: [ Blog ]
---

I discover a strange edge-case in my usage of git and vim together.

[I posted very similar content on the git mailing list as well](https://public-inbox.org/git/CALnO6CDtGRRav8zK2GKi1oHTZWrHFTxZNmnOWu64-ab+oY3_Lw@mail.gmail.com/)

I noticed something odd today---I was working in vim and spawned a new terminal
with `:terminal`. My shell startup files, which use the location of the git
binary to reconstruct paths to things like
`etc/bash_completion.d/git-prompt.sh` and `contrib/git-jump`, suddenly choked.
The location of the git program was suddenly different than usual!

---

A simple scenario where this might occur is in the following zsh code:

```zsh
# zsh allows =cmd to expand to the path of the command, so echo =git is similar
# to which git or command -v git
path_to_git==git
# :h:h in an expansion is a lot like appending ../.. to go up two directories
path_to_git_jump="${git:h:h}/share/git-core/contrib/git-jump"
[[ -x "$path_to_git_jump"/git-jump ]] && path+=("$path_to_git_jump")
```

Here, I'm find the git executable location, moving up two directories, and then
descending into `share/git-core/contrib` to find the git-jump script and add it
to my path. This is somewhat more portable than assuming `git-jump` is always in
the same place, and more convenient than copying that script into my own
Dotfiles and managing updates for it.

---

After some debugging, I came to determine that this occurred, not because of
vim, but because vim was launched from a git-invoked process (in this case,
`contrib/git-jump/git-jump`). My own `git-ed` also suffers from this when
invoked as `git ed`---most external git commands do *not* have this issue when
run directly (e.g., `git-ed`).

The salient git code is [`setup_path()` in `exec-cmd.c`][1] and its call in
[`git.c`][2]. They appear to coordinate to prepend the `libexec` directory to
the environment variable `PATH`.  This causes the location of the `git` binary
to be (e.g.) `/usr/local/libexec/git-core/git`, and not (e.g.)
`/usr/local/bin/git`.

Because subprocesses inherit environment variables from their parents, my vim
process inherits the modifications to `PATH` from the above code. That means any
shell that vim starts inherits the same modification! The net
result is that if I run, say, `git jump grep foo` and then try to invoke
`:terminal` or `:shell`, my shell complains---the git binary path is so
different that it cannot properly find the `git-jump` script.

Unfortunately, this modification propagates to all child processes, as this
simple test-case demonstrates:

```sh
# printf '%s\n' '#!/bin/sh' "printenv PATH | tr : '\n' | grep git-core" > git-show-env
# chmod u+x git-show-env
# PATH=.:$PATH git show-env
/usr/local/Cellar/git/2.26.2/libexec/git-core
```

While it would be *nice* if git didn't modify `PATH` in such a way that it
affected all subprocesses (i.e., if it was somehow scoped to only processes that
need it), I suspect this is at best difficult and at worst highly-error prone or
likely to break things.

In the (possibly eternal) interim, I would like to share some vimscript that
"fixes" `$PATH` in vim when it detects this case. The easiest use is to drop the
code in your vimrc file (usually `~/.vim/vimrc` or `~/.vimrc`). I've tried to
keep it portable in terms of path separators and file paths, but I do not have a
Windows box to test on.

Actually, it's a little more aggressive than I suggested; it strips out *all*
`PATH` entries ending in `libexec/git-core,` not just the first. But I never
have `libexec/git-core` on my `PATH` anyway, so I'm not bothered by that. One
could modify this function to only check the first entry (the one git would have
prepended).

P.S. Does anyone know what the `libexec/git-core` equivalent is on Windows?
[This person][3] alludes to `libexec\git-core`, which I *think* is handled by my code.

P.P.S. If your vim is old and does not have `const`, you can use `let` instead.
You may need to change out the lambda `{_, d -> ... }` for a `v:val` string as
well.

[1]: https://github.com/git/git/blob/87680d32efb6d14f162e54ad3bda4e3d6c908559/exec-cmd.c#L304
[2]: https://github.com/git/git/blob/87680d32efb6d14f162e54ad3bda4e3d6c908559/git.c#L868
[3]: https://wilsonmar.github.io/git-custom-commands/

```vim
" When git starts up, it prepends it's libexec dir to PATH to allow it to find
" external commands.
"
" Thus, if vim is invoked via a git process (such as the contrib git-jump, my
" own git-ed, or any other usage of GIT_EDITOR/VISUAL/EDITOR in git commands, be
" they scripts or internals--with the exception of manually invoking the script
" yourself, without using git: sh .../git-jump), $PATH will contain something
" like libexec/git-core.
"
" We don't generally want it in vim's $PATH, though, as it is passed down to
" *all* subprocesses, including shells started with :terminal or :shell.
function s:fix_git_path() abort
  const slash = has('win32') ? '\' : '/'
  const git_core_base = printf('libexec%sgit-core', slash)
  " optimization: early return
  if $PATH !~# '.*'.git_core_base.'.*'
    return
  endif
  const path_sep = has('win32') ? ';' : ':'
  const path = split($PATH, path_sep)
  const path_sans_libexec_git_core = filter(path, {_, d -> d !~# '.*'.git_core_base})
  const new_path = join(path_sans_libexec_git_core, path_sep)
  let $PATH = new_path
endfunction

augroup fix_git_path
  autocmd!
  autocmd VimEnter * call s:fix_git_path()
augroup END
```
