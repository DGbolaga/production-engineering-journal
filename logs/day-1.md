# What I did
- Read Chapter 1 of "How Linux Works" by Brian Ward.


# What confused me
- Interchanging of terminologies. Threads vs Process vs User Space.


# What resolved it 
- Just understanding that threads are the path of execution (flow from the beginning of a task to the end of it), while Processes are the environment that a thread needs to complete itself (task). 
- A User space just refers to the memory region space that the user programs/process has access to. (programs and process are used very interchangeably) Unlike the User space, the Kernel space has unrestricted access to memory region in it's Kernel mode.


# Tomorrow
1. I'll start my CPU Monitor project.
2. Continue reading How Linux Works.


# Notes:
I'm just starting the book "How Linux works by Brian Ward".
It's about 467 pages.

Let's see how far I can get today. But why am I reading this book in the first place. Well, a friend recommended the book. More so, I use linux as my main system and I want to understand and squeeze as much efficiency from my system as I can get.

**Chapter 1 - The big picture.**
Linux is all about abstraction for the user. At least in the case this chapter presents it to be. The chapter describes the high level of components that makes up the linux system.

1.1 Levels & Layers of Abstraction in a Linux System
In Linux, the 3 main levels.
1. The **Hardware** : which seats at the base. It contains memory, cpu, disks and network interfaces.
2. The **Kernel**: which is above the base, and is the core of the OS. it's more like the software (which stays in the memory) that tells the CPU where to look for it's next task. The Kernel acts as a mediator between the hardware and any program, while also managing the main memory. In simple terms, the kernel understands what the  need of the hardware is (at anytime), manages it and communicates with other programs that might be running.
3. **Processes**: They are referred to as the programs that the kernel manages. This is the upper layer also known as the user space.

![[Screenshot from 2026-06-08 19-23-31.png]]

So what's the difference between the Kernel and the User process?
The answer, very succinctly said is that the kernel runs in **Kernel Mode** (unrestricted access to the processor and main memory) but the user process runs in **user mode** 

In this note, there's a lot of attention to naming details. The kernel space is the area in the memory that the kernel has access to. The User space is restricted and has limited memory access space.

As I read this book, I'm getting the feeling of security being an instinctive obligation in everything the book speaks about.

The author says something about linux thread being able to run kernel threads, which look more like processes but have access to kernel space (examples include kthreadd and kblockd).
- First what does this statement even mean?
- For context a thread is a single, independent path of execution of a task within a program (A Process)
... I'll come back to this thought later.

1.2 Hardware: Understanding the Main Memory.
Straight away the author gives a clear statement regarding the great significance of the main memory among all the hardware. Interesting.
**The main memory is the most important hardware.**

The main memory is literally just a big area containing bunch of 0's and 1's.

