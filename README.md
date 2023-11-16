# Bash Local Chat + System Monitoring Bot 

[[LEIAME em pt-BR]](https://github.com/liviaruegger/sh-local-chat/blob/main/LEIAME.txt)

This project was developed for the Programming Techniques I ([MAC0216](https://uspdigital.usp.br/jupiterweb/obterDisciplina?nomdis=&sgldis=mac0216)) course at IME-USP. It comprises a very simple client/server chat system that enables local communication among users logged into the same computer. A single Bash script implements both the chat system and monitoring functionalities, sending alerts via Telegram bot (basically, a ChatOps bot).


## How to run

Note that the system has been implemented in a single script; therefore, it is necessary to specify whether to execute it as a server or client through command-line arguments.

The chat server should be started before any clients. To execute the server, simply run it as follows:

```shell
$ ./ep2.sh servidor
```

As for the client(s), for each terminal where you want to use the chat system, run the script in client mode with the command:

```shell
$ ./ep2.sh cliente
```

The above instructions assume that the script already has execution permission and is located in the local directory.


## Commands

During execution, the chat system provides the following commands:

### Server

| Command | Description                                                            |
|---------|------------------------------------------------------------------------|
| `list`  | Lists the names of all logged-in users.                                |
| `time`  | Reports the time interval, in seconds, since the server was started.   |
| `reset` | Removes all users created in the current instance of server execution. |
| `quit`  | Terminates the server.                                                 |

### Client

| Command                         | Description                                                                        |
|---------------------------------|------------------------------------------------------------------------------------|
| `create <username> <password>`  | Creates a new user with the name `<username>` and password `<password>`.           |
| `passwd <username> <old> <new>` | Modifies the password of the user `<username>` from `<old>` to `<new>`.            |
| `login <username> <password>`   | Logs in with the user `<username>` and password `<password>`.                      |
| `logout`                        | Logs out of the system without ending the client execution.                        |
| `list`                          | Lists the names of all logged-in users.                                            |
| `msg <username> <message>`      | Writes the message `<message>` on the screen of the user `<username>`.             |
| `quit`                          | Ends the client execution. If the user has not logged out, logs out before ending. |


## Dependencies

- Bash: GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)
- OS: x86_64 GNU/Linux