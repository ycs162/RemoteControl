# RemoteControl
This script is created to allow local machine to access remote server(SSH in this script), then perform nmap, masscan, and whois scan from the remote server.
The scanned results will be copy back to local machine, and remove from the remote server.
The assumption for this script is that both local machine and remote server does not have the tools/updates installed for all tasks.
Prior to the scanning, necssary tools installation for all tasks will run on both local machine and remote server.
