---
title: "ssh configuration"
---

# `ssh` tips & tricks
## Setting up simpler logins

It can be tedious to remember to type long login commands every time
when logging in via ssh to Hamilton. I therefore recommend
that you set up an ssh config file.

Additionally, you might also want to set up ssh keys for passwordless
login.

### The `ssh-config` configuration file

{{< tabs >}}
{{< tab "Mac/Linux" >}}
When you run it, `ssh` reads a configuration file at
`$HOME/.ssh/config`. This file
contains configuration commands that the ssh client applies. For full
details, see [the
documentation](https://linux.die.net/man/5/ssh_config).
{{< /tab >}}
{{< tab "Windows" >}}
When you run it, `ssh` reads a configuration file at
`C:\Users\yourusername\.ssh\config`. This file
contains configuration commands that the ssh client applies. For full
details, see [the
documentation](https://linux.die.net/man/5/ssh_config).
{{< /tab >}}
{{< /tabs >}}

We will add some configuration block to make it simpler to access
Hamilton. For Hamilton 7, you should add the block

```config
Host hamilton
  HostName hamilton.dur.ac.uk
  User <username>
```

while for Hamilton 8 you should use

```config
Host hamilton8
  HostName hamilton8.dur.ac.uk
  User <username>
```

`<username>` is a placeholder for your CIS username (four
characters followed by two digits).

Having done so, you can now write `ssh hamilton` and `ssh hamilton8`
instead of `ssh <username>@hamilton.dur.ac.uk` and `ssh
<username>@hamilton8.dur.ac.uk`, respectively.

### Passwordless login with ssh keys
This bit is somewhat more complicated to get right, so if you're happy
with the shortened login, you could just stop.

As well as permitting login with a password, ssh allows login via
public key authentication. To work, your local machine must have a
keypair, and any remote machine you wish to log in to must have the
public key.

A minimal sequence of instructions is to generate a keypair on
your local machine with

```
ssh-keygen -t rsa -b 4096 -C "YOUREMAIL@ADDRESS"
```

This will prompt you for a _passphrase_. **DO NOT LEAVE IT BLANK**,
since without a passphrase, anyone with the private key can log in as
you!

Next, you must copy the _public_ key to the server you wish to log in
to. You can do this (assuming you set up your ssh config as above) with
`ssh-copy-id hamilton` (for Hamilton 7) or `ssh-copy-id hamilton8` (for
Hamilton 8).

Now, when you log in, you will be prompted for the passphrase of the
private key before being asked for your password. This may not seem like
an advantage, but you can set up an ssh-agent that saves the passphrases
on your machine for the duration of a login session.

Getting the agent setup continues to be complicated, although possibly
your system just does it by magic. GitHub have a [useful
guide](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)
(ignore the github-specific bits). On Mac, [this stackexchange
question](https://apple.stackexchange.com/questions/48502/how-can-i-permanently-add-my-ssh-private-key-to-keychain-so-it-is-automatically)
has some tips.
