---
title: "Hamilton accounts"
---

# Access to Hamilton

For many of the exercises in the course, we will be using the
[Hamilton](https://www.dur.ac.uk/arc/hamilton/) supercomputer. If you do
not have an account on the machine, please apply for one by completing
the [registration
form](https://dur.unidesk.ac.uk/tas/public/ssp/content/detail/service?unid=420662860dae4dceb78e69c685621050)
on the Self Service Portal. More information on access requests is
available
[here](https://durhamuniversity.sharepoint.com/Sites/MyDigitalDurham/SitePages/ServicePage.aspx?Service=%22Hamilton%20-%20High%20Performance%20Computing%20(HPC)%22).

We'll be logging in a lot—please follow the [tips]({{< ref
configuration.md >}}) on how to configure `ssh` for swifter login.

# Hamilton quick start guide

This quick start guide is intended to get you up and running on the Hamilton 8
supercomputer, but it should not be considered a replacement for the
[official documentation](https://www.dur.ac.uk/arc/hamilton/)—please refer to it
for anything that you cannot find here.

## Logging in and transferring code
{{% hint info %}}
The dollar sign `$` represents the prompt and indicates that the
commands should be executed in the shell. You should not type this
character.
{{% /hint %}}

You can access Hamilton via `ssh`, with the command
```sh
$ ssh <username>@hamilton8.dur.ac.uk
```
where `<username>` is a placeholder for your CIS username (four
characters followed by two digits).

Once again, check out the [tips]({{< ref configuration.md
>}}) on how to configure `ssh` for swifter logins.

{{< hint warning >}}

If you are unable to log in to Hamilton, you should contact the [ARC
Platform Team](mailto:arc-rcp@durham.ac.uk), as they are the best placed
to sort things out.

{{< /hint >}}

Hamilton does not mount any of the Durham shared drives, and you have to
transfer any files you want to have on the machine manually. You can do
this in a number of way, but the use of the command line tool
[`scp`](https://linux.die.net/man/1/scp) is recommended. For example, if
you are on your local machine then the command
```sh
$ scp somefile.c USERNAME@hamilton8.dur.ac.uk:~
```
copies `somefile.c` from your local folder on your local machine to your
home directory `~` on Hamilton. The other option is to directly
download files when you are logged in. Some of the exercises in the
course will provide more details on how to do this.

## Compilation environment

As is common with supercomputers, there are many different compiler
versions available on Hamilton. These are managed with [environment
modules](https://modules.readthedocs.io/en/latest/) so that different
Hamilton users can control which compilers and tools they get.

In this course, we will use the GNU Compiler Collection (GCC). You will
have access to different versions depending on the version of Hamilton
you are using. The exercises will typically list what are modules you
need, if any. You can get access to the compiler by running

```sh
$ module load gcc/12.2
```

After that, you should get

```sh
$ gcc --version
gcc (GCC) 12.2.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```


## Running code

When you log in to the Hamilton system, you are on a "login" node. You
can use this to compile code and run some profile analysis programs, but
you **must not** use it for running your simulations. As with most
supercomputers, Hamilton consists of two parts.

1. login nodes (this is where we've been so far); and
2. compute nodes (this is where you want to run your code).

{{< manfig src="hamilton-nodes.svg"
    width="70%"
    caption="Schematic of Hamilton login and compute nodes" >}}

To run code on the compute nodes you need to submit a job to the
scheduler. This program takes care of allocating our work to the compute
nodes to maximise throughput for all users of the system. Hamilton uses
the
[Slurm](https://slurm.schedmd.com/documentation.html) scheduler.

To use the scheduler, you need to create a job script, which is a recipe
for Hamilton to run our code. A job script is a shell script containing
some magic comments that describe the environment you want to use to run
our code. The individual exercises contain some examples, as does the
[Hamilton
documentation](https://www.dur.ac.uk/arc/hamilton/usage/jobs/).

Here is a simple example for a serial job.

```bash
#!/bin/bash
#SBATCH --job-name="myjob"
#SBATCH -o myjob.%A.out
#SBATCH -e myjob.%A.err
#SBATCH -p test
#SBATCH -t 00:05:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=128
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<YOUREMAIL>@durham.ac.uk

source /etc/profile.d/modules.sh

module load gcc/12.2.0

./myexecutable
```

Some things to note. This is a shell script executed with bash (as
indicated by the shebang-line). Lines beginning with `#SBATCH` are
parsed by the job submission command `sbatch` and are used to provide
options to it. Here we selected a particular queue `test` and said
the job will run for a maximum of five minutes (`-t 00:05:00`). The
other options control the size of the job and where output is sent.
Run `man sbatch` on the Hamilton login node to see details of these
flags.

{{< hint "info" >}}

A typical reason your job might fail is because you did not load the
necessary modules, so don't forget to do so!

This is also useful for reproducibility, since it helps you record
exactly the software you used to produce the results.

{{< /hint >}}

The comments are followed by the commands that will be run _on the
compute node_. If you want to load any modules, you should first source
the script `/etc/profile.d/modules.sh` to make the `module` command
available. You should then load the modules you used to compile the
executable that will be run (`./myexecutable` in the example job script
above). You can load additional modules, for example, those that will
give you access to profiling commands. The last line of the script
should be the sequence of commands to run our code (here
just the one command `myexecutable`).

Having saved this job script, as `myjob.slurm` say, you submit it with
`sbatch`

```sh
$ sbatch myjob.slurm
```

This job is now submitted to the queue and will run when a slot is
available.

You can see what jobs you currently have in the queue with

```sh
$ squeue -u $USER
```
