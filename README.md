# CSE 134 Project 4: Pintos Threads

**Due: Check the assignment page on Canvas for the deadline.**

## Learning Objectives

1. Get comfortable extending PintOS.
2. Practice using synchronization primitives in PintOS.

## Requirements

Your submission must include:

1. **Design Document** (`docs/p01.md`) -- describes your key design decisions.
2. **Simple Shell** -- an interactive shell that runs when no command-line arguments are provided.
3. **Alarm Clock** -- a re-implementation of `timer_sleep()` that avoids busy waiting.

See the full assignment specification below.

---

## Environment Setup

You have **two options** for setting up your development environment. Pick whichever works best for you.

### Option A: Docker (Recommended)

This works on **macOS (Intel & Apple Silicon), Windows, and Linux** with no manual toolchain setup.

**Prerequisites:** Install [Docker Desktop](https://www.docker.com/get-started).

#### Build from Dockerfile

```bash
# Build the container (one-time)
docker build -t pintos .

# Run the container with your source mounted
docker run -it --rm --name pintos \
  --mount type=bind,source=$(pwd),target=/pintos \
  pintos bash
```

Inside the container:
```bash
cd /pintos/src/threads
make
cd build
pintos --qemu -- -q
```

You edit files on your host machine; changes are instantly visible inside the container.

#### Pre-built Images

If the Dockerfile build is slow, you can use a pre-built image instead:

**x86 / Intel Macs / Linux / WSL:**
```bash
docker run -it --rm --name pintos \
  --mount type=bind,source=$(pwd),target=/home/PKUOS/pintos \
  pkuflyingpig/pintos bash

# Inside container:
export PATH=/home/PKUOS/toolchain/x86_64/bin:$PATH
cd /home/PKUOS/pintos/src/threads
make
```

**Apple Silicon (ARM) Macs:**
```bash
docker run -it --rm --name pintos \
  --mount type=bind,source=$(pwd),target=/home/PKUOS/pintos \
  sevenchips/pintos-aarch64 bash

# Inside container:
export PATH=/home/PKUOS/toolchain/aarch64/bin:$PATH
cd /home/PKUOS/pintos/src/threads
make
```

### Option B: Native Setup

#### macOS

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install toolchain
brew install qemu i686-elf-binutils i686-elf-gcc

# Verify
command -v qemu-system-i386
command -v i686-elf-gcc
```

#### Windows (WSL 2)

```powershell
# In PowerShell as Administrator
wsl --install
```

Then inside the Ubuntu terminal:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential gcc gcc-multilib make perl qemu-system-x86
```

#### Linux (Ubuntu/Debian)

```bash
sudo apt install -y build-essential gcc gcc-multilib make perl qemu-system-x86
```

### Add Pintos Utils to PATH

Add to your shell config (`~/.zshrc`, `~/.bashrc`, etc.):
```bash
export PATH="$HOME/<path-to-repo>/src/utils:$PATH"
```

---

## Building and Running

```bash
# Build the threads kernel
cd src/threads
make

# Run Pintos (should boot and show the shell if no arguments given)
cd build
pintos --qemu --

# Run with a specific test
pintos --qemu -- -q run alarm-single
```

### Clean Rebuild

```bash
cd src/threads
make clean
make
```

---

## Assignment Details

### 1. Simple Shell

When PintOS boots with no command-line arguments (i.e., `pintos --`), instead of exiting, it should launch an interactive shell.

**Requirements:**
- Display the prompt `CSE134> ` and wait for user input.
- Echo each printable character as the user types.
- On newline, parse the input:
  - `whoami` -- print your CruzID.
  - `exit` -- quit the shell, allowing the kernel to exit.
  - Anything else -- print `Invalid command`.
- After handling a command (unless `exit`), display the prompt again.

### 2. Alarm Clock

Re-implement `timer_sleep()` in `src/devices/timer.c` to **avoid busy waiting**.

```c
void timer_sleep(int64_t ticks);
```

- Suspends the calling thread until at least `ticks` timer ticks have elapsed.
- The thread should be put to sleep (blocked), **not** spin in a loop calling `thread_yield()`.
- There are `TIMER_FREQ` (default 100) ticks per second. Do not change this value.
- You do not need to modify `timer_msleep()`, `timer_usleep()`, or `timer_nsleep()`.

**Important:** You will not receive any points if your code uses the provided busy-wait solution. You must remove busy waiting from the logic to receive credit.

### 3. Design Document

Create `docs/p01.md` with a section for each task (shell and alarm clock). Each section should cover:

1. **Data structures** -- any structs you created or extended (or N/A).
2. **Algorithms** -- how your implementation works.
3. **Synchronization** -- what primitives you used and why.
4. **Design justification** -- why you chose this approach.

Your document should have enough detail that a classmate could re-implement your design by following it.

---

## Running Tests

From `src/threads/build`:

```bash
# Run individual alarm tests
make tests/threads/alarm-single.result
make tests/threads/alarm-multiple.result
make tests/threads/alarm-simultaneous.result
make tests/threads/alarm-zero.result
make tests/threads/alarm-negative.result

# Run all tests at once
make check

# See grade summary
make grade
```

Each `.result` file should end with `pass`.

**Note:** If `pintos` is not found, prefix with the utils path:
```bash
PATH=../../utils:$PATH make tests/threads/alarm-single.result
```

---

## Rubric

| Category | Percentage |
|----------|------------|
| Testing  | 60%        |
| Design   | 40%        |

**Testing breakdown:**
- Simple Shell (manual tests): 30% of total (3 tests, equally weighted: `whoami`, invalid command, `exit`)
- Alarm Clock (automated tests): 30% of total

**Design breakdown:**
- Sufficient detail (30%)
- Accuracy (30%)
- Correctness (30%)
- Simplicity (10%)

---

## Hints

- Check out the [Pintos documentation Section 2.1.2](https://web.stanford.edu/class/cs140/projects/pintos/pintos_2.html) for an overview of the source directories.
- **Synchronization:** Avoid solving concurrency problems by disabling interrupts. Use semaphores, locks, and condition variables instead. The only case where disabling interrupts is appropriate is when coordinating data shared between a kernel thread and an interrupt handler (since interrupt handlers cannot sleep and therefore cannot acquire locks).
- **No busy waiting:** A tight loop calling `thread_yield()` is busy waiting. Your `timer_sleep()` must block the thread.

---

## Source Tree Overview

```
src/
├── threads/       # Thread management, scheduling (your main working area)
├── devices/       # Hardware drivers: timer, keyboard, disk, shutdown
├── lib/           # C standard library subset
├── tests/         # Test programs and grading scripts
├── userprog/      # User programs (not used in this project)
├── vm/            # Virtual memory (not used in this project)
├── filesys/       # File system (not used in this project)
└── utils/         # Utility scripts: pintos, pintos-gdb, backtrace
```

## Debugging with GDB

```bash
# Terminal 1: start Pintos with GDB server
cd src/threads/build
pintos --qemu --gdb -- -q run alarm-single

# Terminal 2: connect GDB
cd src/threads/build
pintos-gdb kernel.o
(gdb) debugpintos
(gdb) break timer_sleep
(gdb) continue
```
