# PintOS Kernel Extension

A set of extensions to **PintOS**, a teaching operating system used in UC Santa Cruz's Computer Systems course, focused on low-level thread scheduling, synchronization, and kernel-level shell functionality.

## What's Implemented

**Blocking timer (`timer_sleep`)**
Re-implemented `timer_sleep()` so that sleeping threads block instead of busy-waiting. The original implementation spun in a loop checking the clock on every tick, wasting CPU cycles that could go to other threads. The new implementation puts a thread to sleep and uses semaphores combined with interrupt-safe synchronization to wake it at the correct tick, without ever polling.

**Interactive kernel shell**
Built a shell that runs directly inside the kernel, handling input parsing, command dispatch, and the prompt/read/execute loop at the OS level — below the point where a typical userspace shell like `bash` would normally operate.

**Thread scheduling and synchronization**
Worked directly with PintOS's low-level thread scheduler and its synchronization primitives — semaphores, locks, and condition variables — along with hardware timer interrupts, to coordinate thread wake-ups correctly and safely.

## Why It Matters

Busy-waiting is a correct but wasteful way to implement sleep/wake behavior: it burns CPU time a scheduler could give to other runnable threads. Fixing `timer_sleep()` to block instead required careful use of interrupt-safe synchronization, since timer interrupts can fire during the exact window where a thread is being put to sleep — getting this wrong causes missed wakeups or race conditions that only show up intermittently under load.

## Environment

Developed and cross-compiled in a reproducible **Docker** environment targeting **x86**, with **QEMU** used for emulation — since PintOS runs on simulated hardware rather than the host machine directly.

## Course Context

Originally built as coursework for UC Santa Cruz's Computer Systems course (CSE 130/134). Shared here as a portfolio reference for the synchronization and kernel-level work involved, not as a submission template.

## Tech

`C` · `pthreads`-equivalent kernel synchronization primitives · `Docker` · `QEMU` · `x86`
